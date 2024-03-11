local reason = ...

local NUM_TICKS = 100

local colorList = {
    0x000000,
    0x0000FF,
    0x00FF00,
    0x00FFFF,
    0xFF0000,
    0xFF00FF,
    0xFFFF00,
    0xFFFFFF
}

local textLines = {}
for v in reason:gmatch("[^\n]+") do
    table.insert(textLines, v)
end

local function drawMiddleMonReason(middleMon)
    middleMon.setPaletteColor(colors.black, 0x000000)
    middleMon.setPaletteColor(colors.white, 0xFFFFFF)
    middleMon.setBackgroundColor(colors.black)
    middleMon.setTextColor(colors.white)
    middleMon.clear()
    middleMon.setTextScale(.5)

    local width, height = middleMon.getSize()
    local yStart = math.floor((height - #textLines) / 2) + 1
    for i, v in ipairs(textLines) do
        local lineX = math.floor((width - #v) / 2) + 1
        middleMon.setCursorPos(lineX, yStart + i - 1)
        middleMon.write(v)
    end
end

local animationProto = {}

function animationProto:tick(monArray)
    self._tick = self._tick + 1

    if self._tick % 2 ~= 1 then
        return
    end

    for i = 1, monArray.width() do
        for j = 1, monArray.height() do
            local randomColor = colorList[math.random(1, #colorList)]
            monArray.cell(i, j).setPaletteColor(1, randomColor)
            monArray.cell(i, j).setBackgroundColor(1)
            monArray.cell(i, j).clear()
        end
    end

    local middleMonX = math.ceil(monArray.width() / 2)
    local middleMonY = math.ceil(monArray.height() / 2)
    local middleMon = monArray.cell(middleMonX, middleMonY)
    drawMiddleMonReason(middleMon, reason)
end

function animationProto:finished()
    return self._tick >= NUM_TICKS
end

local function createAnimation()
    return setmetatable({
        _tick = 0
    }, {__index = animationProto})
end

return createAnimation