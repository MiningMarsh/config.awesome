local awful = require("awful")

return function(args)
    if args.client then
        client.focus = args.client
        client.focus:raise()
    elseif args.tag then
        awful.tag.viewonly(args.tag)
    end
end
