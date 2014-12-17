local awful = require("awful")

return function(args)
    if args.client then
        args.client:swap(args.current.client)
    elseif args.tag then
        local id = awful.tag.getidx(args.tag)
        awful.tag.move(awful.tag.getidx(args.current.tag), args.tag)
        awful.tag.move(id, args.current.tag)
    end
end
