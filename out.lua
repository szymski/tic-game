---------------------------
-- math/vector2.lua
---------------------------

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
---------------------------
-- math/vector3.lua
---------------------------

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
---------------------------
-- math/matrix.lua
---------------------------

matrix = { }
local meta = { }
meta.__index = meta

function mulMatrix(m1, m2)
    local nResultRows = #m1
    local nResultColumns = #m2[1]

    local result = matrix.new(nResultRows, nResultColumns)

    for r = 1, nResultRows do
        for c = 1, nResultColumns do
            for c2 = 1, #m1[1] do
                result[r][c] = result[r][c] + m1[r][c2] * m2[c2][c]
            end
        end
    end

    return result
end

function meta:__mul(other)
    return mulMatrix(self, other)
end

local function newMatrix(nRows, nColumns)
    local rows = { }

    for i = 1, nRows do
        rows[i] = { }

        for j = 1, nColumns do
            rows[i][j] = 0
        end
    end

    return rows
end

local function newIdentityMatrix(nRows, nColumns)
    local rows = { }

    for i = 1, nRows do
        rows[i] = { }

        for j = 1, nColumns do
            rows[i][j] = 0
        end
    end

    for i = 1, math.min(nRows, nColumns) do
        rows[i][i] = 1
    end

    return rows
end

function matrix.new(rows, columns)
    local matrix = newMatrix(rows, columns)
    setmetatable(matrix, meta)

    return matrix
end

function matrix.newIdentity(rows, columns)
    local matrix = newIdentityMatrix(rows, columns)
    setmetatable(matrix, meta)

    return matrix
end

function matrix.newProjection(fov, aspect, near, far)
    local m = matrix.new(4, 4)

    local s = 1 / (math.tan(fov / 2))

    m[1][1] = s / aspect
    m[2][2] = s
    m[3][3] = far / (near - far)
    m[3][4] = -1
    m[4][3] = (far / (near - far)) * near

    return m
end

function matrix.newScale(x, y, z)
    if not y and not z then
        y = x
        z = x
    end

    local m = matrix.newIdentity(4, 4)

    m[1][1] = x
    m[2][2] = y
    m[3][3] = z

    return m
end

function matrix.newTranslation(x, y, z)
    local m = matrix.newIdentity(4, 4)

    m[1][4] = x
    m[2][4] = y
    m[3][4] = z
    m[4][4] = 1

    return m
end

function matrix.newRotationX(angle)
    local m = matrix.newIdentity(4, 4)

    m[2][2] = math.cos(angle)
    m[2][3] = -math.sin(angle)
    m[3][2] = math.sin(angle)
    m[3][3] = math.cos(angle)

    return m
end

function matrix.newRotationY(angle)
    local m = matrix.newIdentity(4, 4)

    m[1][1] = math.cos(angle)
    m[3][1] = -math.sin(angle)
    m[1][3] = math.sin(angle)
    m[3][3] = math.cos(angle)

    return m
end

function matrix.newRotationZ(angle)
    local m = matrix.newIdentity(4, 4)

    m[1][1] = math.cos(angle)
    m[1][2] = -math.sin(angle)
    m[2][1] = math.sin(angle)
    m[2][2] = math.cos(angle)

    return m
end

function matrix.newVector4(x, y, z)
    local m = matrix.new(4, 1)

    m[1][1] = x
    m[2][1] = y
    m[3][1] = z
    m[4][1] = 1

    return m
end
---------------------------
-- video/video.lua
---------------------------

video = { }

video.width = 240
video.height = 136
video.aspect = video.width / video.height

function video.clear(color)
    cls(color)
end

function video.setPixel(x, y, color)
    pix(x, y, color)
end

function video.drawLine(x1, y1, x2, y2, color)
    line(x1, y1, x2, y2, color)
end

function video.draw3DLine(pos1, pos2, color)
    local s1, w1 = video.vectorToScreen(pos1)
    local s2, w2 = video.vectorToScreen(pos2)
    -- video.drawLine(s1.x, s1.y, s2.x, s2.y, color)

    video.enqueue({
        type = VID_LINE,
        color = color,
        depth = (w1 + w2) / 2,
        pos1 = s1,
        pos2 = s2,
    })
end

function video.draw3DTriangle(pos1, pos2, pos3, color)
    local s1, w1 = video.vectorToScreen(pos1)
    local s2, w2 = video.vectorToScreen(pos2)
    local s3, w3 = video.vectorToScreen(pos3)
    -- tri(s1.x, s1.y, s2.x, s2.y, s3.x, s3.y, color)

    video.enqueue({
        type = VID_TRIANGLE,
        color = color,
        depth = (w1 + w2 + w3) / 3,
        pos1 = s1,
        pos2 = s2,
        pos3 = s3,
    })
end

---------------------------------
-- Matrix
---------------------------------

video.matrixStack = { matrix.newIdentity(4, 4) }

