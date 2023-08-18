engine = engine or {}
engine.entities = engine.entities or {}
engine.entities.registry = {}
engine.entities.lastID = 0
engine.world = engine.world or {}
engine.world.entities = engine.world.entities or {}

engine.entities.Create = function(name, data) 
	if (not IsValid(name)) then
		engine.Log("[Entities] tried to create empty entity. Rejecting.")
		return
	end
	
	if (engine.entities.registry[name] == nil) then
		engine.Log("[Entities] attempt to create unknown entity type '" .. name .. "'.")
		return
	end
	
	local template = engine.entities.registry[name]

	
	local x = isnumber(data["x"]) and data["x"] or 0
	local y = isnumber(data["y"]) and data["y"] or 0
	local targetname = data["targetname"] or data["name"] or "*"
	local id = #engine.entities.registry + 1
	local ent = table.deepcopy(template)
	
	for k,v in pairs(data) do
		ent[k] = v
	end	
	
	ent.x = x or 0
	ent.y = y or 0
	ent.targetname = targetname or "*"
	engine.entities.lastID = engine.entities.lastID + 1
	ent.id = engine.entities.lastID
	
	table.insert(engine.world.entities, ent)
	
	if (ent.OnCreate ~= nil and isfunction(ent.OnCreate)) then
		ent:OnCreate()
	end
	
	return ent
end

engine.entities.GetByTargetname = function(targetname) 
	local results = {}
	for _,ent in ipairs(engine.world.entities) do
		if (ent.targetname == targetname) then
			table.insert(results, ent)
		end
	end
	
	return results
end

engine.entities.GetByID = function(id)
	for k, ent in ipairs(engine.world.entities) do
		if (ent.id == id) then
			return ent, k
		end
	end
	return nil
end

engine.entities.DeleteTarget = function(targetname)
	local ents = engine.entities.GetByTargetname(targetname)
	
	if (ents ~= {}) then
		for _,ent in ipairs(ents) do
			return engine.entities.DeleteID(ent.id)
		end
	end
	return false
end

engine.entities.DeleteID = function(id)
	local ent, index = engine.entities.GetByID(id)
	if (ent == nil) then return false end -- Deleting nil?
	
	if (ent.OnDelete ~= nil and isfunction(ent.OnDelete)) then
		ent:OnDelete()
	end

	engine.Log(string.format("[Entities] deleted entity .. %x at [%x,%x]", id, ent.x, ent.y))
	if (ent.OnDelete ~= nil and isfunction(ent.OnDelete)) then
		ent:OnDelete()
	end
	table.remove(engine.world.entities, index)
	return true
end


engine.entities.Delete = function(id) 
	if (not engine.entities.DeleteTarget(id)) then
		if not (engine.entities.DeleteID(id)) then
			engine.Log("[Entities] failed to delete entity by identifier '" .. id .. "'.")
			return false
		end
	end
	return true
end

engine.entities.Register = function(path, index) 
	local ent = engine.Include(path)
	
	if (type(ent) ~= "table") then
		engine.Log("[Entities] Attempt to register entity has failed: " .. path)
		return
	end
	
	local index = index or ent.index
	if (index == nil) then
		engine.Log("[Entities] Attempt to register un-indexed entity: " .. path)
	end
	
	ent.DrawSelf = ent.DrawSelf or function(ent) 
		if (ent.sprite ~= nil) then
			love.graphics.draw(ent.sprite, ent.x, ent.y)
		end
	end
	
	engine.Log("[Entities] Registering entity" .. index .. ".") 
	engine.entities.registry[index] = ent
end

hooks.Add("PostEngineLoad", function() 
	engine.Log("[Entities] Module init. Loading entity definitons...")
	
	engine.entities.Register("Engine/entities/base", "base")
end)

hooks.Add("OnGameUpdate", function(deltaTime) 
	for k, ent in ipairs(engine.world.entities) do
		if (ent.OnUpdate ~= nil and isfunction(ent.OnUpdate)) then
			ent:OnUpdate(deltaTime)
		end
	end
end)

hooks.Add("OnGameDraw", function() 
	for k, ent in ipairs(engine.world.entities) do
		if (ent.OnDraw ~= nil and isfunction(ent.OnDraw)) then
			ent:OnDraw()
			love.graphics.setColor(1,1,1) -- Clear render color if changed.
		end
	end
end)