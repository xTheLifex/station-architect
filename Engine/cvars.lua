engine = engine or {}
engine.cvars = engine.cvars or {}

function engine.AddCVar(key, default, description, toggleKey)
    if (key == nil) then return end
    if (default == nil) then return end
    local desc = description or "No description."

    engine.cvars[key] = {
        ["name"] = key,
        ["default"] = default,
        ["value"] = default,
        ["desc"] = desc,
        ["debug"] = toggleKey and true or false,
        ["toggle"] = toggleKey or nil
    }

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

hooks.Add("OnEngineSetup", function ()
    engine.Log("[CVARS] Setting up any additional console variables...")
	local version = love.filesystem.read("Engine/version.txt") or 0
	engine.version = IsValid(version) and version or 0
	hooks.Fire("OnSetupCVars")
    engine.Log("[CVARS] " .. "Restoring CVars from save file...")
    engine.RestoreCVars()
    engine.SaveCVars()
	hooks.Fire("PostSetupCVars")
end)

hooks.Add("PostEngineDraw", function ()
    if (engine.GetCVar("debug_cvars", false) == false) then return end
	local str = string.format("CVars: [%s]\n", tostring(table.length(engine.cvars)))
	for cvar,cvd in pairs( engine.cvars ) do
        local name = cvd["name"] or "Unknown"
        local debug = cvd["debug"] and (" " .. string.upper(cvd["toggle"]) .. " ") or ""
        local value = tostring(cvd["value"]) or "No Value"
        local default = tostring(cvd["default"])
        local description = cvd["desc"] or "No description"
        
        local line = string.format("[%s]%s: \"%s\" (def: %s) - %s\n", name, debug, value, default, description)
		str = str .. string.wtrim(line, 100, 3)
	end
	love.graphics.print(str, 32 , 32, 0, 1, 1)
end)

hooks.Add("OnKeyPressed", function (key, scancode, isrepeat)
    for name, cvar in pairs(engine.cvars) do
        if (cvar.debug == true and type(cvar.value) == "boolean") then
            if (scancode == cvar.toggle) then
                engine.SetCVar(name, not engine.GetCVar(name, false))
            end
        end
    end
end)

-- -------------------------------------------------------------------------- --
--                                Adding cvars.                               --
-- -------------------------------------------------------------------------- --

engine.AddCVar("showfps", true, "Draws FPS on the screen.", "f8")
engine.AddCVar("debug_cvars", false, "Enable/Disable debugging information about CVars.", "f1")
engine.AddCVar("debug_entities", false, "Enable the debugging of entity information", "f2")
engine.AddCVar("debug_hooks" , false, "Enable/Disable debugging information about Hooks.", "f3")
engine.AddCVar("debug_rendering", false, "Enable/Disable debugging information about Rendering.", "f4")
engine.AddCVar("debug_physics", false, "Enables the display of debug physical information", "f5")
engine.AddCVar("screen_x", 1280, "Screen Width")
engine.AddCVar("screen_y", 720, "Screen Height")
engine.AddCVar("screen_borderless", false, "Enable borderless fullscreen")
engine.AddCVar("fullscreen", false, "Makes the game fullscreen.")