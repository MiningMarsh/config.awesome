-- #############
-- # Libraries #
-- #############

local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
awful.autofocus = require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
local widget    = require("widget")
local lain      = require("lain")
local config    = require("config")

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
        naughty.notify({preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = err})

        -- We just finished handling the error.
        in_error = false
    end)
end

-- #########
-- # Theme #
-- #########

-- Load our theme file.
beautiful.init(".config/awesome/theme.lua")

-- #############
-- # Variables #
-- #############

-- Auto populate some things if we need to.
if not config.desktops or not config.desktops.number then
    if not config.desktops then
        config.desktops = {}
    end
    config.desktops.number = #(config.keys.desktops)
end

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

-- The table of tags.
local tags = awful.tag(config.keys.desktops,
                       s,
                       config.layouts[1]
             )

function tags:byidx(idx)
    local tagid = awful.tag.getidx()
    local tags = screens[mouse.screen].tags
    local tagsize = #tags


    if tagid == 1 then
        tagid = tagsize
    else
        tagid = tagid - 1
    end

    local tag = tags[tagid]
    for _, client in pairs(tag:clients()) do
        client:kill()
    end
end



-- Give each screen a tag table.
for s = 1, screen.count() do
    screens[s] = {}
    -- Generate the screen's tag table
    screens[s].tags = tags

end

-- ########
-- # Menu #
-- ########

-- Global menu object.
local menu = {}
-- Holds the submenus.
menu.sub = {}

-- This is awesomes sub-menu.
menu.sub.awesome = {{"manual",      cmd.terminal:spawn("man awesome")  },
                    {"edit config", cmd.terminal:edit(awesome.conffile)},
                    {"restart",     awesome.restart                    },
                    {"quit",        awesome.quit                       }}

-- This is the main menu.
menu.main = awful.menu({items = {{"awesome",       menu.sub.awesome, beautiful.awesome_icon},
                                 {"open terminal", cmd.terminal:new()                      }}})

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
                instance = awful.menu.clients({theme = {width = 250}})
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
    --
    panels[s].taskbar = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, panels.taskbar.buttons)

    -- Create the wibox
    panels[s].panel = awful.wibox({position = "top",height = 16, screen = s})

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(panels[s].prompt)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()

    right_layout:add(widget.spacer(5))
    right_layout:add(widget.alsa(16, 8))

    right_layout:add(widget.spacer(5))
    right_layout:add(widget.cpu(20, 8))

    right_layout:add(widget.spacer(5))
    right_layout:add(widget.mem(20, 8))

    right_layout:add(widget.spacer(5))
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

