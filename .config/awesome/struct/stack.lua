local function new()
    local data = {}

    local stack = {}
    local size = 0
    function stack:push(value)
        size = size + 1
        data[size] = value
    end

    function stack:peek()
        if size == 0 then
            return nil
        end
        return data[size]
    end

    function stack:size()
        return size
    end

    function stack:pop()
        if size == 0 then
            return nil
        end

        local value = data[size]
        data[size] = nil

        size = size - 1

        return value
    end

    return stack
end

return new
