---@diagnostic disable: deprecated
engine.routines = engine.routines or {}
engine.routines.list = {}
engine.routines.yields = {}

function engine.routines.New(name, func)
    assert(type(name) == "string", "Invalid coroutine name")
    assert(type(func) == "function", "Attempt to create coroutine without a function body.")
    assert(name ~= "", "Empty coroutine name")

    engine.routines.list[name] = coroutine.create(func)
    return engine.routines.list[name]
end

function engine.routines.GetStatus(name)
    local co = engine.routines.list[name]
    if (not co) then return "invalid" end

    return coroutine.status(co)
end

function engine.routines.End(name)
    local co = engine.routines.list[name]
    if (not co) then return end
    if (coroutine.status(co) ~= "dead") then
        coroutine.close(engine.routines.list[name])    
    end
    
    engine.routines.list[name] = nil
end

-- Suspends the current coroutine for specified seconds.
function engine.routines.yields.WaitForSeconds(time)
    local target = CurTime() + time
    while (CurTime() < target) do
        coroutine.yield()
    end
end

-- Suspends the current coroutine and sets the loading text of the engine.
engine.routines.yields.LoadingYield = function (text)
    engine.loadingText = text or "Loading..."
    coroutine.yield()
end

hooks.Add("OnEngineUpdate", function (dt)
    for name, co in pairs(engine.routines.list) do
        if (coroutine.status(co) == "dead") then
            engine.Log("[Routines] Deleting dead coroutine [" .. name .. "]")
            engine.routines.End(name)
        else
            local result = {coroutine.resume(co)}
            if result[1] == false then
                error(string.format([[FATAL:
Coroutine has crashed: %s.
RESULT: %s 
TRACEBACK: %s
                ]], name, result[2], debug.traceback(co)))
            end
        end
    end
end)