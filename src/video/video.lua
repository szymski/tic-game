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