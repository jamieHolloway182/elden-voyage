FishAttackState = Class{__includes = BaseState}
--fish attack state constructor
function FishAttackState:init(level, player, fish)
    self.level = level
    self.player = player
    self.fish = fish

    self.fish.animation.interval = 0.1
    
    self.fish.dy = -4.5
end
--updates fish by handling its jump and return to idle state
function FishAttackState:update(dt)
    if self.fish.y < VIRTUAL_HEIGHT then
        self.fish.dy = self.fish.dy + (GRAVITY * dt)
        self.fish.y = self.fish.y + self.fish.dy
    else
        self.dy = 0
        Timer.tween(2, {
            [self.fish] = {y = VIRTUAL_HEIGHT - 20}
        })
        self.fish:changeState('idle')
    end
end