local FRAME_RATE = 10

local event_handlers = {}
local function emit(name, ...)
    if event_handlers[name] then
        for _, handler in ipairs(event_handlers[name]) do
            handler(...)
        end
    end
end

local event = {}
function event.on(name, func)
    if not event_handlers[name] then
        event_handlers[name] = {}
    end
    table.insert(event_handlers[name], func)
end

function event.loop()
    local timer = os.startTimer(1 / FRAME_RATE)
    while true do
        local event = { os.pullEvent() }--coroutine.yield() }
        if event[1] == "timer" and event[2] == timer then
            emit("frame")
            timer = os.startTimer(1 / FRAME_RATE)
        end
    end
end

return event