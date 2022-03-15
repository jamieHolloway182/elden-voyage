BoombaIdleState = Class{__includes = BaseState}
--boomba idle state constructor
function BoombaIdleState:init(level, player, boomba)
    self.level = level
    self.player = player
    self.boomba = boomba

    self.timePassed = 0
end
--updates boomba by changing its direction and state randomly
function BoombaIdleState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(50) == 1 and self.timePassed > 1 then
        if self.boomba.direction == 'left' then
            self.boomba.direction = 'right'
        elseif self.boomba.direction == 'right' then
            self.boomba.direction = 'left'
        end
    end

    if math.random(4) == 1 then
        self.boomba:changeState('attack')
    end
end