function video.matrix()
    return video.matrixStack[#video.matrixStack]
end

function video.pushMatrix()
    video.matrixStack[#video.matrixStack + 1] = video.matrixStack[#video.matrixStack]
end

function video.popMatrix()
    video.matrixStack[#video.matrixStack] = nil
end

function video.mulMatrix(m)
    video.matrixStack[#video.matrixStack] = video.matrixStack[#video.matrixStack] * m
end

function video.vectorToScreen(vec)
    return video.matrixToScreen(video.matrix() * vec:toMatrix())
end

function video.matrixToScreen(m)
    return vec2.new(video.width / 2 + m[1][1] / m[4][1] / video.aspect * video.width / 2, video.height / 2 + m[2][1] / m[4][1] * video.height / 2), m[4][1]
end

---------------------------------
-- Drawing queue
---------------------------------

VID_POINT = 1
VID_LINE = 2
VID_TRIANGLE = 3

--[[
    A list of tables:
        type - the type of the primitive
        color - color
        depth - depth that will be used with sorting 
]]
video.queue = { }

function video.enqueue(tbl)
    video.queue[#video.queue + 1] = tbl
end

function video.flush()
    table.sort(video.queue, function(a, b) return a.depth > b.depth end)

    for k, v in pairs(video.queue) do
        if v.type == VID_LINE then
            line(v.pos1.x, v.pos1.y, v.pos2.x, v.pos2.y, v.color)
        elseif v.type == VID_TRIANGLE then
            tri(v.pos1.x, v.pos1.y, v.pos2.x, v.pos2.y, v.pos3.x, v.pos3.y, v.color)
        end
    end
    
    video.queue = { }
end
---------------------------
-- video/model.lua
---------------------------

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
---------------------------
-- main.lua
---------------------------

---------------------------------
-- Main
---------------------------------

local i = 0

lastTime = time()
deltaTime = 0

mdl = model.new({
    vec3.new(-0.0000, -0.2217, -33.4401),
    vec3.new(-0.0000, 3.5812, -27.6213),
    vec3.new(17.8221, 3.6324, -21.2395),
    vec3.new(21.4897, -0.3382, -25.6104),
    vec3.new(-0.0000, -3.3595, -27.2373),
    vec3.new(17.4456, -3.2942, -20.7909),
    vec3.new(27.4098, 3.6805, -4.8331),
    vec3.new(32.9127, -0.4543, -5.8034),
    vec3.new(26.6348, -3.2261, -4.6964),
    vec3.new(24.1970, 3.7254, 13.9702),
    vec3.new(28.9300, -0.5701, 16.7028),
    vec3.new(23.3419, -3.1553, 13.4764),
    vec3.new(9.5934, 3.7673, 26.3577),
    vec3.new(11.4191, -0.6854, 31.3738),
    vec3.new(9.1874, -3.0819, 25.2422),
    vec3.new(-9.6311, 3.8059, 26.4612),
    vec3.new(-11.4117, -0.8001, 31.3535),
    vec3.new(-9.1571, -3.0058, 25.1590),
    vec3.new(-24.4831, 3.8414, 14.1353),
    vec3.new(-28.8739, -0.9142, 16.6704),
    vec3.new(-23.1119, -2.9272, 13.3436),
    vec3.new(-27.9517, 3.8735, -4.9286),
    vec3.new(-32.8064, -1.0274, -5.7847),
    vec3.new(-26.1992, -2.8461, -4.6196),
    vec3.new(-18.3169, 3.9024, -21.8292),
    vec3.new(-21.3926, -1.1398, -25.4947),
    vec3.new(-17.0478, -2.7626, -20.3168),
}, { 1, 2, 3,  
2, 5, 6,  
5, 1, 4,  
4, 3, 7,  
3, 6, 9,  
6, 4, 8,  
8, 7, 10,  
7, 9, 12,  
9, 8, 11,  
11, 10, 13,  
10, 12, 15,  
12, 11, 14,  
14, 13, 16,  
13, 15, 18,  
15, 14, 17,  
17, 16, 19,  
16, 18, 21,  
18, 17, 20,  
20, 19, 22,  
19, 21, 24,  
21, 20, 23,  
23, 22, 25,  
22, 24, 27,  
24, 23, 26,  
26, 25, 2,  
25, 27, 5,  
27, 26, 1, })

function TIC()
    deltaTime = (time() - lastTime) * 0.001
    lastTime = time()

    video.clear(0)

    i = i + deltaTime

    local proj = matrix.newProjection(math.pi / 2, 1, 0.1, 1000)
    video.pushMatrix()
    video.mulMatrix(proj)
    local model = matrix.newTranslation(0, 0, -30) * matrix.newRotationX(i * 1) * matrix.newRotationY(i * 0.7) * matrix.newRotationZ(i * 1.3)
    video.pushMatrix()
    video.mulMatrix(model)
    video.mulMatrix(matrix.newScale(0.1, 0.1, 0.1))

    mdl:draw()

    video.popMatrix()    
    -- local pos1 = vec3.new(-0.5, 0, 0)
    -- local pos2 = vec3.new(0.0, 0, 0)
    -- local out1 = (proj * model * pos1:toMatrix()):toScreenPos()
    -- local out2 = (proj * model * pos2:toMatrix()):toScreenPos()

    -- video.drawLine(out1.x, out1.y, out2.x, out2.y, 7)

    video.flush()
    video.popMatrix()
end
