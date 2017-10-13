model = { }
model.__index = model

function model.new(...)
    local tbl = { }
    setmetatable(tbl, model)
    tbl:init(...)
    return tbl
end

function model:init(vertices, indices)
    self.vertices = vertices or { }
    self.indices = indices or { }
end

function model:draw()
    for i = 1, #self.indices, 3 do
        local i1, i2, i3 = self.indices[i], self.indices[i + 1], self.indices[i + 2]
        local v1, v2, v3 = self.vertices[i1], self.vertices[i2], self.vertices[i3]

        video.draw3DTriangle(v1, v2, v3, i / 3 + 1)
    end
end