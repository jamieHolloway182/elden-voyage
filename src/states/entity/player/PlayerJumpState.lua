PlayerJumpState = Class{__includes = BaseState}
--player jump state constructor, gives player upwards boost
function PlayerJumpState:init(player)
    self.player = player
    self.player.dy = -JUMP_BOOST
    gSounds['jump']:play()

    self.player.hitboxOffsetY = 0
end
--changes player to falling
function PlayerJumpState:update(dt)
    self.player:changeState('falling')
end