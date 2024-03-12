local TICKS_PER_TILE = 5

local COLORS = {
    --0xFFFFFF,
    0x00FFFF,
    0xFF00FF,
}

local DIRECTIONS = {
    {0, -1},
    {1, 0},
    {0, 1},
    {-1, 0},
}

local function add(a, b)
    return { a[1] + b[1], a[2] + b[2] }
end
local function isFilled(filled, pos)
    return filled[pos[2]] and filled[pos[2]][pos[1]]
end

local animationProto = {}
function animationProto:setup(monArray)
    self._maxStage = monArray.width() * monArray.height() * TICKS_PER_TILE
    for i = 1, monArray.width() do
        for j = 1, monArray.height() do
            monArray.cell(i, j).setPaletteColor(colors.black, 0x000000)
            monArray.cell(i, j).setBackgroundColor(colors.black)
            monArray.cell(i, j).clear()
        end
    end

    local width, height = monArray.width(), monArray.height()
    self._currentTile = {
        math.ceil(width / 2),
        math.ceil(height / 2)
    }
end
function animationProto:tick(monArray)
    if self._stage % TICKS_PER_TILE == 0 then
        self:_findNextValidTile(monArray)
        self:_drawTile(monArray)
    end
    self._stage = self._stage + 1
end
function animationProto:finished()
    return self._stage >= self._maxStage
end

function animationProto:_findNextValidTile(monArray)
    if not isFilled(self._filled, self._currentTile) then
        -- This is the very first tile
        self:_markFilled(self._currentTile)
        return
    end
    while true do
        local nextDirectionIndex = (self._direction + 1) % #DIRECTIONS
        local nextDirection = DIRECTIONS[nextDirectionIndex + 1]
        local nextDirectionTile = add(self._currentTile, nextDirection)
        if not isFilled(self._filled, nextDirectionTile) then
            self._currentTile = nextDirectionTile
            self._direction = nextDirectionIndex
            self:_markFilled(self._currentTile)
            if monArray.hasCell(self._currentTile[1], self._currentTile[2]) then
                return
            end
        end
        local currentDirection = DIRECTIONS[self._direction + 1]
        self._currentTile = add(self._currentTile, currentDirection)
        self:_markFilled(self._currentTile)
        if monArray.hasCell(self._currentTile[1], self._currentTile[2]) then
            return
        end
    end
end

function animationProto:_drawTile(monArray)
    local color = COLORS[self._nextColor + 1]
    monArray.cell(self._currentTile[1], self._currentTile[2]).setPaletteColor(2, color)
    monArray.cell(self._currentTile[1], self._currentTile[2]).setBackgroundColor(2)
    monArray.cell(self._currentTile[1], self._currentTile[2]).clear()
end

function animationProto:_markFilled(pos)
    if not self._filled[pos[2]] then
        self._filled[pos[2]] = {}
    end
    self._filled[pos[2]][pos[1]] = true
    self._nextColor = (self._nextColor + 1) % #COLORS
end

local function createAnimation()
    return setmetatable({
        _stage = 0,
        _nextColor = -1,
        _direction = 0,
        _filled = {}
    }, {__index = animationProto})
end

return createAnimation