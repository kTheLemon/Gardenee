Colors = {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
    gray = 90,
    bright_red = 91,
    lime = 92,
    bright_yellow = 93,
    bright_blue = 94,
    bright_magenta = 95,
    bright_cyan = 96,
    bright_white = 97,
}

function RenderText(t)
    for i = 1, #t do
        t[i][2] = tostring(t[i][2] or 37)
        t[i][3] = tostring((t[i][3] or 30) + 10)
        io.write("\27[" .. t[i][2] .. "m\27[" .. t[i][3] .. "m" .. t[i][1])
    end
    io.write("\27[0m")
end
