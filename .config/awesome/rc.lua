-- #############
-- # Libraries #
-- #############

local awful           = require('awful')
      awful.autofocus = require('awful.autofocus')
      awful.rules     = require('awful.rules')
local actions         = require('actions')
local beautiful       = require('beautiful')
local config          = require('config')
local gears           = require('gears')
local lain            = require('lain')
local menubar         = require('menubar')
local naughty         = require('naughty')
local struct          = require('struct')
local viml            = require('viml')
local wibox           = require('wibox')
local widget          = require('widget')

-- ##################
-- # Error Handling #
-- ##################
--
-- Note that we do this before anything else so that errors that occur later in
-- the config file end up being handled by this error handling.

do
   -- Marker letting recursions know that we are handling errors, to
   -- prevent endless loops.
   local in_error = false

   -- Install a custom debug handler to let us know when things have exploded.
   awesome.connect_signal(
      'debug::error',

      -- Callback that handles errors in awesome.
      --
      -- Arguments:
      --  The error the callback is handling.
      function(err)

         -- Make sure we don't go into an endless error loop
         if in_error then
            return
         end

         -- Mark that we are handling an error.
         in_error = true

         -- Display a notification to the user letting him know that
         -- there was an error.
         naughty.notify{
            preset = naughty.config.presets.critical,
            text   = 'Error logged to '
	             .. os.getenv('HOME')
	             .. '/awesome-errors.log: '
	             .. err,
            title  = 'Oops, an error happened!',
         }

	 file = io.open(os.getenv('HOME') .. '/awesome-errors.log', 'a+')
         file:write(err .. '\n\n')
         file:close()

         -- We just finished handling the error.
         in_error = false
      end
   )
end

-- #########
-- # Theme #
-- #########

-- Load our theme file.
beautiful.init(os.getenv('HOME') .. '/.config/awesome/theme.lua')

-- ####################
-- # Helper Functions #
-- ####################

-- Get the string for spawning a terminal.
--
-- Returns:
--  The string needed to spawn a new terminal.
function terminal_new()
   awful.spawn(config.terminal)
end

-- Return the string for spawning the given command inside a terminal. The
-- terminal should terminate once the command terminates, but this is not
-- guranteed for all terminals.
--
-- Optional Arguments:
--  cmd - The command to run inside the terminal. If this is not specified, a
--        normal temrinal is spawned.
--
-- Returns:
--  The string needed to spawn a terminal running the given command.
function terminal_spawn(cmd)

   -- If no command is specified, we just fallback to terminal_new().
   if cmd then
      awful.spawn(config.terminal .. ' -e ' .. cmd)
   else
      terminal_new()
   end

end

--
-- Stores the layouts.
local layouts = config.layouts

-- #############
-- # Wallpaper #
-- #############

-- Callback used to set the wallpaper on a screen due to geometry changes.
local function set_screen_wallpaper(s)

   -- Load the defined wallpaper
   local wallpaper = beautiful.wallpaper

   -- Only set the wallpaper if one was defined.
   if wallpaper then

      -- Resolve the wallpaper if it is a callback.
      if 'function' == type(wallpaper) then
	 wallpaper = wallpaper(s)
      end

      -- Set the wallpaper for this screen.
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end

-- Attach the wallpaper callback.
screen.connect_signal('property::geometry', set_screen_wallpaper)

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
      function()
	 terminal_spawn("man awesome")
      end
   },
   {
      "edit config",
      function()
	 awful.spawn(config.editor .. ' ' .. awesome.conffile)
      end
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
         'awesome',
         menu.sub.awesome,
         beautiful.awesome_icon
      },
      {
         'open terminal',
         terminal_new
      }
   }
}

-- Set the terminal for applications that require it
menubar.utils.terminal = config.terminal

-- #########
-- # Panel #
-- #########

-- Holds a seperate panel for each screen.
-- We need this broken out to a global object so that we can run prompts and
-- such on it later.
local panels = struct.weaktable()

