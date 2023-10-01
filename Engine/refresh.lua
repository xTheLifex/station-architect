engine = engine or {}
engine.refresh = engine.refresh or {}
engine.refresh.nextTick = engine.refresh.nextTick or 0
engine.refresh.trackedFiles = engine.refresh.trackedFiles or {}
engine.lua = engine.lua or {}
engine.lua.require = engine.lua.require or require

hooks.Add("OnSetupCVars", function()
    engine.AddCVar("lua_tick", 0.5, "The amount of time between checks for refreshing lua files.")
end)

function engine.refresh.AddFile(path)
    local ref = engine.refresh.trackedFiles[path]
    if (not ref) then
        engine.Log("[Lua-Refresh] Registering [" .. path .. "]")
        engine.refresh.trackedFiles[path] = file.info(path).modtime or CurTime()
    end
end

function engine.refresh.RefreshLua()
    local c = 0
    for f,t in pairs(engine.refresh.trackedFiles) do
        local newTime = file.info(f).modtime
        local oldTime = t

        local r = false
        
        if (newTime ~= oldTime) then
            r = true
            c = c + 1
            engine.refresh.trackedFiles[f] = newTime
            local data = love.filesystem.load(f)
            hooks.Fire("BeforeLuaRefresh", f)
            if (data) then
                return data()
            end
        end
        if (r) then
            engine.Log("[Lua-Refresh] " .. "Refreshed Lua with " .. tostring(c) .. " file(s) changed.")
        end
    end
end

hooks.Add("OnEngineUpdate", function (deltaTime)
    if (engine.refresh.nextTick < CurTime()) then
        local tick = engine.GetCVar("lua_tick", 0.5)
        engine.refresh.nextTick = engine.refresh.nextTick + tick

        engine.refresh.RefreshLua()
    end
end)

hooks.Add("OnFileIncluded", function (path)
    engine.refresh.AddFile(path)
end)


-- Replace the default require behaviour
require = engine.Include