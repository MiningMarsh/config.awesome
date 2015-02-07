return function(self)
    local client = self:client()
    client.maximized_horizontal = not client.maximized_horizontal
    client.maximized_vertical = not client.maximized_vertical
end
