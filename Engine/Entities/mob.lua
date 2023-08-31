local ent = {}
ent.base = "base"
ent.sprite = engine.assets.graphics.Simple["meow"]
ent.nextDirChange = 0
ent.dir = { x = 0, y = 0 }
ent.speed = 5

function ent:OnUpdate(deltaTime)
    if (self.nextDirChange <= CurTime()) then
        self.nextDirChange = CurTime() + love.math.random(5,20) * 0.1
        self.dir = { x = love.math.random(-1,1), y = love.math.random(-1,1)}
    end

    self.x = self.x + ent.dir.x * self.speed * deltaTime
    self.y = self.y + ent.dir.y * self.speed * deltaTime
end

function ent:OnDraw()
	self:DrawSelf()
end


return ent