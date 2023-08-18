game = game or {}
game.Log = function(text) 
	engine.Log("[GAME] " .. text)
end

hooks.Add("OnGameLoad", function() 
	game.Log("Game Loading!")
	local sprites = {}
	for i=0, 12 do
		local asset = engine.assets.graphics.Simple["asteroid" .. i]
		table.insert(sprites, asset["img"])
	end
	
	game.asteroids = {}
	local tilesize=32
	for x=0,48 do
		for y=0,32 do
			local sprite
			if (love.math.random(0,1) == 1) then
				sprite = engine.assets.graphics.Simple["plating"]["img"]
			else
				sprite = sprites[love.math.random(1, #sprites)]
			end
			
			local ex = x * tilesize
			local ey = y * tilesize
			engine.entities.Create("base", {x=ex, y=ey, sprite=sprite})
		end
	end
	game.Log("Asteroids Init!")
end)

hooks.Add("OnGameDraw", function ()	
	
end)