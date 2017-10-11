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