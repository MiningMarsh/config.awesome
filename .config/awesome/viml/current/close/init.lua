return function(self)
    local cl = self:client()
    if cl then
        cl:kill()
    end
end
