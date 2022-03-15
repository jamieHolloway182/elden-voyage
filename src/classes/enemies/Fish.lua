Fish = Class{__includes = Enemy}--fish inherits from enemy
--fish constructor, gives fish its animatio
function Fish:init(def)
    Enemy.init(self, def)
    self.animation = Animation({
        frames = {25, 26},
        interval = 0.1
    })
end
--updates fish
function Fish:update(dt)
    Enemy.update(self, dt)
end
--render fish
function Fish:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation.frame],
        math.floor(self.x), math.floor(self.y), 0.5 * math.pi, 1, 1, 0, 16)
end