local awful     = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules     = require("awful.rules")
local beautiful = require("beautiful")
local gears     = require("gears")
local lain      = require("lain")
local menubar   = require("menubar")
local naughty   = require("naughty")
local viml      = require("viml")
local wibox     = require("wibox")
local widget    = require("widget")

return {
   layouts = {
      awful.layout.suit.tile,
      awful.layout.suit.spiral,
      lain.layout.centerwork,
      awful.layout.suit.floating
   },

   bar = {
      height = 48,
      spacer_width = 8,
   },

   terminal = "konsole",
   editor = "emacsclient -c",

   theme = {
      wallpaper = "~/.config/awesome/background",
      --font      = "Kremlin 8"
   },


   widgets = {
      widget.link(48, 24, 'enxa0cec8cc5fb0', 'wlp59s0'),
      widget.alsa(48, 24),
      widget.cpu(40, 24, 0, 12),
      widget.mem(40, 24),
      widget.battery(40, 16, "/sys/class/power_supply/BAT0/"),
      widget.spacer(8)
   },

   keys = {
      master = "Mod4",

      operations = {
	 viml.operation.focus, "None",
	 viml.operation.kill,  "Ctrl",
	 viml.operation.swap,  "Shift",
	 viml.operation.move,  "Mod1",
      },

      current = {
	 f = viml.current.fullscreen,
	 s = viml.current.float,
	 m = viml.current.maximize,
	 n = viml.current.minimize,
      },

      commands = {
	 v = viml.command.restore,
      },

      movements = {
	 viml.movement.client.current,            "\\",
	 viml.movement.client.direction("down"),  "j",
	 viml.movement.client.direction("left"),  "h",
	 viml.movement.client.direction("right"), "l",
	 viml.movement.client.direction("up"),    "k",
	 viml.movement.client.id(1),              "q",
	 viml.movement.client.id(2),              "w",
	 viml.movement.client.id(3),              "e",
	 viml.movement.client.id(4),              "r",
	 viml.movement.client.id(5),              "t",
	 viml.movement.client.id(6),              "y",
	 viml.movement.client.id(7),              "u",
	 viml.movement.client.id(8),              "i",
	 viml.movement.client.id(9),              "o",
	 viml.movement.client.id(10),             "p",
	 viml.movement.client.next,               "]",
	 viml.movement.client.previous,           "[",
	 viml.movement.tag.current,               "BackSpace",
	 viml.movement.tag.id(1),                 1,
	 viml.movement.tag.id(2),                 2,
	 viml.movement.tag.id(3),                 3,
	 viml.movement.tag.id(4),                 4,
	 viml.movement.tag.id(5),                 5,
	 viml.movement.tag.id(6),                 6,
	 viml.movement.tag.id(7),                 7,
	 viml.movement.tag.id(8),                 8,
	 viml.movement.tag.id(9),                 9,
	 viml.movement.tag.id(10),                0,
	 viml.movement.tag.next,                  "=",
	 viml.movement.tag.previous,              "-",
      },

      launch = "Mod1",

      programs = {

	 b = {
	    name = "Web Browser",
	    command = "firefox"
	 },

	 e = {
	    name = "Text Editor",
	    command = "emacsclient -c"
	 },

	 f = {
	    name = "File Manager",
	    command = "ranger",
	    terminal = true
	 },

	 p = {
	    name = "Process Monitor",
	    command = "htop",
	    terminal = true
	 },

	 s = {
	    name = 'Slack',
	    command = 'flatpak run com.slack.Slack'
	 }
      }
   }
}
