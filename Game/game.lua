game = game or {}
game.Log = function(text) 
	engine.Log("[GAME] " .. text)
end

hooks.Add("OnGameLoad", function() 
	game.Log("Game Loading!")
	local sprites = {}

	
	game.asteroids = {}
	local tilesize=32
	for x=0,engine.world.size[1] do
		for y=0,engine.world.size[2] do
			--local sprite = sprites[love.math.random(1, #sprites)]
			--engine.entities.Create("tile", {x=ex, y=ey, sprite=sprite})
			-- TODO: Tile system and not just images with no behaviour?
			engine.world.SetTile(x,y, "asteroid")
		end
	end

	for i=5,20 do
		engine.entities.Create("mob", {
			x = 8 + i * math.random(0,8),
			y = 8 + i * math.random(0,8)
		})
	end
	
end)

hooks.Add("OnGameDraw", function ()	
	for _,ent in pairs(engine.entities.GetByType("mob")) do
		if (ent.static == false) then
			love.graphics.setColor(1,0,1,0.25)
			love.graphics.circle("line", ent.x, ent.y, 80)

			love.graphics.setColor(0,1,1)
			local t = engine.entities.GetByID(ent.target)
			if t then love.graphics.line(ent.x, ent.y, t.x, t.y) end
			love.graphics.setColor(1,1,1)
		end
	end
end)