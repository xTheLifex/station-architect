engine = engine or {}
engine.rendering = engine.rendering or {}
engine.rendering.CameraModule = require("Engine/Libs/camera")
engine.rendering.camera = engine.rendering.CameraModule(0,0)

local BASE_SPEED = 15
local MAX_ZOOM = 2
local MIN_ZOOM = 0.5

engine.rendering.missingtexture = love.graphics.newImage("Engine/Resources/missing.png")

engine.rendering.GetZoom = function() 
	return engine.rendering.camera.scale or 1
end

engine.rendering.CameraPos = function ()
	local x,y = engine.rendering.camera:position()
	return {
		[1] = x,
		[2] = y,
		["x"] = x,
		["y"] = y
	}
end

engine.rendering.GetCameraSpeed = function()
	local zoom = engine.rendering.GetZoom()
	local speed = BASE_SPEED / zoom
	speed = utils.clamp(speed, 5, 20)
	return speed
end

function engine.rendering.DrawMissingTexture(x,y)
	love.graphics.draw(engine.rendering.missingtexture, x,y)
end

function engine.rendering.DrawSprite(index, frame, dir, x, y)
	local dir = dir or 1
	dir = utils.DirFormat(utils.DirInt(dir))
	local frame = frame or 0
	
	if (engine.assets.graphics[index] == nil) then engine.rendering.DrawMissingTexture(x,y) return end
	local data = engine.assets.graphics[index]

	if (data["directionaltype"] == engine.assets.SpriteDirectionType.FIXED) then
		dir = 1
	end
	-- TODO: Translate for simple direction sprites.

	local frames = data["frames"]
	if not frames then engine.rendering.DrawMissingTexture(x,y) return end

	local img = frames[frame][dir]
	if not img then engine.rendering.DrawMissingTexture(x,y) return end

	love.graphics.draw(img, x,y)
end

hooks.Add("OnSetupCVars", function()
    engine.AddCVar("debug_rendering", false, "Enable/Disable debugging information about Rendering.")
end)

hooks.Add("OnCameraAttach", function()
	engine.rendering.camera:attach()
end)

hooks.Add("OnCameraDetach", function()
	engine.rendering.camera:detach()
end)

hooks.Add("OnMouseWheelUp", function(y)
	local zoom = engine.rendering.GetZoom()
	if (zoom >= MAX_ZOOM) then return end
	engine.rendering.camera:zoom(1.05)
end)

hooks.Add("OnMouseWheelDown", function(y)
	local zoom = engine.rendering.GetZoom()
	if (zoom <= MIN_ZOOM) then return end
	engine.rendering.camera:zoom(0.95)
end)



hooks.Add("OnGameUpdate", function(deltaTime) 

	local zoom = engine.rendering.GetZoom()
	local speed = engine.rendering.GetCameraSpeed()
	speed = utils.clamp(speed, 5, 20)

	if (love.keyboard.isScancodeDown("a")) then
		engine.rendering.camera:move(-speed,0)
	elseif (love.keyboard.isScancodeDown("d")) then
		engine.rendering.camera:move(speed,0)
	end
	
	if (love.keyboard.isScancodeDown("w")) then
		engine.rendering.camera:move(0,-speed)
	elseif (love.keyboard.isScancodeDown("s")) then
		engine.rendering.camera:move(0,speed)
	end
	
end)


hooks.Add("OnGameDraw", function ()
	-- Draw game world.
	local min = utils.CamToWorld(0,0)
	min.x = min.x - engine.world.grid.tilesize
	min.y = min.y - engine.world.grid.tilesize
	local max = utils.CamToWorld(ScreenX(), ScreenY())

	local gmin = engine.world.grid.FromWorldPos(min.x, min.y)
	local gmax = engine.world.grid.FromWorldPos(max.x, max.y)


	hooks.Fire("PreDrawWorld")
	for x=gmin.x+1, gmax.x do 
		for y=gmin.y+1, gmax.y do
			local tile = engine.world.tiles[x] and engine.world.tiles[x][y] or nil
			if (IsValid(tile)) then
				engine.rendering.DrawSprite(tile, 0, 1,x * engine.world.grid.tilesize,y * engine.world.grid.tilesize)
			end
		end
	end

	hooks.Fire("PreDrawEntities")

	-- Draw entities with their layer.
	for i=0,3 do -- 3 layers for now.
		for k, ent in ipairs(engine.world.entities) do
			local layer = ent.layer or 1
			if (ent.x > min.x and ent.x < max.x and ent.y > min.y and ent.y < max.y) then
				if (ent.OnDraw ~= nil and isfunction(ent.OnDraw) and layer == i) then
					ent:OnDraw()
					love.graphics.setColor(1,1,1) -- Clear render color if changed.
				end
			end
		end
	end
end)


hooks.Add("OnInterfaceDraw", function()
	if (engine.GetCVar("debug_rendering", false) == false) then return end
	local zoom = engine.rendering.GetZoom()
	local speed = engine.rendering.GetCameraSpeed()
	love.graphics.print("Camera Zoom :" .. zoom .. ", Camera Speed: " .. speed, 32, 512, 0, 1, 1)
end)
