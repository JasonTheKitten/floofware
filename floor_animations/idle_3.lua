local NUM_TICKS = 10000
local TICKS_PER_CYCLE = 10

local colorList = {
    --{ 0, 0, 0 },
    { 0, 0, 255 },
    { 0, 255, 0 },
    { 0, 255, 255 },
    { 255, 0, 0 },
    { 255, 0, 255 },
    { 255, 255, 0 },
    --{ 255, 255, 255 },
}

local animationProto = {}
function animationProto:setup(monArray)
    for i = 1, monArray.height() do
        self._nextTarget[i] = {}
        self._lastTarget[i] = {}
        for j = 1, monArray.width() do
            self._nextTarget[i][j] = { 0, 0, 0 }
        end
    end
end
function animationProto:tick(monArray)
    self:_updateTargets(monArray)
    self:_blendColors(monArray)
    self._stage = (self._stage + 1) % TICKS_PER_CYCLE
    self._ticks = self._ticks + 1
end
function animationProto:finished()
    return self._ticks >= NUM_TICKS
end

function animationProto:_updateTargets(monArray)
    if self._stage % TICKS_PER_CYCLE == 0 then
        for i = 1, monArray.height() do
            for j = 1, monArray.width() do
                self._lastTarget[i][j] = self._nextTarget[i][j]
                local index = math.random(1, #colorList)
                self._nextTarget[i][j] = colorList[index]
                if self._lastTarget[i][j] == self._nextTarget[i][j] then
                    self._nextTarget[i][j] = colorList[(index % #colorList) + 1]
                end
            end
        end
    end
end
function animationProto:_blendColors(monArray)
    for i = 1, monArray.height() do
        for j = 1, monArray.width() do
            local lastColor = self._lastTarget[i][j]
            local nextColor = self._nextTarget[i][j]
            local stage = self._stage
            local r = lastColor[1] + (nextColor[1] - lastColor[1]) * stage / TICKS_PER_CYCLE
            local g = lastColor[2] + (nextColor[2] - lastColor[2]) * stage / TICKS_PER_CYCLE
            local b = lastColor[3] + (nextColor[3] - lastColor[3]) * stage / TICKS_PER_CYCLE
            monArray.cell(j, i).setPaletteColor(1, r / 255, g / 255, b / 255)
            monArray.cell(j, i).setBackgroundColor(1)
            monArray.cell(j, i).clear()
        end
    end
end

local function createAnimation()
    return setmetatable({
        _stage = 0,
        _ticks = 0,
        _nextTarget = {},
        _lastTarget = {},
    }, {__index = animationProto})
end

return createAnimation