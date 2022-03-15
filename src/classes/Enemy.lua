Enemy = Class{__includes = Entity}--enemy inherits from entity
--enenmy constructor
function Enemy:init(def)
    Entity.init(self, def)
    self.alive = true
    self.enemyType = def.enemyType
    self.canDamage = true
end
--update enemy
function Enemy:update(dt)
    Entity.update(self, dt)
end
--render enemy
function Enemy:render()
    Entity.render(self)
end