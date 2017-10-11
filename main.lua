---------------------------------
-- Vector2
---------------------------------

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

---------------------------------
-- Vector3
---------------------------------

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

---------------------------------
-- Matrix
---------------------------------

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

function meta:toScreenPos()
    return vec2.new(video.width / 2 + self[1][1] / self[4][1] / video.aspect * video.width / 2, video.height / 2 + self[2][1] / self[4][1] * video.height / 2)
end

---------------------------------
-- Video Component
---------------------------------

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

function video.flush()
    
end

---------------------------------
-- Main
---------------------------------

local i = 0

function TIC()
    video.clear(0)

    i = i + 0.02

    local proj = matrix.newProjection(math.pi / 2, 1, 0.1, 1000)
    local model = matrix.newTranslation(0, 0, -10) * matrix.newRotationZ(i * 1.3)
    local pos1 = vec3.new(-0.5, 0, 0)
    local pos2 = vec3.new(0.5, 0, 0)
    local out1 = (proj * model * pos1:toMatrix()):toScreenPos()
    local out2 = (proj * model * pos2:toMatrix()):toScreenPos()

    video.drawLine(out1.x, out1.y, out2.x, out2.y, 7)

    video.flush()
end