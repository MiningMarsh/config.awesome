local awful = require("awful")

return function(id)
    return function(args)

        local count

        if not args.current.master then
            count = 0
        else
            count = 1
            local current = awful.client.next(1, args.current.master)

            while current ~= args.current.master do
                current = awful.client.next(1, current)
                count = count + 1
            end
        end

        if id > count then
            return nil
        end

        args.client = awful.client.next(id - 1, args.current.master)

        return args
    end
end



