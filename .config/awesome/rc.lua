-- #############
-- # Libraries #
-- #############

local awful           = require("awful")
      awful.autofocus = require("awful.autofocus")
      awful.rules     = require("awful.rules")
local beautiful       = require("beautiful")
local config          = require("config")
local gears           = require("gears")
local lain            = require("lain")
local menubar         = require("menubar")
local naughty         = require("naughty")
local viml            = require("viml")
local wibox           = require("wibox")
local widget          = require("widget")
local actions         = require("actions")

-- ##################
-- # Error Handling #
-- ##################

do
    -- Marker letting recursions know that we are handling errors, to
    -- prevent endless loops.
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        -- Mark that we are handling an error.
        in_error = true

        -- Display a notification to the user letting him know that
        -- there was an error.
        naughty.notify{
            preset = naughty.config.presets.critical,
            text   = err,
            title  = "Oops, an error happened!",
        }

        file = io.open("/home/miningmarsh/.awesome-debug", "a+")
        file:write(err .. "\n")
        file:close()

        -- We just finished handling the error.
        in_error = false
    end)
end

-- #########
-- # Theme #
-- #########

-- Load our theme file.
beautiful.init("~/.config/awesome/theme.lua")

-- #############
-- # Variables #
-- #############

-- Add other things that we need.
local cmd = {}

cmd.terminal = {}
function cmd.terminal:new()
    return config.terminal
end

function cmd.terminal:spawn(cmd)
    if cmd then
        return self:new() .. " -e " .. cmd
    else
        return self:new()
    end
end

function cmd.terminal:edit(file)
    return self:spawn(config.editor .. file)
end

local layouts = config.layouts

-- #############
-- # Wallpaper #
-- #############

-- If we loaded a wallpaper in our theme ...
if beautiful.wallpaper then
    -- ... then, for every screen detected ...
    for s = 1, screen.count() do
        -- ... assign our wallpaper to that screen.
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- ###########
-- # Screens #
-- ###########

-- The table of screen.
local screens = {}

