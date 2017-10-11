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