-- Holds the taskbar button information we are going to be using for panels.
-- This is shared across all taskbars.
panels.taskbar = {}

-- All taskbars share the same buttons.
-- Create a lexical instance for variables the callbacks need.
do
   -- Holds the instance of the right click menu we are working with in the
   -- right click callback.
   local menu_instance = nil

   -- Create the taskbar menu callback list.
   panels.taskbar.buttons = awful.util.table.join(

      -- Left mouse click will minimize or maximize the target client.
      awful.button(
	 {}, 1,

	 -- Callback used to minimize or maximize a client.
	 --
	 -- Arguments:
	 --  c - The client to maximize or minimize.
	 function(c)

            -- If the client is the one that is already focused, we should
	    -- minimize it.
            if c == client.focus then
               c.minimized = true
	       return

	    -- Otherwise, unminimize the client. If it became visible on a
	    -- different tag from the current one (for some silly reason),
	    -- switch the visible tag to the clients tag.
	    else

               -- Make sure the window isn't minimized. We can do this later,
	       -- but if we do, we can't sanely check if the client is visible.
               c.minimized = false

	       -- Check if it became visible on the current tag.
               if not c:isvisible() then
                  awful.tag.viewonly(c:tags()[1])
               end

	       -- Make sure the client is focused and raised above other clients.
               client.focus = c
               c:raise()
            end
         end
      ),

      -- Right click opens a menu bar for selecting tasks.
      awful.button(
         {}, 3,

	 -- Opens a task menu, or closes it if it is already open.
         function()

	    -- If the menu is already created, toggle its visibility.
            if menu_instance then
                menu_instance:toggle()

            -- Otherwise, create a new floating task menu about where the mouse
            -- is.
            else
               menu_instance = awful.menu.clients{
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
end

-- ###########
-- # Screens #
-- ###########

-- Connect the screen callback for handling new screens.
awful.screen.connect_for_each_screen(

   -- Callback that handles new screens.
   --
   -- Arguments:
   --  s - The screen to setup.
   function(s)

      -- Setup the wallpaper for this screen.
      set_screen_wallpaper(s)

      -- Assign a tag table to this screen.
      awful.tag({1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, s, layouts[1])

      -- Allocate the panel for this screen.
      panels[s] = {}

      -- Create a promptbox.
      panels[s].prompt = awful.widget.prompt()

      -- Create a tasklist widget
      panels[s].taskbar = awful.widget.tasklist(
         s,
         awful.widget.tasklist.filter.currenttags,
         panels.taskbar.buttons
      )

      -- Create the wibox
      panels[s].panel = awful.wibox({
         position = "top",
         height = config.bar.height,
         screen = s
      })

      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(panels[s].prompt)

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()

      -- Add every widget from the configuration to the layout.
      for _, wid in pairs(config.widgets) do
         right_layout:add(wid)
      end

      -- Only place a system tray on the first desktop
      if s == 1 then
         right_layout:add(wibox.widget.systray())
      end

      -- Now bring it all together (with the tasklist in the middle)
      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_middle(panels[s].taskbar)
      layout:set_right(right_layout)

      -- Populate the panel with the requested layout widget.
      panels[s].panel:set_widget(layout)
   end
)

-- #########
-- # Mouse #
-- #########

-- Add all the mouse callbacks that get called when clicking on the desktop.
root.buttons(
   awful.util.table.join(

      -- Add right click callback for the main awesome background that opens up
      -- the awesome menu.
      awful.button(
	 {}, 3,

	 -- Toggles the visbility of the awesome main menu.
	 function()
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

            naughty.notify({
               preset = naughty.config.presets.low,
               title = "Launching Program",
               text = program.name
	    })
	    if program.terminal then
	       terminal_spawn(program.command)
	    else
               awful.spawn(program.command)
	    end
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

   awful.key({}, "Scroll_Lock",
      function()
         actions.screensaver:lock()
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

   -- Print = Take screenshot.
   awful.key({}, "Print",
      function()

          local datecmd = io.popen("date")
          local date = datecmd:read("*l")

          datecmd:close()
          awful.util.spawn_with_shell(
             "scrot ~/Pictures/Screenshots/'" .. date .. "'.png"
          )

          naughty.notify({
             preset = naughty.config.presets.low,
             title = "Screenshot: " .. date,
             text = percent
	  })
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
         terminal_new()
      end
   ),

    -- Master + z = Restart awesome.
    awful.key({config.keys.master}, "z", awesome.restart),

    -- Mod + Shift + Q = Quit awesome.
    -- awful.key({config.keys.master}, "z", awesome.quit),

    -- Mod + Launch + J = Increment window factor.
    awful.key({config.keys.master, config.keys.launch}, "j",
        function()
            awful.client.incwfact(0.05)
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
    --[[awful.key({config.keys.master, config.keys.launch}, "space",
        function()
            awful.layout.inc(layouts, -1)
        end
    ),
    --]]

    -- Mod + c = Command prompt.
    awful.key({config.keys.master}, "c",
        function()
            panels[mouse.screen].prompt:run()
        end
    ),

   -- Mod + X = Run prompt for lua code.
   awful.key(
       {config.keys.master, config.keys.move}, "x",
       function()
          awful.prompt.run(
             {prompt = "Run Lua code: "},
             panels[mouse.screen].prompt.widget,
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
   awful.button(
      {}, 1,
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

-- ################
-- # Window Rules #
-- ################

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {

   -- All clients will match this rule.
   {
      rule = {},
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = true,
         keys = keys.client,
         maximized_vertical = false,
         maximized_horizontal = false,
         buttons = buttons.client,
         size_hints_honor = false,
	 screen = awful.screen.preferred,
	 placement = (
	    awful.placement.no_overlap
	    + awful.placement.no_offscreen
         )
      }
   },

   -- Plugin containers must be floating to correctly follow
   -- the window.
   {
      rule = {
	 class = "Plugin-container"
      },
      properties = {
         floating = true
      }
   },

   -- URxvt will place black in areas when we don't honor its
   -- hints.
   {
      rule = {
         class = "URxvt"
      },
      properties = {
	 size_hints_honor = true
      }
   },

   -- VirtualBox likes to do weird things,
   {
      rule = {
         class = "VirtualBox"
      },
      properties = {
         maximized = false,
         sticky = false,
         floating = false,
         size_hints_honor = true
      }
   },

   -- Pinentry should float at the center of the screen instead of being tiled
   -- into a corner somewhere.
   {
      rule = {
         class = "pinentry"
      },
      properties = {
         floating = true
      }
   }
}

-- ##################
-- # Window Signals #
-- ##################

-- Signal function to execute when a new client appears.
client.connect_signal(
   "manage",
   function(c, startup)

      -- Make all floating windows ontop windows.
      if c.floating then
         c.ontop = true
      end

      -- Connect a signal to a client that gets executed on mouseover.
      c:connect_signal(
	 "mouse::enter",
	 function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
               -- Focus the client.
               client.focus = c
               c:raise()
            end
         end
      )

      if not startup then
         -- Set the config.windows at the slave,
         -- i.e. put it at the end of others instead of setting it master.
         awful.client.setslave(c)

         -- Put config.windows in a smart way, only if they does not set an
	 -- initial position.
         if not c.size_hints.user_position
	 and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
         end
      end
   end
)

-- Signal to be thrown when a client is focused.
client.connect_signal(
   "focus",
   function(c)
      c.border_color = beautiful.border_focus
   end
)

-- Signal to be thrown when a client is unfocused.
client.connect_signal(
   "unfocus",
   function(c)
      c.border_color = beautiful.border_normal
   end
)
