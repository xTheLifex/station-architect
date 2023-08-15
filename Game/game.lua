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
			local asteroid = {}
			if (love.math.random(0,1) == 1) then
				asteroid.sprite = engine.assets.graphics.Simple["plating"]["img"]
			else
				asteroid.sprite = sprites[love.math.random(1, #sprites)]
			end
			
			asteroid.x = x * tilesize
			asteroid.y = y * tilesize
			table.insert(game.asteroids, asteroid)
		end
	end
	game.Log("Asteroids Init!")
end)

hooks.Add("OnGameDraw", function ()	
	for _, asteroid in ipairs(game.asteroids) do
		love.graphics.draw(asteroid.sprite, asteroid.x, asteroid.y)
	end
end)