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
        lain.layout.uselesstile,
        lain.layout.uselesspiral,
        awful.layout.suit.floating
    },

    terminal = "urxvt",
    editor = "vim",

    startup = {
        "xsetroot -cursor_name left_ptr",
        "compton -b",
        "xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'",
        "xrandr --output HDMI1 --set 'Broadcast RGB' 'Full'",
        "amixer -c 1 sset Speaker,0 64",
        "pidof aria2c || aria2c --conf-path=/home/joshua/.aria2/daemon.conf",
        "pidof rtorrent || rtorrent-create",
        "pidof mpd || mpd"
    },

    theme = {
        wallpaper = "~/.config/awesome/background",
        font      = "Kremlin 8"
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
            c = viml.current.close,
            f = viml.current.fullscreen,
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
            viml.movement.client.id(10),             "p",
            viml.movement.client.id(2),              "w",
            viml.movement.client.id(3),              "e",
            viml.movement.client.id(4),              "r",
            viml.movement.client.id(5),              "t",
            viml.movement.client.id(6),              "y",
            viml.movement.client.id(7),              "u",
            viml.movement.client.id(8),              "i",
            viml.movement.client.id(9),              "o",
            viml.movement.client.next,               "]",
            viml.movement.client.previous,           "[",
            viml.movement.tag.current,               "BackSpace",
            viml.movement.tag.id(1),                 1,
            viml.movement.tag.id(10),                10,
            viml.movement.tag.id(2),                 2,
            viml.movement.tag.id(3),                 3,
            viml.movement.tag.id(4),                 4,
            viml.movement.tag.id(5),                 5,
            viml.movement.tag.id(6),                 6,
            viml.movement.tag.id(7),                 7,
            viml.movement.tag.id(8),                 8,
            viml.movement.tag.id(9),                 9,
            viml.movement.tag.next,                  "=",
            viml.movement.tag.previous,              "-",
        },

        launch = "Mod1",

        programs = {
            b = {
                name = "Web Browser",
                command = "firefox"
            },

            f = {
                name = "File Manager",
                command = "urxvt -e vifm"
            },

            l = {
                name = "Writer",
                command = "libreoffice"
            },

            m = {
                name = "Music Player",
                command = "urxvt -e ncmpcpp"
            },

            v = {
                name = "Video Player",
                command = "vlc"
            },

            d = {
                name = "Text Editor",
                command = "urxvt -e vim"
            }
        }
    }
}
