engine = engine or {}
engine.cvars = engine.cvars or {}

function engine.AddCVar(key, default, description)
    if (key == nil) then return end
    if (default == nil) then return end
    local desc = description or "No description."

    engine.cvars[key] = {
        ["name"] = key,
        ["default"] = default,
        ["value"] = default,
        ["desc"] = desc
    }
    --engine.Log("[CVARS] " .. string.format("Registration of CVar \"%s\" - %s", tostring(key), tostring(default)))
    hooks.Fire("OnCVarAdded", key, default)
end

function engine.GetCVar(key, default)
    local exists = table.ContainsKey(engine.cvars, key)
    if (default == nil) then
        default = engine.GetCVarDefault(key)
    end

    if (not exists) then return default end
    hooks.Fire("OnGetCVar", key)
    return engine.cvars[key]["value"]
end

function engine.GetCVarDefault(key)
    if (engine.cvars[key]) then
        return engine.cvars[key]["default"]
    else
        return nil
    end
end

function engine.GetCVarType(key)
    return type(engine.GetCVarDefault(key))
end


function engine.SetCVar(key, value)
    local exists = table.ContainsKey(engine.cvars, key)
    if (exists) then
        local t = type(value)
        local myt = engine.GetCVarType(key)

        if (t ~= myt) then
            engine.Log("[CVARS] " .. string.format("Attempt to assign CVar \"%s\" (a %s) a value of \"%s\" (a %s)", key, myt, tostring(value) or "UNKNOWN", t))
            return
        end

        engine.cvars[key]["value"] = value
    else
        engine.Log("[CVARS] " .. "ERROR: Attempt to assign CVar [" .. key .. "] not previously defined.")
    end
    hooks.Fire("OnCVarSet", key, value)
end

function engine.RestoreCVars()
    local path = "Game/Data/cvars.ini"
    local data = engine.ParseINI(path)
    local counter = 0

    local section = data["CVARS"]
    if (section ~= nil) then
        assert(istable(section), "Section information invalid")
        for k,v in pairs(section) do
            if (engine.GetCVarType(k) == "boolean") then
                engine.SetCVar(k,tobool(v))
            elseif (engine.GetCVarType(k) == "number") then
                engine.SetCVar(k,tonumber(v))
            else
                engine.SetCVar(k,v)
            end
            counter = counter + 1
        end

        engine.Log("[CVARS] " .. "Restored [" .. tostring(counter) .. "] CVars from data.")
    else
        engine.Log("[CVARS] " .. "Failed to restore cvars from data file: Empty section")
    end
end

function engine.SaveCVars()
    local path = "Game/Data/cvars.ini"
    local ini = {}
    ini["CVARS"] = {}


    for cvar, cvd in pairs(engine.cvars) do
        local name = cvd["name"] or cvar
        local value = cvd["value"] or "0"

        local t = engine.GetCVarType(name)

        if (t == "boolean") then
            if (value == true) then
                ini["CVARS"][name] = 1
            else
                ini["CVARS"][name] = 0
            end
        else
            ini["CVARS"][name] = tostring(value) or "0"
        end
    end

    engine.SaveINI(path, ini)
    engine.Log("[CVARS] " .. "Saved CVars.")
end

function engine.ResetCVars()
    engine.Log("[CVARS] " .. "Resseting CVars..")
    for cvar, cvd in pairs(engine.cvars) do
        cvd["value"] = cvd["default"] or nil
    end
end

function engine.PrintCVars()
    engine.Log("[CVARS] " .. "Retrieving list of CVars...")
    for cvar, cvd in pairs(engine.cvars) do
        local name = cvd["name"]
        local value = cvd["value"]
        local desc = cvd["desc"] or "No description"
        local def = cvd["default"]
        local t = engine.GetCVarType(name)

        engine.Log("[CVARS] " .. string.format("[%s]: \"%s\" (def: %s - a %s value)\n-%s", name, value, def, t, desc))
    end
end

function engine.GetCVars()
    local t = {}
    for cvar, cvd in pairs(engine.cvars) do
        table.insert(t, cvd)
    end
    return t
end

hooks.Add("OnEngineShutdown", function()
    engine.Log("[CVARS] " .. "Saving CVars...")
    engine.SaveCVars()
end)

hooks.Add("OnSetupCVars", function ()
    engine.AddCVar("debug_cvars", false, "Enable/Disable debugging information about CVars.")
    engine.AddCVar("screen_x", 1280, "Screen Width")
    engine.AddCVar("screen_y", 720, "Screen Height")
end)

hooks.Add("PostSetupCVars", function() 
    engine.Log("[CVARS] " .. "Restoring CVars from save file...")
    engine.RestoreCVars()
    engine.SaveCVars()

    local x = engine.GetCVar("screen_x")
    local y = engine.GetCVar("screen_y")
    love.window.setMode(x, y)

end)

hooks.Add("PostEngineDraw", function ()
    if (engine.GetCVar("debug_cvars", false) == false) then return end
	local str = string.format("CVars: [%i]\n", #engine.cvars)
	for cvar,cvd in pairs( engine.cvars ) do
		str = str .. string.format("[%s]: \"%s\" (def: %s) - %s\n", cvd["name"] or "Unknown", tostring(cvd["value"]) or "No Value", tostring(cvd["default"]), cvd["desc"] or "No description")
	end
	love.graphics.print(str, 32 , 32, 0, 1, 1)
end)

