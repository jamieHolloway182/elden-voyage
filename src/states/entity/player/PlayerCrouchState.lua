PlayerCrouchState = Class{__includes = BaseState}
--player crouch state constructor
function PlayerCrouchState:init(player)
    self.player = player

    self.player.animation = Animation({
        frames = {4}
    })
    self.player.hitboxOffsetY = 10
end
--checks if player is still crouching or if they have begun walking or jumping
function PlayerCrouchState:update(dt)
    if love.keyboard.isDown(LEFT_BUTTON) then
        self.player.direction = 'left'
        self.player:changeState('walking')
    elseif love.keyboard.isDown(RIGHT_BUTTON) then
        self.player.direction = 'right'
        self.player:changeState('walking')
    elseif love.keyboard.wasPressed(JUMP_BUTTON) then
        self.player:changeState('jump')
    end

    if not love.keyboard.isDown(DOWN_BUTTON) then
        self.player:changeState('idle')
    end
end