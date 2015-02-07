return function(self)
    local c = self:client()

    if c then
        c.minimized = true
    end
end
