Rotation = {}
Rotation.pitch = 0
Rotation.yaw = 0
Rotation.roll = 0


function Rotation:new(pitch, yaw, roll)
	local v = {}
	setmetatable(v, self)
	self.__index = self
	self.pitch = pitch or 0
	self.yaw = yaw or 0
	self.roll = roll or 0
	return v
end