-- Give each screen a tag table.
for s = 1, screen.count() do
    screens[s] = {}
    -- Generate the screen's tag table
    screens[s].tags = awful.tag(
        {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
        s,
        layouts[1]
    )

end

-- ########
-- # Menu #
-- ########

-- Global menu object.
local menu = {}
-- Holds the submenus.
menu.sub = {}

-- This is awesomes sub-menu.
menu.sub.awesome = {
    {
        "manual",
        cmd.terminal:spawn("man awesome")
    },
    {
        "edit config",
        cmd.terminal:edit(awesome.conffile)
    },
    {
        "restart",
        awesome.restart
    },
    {
        "quit",
        awesome.quit
    }
}

-- This is the main menu.
menu.main = awful.menu{
    items = {
        {
            "awesome",
            menu.sub.awesome,
            beautiful.awesome_icon
        },
        {
            "open terminal",
            cmd.terminal:new()
        }
    }
}

-- Set the terminal for applications that require it
menubar.utils.terminal = cmd.terminal:new()

-- #########
-- # Panel #
-- #########

-- Holds a seperate panel for each screen.
local panels = {}
panels.tags = {}
panels.taskbar = {}

-- All taskbars share the same buttons.
panels.taskbar.buttons = awful.util.table.join(
    awful.button({}, 1,
        function(c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() then
                    awful.tag.viewonly(c:tags()[1])
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end
    ),
    awful.button({}, 3,
        function()
            if instance then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients{
                    theme = {
                        width = 250
                    }
                }
            end
        end
    ),
    awful.button({}, 4,
        function()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end
    ),
    awful.button({}, 5,
        function()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end
    )
)

for s = 1, screen.count() do
    -- Allocate the panel for the screen.
    panels[s] = {}

    -- Create a promptbox.
    panels[s].prompt = awful.widget.prompt()
    -- Create a tasklist widget
    panels[s].taskbar = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, panels.taskbar.buttons)

    -- Create the wibox
    panels[s].panel = awful.wibox({position = "top",height = 16, screen = s})

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(panels[s].prompt)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()

    -- Add every widget from the configuration to the layout.
    for _, wid in pairs(config.widgets) do
        right_layout:add(wid)
    end
    right_layout:add(widget.spacer(4))

    -- Only place a system tray on the first desktop
    if s == 1 then
        right_layout:add(wibox.widget.systray())
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(panels[s].taskbar)
    layout:set_right(right_layout)

    panels[s].panel:set_widget(layout)
end

-- #########
-- # Mouse #
-- #########
--
root.buttons(
    awful.util.table.join(
        awful.button({}, 3, function()
                                menu.main:toggle()
                            end
        )
    )
)

-- ###############
-- # Keybindings #
-- ###############

-- Holds key bindings.
local keys = {}
keys.global = {}

-- Bind program shortcuts.
for key, program in pairs(config.keys.programs) do
    -- Mod + Alt + <key> = Launch <program>.
    keys.global = awful.util.table.join(
        keys.global,
        awful.key({config.keys.master, config.keys.launch}, key,
            function()
                naughty.notify({preset = naughty.config.presets.low,
                                title = "Launching Program",
                                text = program.name})
                awful.util.spawn(program.command)
            end
        )
    )
end

keys.global = awful.util.table.join(
    keys.global,
    viml:keys{
        commands   = config.keys.commands,
        current    = config.keys.current,
        master     = config.keys.master,
        movements  = config.keys.movements,
        operations = config.keys.operations,
    }
)

-- Global key bindings.
keys.global = awful.util.table.join(
    keys.global,

    -- Toggle Touchpad = toggle touchpad.
    awful.key({}, "XF86TouchpadToggle",
        function()
            local file
            file = io.popen("toggle-touchpad")
            local percent = file:read("*l")
            file:close()
            naughty.notify({preset = naughty.config.presets.low,
                            title = "Touchpad",
                            text = percent})
        end
    ),

    -- Sleep = suspend.
    --[[awful.key({}, "XF86Sleep",
        function()
            awful.util.spawn_with_shell("sudo suspension")
        end
    ),]]--

    awful.key({}, "Scroll_Lock",
        function()
            actions.screensaver:lock()
        end
    ),

    -- Toggle Eco Mode = Toggle wireless.
    awful.key({}, "plusminus",
        function()
            local file
            file = io.popen("sudo /usr/local/sbin/toggle-wireless")
            local status = file:read("*l")
            file:close()
            naughty.notify({preset = naughty.config.presets.low,
                            title = "Wireless",
                            text = status})
        end
    ),

    -- Display = Toggle display mode.
    awful.key({}, "XF86Display",
        function()
            awful.util.spawn("set-display")
        end
    ),

    -- Volume Up = Volume up.
    awful.key({}, "XF86AudioRaiseVolume",
        function()
           actions.volume:increase(0.05)
           widget.alsa:update()
        end
    ),

    -- Volume Down = Volume down.
    awful.key({}, "XF86AudioLowerVolume",
        function()
           actions.volume:decrease(0.05)
           widget.alsa:update()
        end
    ),

    -- Pause = Toggle music.
    awful.key({}, "Pause",
        function()
            awful.util.spawn("mpc toggle")
        end
    ),

    -- Break = Stop music.
    awful.key({}, "Break",
        function()
            awful.util.spawn("mpc stop")
        end
    ),

    -- Play = Toggle music.
    awful.key({}, "XF86AudioPlay",
        function()
            awful.util.spawn("mpc toggle")
        end
    ),

    -- Print = Take screenshot.
    awful.key({}, "Print",
        function()
            local datecmd = io.popen("date")
            local date = datecmd:read("*l")
            datecmd:close()
            awful.util.spawn_with_shell("scrot ~/Pictures/Screenshots/'" .. date .. "'.png")
            naughty.notify({preset = naughty.config.presets.low,
                            title = "Screenshot: " .. date,
                            text = percent})
        end
    ),

    -- Stop = Stop music.
    awful.key({}, "XF86AudioStop",
        function()
            awful.util.spawn("mpc stop")
        end
    ),

    -- Next = Next song.
    awful.key({}, "XF86AudioNext",
        function()
            awful.util.spawn("mpc next")
        end
    ),

    -- Previous = Previous song.
    awful.key({}, "XF86AudioPrev",
        function()
            awful.util.spawn("mpc prev")
        end
    ),

    -- Volume Mute = Volume mute/unmute.
    awful.key({}, "XF86AudioMute",
        function()
            actions.volume:toggle()
            widget.alsa:update()
        end
    ),

    -- Birghtness Down = Decrease brightness.
    awful.key({}, "XF86MonBrightnessDown",
        function()
            actions.brightness:decrease(0.1)
        end
    ),

    -- Birghtness Up = Increase brightness.
    awful.key({}, "XF86MonBrightnessUp",
        function()
            actions.brightness:increase(0.1)
        end
    ),

    -- Mod + Enter = Spawn terminal.
    awful.key({config.keys.master}, "Return",
        function()
            awful.util.spawn(cmd.terminal:new())
        end
    ),

    -- Mod + Ctrl + R = Restart awesome.
    awful.key({config.keys.master, config.keys.move}, "z", awesome.restart),

    -- Mod + Shift + Q = Quit awesome.
    awful.key({config.keys.master}, "z", awesome.quit),

    -- Mod + Launch + J = Increment window factor.
    awful.key({config.keys.master, config.keys.launch}, "j",
        function()
            awful.client.incwfact(0.05)
        end
    ),

    -- Mod + End = Eject devices.
    awful.key({config.keys.master}, "End",
        function()
            awful.util.spawn("devmon -c")
        end
    ),

    -- Mod + Home = Turn off screen.
    awful.key({config.keys.master}, "Home",
        function()
            awful.util.spawn("xset dpms force off")
        end
    ),

    -- Mod + Launch + K = Decrement window factor.
    awful.key({config.keys.master, config.keys.launch}, "k",
        function()
            awful.client.incwfact(-0.05)
        end
    ),

    -- Mod + Launch + L = Increment master window factor.
    awful.key({config.keys.master, config.keys.launch}, "l",
        function()
            awful.tag.incmwfact(0.05)
        end
    ),

    -- Mod + Launch + H = Decrement master window factor.
    awful.key({config.keys.master, config.keys.launch}, "h",
        function()
            awful.tag.incmwfact(-0.05)
        end
    ),

    -- Mod + Launch + Shift + K = Decrement the number of master windows.
    awful.key({config.keys.master, config.keys.launch, "Shift"}, "k",
        function()
            awful.tag.incnmaster(-1)
        end
    ),

    -- Mod + Launch + Shift + J = Increment the number of master windows.
    awful.key({config.keys.master, config.keys.launch, "Shift"}, "j",
        function()
            awful.tag.incnmaster(1)
        end
    ),

    -- Mod + Alt + Shift + H = Decrement the number of columns.
    awful.key({config.keys.master, config.keys.launch, "Shift"}, "h",
        function()
            awful.tag.incncol(-1)
        end
    ),

    -- Mod + Launch + Shift + L = Increment the number of columns.
    awful.key({config.keys.master, config.keys.launch, "Shift"},"l",
        function()
            awful.tag.incncol(1)
        end
    ),

    -- Mod + Space = Switch to next layout.
    awful.key({config.keys.master}, "space",
        function()
            awful.layout.inc(layouts, 1)
        end
    ),

    -- Mod + Shift + Space = Switch to previous layout.
    awful.key({config.keys.master, config.keys.launch}, "space",
        function()
            awful.layout.inc(layouts, -1)
        end
    ),

    -- Mod + c = Command prompt.
    awful.key({config.keys.master}, "c",
        function()
            panels[mouse.screen.index].prompt:run()
        end
    ),

    -- Mod + X = Run prompt for lua code.
    awful.key({config.keys.master, config.keys.move}, "x",
        function()
	   awful.prompt.run(
	      {prompt = "Run Lua code: "},
	      panels[mouse.screen.index].prompt.widget,
	      awful.util.eval, nil,
	      awful.util.getdir("cache") .. "/history_eval"
	   )
        end
    )
)

-- Set keys
root.keys(keys.global)

-- ##################
-- # Buttonbindings #
-- ##################

local buttons = {}

buttons.client = awful.util.table.join(
    -- Mouse 1 = Focus a client.
    awful.button({}, 1,
        function (c)
            client.focus = c
            c:raise()
        end
    ),

    -- Mod + Mouse 1 = Move a client.
    awful.button({config.keys.master}, 1,
        awful.mouse.client.move
    ),


    -- Mod + Mouse 3 = Resize a client.
    awful.button({config.keys.master}, 3,
        awful.mouse.client.resize
    )
)

-- #########
-- # Rules #
-- #########

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {-- All clients will match this rule.
                     {rule = {},
                      properties = {border_width = beautiful.border_width,
                                    border_color = beautiful.border_normal,
                                    focus = awful.client.focus.filter,
                                    raise = true,
                                    keys = keys.client,
                                    maximized_vertical = false,
                                    maximized_horizontal = false,
                                    buttons = buttons.client,
                                    size_hints_honor = false}},
                    {rule = {class = "Plugin-container"},
                     properties = {floating = true}},
                    {rule = {class = "URxvt"},
                     properties = {size_hints_honor = true}},
                    {rule = {class = "Conky"},
                     properties = {border_width = 0,
                                   sticky=true}},
                    {rule = {class = "Plasma"},
                     properties = {floating = true},
                     --[[callback = function(c)
                                    c:geometry({width = 600, height = 500})
                                end--]]},
                    {rule = {class = "pinentry"},
                     properties = {floating = true}}}
                     -- Set Firefox to always map on tags number 2 of screen 1.
                     -- { rule = { class = "Firefox" },
                     --   properties = { tag = tags[1][2] } }
-- ###########
-- # Signals #
-- ###########

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)

    -- Make all floating windows ontop windows.
    if c.floating then
        c.ontop = true
    end

    -- Connect a signal to a client that gets executed on mouseover.
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            -- Focus the client.
            client.focus = c
            c:raise()
        end
    end)

    if not startup then
        -- Set the config.windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put config.windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

end)

-- Signal to be thrown when a client is focused.
client.connect_signal("focus",
    function(c)
        c.border_color = beautiful.border_focus
    end
)

-- Signal to be thrown when a client is unfocused.
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)
