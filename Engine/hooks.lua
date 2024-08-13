engine = engine or {}
engine.GetCVar = engine.GetCVar or function() return nil end
hooks = {}
hooks.debug = {}
hooks.debug.calls = {} -- Tracks call history
hooks.debug.heat = {} -- Defines color every time history is cleared
hooks.debug.clearTime = 1 -- Seconds before the colors are updated and history cleared
hooks.debug.lastClean = 0 -- Time where the last cleaning took place.
hooks.debug.uncalled = {}

hooks.flags = {}
hooks.list = {}
hooks.blacklist = {"blacklist"}

-- -------------------------------------------------------------------------- --
--                                    Flags                                   --
-- -------------------------------------------------------------------------- --

function hooks.Flag(hook, flag, val)
	hooks.flags[hook] = hooks.flags[hook] or {}
	hooks.flags[hook][flag] = tobool(val)
end

function hooks.GetFlag(hook, flag)
	hooks.flags[hook] = hooks.flags[hook] or {}
	return hooks.flags[hook][flag] or false
end

local ignoreUnuse = {
	"OnEngineShutdown", "EngineLoadingScreenDraw",
	"OnMouseWheelUp", "OnMouseWheelDown",
	"OnKeyPressed"
}

for _,h in ipairs(ignoreUnuse) do hooks.Flag(h, "ignoreUnused", true) end

-- -------------------------------------------------------------------------- --
--                                   Hooking                                  --
-- -------------------------------------------------------------------------- --

hooks.Add = function(hook, callback)
	--local flags = flags or {}
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end
	
	if (hooks.list[hook] == nil) then
		hooks.list[hook] = {}
		hooks.debug.uncalled[hook] = true
		--for _,flag in ipairs(flags) do hooks.Flag(hook, flag, true) end
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
	if (hooks.list[hook] == nil) then hooks.list[hook] = {} end
	hooks.debug.uncalled[hook] = false
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end

	hooks.debug.calls[hook] = hooks.debug.calls[hook] or 0
	hooks.debug.calls[hook] = hooks.debug.calls[hook] + 1

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
	if (hooks.list[hook] == nil) then hooks.list[hook] = {} end
	for k,v in ipairs(hooks.blacklist) do
		if (hook == v) then return end
	end
	
	hooks.debug.calls[hook] = hooks.debug.calls[hook] or 0
	hooks.debug.calls[hook] = hooks.debug.calls[hook] + 1

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

