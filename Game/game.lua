game = game or {}

hooks.Add("OnGameLoad", function() 
	engine.Log("Game Loading!")
	
	local tilesize=32
	for x=0,engine.world.size[1] do
		for y=0,engine.world.size[2] do
			--local sprite = sprites[love.math.random(1, #sprites)]
			--engine.entities.Create("tile", {x=ex, y=ey, sprite=sprite})
			-- TODO: Tile system and not just images with no behaviour?
			engine.world.SetTile(x,y, "asteroid")
		end
	end
end)

hooks.Add("OnKeyPressed", function (key, scancode, isrepeat)
	if (scancode == "q") then
		-- Spawn
		local pos = engine.world.grid.ToWorldPos(math.random(1,5), math.random(1,5))
		engine.entities.Create("mob", {x = pos.x, y = pos.y})
	elseif(scancode == "e") then
		-- Delete
		local mobs = engine.entities.GetByType("mob")
		local mob = pick(mobs)
		if (mob)  then
			engine.entities.DeleteID(mob.id)
		end
	end
end)