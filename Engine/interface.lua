engine = engine or {}
engine.interface = {}

engine.interface.fonts = {}
engine.interface.fonts.default = love.graphics.newFont(12)


engine.interface.print = function (text, x, y, centerX, centerY)
    local font = engine.interface.fonts.default
    local w = font:getWidth(text);
    local h = font:getHeight();
    local centerX = centerX or true
    local centerY = centerY or true
    love.graphics.print(text, x - (centerX and (w/2) or 0), y - (centerY and (h/2) or 0))
end

hooks.Add("EngineLoadingScreenDraw", function ()
    local text = engine.loadingText or "Loading..."
    engine.interface.print(text, ScreenX()/2, ScreenY()/2)
end)