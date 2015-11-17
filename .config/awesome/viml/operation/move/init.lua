local awful = require("awful")

return function(args)
    if args.client then
        -- This is currently bugged, so we disable this for now.
        --[[ local cl = args.current.client

        if not cl then
            return
        end

        if awful.client.next(1, args.client) == cl then
            args.client:swap(cl)
        else
            while awful.client.next(1, args.client) ~= cl do
                awful.client.swap.byidx(1, cl)
            end
        end

        client.focus = cl
        client.focus:raise()]]--
    elseif args.tag then
        if not args.current.client then
            return
        end
        awful.client.movetotag(args.tag, args.current.client)
        awful.tag.viewonly(args.tag)
    end
end
