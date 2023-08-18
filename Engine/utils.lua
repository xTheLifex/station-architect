engine = engine or {}
utils = utils or {}

-- -------------------------------------------------------------------------- --
--                                    Misc                                    --
-- -------------------------------------------------------------------------- --

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

table.copy = table.deepcopy

function table.clone(org)
  return {table.unpack(org)}
end

function utils.ScreenX()
	return love.graphics.getWidth()
end

function utils.ScreenY()
	return love.graphics.getHeight()
end

ScreenX = utils.ScreenX
ScreenY = utils.ScreenY


function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function string.replace(str, find, replace)
	return string.gsub(str, "%" .. find, replace)
end

function string.startsWith(str, start)
	return str:sub(1, #start) == start
end

function string.endsWith(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end


function table.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function table.Contains(table, value)
	for k, v in pairs(table) do
		if v == value then
			return true
		end
	end

	return false
end
table.contains = table.Contains


function table.ContainsKey(table, key)
	return table[key] ~= nil
end
table.containskey = table.ContainsKey

function engine.LogDebug(text, cvar)
	if (not engine.cvars) then
		engine.Log(text, color)
	end

	if not (cvar == nil) then
		if (engine.GetCVar(cvar, false) == true) then
			engine.Log(text)
		end
	else
		if (engine.GetCVar("debug", false) == true) then
			engine.Log(text)
		end
	end
end

LogDebug = engine.LogDebug
DebugLog = engine.LogDebug

--TODO: Improve with networking.
function engine.Include(path)
	if (string.endsWith(path, ".lua")) then
		hooks.Fire("OnFileIncluded", path)
	else
		hooks.Fire("OnFileIncluded", path .. ".lua")
	end
	return require(path)
end


-- Bit array order
function utils.oBit(n)
	return math.pow(2, n)
end
oBit = utils.oBit -- Global

-- Returns if a given value is valid and safe to use.
function utils.IsValid(v)
	-- There is room for improvement and handling custom data types here.
	if (v == nil) then return false end
	if (isstring(v)) then
		if (v == "") then return false end
	end
	if (istable(v)) then
		if (#v == 0) then return false end
	end
	return true
end
IsValid = utils.IsValid

function utils.Clamp(val, n, m)
	if (type(val) ~= "number") then return val end
	
	local min
	local max
	
	if (n == m) then return val end
	
	if (n > m) then
		max = n
		min = m
	end
	
	if (m > n) then
		max = m
		min = n
	end
	
	if (val > max) then return max end
	if (val < min) then return min end
	return val
end

utils.clamp = utils.Clamp
math.clamp = utils.clamp


-- -------------------------------------------------------------------------- --
--                                    Types                                   --
-- -------------------------------------------------------------------------- --

-- Default types

-- Returns if given value is a boolean
function utils.isbool(val)
	return type(val) == "boolean"
end

-- Returns if given value is a table
function utils.istable(val)
	return type(val) == "table"
end

-- Returns if given value is a string
function utils.isstring(val)
	return type(val) == "string"
end

-- Returns if given value is a number
function utils.isnumber(val)
	return type(val) == "number"
end

-- Returns if given value is a function
function utils.isfunction(val)
	return type(val) == "function"
end

-- Converts a given value into a boolean if possible
function utils.tobool(val)
	if (type(val) == "boolean") then
		return val
	end
	if (isstring(val)) then
		local lstr = string.lower(val)
		if (lstr == "yes" or lstr == "true" or lstr == "1") then
			return true
		end
	end
	if (isnumber(val)) then
		if (val == 1) then return true end
	end
	return false
end

utils.isfunc = utils.isfunction
utils.ismethod = utils.isfunction

-- Globals for default types
isbool 		= utils.isbool
istable		= utils.istable
isstring	= utils.isstring
isnumber	= utils.isnumber
isfunction	= utils.isfunction
isfunc		= utils.isfunc
ismethod	= utils.ismethod
tobool		= utils.tobool

-- Type flag table
engine.type = engine.type or {
	[oBit(1)]	= "string",
	[oBit(2)]	= "number",
	[oBit(3)]	= "player",
	[oBit(4)]	= "character",
	[oBit(5)]	= "clientid",
	[oBit(6)]	= "bool",
	[oBit(7)]	= "color",
	[oBit(8)]	= "vector",
	[oBit(9)]	= "table",
	[oBit(10)]	= "func",

	string 		=	oBit(1),
	number 		=	oBit(2),
	player 		=	oBit(3),
	character 	=	oBit(4),
	clientid 	=	oBit(5),
	bool 		=	oBit(6),
	color 		=	oBit(7),
	vector 		=	oBit(8),
	table		=	oBit(9),
	func		=	oBit(10)
}

-- Returns the engine type of value v
-- TODO: Custom types
function utils.GetType(v)
	if (isstring(v)) then return engine.type.string end
	if (isnumber(v)) then return engine.type.number end
	if (istable(v)) then return engine.type.table end
	if (isfunction(v)) then return engine.type.func end
	return nil
end

GetType = utils.GetType


function utils.RemoveExtension(str)
	if (type(str) ~= "string") then return "" end
	return string.match(str, "(.+)%..+$")
end

function utils.GetDirectoryContents(dir)
	-- TODO: Check dir existance.
	return love.filesystem.getDirectoryItems(dir)
end

function utils.MousePos()
	local x,y = love.mouse.getPosition()
	return {
		["x"] = x,
		["y"] = y,
		[1] = x,
		[2] = y
	}
end

function utils.MouseX()
	local pos = utils.MousePos()
	return pos.x
end

function utils.MouseY()
	local pos = utils.MousePos()
	return pos.y
end

MousePos = utils.MousePos
MouseX = utils.MouseX
MouseY = utils.MouseY