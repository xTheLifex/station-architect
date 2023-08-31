local ent = {}
ent.base = "base"
ent.nextDirChange = 0
ent.dir = { x = 0.0, y = 0.0 }
ent.speed = 12
function ent:OnUpdate(deltaTime)
    self.x = self.x + (self.speed * deltaTime * self.dir.x)
    self.y = self.y + (self.speed * deltaTime * self.dir.y)
    if (self.nextDirChange <= CurTime()) then
        self.nextDirChange = CurTime() + love.math.random(5,20) * 0.1
        self.dir = { x = love.math.random(-1.0,1.0), y = love.math.random(-1.0,1.0)}
    end
end

function ent:OnDraw()
	self:DrawSelf()
end


return ent