package.path = package.path .. ";/floofware/lib/?.lua;/floofware/lib/?/init.lua"

local function loadConfig()
    local file = fs.open("floof.cfg", "r")
    local config = textutils.unserialize(file.readAll())
    file.close()
    return config
end

local config = loadConfig()

local arrayanim = require("arrayanim")
arrayanim.loadMonitorArray("floor", config.floor)

local loadedAnimations = {}
local function loadAnimation(name)
    if not loadedAnimations[name] then
        loadedAnimations[name] = loadfile(name .. ".lua")()
    end
    return loadedAnimations[name]
end

local nextAnimation = 0
local function playNextAnimation()
    local animation = loadAnimation(config.floor_idle_animations[nextAnimation + 1])()
    arrayanim.runAnimation("floor", animation)
    nextAnimation = (nextAnimation + 1) % #config.floor_idle_animations
end

arrayanim.addFinishedListener("floor", playNextAnimation)
playNextAnimation()

require("event").loop()