vec3 = { }
vec3.__index = vec3

function vec3:init(x, y, z)
    self.x, self.y, self.z = x or 0, y or 0, z or 0
end

function vec3:toMatrix()
    return matrix.newVector4(self.x, self.y, self.z)
end

function vec3.new(...)
    local tbl = { };
    setmetatable(tbl, vec3)
    tbl:init(...)

    return tbl
end