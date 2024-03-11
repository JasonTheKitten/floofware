local function columnInvoke(monArray, column, func, ...)
    for i = 1, monArray.height() do
        monArray.cell(column, i)[func](...)
    end
end

local function gradientRow(stage, length)
    local gradientEnd = math.ceil(length / 2) / 15 * stage
    local row = {}
    for i = 1, math.ceil(length / 2) do
        if i == math.ceil(gradientEnd) and i ~= gradientEnd then
            row[i] = i / gradientEnd * 255 * (gradientEnd % 1)
        elseif i > gradientEnd then
            row[i] = 0
        else
            row[i] = i / gradientEnd * 255
        end
    end
    for i = math.ceil(length / 2) + 1, length do
        row[i] = row[length - i + 1]
    end

    return row
end

local function updateMonitors(monArray, row)
    for i = 1, monArray.width() do
        columnInvoke(monArray, i, "setPaletteColor", 1, 0, 0, math.pow(row[i] / 255, 1.75))
        columnInvoke(monArray, i, "setBackgroundColor", 1)
        columnInvoke(monArray, i, "clear")
    end
end

local animationProto = {}
function animationProto:tick(monArray)
    local row =
        self._stage < 15 and gradientRow(self._stage + 1, monArray.width()) or
        self._stage < 21 and gradientRow(15, monArray.width()) or
        gradientRow(36 - self._stage, monArray.width())
    updateMonitors(monArray, row)
    self._stage = (self._stage + 1) % 36
end
function animationProto:finished()
    return false
end

local function createAnimation()
    return setmetatable({
        _stage = 0
    }, {__index = animationProto})
end

return createAnimation