-- -------------------------------------------------------------------------- --
--                                    Debug                                   --
-- -------------------------------------------------------------------------- --

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

	local function grad(value)
		local r, g, b

		return {r, g, b}
	end


	hooks.Add("PostEngineDraw", function ()
		if not (engine.GetCVar("debug_hooks", false)) then
			return false
		end
		local h = hooks.GetHooks() or {}
		local function heatOrder(a,b)
			local _a = hooks.debug.heat[a] and hooks.debug.heat[a][2] or 0
			local _b = hooks.debug.heat[b] and hooks.debug.heat[b][2] or 0
			return _a > _b
		end

		table.sort(h, heatOrder)

		local t = {}
		table.insert(t, w(1))
		table.insert(t, string.format("### Hooks: [%i] ###\n",#h))
		--table.insert(t, "[calls]:callbacks - hook\n")

		local displayCount = 0
		local LIMIT = 50

		table.insert(t, w(1))
		table.insert(t, "* With callbacks:\n")

		-- Draw the ones that have listed callbacks first.
		for _, hook in ipairs(h) do
			local color = hooks.debug.heat[hook] and hooks.debug.heat[hook][1] or {1,1,1}
			if (displayCount >= LIMIT) then
				table.insert(t, color)
				table.insert(t, "(...)\n")
				break
			end

			local count = hooks.debug.heat[hook] and hooks.debug.heat[hook][2] or 0
			local callbacks = #hooks.list[hook]

			if (count > 0 and callbacks > 0) then
				table.insert(t, color)
				table.insert(t, string.format("[%s]:%s - %s\n", count, callbacks, hook))
				displayCount = displayCount+1
			end
		end
		table.insert(t, w(1))
		table.insert(t, "* Without callbacks:\n")

		-- No callbacks registered, but still called alot.
		for _, hook in ipairs(h) do
			local color = hooks.debug.heat[hook] and hooks.debug.heat[hook][1] or {1,1,1}
			if (displayCount >= LIMIT) then
				table.insert(t, color)
				table.insert(t, "(...)\n")
				break
			end

			local count = hooks.debug.heat[hook] and hooks.debug.heat[hook][2] or 0
			local callbacks = #hooks.list[hook]

			if (count > 0 and callbacks == 0) then
				table.insert(t, color)
				table.insert(t, string.format("[%s]:%s - %s\n", count, callbacks, hook))
				displayCount = displayCount+1
			end
		end
		table.insert(t, w(1))
		table.insert(t, "* Not fired, has callbacks:\n")
		
		-- Not called, but has registered callbacks
		for _, hook in ipairs(h) do
			if (displayCount >= LIMIT) then
				table.insert(t, w(1))
				table.insert(t, "(...)\n")
				break
			end

			local count = hooks.debug.heat[hook] and hooks.debug.heat[hook][2] or 0
			local callbacks = #hooks.list[hook]

			if (count <= 0 and callbacks > 0) then
				table.insert(t, w(1))
				table.insert(t, string.format("[%s]:%s - %s\n", count, callbacks, hook))
				displayCount = displayCount+1
			end
		end
		table.insert(t, w(1))
		table.insert(t, "* Not fired, and has no callbacks:\n")

		-- Not fired, and has no callbacks registered.
		for _, hook in ipairs(h) do
			if (displayCount >= LIMIT) then
				table.insert(t, w(0.8))
				table.insert(t, "(...)\n")
				break
			end

			local count = hooks.debug.heat[hook] and hooks.debug.heat[hook][2] or 0
			local callbacks = #hooks.list[hook]

			if (count <= 0 and callbacks == 0) then
				table.insert(t, w(0.8))
				table.insert(t, string.format("[%s]:%s - %s\n", count, callbacks, hook))
				displayCount = displayCount+1
			end
		end
		table.insert(t, "\n")

		love.graphics.print(t, ScreenX() - 312, 32, 0, 1, 1)
	end)
end

hooks.Add("OnEngineUpdate", function (dt)
	if (CurTime() - hooks.debug.lastClean) > hooks.debug.clearTime then
		hooks.debug.heat = {}

		for hook, count in pairs(hooks.debug.calls) do
			
			local white = 0
			local yellow = 200
			local red = 400

			if (count <= white) then
				-- White
				hooks.debug.heat[hook] = {{1,1,1}, count}
			elseif(count <= yellow) then
				-- White to Yellow
				local p = math.midpercent(count, white, yellow)
				hooks.debug.heat[hook] = {{1,1,1-p}, count}
			elseif(count <= red) then
				-- Yellow to Red
				local p = math.midpercent(count, yellow, red)
				hooks.debug.heat[hook] = {{1,1-p,0}, count}
			else
				-- Red
				hooks.debug.heat[hook] = {{1,0,0}, count}
			end

		end

		hooks.debug.calls = {}
		hooks.debug.lastClean = CurTime()
	end
end)

hooks.Add("PostEngineLoad", function ()
	engine.routines.New("AnnounceDeadHooks", function ()
		while (CurTime() < 5) do
			engine.routines.yields.WaitForSeconds(1)
		end

		local hookList = hooks.GetHooks()
		for _,h in ipairs(hookList) do
			if (hooks.debug.uncalled[h] == true and not hooks.GetFlag(h, "ignoreUnused")) then 
				engine.Log(string.format("[HOOKS] WARNING: Hook [%s] has not yet been called in %s seconds. Consider removing it if it's unecessary.", h, tostring(math.floor(CurTime()))))
				coroutine.yield()
			end
		end
	end)
end)