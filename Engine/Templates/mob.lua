local ent = {}
ent.base = "base"
ent.nextDirChange = 0
ent.dir = Vector(0,0)
ent.sprite = "Simple/1D/meow.png"
ent.speed = 12
ent.tint = 1
ent.collider = {
    type = "circle",
    radius = 16
}

function ent:OnCreate()
    self.static = (math.random(0,5) ~= 0)
end

function ent:OnUpdate(deltaTime)
    if not self.static then
        self.x = self.x + (self.speed * deltaTime * self.dir.x)
        self.y = self.y + (self.speed * deltaTime * self.dir.y)
        if (self.nextDirChange <= CurTime()) then
            self.nextDirChange = CurTime() + love.math.random(5,20) * 0.1
            self.dir = { x = love.math.random(-1.0,1.0), y = love.math.random(-1.0,1.0)}
        end
    end

    if (self.target) then
        local ent = engine.entities.GetByID(self.target)
        local dist = engine.entities.Distance(self, ent)

        if (dist > 80) then
            self.target = nil
        end

        -- set this entity's dir to point towards target
        local angle = math.atan2(ent.y - self.y, ent.x - self.x)
        self.dir = { x = math.cos(angle), y = math.sin(angle) }
    else
        local all_near = engine.entities.GetOnRadius(self.x, self.y, 80)
        local possible_targets = {}
        
        for _,ent in pairs(all_near) do
            if (ent.static == true) then
                table.insert(possible_targets, ent)
            end
        end

        if possible_targets and possible_targets[1] then
            self.target = possible_targets[1].id
        end
    end
end

function ent:OnDraw()
    if self.static then
        love.graphics.setColor(0,0,0.5)
    else
        love.graphics.setColor(self.tint,1-self.tint,1-self.tint)
    end
	self:DrawSelf()
end

return ent