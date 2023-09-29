engine = engine or {}
file = file or {}


---@diagnostic disable-next-line: duplicate-set-field
function file.exists(path)
    local f = io.open(path, "r")
    if (f~=nil) then
        return true
    else
        return false
    end
end

function engine.GetLogFile()
    if (IsValid(engine.logfile)) then
        return engine.logfile
    end

    local date = tostring(os.date("%d-%m-%y"))
    local counter = 1

    while (file.exists(string.format ( "Engine/Logs/%s(%i).log", date, counter) ) and counter < 9999) do
        counter = counter + 1
    end
    engine.logfile = string.format( "Engine/Logs/%s(%i).log", date, counter )
    return engine.logfile
end


function engine.Log(text, color)    
    if (text == nil or text == "") then return end

    local out = os.date("[%X] ") .. text

    local fn = engine.GetLogFile()
    local f = io.open(fn,"a")
    if (f) then
        f:write(out .. "\n")
        io.close(f)
    end

    print(out)
end
Log = engine.Log