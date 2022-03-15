PlayerFallState = Class{__includes = BaseState}
--player fall state constructor
function PlayerFallState:init(player)
    self.player = player
    self.float = self.player.dy == 0
    self.canDoubleJump = true

    self.player.animation = Animation({
        frames = {3}
    })

    self.player.hitboxOffsetY = 0
end
--updates player while falling with position and collisions
function PlayerFallState:update(dt)
--handles player's direction
    if love.keyboard.isDown('left') then 
        self.player.direction = 'left'
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
    end
--if player moving upwards    
    if self.player.dy < 0 then
        if love.keyboard.isDown(JUMP_BUTTON) then
            self.player.dy = self.player.dy + (GRAVITY*dt * 0.75)
        else
            self.player.dy = self.player.dy + (GRAVITY * dt * 2)
        end
--if player moving downwards
    else
        if love.keyboard.wasPressed(JUMP_BUTTON) and self.canDoubleJump and self.player.doubleJump then
            self.canDoubleJump = false
            self.player.dy = -JUMP_BOOST
        else
            if love.keyboard.isDown(DOWN_BUTTON) then
                self.player.dy = self.player.dy + (GRAVITY*dt / 0.4)
            elseif self.player.floatState and love.keyboard.isDown(JUMP_BUTTON) then
                self.player.dy = self.player.dy + (GRAVITY*dt * 0.3)
            else
                self.player.dy = self.player.dy + (GRAVITY*dt)
            end
        end
    end
--moves player left and right while jumping, handles collisions
    if love.keyboard.isDown(RIGHT_BUTTON) then
        self.player.x = self.player.x + (PLAYER_WALK_SPEED * dt)
        if self.player:checkRightCollisions() or self.player:checkObjectCollisions() then
            self.player.x = self.player.x - (PLAYER_WALK_SPEED * dt)
        end
    elseif love.keyboard.isDown(LEFT_BUTTON)  then
        self.player.x = self.player.x - (PLAYER_WALK_SPEED * dt)
        if self.player:checkLeftCollisions()  or self.player:checkObjectCollisions() then
            self.player.x = self.player.x + (PLAYER_WALK_SPEED * dt)
        end
    end
    
    

    self.player.y = self.player.y + self.player.dy
    local obj = self.player:checkObjectCollisions()
    local tile = self.player:checkDownwardCollisions()

    if obj then
        self.player.y = self.player.y - self.player.dy
    end

    --handles collisions whilst moving upwards
    if self.player.dy < 0 and obj then
        if self.player.y > obj.y + obj.height then
            obj.onCollide(self.player.state, obj)
            self.player.dy = 0
        end
    end
    --handles collisions whilst moving downwards
    if self.player.y - self.player.height < self.player.level.height * TILE_SIZE then
        if (tile or obj) and self.player.dy > 0.5  then
            if obj and self.player.y < obj.y then --fall on obj
                self.player.y = obj.y - self.player.height
                self.player.dy = 0
                obj.onCollide(self.player.state, obj)
                self.player:changeState('idle')
            elseif tile and self.player.y + self.player.height < tile.yPos + 0.1 then --fall on tile
                self.player.dy = 0
                self.player:changeState('idle')
            end
        end
    end
end