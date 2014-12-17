local awful = require("awful")

return function(args)
    awful.tag.viewprev()
    args.tag = awful.tag.selected()
    return args
end
