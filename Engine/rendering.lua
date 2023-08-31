engine = engine or {}
engine.rendering = engine.rendering or {}
engine.rendering.CameraModule = require("Engine/Libs/camera")
engine.rendering.camera = engine.rendering.CameraModule(0,0)

local BASE_SPEED = 15
local MAX_ZOOM = 2
local MIN_ZOOM = 0.5

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


hooks.Add("OnSetupCVars", function()
    engine.AddCVar("debug_rendering", false, "Enable/Disable debugging information about Rendering.")
end)

hooks.Add("PreGameDraw", function()
	engine.rendering.camera:attach()
end)

hooks.Add("PostGameDraw", function()
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
	min.x = min.x-32
	min.y = min.y-32 
	local max = utils.CamToWorld(ScreenX(), ScreenY())

	local gmin = engine.world.grid.FromWorldPos(min.x, min.y)
	local gmax = engine.world.grid.FromWorldPos(max.x, max.y)


	for x=gmin.x+1, gmax.x do 
		for y=gmin.y+1, gmax.y do
			local tile = engine.world.tiles[x] and engine.world.tiles[x][y] or nil
			if (IsValid(tile)) then
				love.graphics.draw(tile, x * engine.world.grid.tilesize, y * engine.world.grid.tilesize)
			end
		end
	end

	-- Draw entities with their layer.
	for i=0,3 do -- 3 layers for now.
		for k, ent in ipairs(engine.world.entities) do
			local layer = ent.layer or 1
			
			if (ent.OnDraw ~= nil and isfunction(ent.OnDraw) and layer == i) then
				ent:OnDraw()
				love.graphics.setColor(1,1,1) -- Clear render color if changed.
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
