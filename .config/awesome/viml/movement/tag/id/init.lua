local awful = require("awful")

return function(id)
    return function(args)
        args.tag = awful.tag.gettags(args.current.screen)[id]
        return args
    end
end
