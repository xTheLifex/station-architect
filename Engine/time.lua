engine = engine or {}
engine.time = engine.time or {}
engine.time.deltaTime = 0
engine.time.currentTime = os.time(os.date("!*t"))

function CurTime()
    return engine.time.currentTime
end

function DeltaTime()
    return engine.time.deltaTime
end

hooks.Add("OnEngineUpdate", function(deltaTime)
    engine.time.deltaTime = deltaTime
    engine.time.currentTime = os.time(os.date("!*t"))
end)
