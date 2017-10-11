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