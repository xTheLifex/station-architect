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

	local superList = {}
	local function deepCopyWithInheritance(template)
        local copy = {}
        local baseName = template.base

        -- Recursively copy base entity if there is one
        if baseName and engine.entities.registry[baseName] then
            local baseCopy = deepCopyWithInheritance(engine.entities.registry[baseName])
            for k, v in pairs(baseCopy) do
                copy[k] = v
            end
			copy.super = baseCopy
        end

        -- Copy the current entity's properties
        for k, v in pairs(template) do
            copy[k] = v
        end

        return copy
    end
	
	local template = engine.entities.registry[name]
	
	local x = isnumber(data["x"]) and data["x"] or 0
	local y = isnumber(data["y"]) and data["y"] or 0
	local tilepos = engine.world.grid.FromWorldPos(x,y)
	local tilex = tilepos.x
	local tiley = tilepos.y
	local targetname = data["targetname"] or data["name"] or "*"
	local id = #engine.entities.registry + 1
	local ent = deepCopyWithInheritance(template)
	
	for k,v in pairs(data) do
		ent[k] = v
	end	
	
	ent.x = x or 0
	ent.y = y or 0
	ent.tilex = tilex
	ent.tiley = tiley
	ent.gridx = tilex
	ent.gridy = tiley
	ent.targetname = targetname or "*"
	engine.entities.lastID = engine.entities.lastID + 1
	ent.id = engine.entities.lastID
	
	table.insert(engine.world.entities, ent)
	
	if (ent.OnCreate ~= nil and isfunction(ent.OnCreate)) then
		ent:OnCreate()
	end
	
	return ent
end

engine.entities.GetOnGrid = function(gx, gy)
	local results = {}
	for k, ent in ipairs(engine.world.entities) do
		if (ent.tilex == gx and ent.tiley == gy) then
			table.insert(results, ent)
		end
	end
	return results
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
		return
	end
	
	ent.DrawSelf = ent.DrawSelf or function(ent) 
		if (ent.sprite ~= nil) then
			if (type(ent.sprite) == "string") then
				local asset = engine.assets.graphics.Simple[ent.sprite]["img"]
				if (asset) then
					love.graphics.draw(asset, ent.x, ent.y)
				end
			else
				love.graphics.draw(ent.sprite, ent.x, ent.y)
			end
		end
	end
	
	engine.Log("[Entities] Registering entity " .. index .. ".") 
	engine.entities.registry[index] = ent
end

hooks.Add("OnGameUpdate", function(deltaTime) 
	local max = {
		x = engine.world.size[1] * engine.world.grid.tilesize,
		y = engine.world.size[2] * engine.world.grid.tilesize
	}
	local min = {x=0, y=0}
	for k, ent in ipairs(engine.world.entities) do
		if (ent.OnUpdate ~= nil and isfunction(ent.OnUpdate)) then
			ent:OnUpdate(deltaTime)
			-- Validate position
			if (ent.x > max.x) then ent.x = max.x end
			if (ent.x < min.x) then ent.x = min.x end
			if (ent.y > max.y) then ent.y = max.y end
			if (ent.y < min.y) then ent.y = min.y end
			-- Update tile position values
			local tilepos = engine.world.grid.FromWorldPos(ent.x, ent.y)
			ent.tilex = tilepos.x
			ent.tiley = tilepos.y
			ent.gridx = tilepos.x
			ent.gridy = tilepos.y
		end
	end
end)

hooks.Add("PostEngineLoad", function() 
	engine.Log("[Entities] Module init. Loading entity definitons...")
	
	engine.entities.Register("Engine/entities/base", "base")
	engine.entities.Register("Engine/entities/wall", "wall")
	engine.entities.Register("Engine/entities/mob", "mob")
end)