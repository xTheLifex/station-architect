local ent = {}

function ent:OnDelete()

end

function ent:OnCreate()

end

function ent:OnUpdate()

end

function ent:DrawSelf()
	love.graphics.draw(self.sprite, self.x, self.y)
end

function ent:OnDraw()
	self:DrawSelf() -- Default render method.
end

return ent