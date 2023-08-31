engine = engine or {}
engine.time = engine.time or {}
engine.time.deltaTime = 0
engine.time.startTime = os.time(os.date("!*t"))
engine.time.currentTime = 0

function CurTime()
    return engine.time.currentTime
end

function UnixTime()
	return os.time(os.date("!*t"))
end

DateTime = UnixTime

function DeltaTime()
    return engine.time.deltaTime
end

hooks.Add("OnEngineUpdate", function(deltaTime)
    engine.time.deltaTime = deltaTime
    engine.time.currentTime = engine.time.currentTime + deltaTime
end)
