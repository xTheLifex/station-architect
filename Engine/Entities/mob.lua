local ent = {}
ent.base = "base"
ent.nextDirChange = 0
ent.dir = { x = 0.0, y = 0.0 }
ent.sprite = "meow"
ent.speed = 12

ent.tint = 1

function ent:OnUpdate(deltaTime)
    self.x = self.x + (self.speed * deltaTime * self.dir.x)
    self.y = self.y + (self.speed * deltaTime * self.dir.y)
    if (self.nextDirChange <= CurTime()) then
        self.nextDirChange = CurTime() + love.math.random(5,20) * 0.1
        self.dir = { x = love.math.random(-1.0,1.0), y = love.math.random(-1.0,1.0)}
    end

    if (meow ~= nil and meow.master ~= nil) then
        if (meow.master.id == self.id) then
            self.tint = 1
        else
            local dist = engine.entities.Distance(meow.master, self)

            local tint = 1/( ( (dist/1000) +1)^2 )
            self.tint = tint
        end
    end
end

function ent:OnDraw()
    love.graphics.setColor(self.tint,1-self.tint,1-self.tint)
	self:DrawSelf()
end

return ent