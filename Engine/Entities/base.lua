local ent = {}

function ent:OnDelete()

end

function ent:OnCreate()
	self.nextChange = CurTime() + 3
	self.color = {1,1,1}
end

function ent:OnUpdate(deltaTime)
	if (CurTime() > self.nextChange) then
		self.nextChange = CurTime() + math.random(1,3)
		local c = math.random(1,3)
		self.color = {1,1,1}
		if (c == 1) then self.color = {1,0,0} end
		if (c == 2) then self.color = {0,1,0} end
		if (c == 3) then self.color = {0,0,1} end
	end
end

function ent:OnDraw()
	love.graphics.setColor(self.color)
	self:DrawSelf()
end

return ent