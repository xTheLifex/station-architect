engine = engine or {}
engine.libs = engine.libs or {}
engine.libs.csv = engine.libs.csv or require("Engine.Libs.csv")

file = {}
file.current = nil

function file.open(path, mode)
    local f, err = io.open(path, mode)
    if (IsValid(err)) then
        engine.Log(string.format("A error has occured while reading %s:\n%s\n", path, err))
    else
        file.current = path
        return f
    end
end

function file.close(f)
    if (IsValid(f)) then
        file.current = nil
        io.close(f)
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function file.exists(path)
    local f = file.open(path, "r")
    if (f~=nil) then
        file.close(f)
        return true
    else
        return false
    end
end

function file.info(path)
    --TODO: Replace with own methods.
    return love.filesystem.getInfo(path, "file")
end

function file.create(path, data)
    assert(path, "Attempted to create a file without path or name.")
    if (not file.exists(path)) then return end

    local f = file.open(path, "w")
    if (data) then
        if (istable(data)) then
            for _,line in ipairs(data) do
                f:write(line)
            end
        else
            f:write(data)
        end
    end
    file.close(path)
end

function file.write(path, data)
    assert(path, "Attempted to write to invalid file.")
    assert(data, "Attempted to write invalid data to file.")
    if (not file.exists(path)) then return end
    local f = file.open(path, "w")
    if (istable(data)) then
        for _,line in ipairs(data) do
            f:write(line)
        end
    else
        f:write(data)
    end
    file.close(f)
end

function file.read(path)
    assert(path, "Attempt to read invalid file")
    if (not file.exists(path)) then
        engine.Log(string.format("File.Read could not find or use \"%s\" for reading."))
        return {}, false
    end

    local f = file.open(path, "r")
    local t = {}
    for line in f:lines() do
        table.insert(t, line)
    end
    file.close(f)
    return t, true
end

function engine.ParseINI(path)
    if not (file.exists(path)) then
        engine.Log("Attempt to read invalid INI file.")
        return {}
    end

    local ini = {}

    local data = file.read(path)
    -- Read sections
    for _,line in ipairs(data) do
        local section = string.gsub(line, "%[.+%]", "s")
        if (section == "s") then
            -- This is a section!
            local sname = string.sub(line, 2, -2)
            ini[sname] = {}
        end
    end
    -- Read values
    local curSection = "Misc"
    for _,line in ipairs(data) do
        local section = string.gsub(line, "%[.+%]", "s")
        if (section == "s") then
            -- This is a section!
            local sname = string.sub(line, 2, -2)
            curSection = sname
        else
            -- This is NOT a section!
            local words = string.split(line, "=")
            if (#words > 1) then
                local k = words[1]
                local v = words[2]
                if (ini[curSection]) then
                    ini[curSection][k] = v
                end
            end
        end
    end

    return ini
end

function engine.SaveINI(path, data)
    assert(path, "Attempt to save a INI file without a name.")
    assert(istable(data), "Trying to save illegal data to INI file.")

    if (data == {}) then
        engine.Log("Trying to save empty data to INI! Refusing to protect data!")
        return
    end

    local f,err = file.open(path, "w")
    if (f) then
        for section,info in pairs(data) do
            f:write("[",section,"]\n")
            for k,v in pairs(info) do
                if (not istable(v)) then
                    f:write(string.format("%s=%s\n", tostring(k), tostring(v))) 
                end
            end
        end

        file.close(f)
    end
end

function file.GetNameFromPath(fileDir)
    return string.gmatch(fileDir, ".+/([^/]+)$")
end

hooks.Add("OnEngineDraw", function ()
    if (IsValid(file.current)) then
        local t = {}
        table.insert(t, {1,0,0})
        table.insert(t, string.format("Current open file: [%s]", file.current))
        love.graphics.print(t, 256, 0, ScreenY()-128, 1, 1)
    end
end)