-- Global key bindings.
keys.global = awful.util.table.join(

    -- Volume Up = Volume up.
    awful.key({}, "XF86AudioRaiseVolume",
        function()
            awful.util.spawn("amixer set Master 5%+")
            widget.alsa:update()
        end
    ),

    -- Volume Down = Volume down.
    awful.key({}, "XF86AudioLowerVolume",
        function()
            awful.util.spawn("amixer set Master 5%-")
            widget.alsa:update()
        end
    ),

    -- Play = Toggle music.
    awful.key({}, "XF86AudioPlay",
        function()
            awful.util.spawn("mpc toggle")
            widget.alsa:update()
        end
    ),

    -- Stop = Stop music.
    awful.key({}, "XF86AudioStop",
        function()
            awful.util.spawn("mpc stop")
            widget.alsa:update()
        end
    ),

    -- Next = Next song.
    awful.key({}, "XF86AudioNext",
        function()
            awful.util.spawn("mpc next")
            widget.alsa:update()
        end
    ),

    -- Previous = Previous song.
    awful.key({}, "XF86AudioPrev",
        function()
            awful.util.spawn("mpc prev")
            widget.alsa:update()
        end
    ),

    -- Volume Mute = Volume mute/unmute.
    awful.key({}, "XF86AudioMute",
        function()
            widget.alsa:update()
            awful.util.spawn("amixer sset Master toggle")
        end
    ),

    -- Birghtness Down = Decrease brightness.
    awful.key({}, "XF86MonBrightnessDown",
        function()
            awful.util.spawn("xbacklight -dec 10")
        end
    ),

    -- Birghtness Up = Increase brightness.
    awful.key({}, "XF86MonBrightnessUp",
        function()
            awful.util.spawn("xbacklight -inc 10")
        end
    ),

    -- Close left.
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.left,
        function()
            local old = client.focus
            if old then
                awful.client.focus.bydirection("left")
                if client.focus and client.focus ~= old then
                    client.focus:kill()
                    client.focus = old
                end
            end
        end
    ),

    -- Close right
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.right,
        function()
            local old = client.focus
            if old then
                awful.client.focus.bydirection("right")
                if client.focus and client.focus ~= old then
                    client.focus:kill()
                    client.focus = old
                end
            end
        end
    ),

    -- Close up
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.up,
        function()
            local old = client.focus
            if old then
                awful.client.focus.bydirection("up")
                if client.focus and client.focus ~= old then
                    client.focus:kill()
                    client.focus = old
                end
            end
        end
    ),

    -- Close down
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.down,
        function()
            local old = client.focus
            if old then
                awful.client.focus.bydirection("down")
                if client.focus and client.focus ~= old then
                    client.focus:kill()
                    client.focus = old
                end
            end
        end
    ),

    -- Focus left.
    awful.key({config.keys.master}, config.keys.windows.left,
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end
    ),

    -- Focus down.
    awful.key({config.keys.master}, config.keys.windows.down,
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end
    ),

    -- Focus up.
    awful.key({config.keys.master}, config.keys.windows.up,
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end
    ),

    -- Focus right.
    awful.key({config.keys.master}, config.keys.windows.right,
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end
    ),

    -- Shift left.
    awful.key({config.keys.master, config.keys.move}, config.keys.windows.left,
        function()
            awful.client.swap.bydirection("left")
        end
    ),

    -- Shift down.
    awful.key({config.keys.master, config.keys.move}, config.keys.windows.down,
        function()
            awful.client.swap.bydirection("down")
        end
    ),

    -- Shift up.
    awful.key({config.keys.master, config.keys.move}, config.keys.windows.up,
        function()
            awful.client.swap.bydirection("up")
        end
    ),

    -- Shift right.
    awful.key({config.keys.master, config.keys.move}, config.keys.windows.right,
        function()
            awful.client.swap.bydirection("right")
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

    -- Focus on next window.
    awful.key({config.keys.master}, config.keys.windows.next,
        function()
            awful.client.focus.byidx(1)
        end
    ),

    -- Focus on previous window.
    awful.key({config.keys.master}, config.keys.windows.previous,
        function()
            awful.client.focus.byidx(-1)
        end
    ),

    -- Close next window.
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.next,
        function()
            local old = client.focus
            if old then
                awful.client.focus.byidx(1)
                if client.focus and client.focus ~= old then
                    client.focus:kill()
                end
                client.focus = old
            end
        end
    ),


    -- Close previous window.
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.previous,
        function()
            local old = client.focus
            if old then
                awful.client.focus.byidx(-1)
                if client.focus and client.focus ~= old then
                    client.focus:kill()
                end
                client.focus = old
            end
        end
    ),

    -- Shift this window with the next window.
    awful.key({config.keys.master, config.keys.move}, config.keys.windows.next,
        function()
            awful.client.swap.byidx(1)
        end
    ),

    -- Shift this window with the previous window.
    awful.key({config.keys.master, config.keys.move}, config.keys.windows.previous,
        function()
            awful.client.swap.byidx(-1)
        end
    ),

    -- View previous tag.
    awful.key({config.keys.master}, config.keys.desktops.previous,
        function()
            awful.tag.viewprev()
        end
    ),

    -- View next tag.
    awful.key({config.keys.master}, config.keys.desktops.next,
        function()
            awful.tag.viewnext()
        end
    ),

    -- Close windows on next tag.
    awful.key({config.keys.master, config.keys.close}, config.keys.desktops.next,
        function()
            local tagid = awful.tag.getidx()
            local tags = screens[mouse.screen].tags
            local tagsize = #tags

            if tagid == tagsize then
                tagid = 1
            else
                tagid = tagid + 1
            end

            local tag = tags[tagid]
            for _, client in pairs(tag:clients()) do
                client:kill()
            end
        end
    ),

    -- Close windows on previous tag.
    awful.key({config.keys.master, config.keys.close}, config.keys.desktops.previous,
        function()
            local tagid = awful.tag.getidx()
            local tags = screens[mouse.screen].tags
            local tagsize = #tags

            if tagid == 1 then
                tagid = tagsize
            else
                tagid = tagid - 1
            end

            local tag = tags[tagid]
            for _, client in pairs(tag:clients()) do
                client:kill()
            end
        end
    ),

    -- Close windows on current tag.
    awful.key({config.keys.master, config.keys.close}, config.keys.desktops.current,
        function()
            local tagid = awful.tag.getidx()
            local tags = screens[mouse.screen].tags
            local tag = tags[tagid]
            for _, client in pairs(tag:clients()) do
                client:kill()
            end
        end
    ),

    -- Move window to previous tag.
    awful.key({config.keys.master, config.keys.move}, config.keys.desktops.previous,
        function()
            local tagid = awful.tag.getidx()
            local tags = screens[mouse.screen].tags
            local tagsize = #tags

            if tagid == 1 then
                tagid = tagsize
            else
                tagid = tagid - 1
            end

            awful.client.movetotag(tags[tagid])
            awful.tag.viewprev()
        end
    ),

    -- Move window to next tag.
    awful.key({config.keys.master, config.keys.move}, config.keys.desktops.next,
        function()
            local tagid = awful.tag.getidx()
            local tags = screens[mouse.screen].tags
            local tagsize = #tags

            if tagid == tagsize then
                tagid = 1
            else
                tagid = tagid + 1
            end

            awful.client.movetotag(tags[tagid])
            awful.tag.viewnext()
        end
    ),

    -- Mod + . = Increment master window factor.
    awful.key({config.keys.master}, ".",
        function()
            awful.tag.incmwfact(0.05)
        end
    ),

    -- Mod + , = Decrement master window factor.
    awful.key({config.keys.master}, ",",
        function()
            awful.tag.incmwfact(-0.05)
        end
    ),

    -- Mod + . = Increment window factor.
    awful.key({config.keys.master, config.keys.move}, ".",
        function()
            awful.client.incwfact(0.05)
        end
    ),

    -- Mod + , = Decrement window factor.
    awful.key({config.keys.master, config.keys.move}, ",",
        function()
            awful.client.incwfact(-0.05)
        end
    ),

    -- Mod + ; = Decrement the number of master config.windows.
    awful.key({config.keys.master}, ";",
        function()
            awful.tag.incnmaster(-1)
        end
    ),

    -- Mod + Shift + ' = Increment the number of master config.windows.
    awful.key({config.keys.master}, "'",
        function()
            awful.tag.incnmaster(1)
        end
    ),

    -- Mod + Shift + ; = Decrement the number of columns.
    awful.key({config.keys.master, config.keys.move}, ";",
        function()
            awful.tag.incncol(-1)
        end
    ),

    -- Mod + Shift + ' = Increment the number of columns.
    awful.key({config.keys.master, config.keys.move}, "'",
        function()
            awful.tag.incncol(1)
        end
    ),

    -- Mod + Space = Switch to next layout.
    awful.key({config.keys.master}, "space",
        function()
            awful.layout.inc(config.layouts, 1)
        end
    ),

    -- Mod + Shift + Space = Switch to previous layout.
    awful.key({config.keys.master, config.keys.move}, "space",
        function()
            awful.layout.inc(config.layouts, -1)
        end
    ),

    -- Mod + Ctrl + N = Un-minimize.
    awful.key({config.keys.master, config.keys.close}, "n", awful.client.restore),

    -- Mod + c = Command prompt.
    awful.key({config.keys.master}, "c",
        function()
            panels[mouse.screen].prompt:run()
        end
    ),

    -- Mod + X = Run prompt for lua code.
    awful.key({config.keys.master, config.keys.move}, "x",
        function()
            awful.prompt.run({prompt = "Run Lua code: "},
            panels[mouse.screen].prompt.widget,
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
        end
    ),

    -- Mod + Shift + C = Launch application from menubar.
    awful.key({config.keys.master, config.keys.move}, "c",
        function()
            menubar.show()
        end
    )
)

