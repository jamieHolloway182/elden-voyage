Boomba = Class{__includes = Enemy}--boomba inherits from enemy
--boomba constructor
function Boomba:init(def)
    Enemy.init(self, def)
    self.startY = def.y
    self.goingUp = math.random(2) == 1
    self.attacking = false
end
--update boomba enemy and its particle system
function Boomba:update(dt)
    Enemy.update(self, dt)
    if self.psystem then
        self.psystem:update(dt)
    end
end
--render boomba and its particle system
function Boomba:render()
    if not self.exploded then
        Enemy.render(self)
    end
    if self.psystem then
        love.graphics.draw(self.psystem, self.x, self.y)
    end
end