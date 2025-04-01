engine = engine or {}
engine.time = engine.time or {}
engine.time.startTime = os.time(os.date("!*t"))
engine.time.currentTime = 0
engine.time.deltaTime = 0
engine.time.nextTime = love.timer.getTime()
engine.time.minDelta = 1/60 -- FPS

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
    local fps = engine.GetCVar("maxfps", 60)
    engine.time.nextTime = engine.time.nextTime + 1/fps
end)

hooks.Add("PostGameDraw", function() 
    local cur_time = love.timer.getTime()
    if engine.time.nextTime <= cur_time then
        engine.time.nextTime = cur_time
        return
    end
    love.timer.sleep(engine.time.nextTime - cur_time)
end)