-- Bind program shortcuts.
for key, program in pairs(config.keys.programs) do
    -- Mod + Alt + <key> = Launch <program>.
    keys.global = awful.util.table.join(
        keys.global,
        awful.key({config.keys.master, config.keys.launch}, key,
            function()
                awful.util.spawn(program)
            end
        )
    )
end

-- Keys to control clients.
keys.client = awful.util.table.join(

    -- Mod + F = Toggle fullscreen.
    awful.key({config.keys.master}, "f",
        function(c)
            c.fullscreen = not c.fullscreen
        end
    ),

    -- Mod + Shift + C = Kill the client.
    awful.key({config.keys.master}, "x",
        function(c)
            c:kill()
        end
    ),

    -- Close current window.
    awful.key({config.keys.master, config.keys.close}, config.keys.windows.current,
        function(c)
            c:kill()
        end
    ),

    -- Mod + Ctrl + Space = Toggle Floating.
    awful.key({config.keys.master, config.keys.close}, "space", awful.client.floating.toggle),

    -- Mod + Ctrl + Enter = Swap client with the master window.
    awful.key({config.keys.master, config.keys.close}, "Return",
        function(c)
            c:swap(awful.client.getmaster())
        end
    ),


    -- Mod + N = Minimize the current client.
    awful.key({config.keys.master}, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end
    ),

    -- Mod + M = Toggle maximize.
    awful.key({config.keys.master}, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end
    )
)

