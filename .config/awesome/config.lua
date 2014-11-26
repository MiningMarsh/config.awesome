local awful     = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules     = require("awful.rules")
local beautiful = require("beautiful")
local gears     = require("gears")
local lain      = require("lain")
local menubar   = require("menubar")
local naughty   = require("naughty")
local wibox     = require("wibox")
local widget    = require("widget")

return {layouts = {lain.layout.centerwork,
                   lain.layout.uselesstile,
                   lain.layout.uselesspiral,
                   awful.layout.suit.floating},

        terminal = "urxvt",
        editor   = "vim",

        startup = {"compton",
                   "xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'",
                   "xrandr --output HDMI1 --set 'Broadcast RGB' 'Full'",
                   "amixer -c 1 sset Speaker,0 64"},

        theme = {wallpaper = "~/.config/awesome/background",
                 font      = "Kremlin 8"},

        keys = {master = "Mod4",
                move   = "Shift",
                close  = "Control",
                launch = "Mod1",

                programs = {b = "firefox",
                            f = "urxvt -e vifm",
                            o = "libreoffice",
                            m = "urxvt -e cmus",
                            t = "urxvt",
                            v = "vlc",
            		        e = "urxvt -e vim"},

                windows = {'q','w','e','r','t','y','u','i','o','p',

                           previous = '[',
                           next     = ']',
                           up       = 'k',
                           down     = 'j',
                           left     = 'h',
                           right    = 'l',
                           current  = '\\'},

                desktops = {"#10","#11","#12","#13","#14","#15","#16","#17",
                            "#18","#19",

                            previous = '-',
                            next     = '=',
                			current  = "BackSpace"}}}
