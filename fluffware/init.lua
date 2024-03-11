package.path = package.path .. ";/fluffware/lib/?.lua;/fluffware/lib/?/init.lua"

local function loadConfig()
    local file = fs.open("fluff.cfg", "r")
    local config = textutils.unserialize(file.readAll())
    file.close()
    return config
end

local arrayanim = require("arrayanim")
arrayanim.loadMonitorArray("floor", loadConfig().floor)

arrayanim.runAnimation("floor", loadfile("floor_animations/welcome.lua")()())

require("event").loop()