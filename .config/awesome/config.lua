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

    terminal = "urxvtc",
    editor = "emacsclient -c",

    startup = {
        "dispatch-confd &",
        "newsd &",
        "pidof redshift || redshift &",
        "pidof udevil || devmon --sync --info-on-mount &",
        "emacsd",
        "gpud &",
        "pidof mpd || mpd && mpc pause",
        "pidof urxvtd || urxvtd -f",
        "synclient TapButton1=1 TapButton2=3 TapButton3=2",
        "xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'",
        "xrandr --auto",
        "xrandr --output HDMI1 --set 'Broadcast RGB' 'Full'",
        --"xrandr --setprovideroutputsource modesetting NVIDIA-0",
        "xset s on -dpms",
        "xset s 600 600",
        "xsetroot -cursor_name left_ptr",
	"pidof xautolock || xautolock -time 10 -locker xtrlock &",
    },

    theme = {
        wallpaper = "~/.config/awesome/background",
        --font      = "Kremlin 8"
    },

    widgets = {
        widget.link(16, 8),
        widget.alsa(16, 8),
        widget.battery(16, 8),
        widget.cpu(20, 8),
        widget.mem(20, 8),
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

            f = {
                name = "File Manager",
                command = "urxvtc -e vifm"
            },

            w = {
                name = "Writer",
                command = "libreoffice"
            },

            m = {
                name = "Music Player",
                command = "urxvtc -e ncmpcpp"
            },

            v = {
                name = "Video Player",
                command = "vlc"
            },

            e = {
                name = "Text Editor",
                command = "emacsclient -c"
            },

            c = {
                name = "IRC",
                command = "erc"
            },

            t = {
                name = "Tiny Fugue",
                command = "urxvtc -e tf"
            }
        }
    }
}
