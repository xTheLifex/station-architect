engine = engine or {}
engine.assets = engine.assets or {}

engine.assets.graphics = {}
engine.assets.sounds = {}
engine.assets.mounts = {}

-- TODO: Code things

-- How this will work:

-- 1. Mount content from a folder.
-- 2. Import Graphics from the Textures/ folder
-- 2.1 Pass this to a function to be recursive
-- ? 2.2 If folder is "Atlas", ignore as it will be dealt specially later
-- ? Use "Tiles" as name instead? 
-- 2.3 Import all textures with relative paths.
-- Example: "Game/Textures/Human/Head.png" becomes "Human/head.png"
-- ? 2.4 Import all atlas textures and throw them on a sprite atlas.

engine.assets.GetRelativePath = function (fullPath)
    return string.match(fullPath, ".+/Assets/(.+)$")
end

engine.assets.MountFile = function (filePath)
    engine.Log("Mounting " .. filePath)
    if not file.exists(filePath) then return end
    local relativePath = engine.assets.GetRelativePath(filePath)
    local mounted = false

    local imageTypes = {
        [".jpg"] = true,
        [".jpeg"] = true,
        [".png"] = true,
        [".bmp"] = true,
        [".tga"] = true,
        [".hdr"] = true,
        [".pic"] = true,
        [".exr"] = true,
    }

    local ext = utils.GetFileExtension(filePath)
    

    if (imageTypes[ext] == true) then
        local img = love.graphics.newImage(filePath, {mipmaps=true})
        img:setMipmapFilter('nearest', 0)
        engine.assets.graphics[string.lower(relativePath)] = img
        mounted = true
    end

    if mounted then
        local mount = string.remove(filePath, relativePath)
        engine.assets.mounts[mount] = engine.assets.mounts[mount] or {}
        table.insert(engine.assets.mounts[mount], relativePath)
    end
end

engine.assets.GetTexture = function(relativePath)
    local path = string.lower(relativePath)
    return engine.assets.graphics[path] 
    or engine.assets.graphics[utils.RemoveExtension(path)] 
    or engine.assets.missingtexture
end

engine.assets.GetMountPath = function(fullPath)
    local relativePath = engine.assets.GetRelativePath(fullPath)
    for mount, items in pairs(engine.assets.mounts) do
        if (table.contains(items, relativePath)) then
            return mount
        end
    end
    error("Assets Error: Failed to find mount path for " .. fullPath .. ".\nRelative Path: " .. relativePath .. ".\n")
    return "Err"
end

engine.assets.MountPath = function(mountDir)
    if not mountDir or type(mountDir) ~= "string" then
        return
    end

    local processed = 0

    local function ScanDir(dir)
        local assets = love.filesystem.getDirectoryItems(dir)
        if assets then
            for _, asset in ipairs(assets) do
                local fullPath = dir .. asset
                local info = love.filesystem.getInfo(fullPath)

                if info then
                    if info.type == "file" then
                        processed = processed + 1
                        if (processed % 50 == 0) then
                            engine.routines.yields.LoadingYield("Importing Graphics... ".. engine.routines.GetLoadingCyclebar())
                        end
                        engine.assets.MountFile(fullPath)
                    elseif info.type == "directory" then
                        ScanDir(fullPath .. "/")
                    end
                end
            end
        end
    end

    if not string.endsWith(mountDir, "/") then
        mountDir = mountDir .. "/"
    end

    ScanDir(mountDir)
    engine.Log("[Assets] Loaded " .. processed .. " assets from " .. mountDir)
end


hooks.Add("OnGameLoad", function ()
    engine.routines.yields.LoadingYield("Loading Assets...")
    engine.Log("[Assets] Loading Assets...")
    engine.assets.MountPath("Engine")
    engine.assets.MountPath("Game")

    local g = ""
    for k,v in pairs(engine.assets.graphics) do
        g = g .. k .. "\n"
    end
    engine.Log("GRAPHICS:\n" .. g)
end)