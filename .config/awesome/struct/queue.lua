-- Our queue factory.
local function new()

    -- Instance data.
    local head = nil
    local tail = nil
    local size = 0
    local queue = {}

    function queue:add(data)
        local node = {}
        node.data = data
        node.previous = nil
        node.next = head

        if size == 0 then
            tail = node
        else
            head.previous = node
        end

        size = size + 1
        head = node
    end

    function queue:view()
        if size == 0 then
            return nil
        end

        return tail.data
    end

    function queue:size()
        return size
    end

    function queue:empty()
        return size == 0
    end

    function queue:remove()
        if size == 0 then
            return nil
        end

        local data = tail.data

        if size == 1 then
            tail = nil
            head = nil
        else
            tail = tail.previous
            tail.next = nil
        end

    	size = size - 1

        return data
    end

    return queue
end

return new
