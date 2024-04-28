-- The main engine reference 
engine = {}
serialize = serialize or require("Engine.Libs.ser")
engine.quitReady = false
engine.libs = engine.libs or {}
love.filesystem.setIdentity("RexEngine")
engine.loading = false -- If the engine is currently doing loading process.

local intro = false

function love.load()
	-- ---------------------------------- Utils --------------------------------- --
	require("Engine/utils")
	
	-- --------------------------------- Modules -------------------------------- --
	require("Engine/logging")
	engine.Log("[Core] " .. os.date("Logging started for: %d/%m/%y"))
	require("Engine/hooks")
	engine.Log("[Core] " .. "Loaded hook module.")
	require("Engine/cvars")
	engine.Log("[Core] " .. "Loaded cvar module.")
	require("Engine/time")
	engine.Log("[Core] " .. "Loaded time module.")
	require("Engine/files")
	engine.Log("[Core] " .. "Loaded file module.")
	require("Engine/routines")
	engine.Log("[Core] " .. "Loaded routines module.")

	-- ! DISABLED ! --
	-- The live-updating is cool, but it isn't perfect, and it might create a multitude of issues
	-- that i'm not willing to fix, or maintain.
	-- It will be disabled until further notice.
	--require("Engine/refresh")
	--engine.Log("[Core] " .. "Loaded lua dynamic refresh module.")

	require("Engine/assets")
	engine.Log("[Core] " .. "Loaded assets module.")
	require("Engine/entities")
	engine.Log("[Core] " .. "Loaded entities module.")
	require("Engine/world")
	engine.Log("[Core] " .. "Loaded world module.")
	require("Engine/rendering")
	engine.Log("[Core] " .. "Loaded rendering module.")
	--require("Engine/physics")
	--engine.Log("[Core] " .. "Loaded physics module.")
	
	require("Engine/interface")
	engine.Log("[Core] " .. "Loaded interface module.")

	if (intro) then
		require("Engine/Intro/intro")
		engine.Log("[Core] " .. "Loaded intro module.")
	end

	--engine.libs.loveframes = require("Engine.Libs.loveframes")
	--loveframes = engine.libs.loveframes
	--engine.Log("[Core] " .. "Loaded external libraries.")

	engine.Log("[Core] " .. "Finished loading engine modules.")
	
	--love.math.setRandomSeed( CurTime() )
	math.randomseed( CurTime() )
	
---@diagnostic disable-next-line: param-type-mismatch
	engine.Log("[Core] " .. "Applied seed to random generator: " .. os.time(os.date("!*t")))
	-- ---------------------------------- Setup --------------------------------- --
	engine.Log("[Core] " .. "Setting up CVars...")
	hooks.Fire("OnSetupCVars")

	-- Engine CVars.
	engine.AddCVar("debug_engine", false, "Enable misc. debug information regarding the engine, that wouldn't fit anywhere else.", "f5")

	hooks.Fire("PostSetupCVars")

	-- ------------------------------ Game Loading ------------------------------ --
	-- This was made async for loading screens.
	engine.loading = true
	engine.routines.New("EngineLoad", function ()
		engine.Log("[Core] " .. "Engine loaded!")
		hooks.Fire("PostEngineLoad")
		engine.quitReady = true
	
		if (engine.GetCVar("debug_cvars", false)) then
			engine.PrintCVars()
		end
	
		if (not intro) then
			engine.Log("[Core] " .. "Loading game...")
			hooks.Fire("PreGameLoad")
			require("Game/game")
			hooks.Fire("OnGameLoad")
			hooks.Fire("PostGameLoad")
		end

		engine.loading = false
	end)
	-- -------------------------------------------------------------------------- --
end

function love.keypressed(key, scancode, isrepeat)
	hooks.Fire("OnKeyPressed", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
	hooks.Fire("OnKeyReleased", key, scancode, isrepeat)	
end

function love.textinput(text)
	hooks.Fire("OnTextInput", text)
end

function love.mousepressed(x, y, button)
	hooks.Fire("OnMousePress", x, y, button)
end

function love.mousereleased(x, y, button)
	hooks.Fire("OnMouseRelease", x, y, button)
end

function love.update(deltaTime)
	if engine.loading == true then hooks.Fire("EngineLoadingScreenUpdate") end

	hooks.Fire("PreEngineUpdate", deltaTime)
	hooks.Fire("OnEngineUpdate", deltaTime)
	hooks.Fire("PostEngineUpdate", deltaTime)
	
	hooks.Fire("PreGameUpdate", deltaTime)
	hooks.Fire("OnGameUpdate", deltaTime)
	hooks.Fire("PostGameUpdate", deltaTime)
end

function love.wheelmoved(x, y)
	hooks.Fire("OnMouseWheel", x, y)
    if y > 0 then
        -- mouse wheel moved up
		hooks.Fire("OnMouseWheelUp", y)
    elseif y < 0 then
        -- mouse wheel moved down
		hooks.Fire("OnMouseWheelDown", y)
    end
end

function love.draw()
	hooks.Fire("PreDraw")

	if engine.loading == true then hooks.Fire("EngineLoadingScreenDraw") end
	
	hooks.Fire("OnCameraAttach")
	hooks.Fire("PreGameDraw")
	hooks.Fire("OnGameDraw")
	hooks.Fire("PostGameDraw")
	hooks.Fire("OnCameraDetach")
	
	hooks.Fire("PreInterfaceDraw")
	hooks.Fire("OnInterfaceDraw")
	hooks.Fire("PostInterfaceDraw")

	hooks.Fire("PreEngineDraw")
	hooks.Fire("OnEngineDraw")
	hooks.Fire("PostEngineDraw")
	
	hooks.Fire("PostDraw")
end

function love.quit()
	if (not engine.quitReady) then
		engine.Log("[Core] " .. "An attempt was made to shutdown, but the engine isn't ready to shutdown yet. Ignoring...")
		return true
	else
		engine.Log("[Core] " .. "Preparing for shutdown...")
		hooks.Fire("OnEngineShutdown")
		engine.Log("[Core] " .. "Shutting down...")
		return false
	end
end