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
    engine.api.env.hooks = hooks
    engine.api.env.engine = engine
    engine.api.env.game.Log = function(text)
        engine.Log("[Game] " .. text)
    end
    engine.api.env.require = function(modname)
        if (string.startsWith(modname, "engine")) then
            error("Invalid module to require.")
            return
        end
        return require(modname)
    end


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
