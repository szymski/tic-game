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
    local s1, s2 = video.vectorToScreen(pos1), video.vectorToScreen(pos2)
    video.drawLine(s1.x, s1.y, s2.x, s2.y, color)
end

function video.draw3DTriangle(pos1, pos2, pos3, color)
    local s1, s2, s3 = video.vectorToScreen(pos1), video.vectorToScreen(pos2), video.vectorToScreen(pos3)
    tri(s1.x, s1.y, s2.x, s2.y, s3.x, s3.y, color)
end

function video.flush()

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
    return vec2.new(video.width / 2 + m[1][1] / m[4][1] / video.aspect * video.width / 2, video.height / 2 + m[2][1] / m[4][1] * video.height / 2)
end

---------------------------------
-- Drawing queue
---------------------------------

VID_POINT = 1
VID_LINE = 2
VID_TRIANGLE = 3

video.queue = { }
---------------------------
-- main.lua
---------------------------

---------------------------------
-- Main
---------------------------------

local i = 0

function TIC()
    video.clear(0)

    i = i + 0.02

    local proj = matrix.newProjection(math.pi / 2, 1, 0.1, 1000)
    video.pushMatrix()
    video.mulMatrix(proj)
    local model = matrix.newTranslation(0, 0, -10) * matrix.newRotationX(i * 1) * matrix.newRotationY(i * 0.7) * matrix.newRotationZ(i * 1.3)
    video.pushMatrix()
    video.mulMatrix(model)

    -- video.draw3DLine(vec3.new(-0.5, -0.5, -0.5), vec3.new(0.5, -0.5, -0.5), 8)
    -- video.draw3DLine(vec3.new(0.5, -0.5, -0.5), vec3.new(0.5, 0.5, -0.5), 8)
    -- video.draw3DLine(vec3.new(0.5, 0.5, -0.5), vec3.new(-0.5, 0.5, -0.5), 8)
    -- video.draw3DLine(vec3.new(-0.5, 0.5, -0.5), vec3.new(-0.5, -0.5, -0.5), 8)

    -- video.draw3DLine(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), 8)
    -- video.draw3DLine(vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 8)
    -- video.draw3DLine(vec3.new(0.5, 0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), 8)
    -- video.draw3DLine(vec3.new(-0.5, 0.5, 0.5), vec3.new(-0.5, -0.5, 0.5), 8)

    -- video.draw3DLine(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, -0.5, -0.5), 8)
    -- video.draw3DLine(vec3.new(0.5, -0.5, 0.5),vec3.new(0.5, -0.5, -0.5), 8)
    -- video.draw3DLine(vec3.new(0.5, 0.5, 0.5), vec3.new(0.5, 0.5, -0.5), 8)
    -- video.draw3DLine(vec3.new(-0.5, 0.5, 0.5), vec3.new(-0.5, 0.5, -0.5), 8)

    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 1)
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 2)

    video.mulMatrix(matrix.newRotationX(math.pi / 2))
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 3)
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 4)

    video.mulMatrix(matrix.newRotationX(math.pi / 2))
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 5)
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 6)

    video.mulMatrix(matrix.newRotationX(math.pi / 2))
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 7)
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 8)

    video.mulMatrix(matrix.newRotationY(math.pi / 2))
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 9)
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 10)

    video.mulMatrix(matrix.newRotationY(-math.pi / 2))
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(0.5, -0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 11)
    video.draw3DTriangle(vec3.new(-0.5, -0.5, 0.5), vec3.new(-0.5, 0.5, 0.5), vec3.new(0.5, 0.5, 0.5), 12)

    video.popMatrix()    
    -- local pos1 = vec3.new(-0.5, 0, 0)
    -- local pos2 = vec3.new(0.0, 0, 0)
    -- local out1 = (proj * model * pos1:toMatrix()):toScreenPos()
    -- local out2 = (proj * model * pos2:toMatrix()):toScreenPos()

    -- video.drawLine(out1.x, out1.y, out2.x, out2.y, 7)

    video.flush()
    video.popMatrix()
end
