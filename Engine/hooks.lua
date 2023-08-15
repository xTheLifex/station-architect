engine = engine or {}
engine.GetCVar = engine.GetCVar or function() return nil end
hooks = {}
hooks.last = {}
hooks.lastClearTime = 0
hooks.list = {}
hooks.blacklist = {"blacklist"}

hooks.Add = function(hook, callback)
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end
	
	if (hooks.list[hook] == nil) then
		hooks.list[hook] = {}
	end

	if (engine.cvars) then
		if (#hooks.list[hook] > 100) then
			engine.Log("[Hooks] " .. "WARNING! Adding yet another callback to a hook [" .. hook .. "] that has over 100 callbacks!")
		end
	end

	table.insert(hooks.list[hook], callback)
end

-- Gets a list of registered hooks.
hooks.GetHooks = function()
	local t = {}
	for key, _ in pairs(hooks.list) do
		
		if (type(hooks.list[key]) == "table") then
			local invalid = false
			for k,v in ipairs(hooks.blacklist) do
				if (key == v) then invalid = true end
			end
			if not invalid then
				table.insert(t, key)
			end
			
		end
	end
	return t
end

-- Fires the hook and returns all of the results from all the callbacks.
hooks.Fire = function(hook, ...)
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end

	if not (table.contains(hooks.last, hook)) then
		table.insert(hooks.last, hook)
	end

	if (hooks.list[hook] ~= nil) then
		local t = {}
		for k,v in ipairs(hooks.list[hook]) do
			local r = v(unpack({...}))
			if (r ~= nil) then table.insert(t, r) end
		end
		return t
	end
	return nil
end

hooks.FireCheckReturn = function(hook, value, ...)
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end
	
	if not (table.contains(hooks.last, hook)) then
		table.insert(hooks.last, hook)
	end

	if (hooks.list[hook] ~= nil) then
		for k,v in ipairs(hooks.list[hook]) do
			local r = v(unpack({...}))
			if (r ~= nil) then
				if (r == value) then
					return true
				end
			end
		end
	end
	return false
end

hooks.Clear = function(hook) 
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end
	
	if (hooks.list[hook] ~= nil) then
		hooks.list[hook] = nil
	end
end

hooks.Remove = function(hook, callback)
	if (callback == nil) then
		if (type(hook) == "function") then
			-- Treat as callback
			local callback = hook
			local hookList = hooks.GetHooks()
			for _,h in ipairs(hookList) do
				local index = table.indexOf(hooks.list[h], callback)
				if (index ~= nil) then table.remove(hooks.list[h], index) end

				if (#hooks.list[h] == 0) then
					hooks.Clear(h)
				end
			end
		else 
			hooks.Clear(hook)
		end
	else
		if (type(callback) ~= "function") then
			return
		end
		if (hooks.list[hook] ~= nil) then
			local index = table.indexOf(hooks.list[hook], callback)
			if (index ~= nil) then table.remove(hooks.list[hook], index) end

			if (#hooks.list[hook] == 0) then
				hooks.Clear(hook)
			end
		end
	end
end

local CVAR_DEBUG = "debug_hooks"

hooks.Add("OnSetupCVars" , function ()
	engine.AddCVar(CVAR_DEBUG , false, "Enable/Disable debugging information about Hooks.")
end)

hooks.Add("OnEngineUpdate", function ()
	if (CurTime() - hooks.lastClearTime > 0.1) then
		hooks.lastClearTime = CurTime()
		hooks.last = {}
	end
end)

do
	local function r(i)
		return {i,0,0}
	end

	local function g(i)
		return {0,i,0}
	end

	local function b(i)
		return {0,0,i}
	end

	local function w(i)
		return {i,i,i}
	end


	hooks.Add("PostEngineDraw", function ()
		if not (engine.GetCVar(CVAR_DEBUG, false)) then
			return false
		end
		local h = hooks.GetHooks() or {}
		local t = {}

		table.insert(t, w(1))
		table.insert(t, string.format("Hooks: [%i]\n",#h))

		local count = 0
		local LIMIT = 20

		for _, hook in ipairs(h) do
			if (count >= LIMIT) then
				table.insert(t, b(1))
				table.insert(t, "(...)\n")
				break
			end
			if (table.contains(hooks.last, hook)) then
				table.insert(t, b(1))
				table.insert(t, string.format("%s\n", hook))
				count = count+1
			end
		end
		
		LIMIT = LIMIT-math.floor(count/2) -- Limit of INACTIVE hooks on screen
		count = 0
		
		for _, hook in ipairs(h) do
			if (count >= LIMIT) then
				table.insert(t, w(1))
				table.insert(t, "(...)\n")
				break
			end

			if (not table.contains(hooks.last, hook)) then
				table.insert(t, w(1))
				table.insert(t, string.format("%s\n", hook))
				count = count+1
			end
		end

		love.graphics.print(t, 712, 32, 0, 1, 1)
	end)
end