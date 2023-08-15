engine = engine or {}
engine.assets = engine.assets or {}

engine.assets.graphics = {}
engine.assets.sounds = {}


engine.assets.graphics.Simple = {}
engine.assets.graphics.Animated = {}
engine.assets.graphics.General = {}

--  This function will import simple, non-animated images.
engine.assets.ImportGraphics = function (graphicType, imgType, dir, file, index)
    local t = string.lower(graphicType)
	local imt = string.lower(imgType)
	local cleanname = utils.RemoveExtension(file)
    local index = index or cleanname
	
	
	-- Simple image
	if (t == "simple") then
		
		if (imt == "1d") then
			-- 1D
			local asset = {}
			local img = love.graphics.newImage(dir .. "/" .. file)
			asset["dir"] = dir
			asset["path"] = dir .. "/" .. file
			asset["file"] = file
			asset["type"] = t
			asset["graphictype"] = t
			asset["imgtype"] = imt
			asset["imgt"] = imt
			asset["imt"] = imt
			asset["img"] = img
			asset["index"] = index
			engine.assets.graphics.Simple[index] = asset
			return asset
		end
		
		if (imt == "4d") then
			-- 4D
			return
		end
		
		if (imt == "8d") then
			-- 8D
			return
		end
		
		if (imt == "16d") then
			-- 16D
		end
		
		if (imt == "wall") then
			-- Wall
		end
		
		return
	end
	
	-- Animated Image
	if (t == "animated") then
		if (imt == "1d") then
			-- 1D
			return
		end
		
		if (imt == "4d") then
			-- 4D
			return
		end
		
		if (imt == "8d") then
			-- 8D
			return
		end
	
		return
	end
	
	-- General Graphics Image
	return
end

hooks.Add("OnGameLoad", function() 
	engine.Log("[Assets] Starting graphical asset import")
	local imported = 0
	
	-- Simple
	local sp = "Game/Assets/Textures/Simple/"
	local sd1 = love.filesystem.getDirectoryItems(sp .. "1D") -- Files
	local sd4 = love.filesystem.getDirectoryItems(sp .. "4D") -- Folders
	local sd8 = love.filesystem.getDirectoryItems(sp .. "8D") -- Folders
	local sd16 = love.filesystem.getDirectoryItems(sp .. "16D") -- Folders
	local sdw = love.filesystem.getDirectoryItems(sp .. "WALL") -- Folders
	
	for _, file in ipairs(sd1) do
		local info = love.filesystem.getInfo(sp .. "1D/" .. file)
		if (info.type == "file") then
			engine.assets.ImportGraphics("Simple", "1D", sp .. "1D", file)
			imported = imported+1
		end
	end
	
	
	-- Animated
	local ap = "Game/Assets/Textures/Animated/"
	local ad1 = love.filesystem.getDirectoryItems(ap .. "1D") -- Folders
	local ad4 = love.filesystem.getDirectoryItems(ap .. "4D") -- Folders
	local ad8 = love.filesystem.getDirectoryItems(ap .. "8D") -- Folders
	
	engine.Log("[Assets] Finished asset import of " .. imported .. " graphical assets.")
	
end)
