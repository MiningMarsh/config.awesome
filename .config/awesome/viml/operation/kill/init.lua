return function(args)
    if args.client then
        if args.client.class ~= "Plasma" then
            args.client:kill()
        end
    elseif args.tag then
        for _, client in pairs(args.tag:clients()) do
            if client.class ~= "Plasma" then
                client:kill()
            end
        end
    end
end
