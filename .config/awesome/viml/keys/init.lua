local awful   = require("awful")
local naughty = require("naughty")

local function parse(table)
    local new = {}

    for i=1, #table, 2 do
        new[table[i]] = table[i + 1]
    end

    return new
end

return function(self, args)
    local bindings

    for movement, movementkey in pairs(parse(args.movements)) do
        for command, commandkey in pairs(parse(args.operations)) do
            if commandkey ~= "None" then
                bindings = awful.util.table.join(
                    bindings,
                    awful.key({args.master, commandkey}, movementkey,
                        function()
                            self:apply{
                                command  = command,
                                movement = movement,
                            }
                        end
                    )
                )
            else
                bindings = awful.util.table.join(
                    bindings,
                    awful.key({args.master}, movementkey,
                        function()
                            self:apply{
                                command  = command,
                                movement = movement,
                            }
                        end
                    )
                )
            end
        end
    end

    for key, command in pairs(args.current) do
        bindings = awful.util.table.join(
            bindings,
            awful.key({args.master}, key,
                function()
                    command(self.current)
                end
            )
        )
    end

    for key, command in pairs(args.commands) do
        bindings = awful.util.table.join(
            bindings,
            awful.key({args.master}, key, command)
        )
    end

    return bindings
end
