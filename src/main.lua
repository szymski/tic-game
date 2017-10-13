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