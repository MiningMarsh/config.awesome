local awful = require("awful")

return function(direction)
    return function(args)
        awful.client.focus.bydirection(direction, args.current.client)
        args.client = client.focus
        return args
    end
end
