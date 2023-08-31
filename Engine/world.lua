engine = engine or {}
engine.world = engine.world or {}
engine.world.entities = engine.world.entities or {}
engine.world.tiles = {}
engine.world.grid = {}
engine.world.grid.tilesize = 32
engine.world.size = {128, 128}

for x=0, engine.world.size[1] do
	for y=0, engine.world.size[2] do
		engine.world.tiles[x] = engine.world.tiles[x] or {}
		engine.world.tiles[x][y] = engine.world.tiles[x][y] or {}
		engine.world.tiles[x][y] = {} -- TODO: Replace with space tile
	end
end

engine.world.grid.FromWorldPos = function(x,y)
	local gx = math.floor(x / engine.world.grid.tilesize)
	local gy = math.floor(y / engine.world.grid.tilesize)
	return {
		["x"] = gx,
		["y"] = gy,
		[1] = gx,
		[2] = gy
	}
end

engine.world.grid.ToWorldPos = function(gx, gy)
	local x = gx * engine.world.grid.tilesize
	local y = gy * engine.world.grid.tilesize
	
	return {
		["x"] = x,
		["y"] = y,
		[1] = x,
		[2] = y
	}
end

engine.world.grid.SnapPos = function(x, y)
	local gpos = engine.world.grid.FromWorldPos(x,y)
	return engine.world.grid.ToWorldPos(gpos.x, gpos.y)
end

engine.world.IsWithinBoundaries = function(x,y) 
	if (x > engine.world.size[1]) then return false end
	if (x < 0) then return false end
	if (y > engine.world.size[2]) then return false end
	if (y < 0) then return false end
	return true
end

engine.world.SetTile = function (x,y, tile)
	if (not engine.world.IsWithinBoundaries(x,y)) then
		engine.Log("[World] Attempted to set tile outside of bounds at (" .. x .. "," .. y .. ")")
		return
	end
	engine.world.tiles[x][y] = tile
end

hooks.Add("PostGameDraw", function() 
	-- Debug information
	if (engine.GetCVar("debug_rendering", false) == false) then return end
	local pos = CamToWorld(MouseX(), MouseY())
	local gridpos = engine.world.grid.FromWorldPos(pos.x, pos.y)
	local gridworldpos =  engine.world.grid.SnapPos(pos.x, pos.y)
	if (not engine.world.IsWithinBoundaries(gridpos.x,gridpos.y)) then return end
	love.graphics.rectangle("line", gridworldpos.x, gridworldpos.y, engine.world.grid.tilesize, engine.world.grid.tilesize)
	love.graphics.print("X: " .. gridworldpos.x .. " Y: " .. gridworldpos.y, gridworldpos.x + 24, gridworldpos.y + 24)

	love.graphics.print("X: " .. gridpos.x .. " Y: " .. gridpos.y, gridworldpos.x + 24, gridworldpos.y + 4)
end)