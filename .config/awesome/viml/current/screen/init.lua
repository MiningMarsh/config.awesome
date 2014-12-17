return function(self)
    if client.focus then
        return client.focus.screen
    else
        return mouse.screen
    end
end
