local function backslashcheck(str, i)
    if str:sub(i - 1, i - 1) == "\\" then
        return not backslashcheck(str, i - 1)
    end
    return false
end

local function TableSplit(str)
    local currstorage = ""
    local currtablestorage = {}
    local storage = {}
    local i = 1
    while i < #str do
        i = i + 1
        local char = str:sub(i, i)
        if char == "{" and not backslashcheck(str, i) then
            local j = i
            local depth = 1
            while depth >= 1 do
                j = j + 1
                local char = str:sub(j, j)
                if char == "{" and not backslashcheck(str, i) then
                    depth = depth + 1
                elseif char == "}" and not backslashcheck(str, j) then
                    depth = depth - 1
                end
            end
            currstorage = currstorage .. str:sub(i, j)
            i = j
        elseif char == "=" and not backslashcheck(str, i) then
            table.insert(currtablestorage, currstorage)
            currstorage = ""
        elseif char == ";" and not backslashcheck(str, i) then
            table.insert(currtablestorage, currstorage)
            currstorage = ""
            table.insert(storage, currtablestorage)
            currtablestorage = {}
        else
            currstorage = currstorage .. char
        end
    end
    return storage
end

local GON = {}

GON.encodeValue = function(value)
    if type(value) == "string" then
        value = string.gsub(value, "\\", "\\\\")
        value = string.gsub(value, "=", "\\=")
        value = string.gsub(value, ";", "\\;")
        value = string.gsub(value, "}", "\\}")
        value = string.gsub(value, "{", "\\{")
        return "s" .. value
    elseif type(value) == "number" then
        return "n" .. tostring(value)
    elseif type(value) == "boolean" then
        return "b" .. (value and "1" or "0")
    elseif type(value) == "table" then
        local val = "{"
        for k, v in pairs(value) do
            val = val .. GON.encodeValue(k) .. "=" .. GON.encodeValue(v) .. ";"
        end
        return val .. "}"
    end
end

GON.decodeValue = function(value)
    if string.sub(value, 1, 1) == "s" then
        value = string.gsub(value, "\\\\", "\\")
        value = string.gsub(value, "\\=", "=")
        value = string.gsub(value, "\\;", ";")
        value = string.gsub(value, "\\}", "}")
        value = string.gsub(value, "\\{", "{")
        return string.sub(value, 2)
    elseif string.sub(value, 1, 1) == "n" then
        return tonumber(string.sub(value, 2))
    elseif string.sub(value, 1, 1) == "b" then
        return string.sub(value, 2) == "1"
    elseif string.sub(value, 1, 1) == "{" then
        local val = {}
        local i = 2
        local keyvalues = TableSplit(value)
        for k, v in ipairs(keyvalues) do
            local ke, va = v[1], v[2]
            val[GON.decodeValue(ke)] = GON.decodeValue(va)
        end
        return val
    end
end

GON.encode = GON.encodeValue
GON.decode = GON.decodeValue

return GON
