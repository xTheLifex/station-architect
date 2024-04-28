---@diagnostic disable: lowercase-global
engine = engine or {}
utils = utils or {}

-- -------------------------------------------------------------------------- --
--                                    Misc                                    --
-- -------------------------------------------------------------------------- --

function utils.ScreenX()
	return love.graphics.getWidth()
end

function utils.ScreenY()
	return love.graphics.getHeight()
end

ScreenX = utils.ScreenX
ScreenY = utils.ScreenY

function engine.LogDebug(text, cvar)
	if (not engine.cvars) then
		engine.Log(text)
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

-- Maintains the original require function preserved.
engine.lua = engine.lua or {}
engine.lua.require = require
function engine.Include(path)
	if (string.endsWith(path, ".lua")) then
		hooks.Fire("OnFileIncluded", path)
	else
		hooks.Fire("OnFileIncluded", path .. ".lua")
	end
	return engine.lua.require(path)
end

-- Bit array order
function utils.oBit(n)
	return math.pow(2, n)
end

oBit = utils.oBit -- Global

-- Returns if a given value is valid and safe to use.
function utils.IsValid(v)
	-- There is room for improvement and handling custom data types here.
	function e(x) return (x == nil) end

	if (v == nil) then return false end
	if (isstring(v)) then
		if (v == "") then return false end
	end
	if (istable(v)) then
		if (#v == 0) then return false end
	end
	if (isent(v)) then
		if e(v.x) then return false end
		if e(v.y) then return false end
		if e(v.id) then return false end
		if e(v.type) then return false end

		-- Entity is deleted and awaiting cleanup, once that system is implemented of course.
		if (v.deleted ~= nil and v.deleted == true) then
			return false
		end
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

-- Linearly interpolates from a to b by t.
function utils.lerp(a, b, t) return a * (1 - t) + b * t end

math.lerp = utils.lerp

-- Finds the percentage that x represents between a and b.
function utils.midpercent(x, a, b)
	if (a > b) then return utils.midpercent(x, b, a) end
	return math.clamp((x - a) / (b - a), 0, 1)
end

math.midpercent = utils.midpercent

function utils.RemoveExtension(str)
	if (type(str) ~= "string") then return "" end
	return string.match(str, "(.+)%..+$") or str
end

function utils.GetFileExtension(str)
	if type(str) ~= "string" then
		return ""
	end
	return string.match(str, "%.([^%.]+)$") or ""
end

function utils.GetDirectoryContents(dir)
	-- TODO: Check dir existance.
	return love.filesystem.getDirectoryItems(dir)
end

function utils.DirFormat(dir)
	local dir = dir or 0
	assert(type(dir) == "number", "Invalid direction to convert")

	if dir > 0 then dir = math.floor(dir) end
	if dir < 0 then dir = math.ceil(dir) end

	if (dir > 8) then
		while dir > 8 do
			dir = dir - 8
		end
	end

	if (dir < 1) then
		while dir < 1 do
			dir = dir + 8
		end
	end

	return dir
end

function utils.DirString(intdir)
	local intdir = utils.DirFormat(intdir) or 0
	assert(type(intdir) == "number", "Invalid type for direction")

	local t = {
		[1] = "N",
		[2] = "NE",
		[3] = "E",
		[4] = "SE",
		[5] = "S",
		[6] = "SW",
		[7] = "W",
		[8] = "NW"
	}

	return t[intdir]
end

function utils.DirInt(dir)
	local t = {
		["N"] = 1,
		["NE"] = 2,
		["E"] = 3,
		["SE"] = 4,
		["S"] = 5,
		["SW"] = 6,
		["W"] = 7,
		["NW"] = 8
	}
	if (isnumber(dir)) then return dir end

	return t[dir] or 1
end

function utils.VectorToDir(vec)
	if (vec == nil) then return nil end
	if (not isvector(vec)) then return 1 end
	local x, y = unpack(vec)

	local angle = math.atan2(y, x)
	local direction = math.deg(angle) + 180
	local octant = math.floor((direction % 360) / 45) + 1

	return octant
end

VectorToDir = utils.VectorToDir
VecToDir = utils.VectorToDir
DirString = utils.DirString
DirectionString = utils.DirString
DirFormat = utils.DirFormat
DirectionFormat = utils.DirFormat
DirInt = utils.DirInt
DirectionInt = utils.DirInt

-- -------------------------------------------------------------------------- --
--                                   String                                   --
-- -------------------------------------------------------------------------- --

function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

string.Split = string.split

function string.remove(inputString, toRemove)
	if type(inputString) ~= "string" or type(toRemove) ~= "string" then
		return inputString
	end

	local startPos, endPos = string.find(inputString, toRemove)

	if startPos and endPos then
		return string.sub(inputString, 1, startPos - 1) .. string.sub(inputString, endPos + 1)
	else
		return inputString
	end
end

string.Remove = string.remove

function string.replace(str, find, replace)
	return string.gsub(str, "%" .. find, replace)
end

string.Replace = string.replace

function string.startsWith(str, start)
	return str:sub(1, #start) == start
end

string.StartsWith = string.startsWith

function string.endsWith(str, ending)
	return ending == "" or str:sub(- #ending) == ending
end

string.EndsWith = string.endsWith

-- Trims down a string by the max amount of characters, additionally, can split into several lines.
function string.trim(str, max, breakLines, maxLines)
	if not max or max <= 0 then return str end
	local maxLines = maxLines or 3
	local breakLines = breakLines and true or false

	if (breakLines == false) then
		local trim = string.sub(str, 1, max - 3)

		if trim == str then return str end
		return trim .. "..."
	end

	local count = 0
	local result = ""
	local lines = 1
	for c in str:gmatch "." do
		count = count + 1

		if (count >= max - 3 and lines >= maxLines) then
			result = result .. "..."
			return result
		end

		if (count > max) then
			count = 0

			if (lines >= maxLines) then
				result = result .. "..."
				return result
			end

			result = result .. "\n"
			lines = lines + 1
		end
		result = result .. c
	end

	return result
end

string.Trim = string.trim

function string.wtrim(str, maxChars, maxLines)
	if not maxChars or maxChars <= 0 then return str end
	local maxLines = maxLines or 1
	if not maxLines or maxLines <= 0 then maxLines = 1 end
	local charCount = 0
	local lineCount = 1
	local result = ""

	for _, word in ipairs(string.split(str, " ")) do
		if (charCount + #word + 3 > maxChars) then
			if (lineCount >= maxLines) then
				result = result .. "..."
				return result
			end

			result = result .. "\n"
			lineCount = lineCount + 1
			charCount = 0
		end
		result = result .. word .. " "
		charCount = charCount + #word + 1
	end

	return result
end

string.wordTrim = string.wtrim


function string.unify(...)
	local str = ""
	for k, v in pairs({ ... }) do
		if (type(v) == "string") then str = str .. v end
		if (type(v) == "table") then
			for _, s in pairs(v) do
				if (type(s) == "string") then str = str .. s end
			end
		end
	end

	return str
end

string.Unify = string.unify


-- -------------------------------------------------------------------------- --
--                                    Table                                   --
-- -------------------------------------------------------------------------- --

function table.clone(org)
	return { table.unpack(org) }
end

function table.pasteOver(into, from)
	local into = into
	for k, v in pairs(from) do
		into[k] = v
	end
	return into
end

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

table.pasteover = table.pasteOver
table.deepCopy = table.deepcopy
table.ShallowCopy = table.shallowcopy
table.copy = table.deepcopy

function table.length(t)
	assert(istable(t), "Argument variable to measure for table's length is not a table")
	local count = 0
	for _, __ in pairs(t) do
		count = count + 1
	end
	return count
end

function table.ilength(t) return #t end

table.len = table.length
table.ilen = table.ilength


function table.indexOf(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil
end

table.IndexOf = table.indexOf

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

function table.AllEqual(table, value)
	for k, v in pairs(table) do
		if (v ~= value) then
			return false
		end
	end
	return true
end

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

-- Custom types

-- Returns true if given value is a entity
function utils.isent(val)
	if (type(val) ~= "table") then return false end
	local meta = getmetatable(val)

	for index, template in pairs(engine.entities.registry) do
		if (meta == template) then return true end
	end

	return false
end

-- Returns true if given value is a color
function utils.iscolor(val)
	if (not istable(val)) then return false end
	if (val[1] == nil) then return false end
	if (val[2] == nil) then return false end
	if (val[3] == nil) then return false end
	if (not isnumber(val[1])) then return false end
	if (not isnumber(val[2])) then return false end
	if (not isnumber(val[3])) then return false end
	if (not IsValid(val.r)) then return false end
	if (not IsValid(val.g)) then return false end
	if (not IsValid(val.b)) then return false end
	return true
end

function utils.isvector(val)
	if (not istable(val)) then return false end
	if (val[1] == nil) then return false end
	if (val[2] == nil) then return false end
	if (val[3] == nil) then return false end
	if (not isnumber(val[1])) then return false end
	if (not isnumber(val[2])) then return false end
	if (not isnumber(val[3])) then return false end
	if (val["x"] ~= nil and not isnumber(val["x"])) then return false end
	if (val["y"] ~= nil and not isnumber(val["y"])) then return false end
	if (val["z"] ~= nil and not isnumber(val["z"])) then return false end
	return true
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

utils.isfunc   = utils.isfunction
utils.ismethod = utils.isfunction

-- Globals for default types
isbool         = utils.isbool
istable        = utils.istable
isstring       = utils.isstring
isnumber       = utils.isnumber
iscolor        = utils.iscolor
isvector       = utils.isvector
isfunction     = utils.isfunction
isfunc         = utils.isfunc
ismethod       = utils.ismethod
tobool         = utils.tobool
isent          = utils.isent

-- Type flag table
engine.type    = engine.type or {
	[oBit(1)] = "string",
	[oBit(2)] = "number",
	[oBit(3)] = "bool",
	[oBit(4)] = "color",
	[oBit(5)] = "vector",
	[oBit(6)] = "table",
	[oBit(7)] = "func",
	[oBit(8)] = "entity",

	string    = oBit(1),
	number    = oBit(2),
	bool      = oBit(3),
	color     = oBit(4),
	vector    = oBit(5),
	table     = oBit(6),
	func      = oBit(7),
	entity    = oBit(8)
}

-- Returns the engine type of value v
-- TODO: Custom types
function utils.GetType(v)
	if (iscolor(v)) then return engine.type.color end
	if (isent(v)) then return engine.type.entity end
	if (isvector(v)) then return engine.type.vector end
	if (isstring(v)) then return engine.type.string end
	if (isnumber(v)) then return engine.type.number end
	if (istable(v)) then return engine.type.table end
	if (isfunction(v)) then return engine.type.func end
	return nil
end

GetType = utils.GetType


-- -------------------------------------------------------------------------- --
--                                    Mouse                                   --
-- -------------------------------------------------------------------------- --

function utils.MousePos()
	local x, y = love.mouse.getPosition()
	return {
		["x"] = x,
		["y"] = y,
		[1] = x,
		[2] = y
	}
end

function utils.CamToWorld(x, y)
	local rx, ry = engine.rendering.camera:worldCoords(x, y)
	return {
		[1] = rx,
		[2] = ry,
		["x"] = rx,
		["y"] = ry
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
CamToWorld = utils.CamToWorld

function utils.Distance(x1, y1, x2, y2)
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt(dx * dx + dy * dy)
end

function utils.Vector(x, y)
	return { [1] = x, [2] = y, ["x"] = x, ["y"] = y }
end

Vector = utils.Vector
Vec = utils.Vector
