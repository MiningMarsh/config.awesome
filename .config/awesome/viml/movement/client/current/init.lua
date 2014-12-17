local naughty = require("naughty")

return function(args)
    args.client = args.current.client
    return args
end
