FlyIdleState = Class{__includes = BaseState}
--fly idle state constructor
function FlyIdleState:init(level, player, fly)
    self.fly = fly

    self.fly.animation = Animation({
        frames = {33 + (self.fly.type - 1) * 3, 33 + (self.fly.type - 1) * 3 + 1},
        interval = 0.4
    })
    self.timePassed = 0
end
--updates fly by changing its direction and state randomly
function FlyIdleState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(50) == 1 and self.timePassed > 1 then
        self.fly:changeState('move')
    end
    if math.random(50) == 1 and self.timePassed > 1 then
        if self.fly.direction == 'left' then
            self.fly.direction = 'right'
        elseif self.fly.direction == 'right' then
            self.fly.direction = 'left'
        end
    end

    if math.random(400) == 1 then
        self.fly:changeState('attack')
    end
end