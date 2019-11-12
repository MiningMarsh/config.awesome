local function new()
   local table = {}
   local metatable = {}
   setmetatable(table, metatable)
   -- This is what actually annotates the root table as a weak table.
   metatable.__mode = "k"

   return table
end

return new
