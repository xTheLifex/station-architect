engine = engine or {}
engine.music = engine.music or {}
engine.audio = engine.audio or {}
engine.sound = engine.sound or {}

-- ------------------------------------ - ----------------------------------- ---- ------------------------------------ - ----------------------------------- --
-- LÖVE supports a lot of audio formats, thanks to the love.sound module, which handles all the decoding. 
-- Supported formats include:
--     MP3
--     Ogg Vorbis
--     WAVE
--     and just about every tracker format you can think of - XM, MOD, and over twenty others.
-- Ogg Vorbis and 16-bit WAVE are the recommended formats. Others may have minor quirks. 
-- For example, the MP3 decoder may pad a few samples depending on what encoder was used. 
-- These issues come from the libraries LÖVE uses to decode the audio files and can't be fixed in LÖVE directly
-- ------------------------------------ - ----------------------------------- ---- ------------------------------------ - ----------------------------------- --

-- Current playing sounds.
engine.currentSounds = {}

-- Current track to play
engine.audio.targetTrack = nil
engine.audio.targetVolume = 1
engine.audio.targetSmoothing = true

-- -------------------------------------------------------------------------- --
--                                  Importing                                 --
-- -------------------------------------------------------------------------- --
engine.audio.Import = function (path, clip, type)
    local fullpath = path .. "/" .. clip
    local name = utils.RemoveExtension(clip)
    local type = type or "sound"
    if (not file.exists(fullpath)) then
        engine.Log("[Audio] Invalid file to import: " .. fullpath)
        return nil
    end

    assert((type == "music" or type == "sound"), "Invalid audio import type")

    if (type == "music") then
        local source = love.audio.newSource(fullpath, "stream")
        local duration = source:getDuration("seconds")
        
        engine.music[name] = {
            ["name"] = name,
            ["duration"] = duration,
            ["source"] = source,
            ["file"] = fullpath
        }
        return engine.music[name]
    end

    if (type == "sound") then
        local source = love.audio.newSource(fullpath, "static")
        local duration = source:getDuration("seconds")
        
        table.insert(engine.sound, {
            ["name"] = name,
            ["duration"] = duration,
            ["source"] = source,
            ["file"] = fullpath,
            ["id"] = #engine.sound
        })

        return engine.sound[#engine.sound]
    end
end

engine.audio.ImportMusic = function (path, clip)
    return engine.audio.Import(path, clip, "music")
end

engine.audio.ImportSound = function (path, clip)
    return engine.audio.Import(path, clip, "sound")
end
-- -------------------------------------------------------------------------- --
--                                   Playing                                  --
-- -------------------------------------------------------------------------- --
engine.audio.PlayMusic = function(track, volume, insta)
    local volume = volume or 1
    local insta = insta or false
    if (not engine.music[track]) then
        engine.Log("[Audio] Attempting to play unregistered track: " .. track)
        return
    end
    engine.audio.targetTrack = track
    engine.audio.targetVolume = volume
    engine.audio.targetSmoothing = not insta
    engine.Log("[Audio] Music track set: " .. engine.audio.targetTrack)
end

engine.audio.StopMusic = function ()
    engine.audio.targetTrack = nil
end

engine.audio.PlaySound = function (sound, volume)
    -- TODO: Find if sound is a numeric ID, a file path or file name.
    -- TODO: If file name, are there duplicates? If there are none, then play normally. Else, raise exception.
    -- TODO: If file name, search through registered sounds for the matching path.
    return nil
end


engine.audio.Play = function(clip, volume, insta) 
    -- TODO: Search both music and  sound, and determine which is it.
end

-- -------------------------------------------------------------------------- --
--                                  Updating                                  --
-- -------------------------------------------------------------------------- --

hooks.Add("OnEngineUpdate", function (dt)
    for name,info in pairs(engine.music) do

        if (name == engine.audio.targetTrack) then
            --  This is the target music to play.
            local volume = info.source:getVolume()
            if (volume < engine.audio.targetVolume) then
                info.source:setVolume(math.clamp(volume + 0.5 * dt, 0, 1))
            end

            if (not info.source:isPlaying()) then
                info.source:play()
                if (engine.audio.targetSmoothing) then
                    info.source:setVolume(0)
                else
                    info.source:setVolume(1)
                end
            end
        else
            -- Not the target music to play.
            local volume = info.source:getVolume()
            if (volume > 0) then
                info.source:setVolume(math.clamp(volume - 0.5 * dt, 0, 1))
            end

            if (volume == 0) then
                info.source:stop()
            end
        end
    end
end)