-- Bind desktop keys.
for i, key in ipairs(config.keys.desktops)  do
    -- The keycode for the specified number key.

    -- Bind some keys.
    keys.global = awful.util.table.join(keys.global,

        -- Mod + # = View tag.
        awful.key({config.keys.master}, key,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewonly(tag)
                end
            end
        ),

        -- Mod + Shift + # = Move client to tag.
        awful.key({config.keys.master, config.keys.move}, key,
            function()
                if client.focus then
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if tag then
                        awful.client.movetotag(tag)
                        awful.tag.viewonly(tag)
                    end
                end
            end
        ),

        -- Mod + Control + # = Kill all clients on tag.
        awful.key({config.keys.master, config.keys.close}, key,
            function()
                local tag
                if not client.focus then
                    tag = awful.tag.gettags(mouse.screen)[i]
                else
                    tag = awful.tag.gettags(client.focus.screen)[i]
                end
                for _, client in pairs(tag:clients()) do
                    client:kill()
                end
            end
        )

    )
end

-- Bind window keys.
for i, key in ipairs(config.keys.windows) do
    -- The keycode for the specified number key.
    --
    -- Bind some keys.
    keys.global = awful.util.table.join(keys.global,

        -- Mod + # = View client.
        awful.key({config.keys.master}, key,
            function()
                -- Store the focused client.
                local focus = client.focus

                -- Get the master client.
                local master = awful.client.getmaster()

                -- Find out the position of the master relative to the focused
                -- client.
                local focusnum = 0
                while focus ~= awful.client.next(focusnum, master) do
                    focusnum = focusnum + 1
                end

                local target = i - focusnum - 1

                -- Get number of clients.
                local numclients = 1
                while master ~= awful.client.next(numclients, master) do
                    numclients = numclients + 1
                end

                -- Change focus if we can.
                if target + focusnum < numclients then
                    awful.client.focus.byidx(target)
                end
            end
        ),

        -- Mod + Shift + # = Swap client.
        awful.key({config.keys.master, config.keys.move}, key,
            function(c)
                -- Store the focused client.
                local focus = client.focus

                -- Get the master client.
                local master = awful.client.getmaster()

                local target = i - 1

                -- Get number of clients.
                local numclients = 1
                while master ~= awful.client.next(numclients, master) do
                    numclients = numclients + 1
                end

                -- Swap if we can
                if target < numclients then
                    -- Grab the client,
                    local toswap = awful.client.next(target, master)

                    toswap:swap(focus)
                end
            end
        ),

        -- Mod + Control + # = Kill client.
        awful.key({config.keys.master, config.keys.close}, key,
            function(c)
                -- Get the master client.
                local master = awful.client.getmaster()

                local target = i - 1

                -- Get number of clients.
                local numclients = 1
                while master ~= awful.client.next(numclients, master) do
                    numclients = numclients + 1
                end

                -- Swap if we can
                if target < numclients then
                    -- Grab the client,
                    local toswap = awful.client.next(target, master)

                    if toswap then
                        toswap:kill()
                    end
                end
            end
        )
    )
end

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
            client.focus = c;
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
                                    buttons = buttons.client,
                                    size_hints_honor = false}},
                    {rule = {class = "Plugin-container"},
                     properties = {floating = true}},
                    {rule = {class = "URxvt"},
                     properties = {size_hints_honor = true}},
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

    -- Connect a signal to a client that gets executed on mouseover.
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            -- Focus the client.
            client.focus = c
        end
    end)

    if not startup then
        -- Set the config.windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

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
    end)

-- Signal to be thrown when a client is unfocused.
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end)

-- ####################
-- # Startup commands #
-- ####################

for _, v in pairs(config.startup) do
    awful.util.spawn_with_shell(v .. " &")
end

