local StringCharset = {}
local NumberCharset = {}

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do StringCharset[#StringCharset + 1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset + 1] = string.char(i) end

function zf.log(type, message)
    local callingResource = GetInvokingResource()
    local printTypes = {
        ['success'] = {
            color = '^2',
            label = ('%s:SUCCESS'):format(callingResource),
            printer = function(content) print(content) end,
        },
        ['warning'] = {
            color = '^3',
            label = ('%s:WARN'):format(callingResource),
            printer = function(content) print(content) end,
        },
        ['error'] = {
            color = '^1',
            label = ('%s:ERROR'):format(callingResource),
            printer = function(content) error(content) end,
        },
        ['inform'] = {
            color = '^5',
            label = ('%s:INFORM'):format(callingResource),
            printer = function(content) print(content) end,
        },
    }
    local finalMessage = '[' .. printTypes[type].label .. ']' .. printTypes[type].color .. message .. ' ^0'
    printTypes[type].printer(finalMessage)
end

function zf.randomStr(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    if length <= 0 then return '' end
    local str = ""
    for i = 1, length do
        local rand = math.random(#charset)
        str = str .. string.sub(charset, rand, rand)
    end
    return str
end

function zf.randomInt(length)
    if length <= 0 then return '' end
    local min = 10^(length-1)
    local max = 10^length - 1
    return math.random(min, max)
end

function zf.splitStr(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        result[#result + 1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    result[#result + 1] = string.sub(str, from)
    return result
end

function zf.trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function zf.firstToUpper(value)
    if not value then return nil end
    return (value:gsub("^%l", string.upper))
end

function zf.round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

function zf.getCoreName()
    return zf.core
end

function zf.getInventoryName()
    return zf.inventory
end

function zf.getCoreObject()
    return CoreObject
end

function zf.getProgressColor(pourcentage, inverted)
    if inverted then
        if pourcentage > 75 then return '#2a9d8f' end
        if pourcentage > 50 then return '#e9c46a' end
        if pourcentage > 30 then return '#f4a261' end
        if pourcentage > 0 then return '#e63946' end
    end
    if pourcentage > 75 then return '#e63946' end
    if pourcentage > 50 then return '#f4a261' end
    if pourcentage > 30 then return '#e9c46a' end
    if pourcentage > 0 then return '#2a9d8f' end
end
