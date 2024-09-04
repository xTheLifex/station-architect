engine = engine or {}
engine.entities = engine.entities or {}
engine.entities.registry = {}
engine.entities.lastID = 0
engine.world = engine.world or {}
engine.world.entities = engine.world.entities or {}
engine.world.lastID = 0

uuid = require("Engine.Libs.uuid")
uuid.seed()

engine.entities.base = {
	name = "",
	id = "",
	x = 0,
	y = 0,
	dir = Vector(0,0),
	type = "",
	collider = {}
}

-- -------------------------------------------------------------------------- --
--                          Entity Creation Function                          --
-- -------------------------------------------------------------------------- --

engine.entities.Create = function(name, data, forceID) 
	if (not IsValid(name)) then
		engine.Log("[Entities] tried to create empty entity. Rejecting.")
		return
	end
	
	if (engine.entities.registry[name] == nil) then
		engine.Log("[Entities] attempt to create unknown entity type '" .. name .. "'.")
		return
	end

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
	
	-- TODO: Move alot of those verifications and hardcodes to the entity registration, keep out of the entity creation

	local template = engine.entities.registry[name]

	local x = isnumber(data["x"]) and data["x"] or 0
	local y = isnumber(data["y"]) and data["y"] or 0
	local tilepos = engine.world.grid.FromWorldPos(x,y)
	local tilex = tilepos.x
	local tiley = tilepos.y
	local targetname = data["targetname"] or data["name"] or "*"
	local ent = deepCopyWithInheritance(template)
	local collider = data["collider"] or {
		type = "circle",
		radius = 16
	}
	local dir = data["dir"] or Vector(0,0)
	local id = forceID or uuid.new()
	if (forceID ~= nil) then
		while (engine.world.entities[id] ~= nil) do
			uuid.seed()
			id = uuid.new()
		end
	end

	for k,v in pairs(data) do
		ent[k] = v
	end	
	
	ent.x = x or 0
	ent.y = y or 0
	ent.tilex = tilex
	ent.tiley = tiley
	ent.dir = dir
	ent.targetname = targetname or "*"
	ent.type = name
	ent.collider = collider
	ent.id = uuid.new()
	table.insert(engine.world.entities, ent)

	if (ent.OnCreate ~= nil and isfunction(ent.OnCreate)) then
		ent:OnCreate()
	end

	setmetatable(ent, template)
	hooks.Fire("OnEntityCreated", ent)
	return ent
end

-- -------------------------------------------------------------------------- --
--                              Entity Functions                              --
-- -------------------------------------------------------------------------- --

-- ----------------------------- Distance Checks ---------------------------- --

engine.entities.TileDistanceFromPoint = function(ent, gx, gy)
	if (gx == nil or gy == nil) then return nil end
	if (ent == nil) then return nil end

	assert(ent.tilex ~= nil, "Provided entity table does not contain position")
	assert(ent.tiley ~= nil, "Provided entity table does not contain position")

	return utils.Distance(ent.tilex, ent.tiley, gx, gy)
end

engine.entities.TileDistanceFromEntity = function(ent, other)
	if (ent == nil) then return nil end
	if (other == nil) then return nil end

	assert(ent.tilex ~= nil, "Provided entity table does not contain position")
	assert(ent.tiley ~= nil, "Provided entity table does not contain position")
	assert(other.tilex ~= nil, "Provided entity table does not contain position")
	assert(other.tiley ~= nil, "Provided entity table does not contain position")

	return utils.Distance(ent.tilex, ent.tiley, other.tilex, other.tiley)
end

engine.entities.DistanceFromPoint = function(ent, x, y)
	if (x == nil or y == nil) then return nil end
	if (ent == nil) then return nil end

	assert(ent.x ~= nil, "Provided entity table does not contain position")
	assert(ent.y ~= nil, "Provided entity table does not contain position")

	return utils.Distance(ent.x, ent.y, x, y)
end

engine.entities.DistanceFromEntity = function(ent, other)
	if (ent == nil) then return nil end
	if (other == nil) then return nil end

	assert(ent.x ~= nil, "Provided entity table does not contain position")
	assert(ent.y ~= nil, "Provided entity table does not contain position")
	assert(other.x ~= nil, "Provided entity table does not contain position")
	assert(other.y ~= nil, "Provided entity table does not contain position")

	return utils.Distance(ent.x, ent.y, other.x, other.y)
end

engine.entities.Distance = function(ent, a, b)
	-- 'a' may be a entity.
	if (type(a) == "table") then
		return engine.entities.DistanceFromEntity(ent, a);
	else
		return engine.entities.DistanceFromPoint(ent, a, b)
	end
end

engine.entities.TileDistance = function(ent, a, b)
	-- 'a' may be a entity.
	if (type(a) == "table") then
		return engine.entities.TileDistanceFromEntity(ent, a);
	else
		return engine.entities.TileDistanceFromPoint(ent, a, b)
	end
end

-- -------------------------------- Position -------------------------------- --

engine.entities.GetOnGrid = function(gx, gy)
	local results = {}
	for k, ent in ipairs(engine.world.entities) do
		if (ent.tilex == gx and ent.tiley == gy) then
			table.insert(results, ent)
		end
	end
	return results
