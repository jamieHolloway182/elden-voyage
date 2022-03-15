SnailWalkState = Class{__includes = BaseState}
--snail walk state constructor
function SnailWalkState:init(level, player, snail)
    self.snail = snail

    self.snail.width = 16
    self.snail.height = 16

    self.snail.offsetX = 1

    self.snail.animation = Animation({
        frames = {49 + (self.snail.type - 1) * 4, 50 + (self.snail.type - 1) * 4},
        interval = 0.5
    })
    self.player = player

    self.timePassed = 0
end
--updates snail by changing its direction and state randomly and moving it towards the player
function SnailWalkState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(100) == 1 and self.timePassed > 3 then
        self.snail:changeState('idle')
    end

    if self.player.x < self.snail.x then
        self.snail.direction = "right"
    else
        self.snail.direction = "left"
    end
--move toward player and handle collisions
    if math.abs(self.player.x - self.snail.x) > 10 then
        if self.snail.direction == 'left' and not self.snail:checkRightCollisions() then
            self.snail.x = self.snail.x + self.snail.width / 2
            local bool = self.snail:checkDownwardCollisions()
            self.snail.x = self.snail.x - self.snail.width / 2
            if bool then
                self.snail.x = self.snail.x + (SNAIL_WALK_SPEED * dt)
            end
        elseif self.snail.direction == 'right' and not self.snail:checkLeftCollisions() then
            self.snail.x = self.snail.x - self.snail.width / 2
            local bool = self.snail:checkDownwardCollisions()
            self.snail.x = self.snail.x + self.snail.width / 2
            if bool then
                self.snail.x = self.snail.x - (SNAIL_WALK_SPEED * dt)
            end
        end
    end
end