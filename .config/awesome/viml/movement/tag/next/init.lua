local awful = require("awful")

return function(args)
    awful.tag.viewnext()
    args.tag = awful.tag.selected()
    return args
end
