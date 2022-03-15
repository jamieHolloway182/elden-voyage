Blob = Class{__includes = Enemy}--blob inherits from enemy
--blob constructor
function Blob:init(def)
    Enemy.init(self, def)
    self.type = def.type
end
--code updates blob enemy
function Blob:update(dt)
    Enemy.update(self, dt)
end
--render's blob and its projectile
function Blob:render()
    Enemy.render(self)
    if self.projectile then
        self.projectile:render()
    end
end