Snail = Class{__includes = Enemy}--snail inherits from enemy
--snail constructor
function Snail:init(def)
    Enemy.init(self, def)
    self.type = def.type
end
--update snail
function Snail:update(dt)
    Enemy.update(self, dt)
end
--render snail
function Snail:render()
    Enemy.render(self)
end