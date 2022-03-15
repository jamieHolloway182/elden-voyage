Fly = Class{__includes = Enemy}--fly inherits from enemy
--fly constructor
function Fly:init(def)
    Enemy.init(self, def)
    self.type = def.type
    self.startY = def.y
    self.shooting = false

    self.goingUp = math.random(2) == 1

    self.bullet = false
    self.timeSinceAttacking = 0
end
--updates fly and its bullet
function Fly:update(dt)
    Enemy.update(self, dt)
    self.timeSinceAttacking = self.timeSinceAttacking + dt
    if self.bullet then
        self.bullet:update(dt)
    end
end
--render fly and its bullet
function Fly:render()
    Enemy.render(self)
    if self.bullet then
        self.bullet:render()
    end
end