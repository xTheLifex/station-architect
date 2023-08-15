Transform = {}
Transform.position = {}
Transform.rotation = {}


function Transform:new(pos, rot)
	local t = {}
	setmetatable(t, self)
	self.__index = self
	self.position = pos or Vector3:new(0,0,0)
	self.rotation = rot or Rotation:new(0,0,0)
	return t
end