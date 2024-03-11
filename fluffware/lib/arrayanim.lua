local event = require("event")

local monitorArrays = {}
local runningAnimations = {}

local function registerMonitorArray(name, monitorArray)
    monitorArrays[name] = {
        cell = function(x, y)
            return monitorArray[y][x]
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

local function runAnimation(name, animation)
    runningAnimations[name] = animation
end

event.on("frame", function()
    for name, animation in pairs(runningAnimations) do
        if animation:finished() then
            runningAnimations[name] = nil
        else
            animation:tick(monitorArrays[name])
        end
    end
end)

return {
    registerMonitorArray = registerMonitorArray,
    loadMonitorArray = loadMonitorArray,
    runAnimation = runAnimation
}