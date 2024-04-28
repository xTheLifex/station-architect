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
end)