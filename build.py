files = [
    "math/vector2.lua",
    "math/vector3.lua",
    "math/matrix.lua",
    "video/video.lua",
    "video/model.lua",
    "main.lua",
]
with open("out.lua", "w") as outfile:
    for fname in files:
        with open("src/" + fname) as infile:
            outfile.write("---------------------------\n")
            outfile.write("-- " + fname + "\n")
            outfile.write("---------------------------\n\n")
            for line in infile:
                outfile.write(line)
            outfile.write("\n")