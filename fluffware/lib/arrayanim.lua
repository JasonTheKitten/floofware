local event = require("event")

local monitorArrays = {}
local runningAnimations = {}
local finishedListeners = {}

local function registerMonitorArray(name, monitorArray)
    monitorArrays[name] = {
        cell = function(x, y)
            return monitorArray[y][x]
        end,
        hasCell = function(x, y)
            return x >= 1 and x <= #monitorArray[1] and y >= 1 and y <= #monitorArray
        end,
        width = function()
            return #monitorArray[1]
        end,
        height = function()
            return #monitorArray
        end
    }
end

local function loadMonitorArray(name, config)
    local monitorArray = {}
    for y = 1, #config do
        monitorArray[y] = {}
        for x = 1, #config[y] do
            monitorArray[y][x] = peripheral.wrap(config[y][x])
        end
    end

    registerMonitorArray(name, monitorArray)
end

local function addFinishedListener(name, listener)
    if not finishedListeners[name] then
        finishedListeners[name] = {}
    end
    table.insert(finishedListeners[name], listener)
end

local function runAnimation(name, animation)
    if animation.setup then
        animation:setup(monitorArrays[name])
    end
    runningAnimations[name] = animation
end

event.on("frame", function()
    for name, animation in pairs(runningAnimations) do
        if animation:finished() then
            runningAnimations[name] = nil
            for _, listener in ipairs(finishedListeners[name] or {}) do
                listener()
            end
        else
            animation:tick(monitorArrays[name])
        end
    end
end)

return {
    registerMonitorArray = registerMonitorArray,
    loadMonitorArray = loadMonitorArray,
    runAnimation = runAnimation,
    addFinishedListener = addFinishedListener
}