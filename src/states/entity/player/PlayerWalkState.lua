PlayerWalkState = Class{__includes = BaseState}
--player walk state constructor
function PlayerWalkState:init(player)
    self.player = player
    self.begunFall = false

    self.player.dy = 0

    self.player.animation = Animation({
        frames = {10,11},
        interval = 0.1
    })
    self.player.hitboxOffsetY = 0
end
--handles updating x coord and collisions
function PlayerWalkState:update(dt)
--updates direction
    if love.keyboard.isDown(LEFT_BUTTON) then 
        self.player.direction = 'left'
    elseif love.keyboard.isDown(RIGHT_BUTTON) then
        self.player.direction = 'right'
    end
    if love.keyboard.isDown(JUMP_BUTTON) then
        self.player:changeState('jump')
    end
--updates x coords while checking for tile and object collision
    if love.keyboard.isDown(LEFT_BUTTON) or love.keyboard.isDown(RIGHT_BUTTON) then
        if self.player.direction == 'left' and not self.player:checkLeftCollisions() then
            self.player.x = self.player.x - (PLAYER_WALK_SPEED * dt)
            self.player.y = self.player.y - 1
            local obj = self.player:checkObjectCollisions()
            if obj and self.player.y + self.player.height - 1 > obj.y then
                self.player.x = self.player.x + (PLAYER_WALK_SPEED * dt)
            end
            self.player.y = self.player.y + 1
        elseif self.player.direction == 'right' and not self.player:checkRightCollisions() then
            self.player.x = self.player.x + (PLAYER_WALK_SPEED * dt)
            self.player.y = self.player.y - 1
            local obj = self.player:checkObjectCollisions()
            if obj and self.player.y + self.player.height - 1 > obj.y then
                self.player.x = self.player.x - (PLAYER_WALK_SPEED * dt)
            end
            self.player.y = self.player.y + 1
        end
    else
        self.player:changeState('idle')
    end
--checks if the player has fallen off edge
    if not self.player:checkDownwardCollisions() and not self.player:checkObjectCollisions() and not self.begunFall then
        self.begunFall = true
        Timer.after(0.03, function() 
            if love.keyboard.wasPressed(JUMP_BUTTON) then
                self.player:changeState("jump")
            else
                self.player:changeState('falling')
            end
        end)
    end
end