engine = engine or {}
engine.assets = engine.assets or {}

engine.assets.graphics = {}
engine.assets.sounds = {}

engine.assets.SpriteDirectionType = {
    FIXED = 0,
    SIMPLE = 1,
    FULL = 2
}

engine.assets.overrides = {}

-- Load overrides
do
    if (file.exists("Game/Assets/Textures/overrides.lua")) then
        local o = require("Game.Assets.Textures.overrides")
        if (type(o) == "table") then
            engine.assets.overrides = o
        end
    end
end

function engine.assets.GetSpriteOverrides(containingDir, assetName, index)
    local index = index or utils.RemoveExtension(assetName)
    local base = engine.assets.overrides[index] or engine.assets.overrides[assetName] or false
    
    local attempts = {
        [1] = containingDir .. "overrides.lua",
        [2] = containingDir .. index .. ".lua",
        [3] = containingDir .. string.replace(index, ".png", "") .. ".lua",
        [4] = containingDir .. assetName .. ".lua",
        [5] = containingDir .. string.replace(assetName, ".png", "") .. ".lua",
    }

    for _, str in ipairs(attempts) do
        if (love.filesystem.getInfo(str, "file") ~= nil) then
            local fo = require(str)
            if (istable(fo)) then
                return table.pasteOver(base, fo)
            end
        end
    end

    return base
end

-- TODO: Create one unified class for assets, and make functions to return sprites for the renderer module to use

-- Returns a direction table for a single frame. Internal engine usage.
engine.assets.DirTable = function (n,ne,e,se,s,sw,w,nw)
    return {
        [1] = n,
        [2] = ne,
        [3] = e,
        [4] = se,
        [5] = s,
        [6] = sw,
        [7] = w,
        [8] = nw,
        ["N"] = n,
        ["NE"] = ne,
        ["E"] = e,
        ["SE"] = se,
        ["S"] = s,
        ["SW"] = sw,
        ["W"] = w,
        ["NW"] = nw
    }
end

-- Returns a direction table for a single frame. Internal engine usage.
engine.assets.DirTableFour = function ( north, south, east, west)
    return engine.assets.DirTable(
        north,
        nil,
        east,
        nil,
        south,
        nil,
        west,
        nil
    ) -- This is arbitrary for no reason.
end

-- Imports a game icon texture
engine.assets.ImportGraphics = function (containingDir, assetName, index)
    local assetPath = containingDir .. assetName
    local index = index or utils.RemoveExtension(assetName)

    -- ----------------------- Simple 1 file sprite, 1 dir ---------------------- --
    local info = love.filesystem.getInfo(assetPath)
    if (info.type == "file") then
        -- It's a single file. Just import it easily.
        local asset = {}
        local img = love.graphics.newImage(assetPath)
        
        asset["dir"] = containingDir
        asset["path"] = assetPath
        asset["index"] = index
        asset["frames"] = {
            [1] = engine.assets.DirTable(img)
        }
        asset["directionaltype"] = engine.assets.SpriteDirectionType.FIXED

        asset["fps"] = 24
        -- Get overrides
        local o = engine.assets.GetSpriteOverrides(containingDir, assetName, index)
        -- Apply overrides
        if (o ~= false) then
            if o["fps"] and isnumber(o["fps"]) then
                asset["fps"] = o["fps"]
            end
        end
        engine.assets.graphics[index] = asset
        return asset
    elseif (info.type == "directory") then
        -- It's a directory.
        -- ---------------------- Simple 1 Dir Animated Sprites --------------------- --
        local one  = file.exists(assetPath .. "/" .. index .. "1.png")
        local zero = file.exists(assetPath .. "/" .. index .. "0.png")

        if (one or zero) then
            -- Directory contains a simple animated sprite format.
            local asset = {}
            asset["dir"] = containingDir
            asset["path"] = assetPath
            asset["index"] = index
            asset["frames"] = {}
            asset["directionaltype"] = engine.assets.SpriteDirectionType.FIXED

            local i = 0
            if (one and not zero) then i = 1 end
            local path = assetPath .. "/" .. index .. i .. ".png"
            while(file.exists(path)) do
                -- Import frame
                local img = love.graphics.newImage(path)
                asset["frames"][i] = engine.assets.DirTable(img)

                i = i + 1
                path = assetPath .. "/" .. index .. i .. ".png"
            end

            asset["fps"] = 24
            -- Get overrides
            local o = engine.assets.GetSpriteOverrides(containingDir, assetName, index)
            -- Apply overrides
            if (o ~= false) then
                if o["fps"] and isnumber(o["fps"]) then
                    asset["fps"] = o["fps"]
                end
            end

            engine.assets.graphics[index] = asset
            return asset

        end

        -- ----------------- Any amount of frames and all directions ---------------- --
        local assetContents = love.filesystem.getDirectoryItems(assetPath)
        
        -- Check for simple animated sprite content
        for _,content in ipairs(assetContents) do
            
        end
    else
        -- It's some other type of bullshit we're not dealing with
        engine.Log("[Assets] Error: Invalid file path or type: " .. assetPath)
        return false
    end
end

hooks.Add("OnGameLoad", function()
    engine.Log("[Assets] Importing Graphics...")

	local sp = "Game/Assets/Textures/Simple/"
	local sd1 = love.filesystem.getDirectoryItems(sp .. "1D") -- Files
	local sd4 = love.filesystem.getDirectoryItems(sp .. "4D") -- Folders
	local sd8 = love.filesystem.getDirectoryItems(sp .. "8D") -- Folders
	local sdw = love.filesystem.getDirectoryItems(sp .. "WALL") -- Folders
	local ap = "Game/Assets/Textures/Animated/"
	local ad1 = love.filesystem.getDirectoryItems(ap .. "1D") -- Folders
	local ad4 = love.filesystem.getDirectoryItems(ap .. "4D") -- Folders
	local ad8 = love.filesystem.getDirectoryItems(ap .. "8D") -- Folders

	for _, asset in ipairs(sd1) do
		local info = love.filesystem.getInfo(sp .. "1D/" .. asset)
		if (info.type == "file") then
			engine.assets.ImportGraphics(sp .. "1D/", asset)
		end
	end

    -- for _, asset in ipairs(sd4) do
	-- 	local info = love.filesystem.getInfo(sp .. "4D/" .. asset)
	-- 	if (info.type == "file") then
	-- 		engine.assets.ImportGraphics(sp .. "4D/", asset)
	-- 	end
	-- end

    -- for _, asset in ipairs(sd8) do
	-- 	local info = love.filesystem.getInfo(sp .. "8D/" .. asset)
	-- 	if (info.type == "file") then
	-- 		engine.assets.ImportGraphics(sp .. "8D/", asset)
	-- 	end
	-- end

    for _, asset in ipairs(ad1) do
		local info = love.filesystem.getInfo(ap .. "1D/" .. asset)
		if (info.type == "directory") then
			engine.assets.ImportGraphics(ap .. "1D/", asset)
		end
	end

    local i = 0
    for k,v in pairs(engine.assets.graphics) do
        i = i + 1
    end

    engine.Log("[Assets] Imported " .. i .. " graphics." )
end)