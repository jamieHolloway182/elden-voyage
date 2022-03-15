Powerup = Class{__includes = Object}--powerup inherits from object
--powerup constructor
function Powerup:init(def)
    Object.init(self, def)
    self.startY = self.y

    self.falling = true

    self.timePlayed = 0
    self.canInteract = true

    self.usable = def.usable or false
    self.onUse = def.onUse

    self.onFinish = def.onFinish
end
--update handles powerup moving out of block when it spawns
function Powerup:update(dt)
    Object.update(self, dt)
    self.timePlayed = self.timePlayed + dt

    if self.falling and self.y > self.startY - TILE_SIZE then
        self.y = self.y - (POWERUP_FALL_SPEED * dt)
    end
end
--renders powerup in level
function Powerup:render()
    Object.render(self)
end
--renders powerup symbol in top left to indicate player holds this powerup
function Powerup:renderSymbol(xPos)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], xPos, 22)
end