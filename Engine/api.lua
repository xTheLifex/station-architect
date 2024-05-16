engine = engine or {}
engine.api = {}
engine.gameEnviroment = {}
engine.api.env = {}

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

engine.api.pcall = function(f, ...)
    if not isfunc(f) then return f end
    setfenv(f, engine.gameEnviroment)
    f(unpack { ... })
end

-- -------------------------------------------------------------------------- --
--                               API Declaration                              --
-- -------------------------------------------------------------------------- --

hooks.Add("OnEngineSetup", function()
    engine.api.env.game = {}
    engine.api.env.engine = {}
    engine.api.env.hooks = hooks
    engine.api.env.engine.Log = function(text)
        engine.Log("[Game] " .. text)
    end
    engine.api.env.game.Log = function(text)
        engine.Log("[Game] " .. text)
    end
    engine.api.env.engine.world = engine.world
    engine.api.env.utils = utils
    engine.api.env.require = function(modname)
        if (string.startsWith(modname, "engine")) then
            error("Invalid module to require.")
            return
        end
        return require(modname)
    end
    engine.api.env.engine.entities = engine.entities
    engine.api.env.engine.world = engine.world

    engine.api.env.isfunc = isfunc
    engine.api.env.isfunction = isfunction
    engine.api.env.ismethod = ismethod
    engine.api.env.isbool = isbool
    engine.api.env.isstring = isstring
    engine.api.env.istable = istable
    engine.api.env.isent = isent
    engine.api.env.IsValid = IsValid
    engine.api.env.Vector = Vector
    engine.api.env.MousePos = MousePos
    engine.api.env.MouseX = MouseX
    engine.api.env.MouseY = MouseY
    engine.api.env.ScreenX = ScreenX
    engine.api.env.ScreenY = ScreenY
    engine.api.env.ipairs = ipairs
    engine.api.env.pairs = pairs
    engine.api.env.pick = pick
    

    engine.api.env.love = love
    --engine.api.env.love.keypressed = love.keypressed

    engine.api.env.math = math
    
    setmetatable(engine.gameEnviroment, {
        __index = engine.api.env,
        __newindex = function(t, k, v)
            if engine.api.env[k] ~= nil then
                if engine.api.env[k] ~= v then
                    error("Attempt to override existing engine API.", 2)
                end
            else
                rawset(t, k, v) -- Allow adding new modules
            end
        end
    })
end)

-- -------------------------------------------------------------------------- --
--                                   Loading                                  --
-- -------------------------------------------------------------------------- --

hooks.Add("OnGameLoad", function()
    local f = assert(loadfile("Game/game.lua"))
    setfenv(f, engine.gameEnviroment)
    f()
end)
