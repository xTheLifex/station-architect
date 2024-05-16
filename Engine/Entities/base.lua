local ent = {}

function ent:DrawSelf()
    if not ent.sprite then return end

    local img = engine.assets.GetTexture(ent.sprite)
    if img then
        local x = ent.x - (ent.center[1] or 0)
        local y = ent.y - (ent.center[2] or 0)
        love.graphics.draw(img, x,y)
    end
end

function ent:OnDebugDraw()
    love.graphics.print(string.format("%s[%s]", self.targetname, self.id), self.x, self.y + 4, 0, 0.5, 0.5)
    love.graphics.print(self.type, self.x, self.y + 12, 0, 0.5, 0.5)
end

function ent:OnDelete()

end

function ent:OnCreate()

end

function ent:OnUpdate(deltaTime)

end

function ent:OnDraw()
	self:DrawSelf()
end

return ent