end

engine.entities.GetOnGridRadius = function(gx, gy, radius)
	local results = {}
	for k, ent in ipairs(engine.world.entities) do
		local dist = utils.Distance(ent.tilex, ent.tiley, gx, gy)

		if (dist < radius) then
			table.insert(results, ent)
		end
	end

	return results
end

engine.entities.GetOnRadius = function(x,y, radius)
	local results = {}
	for k, ent in ipairs(engine.world.entities) do
		local dist = utils.Distance(ent.x, ent.y, x,y)

		if (dist < radius) then
			table.insert(results, ent)
		end
	end

	return results
end

-- --------------------------------- Filters -------------------------------- --

engine.entities.GetByType = function(type)
	local results = {}
	for k, ent in ipairs(engine.world.entities) do
		if (ent.type == type) then
			table.insert(results, ent)
		end
	end
	return results
end

engine.entities.GetAll = function()
	return engine.world.entities
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

-- -------------------------------------------------------------------------- --
--                               Entity Deletion                              --
-- -------------------------------------------------------------------------- --

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
	
	engine.Log(string.format("[Entities] deleted entity .. %s at [%x,%x]", id, ent.x, ent.y))
	if (ent.OnDelete ~= nil and isfunction(ent.OnDelete)) then
		ent:OnDelete()
	end
	table.remove(engine.world.entities, index)
	hooks.Fire("OnEntityDeleted", ent)
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

-- -------------------------------------------------------------------------- --
--                             Entity Registration                            --
-- -------------------------------------------------------------------------- --

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

	ent.Delete = function(ent)
		engine.entities.DeleteID(ent.id)
	end

	ent.SetPos = function(ent, x, y)
		ent.x = x
		ent.y = y
	end

	ent.GetPos = function (ent)
		return {
			ent.x,
			ent.y,
			["x"] = ent.x,
			["y"] = ent.y
		}
	end

	if (ent.collider ~= nil) then
		-- As of now, we are forcing all entities to use circle colliders.
		ent.collider.type = "circle"
		ent.collider.radius = ent.collider.radius or 16
		
		ent.bbox = ent.bbox or {}
		ent.bbox.top = Vec(-ent.collider.radius, -ent.collider.radius)
		ent.bbox.bottom = Vec(ent.collider.radius, ent.collider.radius)

		if (ent.collider.type == "circle") then
			ent.bbox = ent.bbox or {}
			ent.bbox.top = Vec(-ent.collider.radius, -ent.collider.radius)
			ent.bbox.bottom = Vec(ent.collider.radius, ent.collider.radius)
		else
			ent.bbox.top = Vec(-16, -16)
			ent.bbox.bottom = Vec(16, 16)
		end
	end

	local center = ent.center or Vec(16,16)
	center[1] = center[1] or 16
	center[2] = center[2] or 16
	center.x = center.x or center[1]
	center.y = center.y or center[2]

	ent.center = center

	engine.Log("[Entities] Registering entity " .. index .. ".") 
	engine.entities.registry[index] = ent
end


-- -------------------------------------------------------------------------- --
--                                  Save/Load                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
--                               Entity Updates                               --
-- -------------------------------------------------------------------------- --

hooks.Add("OnGameUpdate", function(deltaTime) 
	local max = {
		x = (engine.world.size[1] * engine.world.grid.tilesize) + 32,
		y = (engine.world.size[2] * engine.world.grid.tilesize) + 32
	}
	local min = {x=0, y=0}
	hooks.Fire("PreEntitiesUpdate")
	for k, ent in ipairs(engine.world.entities) do
		if (ent.OnUpdate ~= nil and isfunction(ent.OnUpdate)) then
			-- Entity update method
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
		end
	end
	hooks.Fire("PostEntitiesUpdate")
end)

-- -------------------------------------------------------------------------- --
--                         Entity Registration Loading                        --
-- -------------------------------------------------------------------------- --

hooks.Add("PostEngineLoad", function() 
	-- TODO: Make async
	engine.Log("[Entities] Loading base entity definitons...")
	
	engine.entities.Register("Engine/Entities/base", "base")
	--engine.entities.Register("Engine/Entities/wall", "wall")
	engine.entities.Register("Engine/Entities/mob", "mob")
end)

-- -------------------------------------------------------------------------- --
--                                  Debugging                                 --
-- -------------------------------------------------------------------------- --

hooks.Add("PostGameDraw", function() 
	-- Debug information
	if (engine.GetCVar("debug_entities", false) == false) then return end
	for k, ent in ipairs(engine.entities.GetAll()) do
		love.graphics.circle("fill", ent.x, ent.y, 1)
		if (ent.OnDebugDraw ~= nil and isfunc(ent.OnDebugDraw)) then
			ent:OnDebugDraw()
		else
			love.graphics.print(string.format("%s[%s]", ent.targetname, ent.id), ent.x, ent.y + 4, 0, 0.5, 0.5)
			love.graphics.print(ent.type, ent.x, ent.y + 12, 0, 0.5, 0.5)
		end
	end
end)	

