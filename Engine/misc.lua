-- -------------------------------------------------------------------------- --
--                                   Metrics                                  --
-- -------------------------------------------------------------------------- --

hooks.Add("OnEngineUpdate", function(deltaTime) 
    engine.fps = 1/deltaTime
end)

hooks.Add("OnEngineDraw", function ()
    if (engine.GetCVar("showfps", false) == true) then
        local avg = love.timer.getAverageDelta()
        local s = string.format("FPS: %s, AVG: %s", math.floor(engine.fps), math.floor(1/avg))
        love.graphics.print(s, 0, 0, 0, 1,1)
    end
end)
