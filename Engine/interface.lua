engine = engine or {}
engine.interface = {}
engine.interface.fonts = {}
engine.interface.fonts.default = love.graphics.newFont(12)
engine.interface.elements = {}

require("Engine.Interface.Modules.base")

-- -------------------------------------------------------------------------- --
--                                   System                                   --
-- -------------------------------------------------------------------------- --

engine.interface.print = function (text, x, y, centerX, centerY)
    local font = engine.interface.fonts.default
    local w = font:getWidth(text);
    local h = font:getHeight();
    local centerX = centerX or true
    local centerY = centerY or true
    love.graphics.print(text, x - (centerX and (w/2) or 0), y - (centerY and (h/2) or 0))
end



function engine.interface.Draw()

end

-- -------------------------------------------------------------------------- --
--                                    Hooks                                   --
-- -------------------------------------------------------------------------- --

hooks.Add("OnInterfaceDraw", engine.interface.Draw)

hooks.Add("EngineLoadingScreenDraw", function ()
    local text = engine.loadingText or "Loading..."
    engine.interface.print(text, ScreenX()/2, ScreenY()/2)
end)

hooks.Add("OnCVarSet", function (key, value)
    screen_vars = {"screen_borderless", "screen_x", "screen_y"}
    if (table.contains(screen_vars, key)) then
        local x = engine.GetCVar("screen_x", 1280)
        local y = engine.GetCVar("screen_y", 720)
        local fullscreen = engine.GetCVar("fullscreen", false)
        local borderless = engine.GetCVar("screen_borderless", false)
        love.window.setMode(x or 1280, y or 720, {resizable=true, fullscreen=fullscreen or false, centered=true, borderless=borderless or false, msaa=1})
    end
end)

