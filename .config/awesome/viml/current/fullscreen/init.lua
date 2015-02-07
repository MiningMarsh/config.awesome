return function(self)
    local client = self:client()
    client.fullscreen = not client.fullscreen
end
