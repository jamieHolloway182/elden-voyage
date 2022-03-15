PlayerIdleState = Class{__includes = BaseState}
--player idle state constructor
function PlayerIdleState:init(player)
    self.player = player

    self.player.animation = Animation({
        frames = {1}
    })
    self.player.hitboxOffsetY = 0
end
--handles moving player out of idle state through walking, jumping or crouching
function PlayerIdleState:update(dt)
    if love.keyboard.isDown(LEFT_BUTTON) then
        self.player.direction = 'left'
        self.player:changeState('walking')
    elseif love.keyboard.isDown(RIGHT_BUTTON) then
        self.player.direction = 'right'
        self.player:changeState('walking')
    elseif love.keyboard.isDown(JUMP_BUTTON) then
        self.player:changeState('jump')
    elseif love.keyboard.wasPressed(DOWN_BUTTON) then
        self.player:changeState('crouch')
    end
end