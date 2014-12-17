return function(args)
    if args.client then
        args.client:kill()
    elseif args.tag then
        for _, client in pairs(args.tag:clients()) do
            client:kill()
        end
    end
end
