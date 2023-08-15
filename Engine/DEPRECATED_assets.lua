engine = engine or {}
engine.assets = engine.assets or {}

engine.assets.CharacterSets = {}
engine.assets.FaceSets = {}
engine.assets.IconSets = {}
engine.assets.BattlerSets = {}

engine.assets.Import = function (assetType, dir, file, index)
    local t = string.lower(assetType)
    local img = love.graphics.newImage(dir .. "/" .. file)
    local index = index or utils.RemoveExtension(file)

    if (t == "face" or t == "faceset") then
        -- ------------------------------- Import Face ------------------------------ --


    elseif (t == "character" or t == "characterset" or t == "charset") then
        -- --------------------------- Import Characterset -------------------------- --
        local set = {}
        local size = 48 -- Sprite size.

        for h=0,1 do
            for i=1,4 do
                set[i+h*4]            = {}
                set[i+h*4]["DOWN"]    = {}
                set[i+h*4]["UP"]      = {}
                set[i+h*4]["LEFT"]    = {}
                set[i+h*4]["RIGHT"]   = {}
            end
        end

        local DIRECTION = {
            [0] = "DOWN",
            [1] = "LEFT",
            [2] = "RIGHT",
            [3] = "UP"
        }

        for h=0,1 do
            for i=0,3 do
                for y=0,3 do
                    for x=0,2 do
                        set[(i+1)+(h*4)][DIRECTION[y]][x+1] = love.graphics.newQuad((i*(size*3))+(size*x), (h*(size*4))+(size*y), size, size, img)
                    end
                end
            end
        end

        set["path"] = dir .. "/" .. file
        set["dir"] = dir
        set["file"] = file
        set["index"] = index
        set["img"] = img

        engine.assets.CharacterSets[index] = set
    elseif (t == "icon" or t == "iconset") then
        -- ----------------------------- Import Iconset ----------------------------- --


    elseif (t == "svb" or t == "sideviewbattler" or t == "svbattler") then
        -- ---------------------------- Import SV Battler --------------------------- --


    end
end

hooks.Add("OnGameLoad", function ()
    -- Start a loading coroutine to load assets in the background.
    local co = engine.routines.New("LoadAssets", function ()
        -- Load assets
        local chars = love.filesystem.getDirectoryItems("Game/Image/Characters")
        local faces = love.filesystem.getDirectoryItems("Game/Image/Facesets")
        local icons = love.filesystem.getDirectoryItems("Game/Image/Iconsets")
        local svb = love.filesystem.getDirectoryItems("Game/Image/SVB")
    
        local screen = engine.rendering.UI.GetScreen("Loading")
        screen = screen or {}
        screen.Variables = screen.Variables or {}
        
        local total = #chars + #faces + #icons + #svb
        local progress = 0

        screen.Variables["Min"] = 0
        screen.Variables["Max"] = total

        screen.Variables["TopText"] = "Loading Character Assets..."    
        engine.Log("[Assets] " .. "Loading Character Assets...")

        for _, file in ipairs(chars) do
            screen.Variables["BottomText"] = file
            engine.assets.Import("CharacterSet", "Game/Image/Characters", file)
            progress = progress + 1
            screen.Variables["Progress"] = progress
            
            coroutine.yield()
        end
    
        screen.Variables["TopText"] = "Loading Face Assets..."   
        engine.Log("[Assets] " .. "Loading Face Assets...")

        for _, file in ipairs(faces) do
            screen.Variables["BottomText"] = file
            engine.assets.Import("FaceSet", "Game/Image/Facesets", file)
            progress = progress + 1
            screen.Variables["Progress"] = progress
            
            coroutine.yield()
        end
    
        screen.Variables["TopText"] = "Loading Icon Assets..."   
        engine.Log("[Assets] " .. "Loading Icon Assets...")

        for _, file in ipairs(icons) do
            screen.Variables["BottomText"] = file
            engine.assets.Import("IconSet", "Game/Image/Iconsets", file)
            progress = progress + 1
            screen.Variables["Progress"] = progress
            
            coroutine.yield()
        end
    
        screen.Variables["TopText"] = "Loading Battler Assets..."   
        engine.Log("[Assets] " .. "Loading Battler Assets...")

        for _, file in ipairs(svb) do
            screen.Variables["BottomText"] = file
            engine.assets.Import("SideViewBattler", "Game/Image/SVB", file)
            progress = progress + 1
            screen.Variables["Progress"] = progress
            
            coroutine.yield()
        end

        hooks.Fire("OnAssetsLoaded")
    end)
end)