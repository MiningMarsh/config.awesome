local awful = require("awful")

return function(args)
    args.client = awful.client.next(-1)
    if args.client and args.client ~= args.current.client then
        return args
    else
        return
    end
end
