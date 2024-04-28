-- -------------------------------------------------------------------------- --
--                                    Intro                                   --
-- -------------------------------------------------------------------------- --
-- Will play after basic initialization. After the intro is played or skipped
-- the game will load.
-- ------------------------------------ - ----------------------------------- --

engine = engine or {}

local intro = love.graphics.newVideo("Engine/Intro/movie.ogg")
intro:play()

local function LoadGame()
    engine.Log("Loading game...")
    hooks.Fire("PreGameLoad")
    engine.Include("Game/game")
    hooks.Fire("OnGameLoad")
    hooks.Fire("PostGameLoad")
end


local function DrawIntro()
    if (not intro:isPlaying()) then
        ---@diagnostic disable-next-line: undefined-global
        EndIntro()
    else
        local sx = love.graphics.getWidth() / intro:getWidth()
        local sy = love.graphics.getHeight() / intro:getHeight()
        love.graphics.draw(intro,0,0,0,sx,sy)
    end
end

local function EndIntro()
    intro:pause()
    intro:release()
    hooks.Remove("OnKeyPressed", EndIntro)
    hooks.Remove("OnEngineDraw", DrawIntro)
    LoadGame()
end


hooks.Add("OnKeyPressed", EndIntro)
hooks.Add("OnEngineDraw", DrawIntro)