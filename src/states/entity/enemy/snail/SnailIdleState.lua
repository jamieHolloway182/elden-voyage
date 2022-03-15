SnailIdleState = Class{__includes = BaseState}
--snail idle state constructor
function SnailIdleState:init(level, player, snail)
    self.snail = snail

    self.snail.width = 8
    self.snail.height = 8

    self.snail.offsetX = 4

    self.snail.animation = Animation({
        frames = {51 + (self.snail.type - 1) * 4}
    })
    self.timePassed = 0
end
--updates snail by randomly changing state
function SnailIdleState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(50) == 1 and self.timePassed > 1 then
        self.snail:changeState('walk')
    end
end
