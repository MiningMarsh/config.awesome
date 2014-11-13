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

return {desktops = {keys = {"#10",
                            "#11",
                            "#12",
                            "#13",
                            "#14",
                            "#15",
                            "#16",
                            "#17",
                            "#18",
                            "#19"},
                    layouts = {lain.layout.centerwork,
                               lain.layout.uselesstile,
                               lain.layout.uselesspiral}},

        windows = {keys = {'q',
                           'w',
                           'e',
                           'r',
                           't',
                           'y',
                           'u',
                           'i',
                           'o',
                           'p'}},

        startup = {"pidof compton || compton -f --no-fading-openclose -b",
                   "xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'",
                   "xrandr --output HDMI1 --set 'Broadcast RGB' 'Full'",
                   "amixer -c 1 sset Speaker,0 64"},

        theme = {wallpaper = "/usr/local/Blood.jpg",
                 font      = "Kremlin 8"},

        shortcuts = {programs = {f="firefox",
                                 t="urxvt -e cmus",
                                 l="libreoffice",
                                 u="urxvt",
                                 v="vlc",
                                 m="urxvt -e vifm"}}}
