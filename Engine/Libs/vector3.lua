Vector3 = {}
Vector3.x = 0
Vector3.y = 0
Vector3.z = 0

function Vector3:new(x,y,z)
	local v = {}
	setmetatable(v, self)
	self.__index = self
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	return v
end

function Vector3:Distance(other)
	local ox = other.x or 0
	local oy = other.y or 0
	local oz = other.z or 0
	
	local x = 0
	local y = 0
	local z = 0
	
	if (ox > self.x) then
		x = ox - self.x
	else
		x = self.x - ox
	end
	
	if (oy > self.y) then
		y = oy - self.y
	else
		y = self.y - oy
	end
	
	if (oz > self.z) then
		z = oz - self.z
	else
		z = self.z - oz
	end
	
	return Vector3:new(x,y,z)
end
