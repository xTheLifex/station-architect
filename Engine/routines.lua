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

function engine.routines.yields.WaitForSeconds(time)
    local target = CurTime() + time
    while (CurTime() < target) do
        coroutine.yield()
    end
end

hooks.Add("OnEngineUpdate", function (dt)
    for name, co in pairs(engine.routines.list) do
        if (coroutine.status(co) == "dead") then
            engine.Log("[Routines] Deleting dead coroutine [" .. name .. "]")
            engine.routines.End(name)
        else
            coroutine.resume(co)
        end
    end
end)