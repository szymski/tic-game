vec2 = { }
vec2.__index = vec2

function vec2:init(x, y)
    self.x, self.y = x or 0, y or 0
end

function vec2.new(...)
    local tbl = { };
    setmetatable(tbl, vec2)
    tbl:init(...)

    return tbl
end