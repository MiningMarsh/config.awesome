local function new(size)
    size = size or 100

    local graph = {}

    for i=1, size do
        graph[i] = 0
    end

    function graph:push(element)
        for i=1, size - 1 do
            local t = size - i
            self[t + 1] = self[t]
        end

        self[1] = element
    end

    function graph:peek(index)
        return graph[index]
    end

    function graph:size()
        return size
    end

    return graph
end

return new
