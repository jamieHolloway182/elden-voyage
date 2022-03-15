FishIdleState = Class{__includes = BaseState}
--fish idle state constructor
function FishIdleState:init(level, player, fish)
    self.level = level
    self.player = player
    self.fish = fish

    self.fish.animation.interval = 0.4
    self.timePassed = 0
end
--updates boomba by changing its state randomly
function FishIdleState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(40) == 1  and self.timePassed > 2 then
        self.fish:changeState('attack')
    end
end