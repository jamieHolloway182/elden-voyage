--requires all libraries
Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
require 'lib/slam'
--requires all files in project
require 'src/constants'
require 'src/globals'
require 'src/util'
require 'src/Animation'
require 'src/states/game/BaseState'
require 'src/StateMachine'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'
require 'src/states/game/EndState'
require 'src/states/game/OptionsState'
require 'src/states/game/HighScoreState'
require 'src/states/entity/player/PlayerWalkState'
require 'src/states/entity/player/PlayerJumpState'
require 'src/states/entity/player/PlayerFallState'
require 'src/states/entity/player/PlayerIdleState'
require 'src/states/entity/player/PlayerCrouchState'
require 'src/states/entity/enemy/snail/SnailIdleState'
require 'src/states/entity/enemy/snail/SnailWalkState'
require 'src/states/entity/enemy/fly/FlyIdleState'
require 'src/states/entity/enemy/fly/FlyMoveState'
require 'src/states/entity/enemy/fly/FlyAttackState'
require 'src/states/entity/enemy/blob/BlobIdleState'
require 'src/states/entity/enemy/blob/BlobAttackState'
require 'src/states/entity/enemy/boomba/BoombaIdleState'
require 'src/states/entity/enemy/boomba/BoombaMoveState'
require 'src/states/entity/enemy/boomba/BoombaAttackState'
require 'src/states/entity/enemy/fish/FishIdleState'
require 'src/states/entity/enemy/fish/FishAttackState'
require 'src/classes/Entity'
require 'src/classes/Player'
require 'src/classes/Object'
require 'src/classes/Enemy'
require 'src/classes/Powerup'
require 'src/classes/Projectile'
require 'src/classes/enemies/Snail'
require 'src/classes/enemies/Fly'
require 'src/classes/enemies/Blob'
require 'src/classes/enemies/Boomba'
require 'src/classes/enemies/Fish'
require 'src/Level'
require 'src/GameLevel'
require 'src/Tile'
--dictionary of all graphics / sprites
gTextures = {
    ['backgrounds'] = love.graphics.newImage('graphics/backgrounds.png'),
    ['green-alien'] = love.graphics.newImage('graphics/green_alien.png'),
    ['blue-alien'] = love.graphics.newImage('graphics/blue_alien.png'),
    ['pink-alien'] = love.graphics.newImage('graphics/pink_alien.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['flag-poles'] = love.graphics.newImage('graphics/flags.png'),
    ['flags'] = love.graphics.newImage('graphics/flags.png'),
    ['traps'] = love.graphics.newImage('graphics/ladders_and_signs.png'),
    ['bushes'] = love.graphics.newImage('graphics/bushes.png'),
    ['water'] = love.graphics.newImage('graphics/water.png'),
    ['blocks'] = love.graphics.newImage('graphics/blocks.png'),
    ['sheet'] = love.graphics.newImage('graphics/sheet.png'),
    ['mushrooms'] = love.graphics.newImage('graphics/mushrooms.png'),
    ['platforms'] = love.graphics.newImage('graphics/mushrooms.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png'),
    ['enemies'] = love.graphics.newImage('graphics/creatures.png'),
    ['gems'] = love.graphics.newImage('graphics/gems.png'),
    ['bombs-coins'] = love.graphics.newImage('graphics/coins_and_bombs.png'),
    ['explosion'] = love.graphics.newImage('graphics/explosion.png'),
    ['fireball'] = love.graphics.newImage('graphics/fireballs.png'),
    ['wings'] = love.graphics.newImage('graphics/wings.png')

}
--dictionary of all sprite quads
gFrames = {
    ['backgrounds'] = GenerateQuads(gTextures['backgrounds'], 256, 128),
    ['green-alien'] = GenerateQuads(gTextures['green-alien'], 16, 20),
    ['blue-alien'] = GenerateQuads(gTextures['blue-alien'], 16, 20),
    ['pink-alien'] = GenerateQuads(gTextures['pink-alien'], 16, 20),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 16, 16),
    ['flag-poles'] = GenerateQuads(gTextures['flag-poles'], 16, 48),
    ['flags'] = GenerateQuads(gTextures['flags'], 16, 16),
    ['traps'] = GenerateQuads(gTextures['traps'], 16, 16),
    ['bushes'] = GenerateQuads(gTextures['bushes'], 16, 16),
    ['water'] = GenerateQuads(gTextures['water'], 16, 16),
    ['blocks'] = GenerateQuads(gTextures['blocks'], 16, 16),
    ['sheet'] = GenerateQuads(gTextures['sheet'], 70, 70, 2, 2),
    ['mushrooms'] = GenerateQuads(gTextures['mushrooms'], 16, 16),
    ['platforms'] = GenerateQuads(gTextures['mushrooms'], 16, 8),
    ['enemies'] = GenerateQuads(gTextures['enemies'], 16, 16),
    ['particle'] = GenerateQuads(gTextures['particle'], 8, 8),
    ['gems'] = GenerateQuads(gTextures['gems'], 16, 16),
    ['bombs-coins'] = GenerateQuads(gTextures['bombs-coins'], 16, 16),
    ['explosion'] = GenerateQuads(gTextures['explosion'], 16, 16),
    ['fireball'] = GenerateQuads(gTextures['fireball'], 16, 16),
    ['wings'] = GenerateQuads(gTextures['wings'], 16, 16)
}
--dictionary of all fonts
gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}
--dictionary of all sounds
gSounds = {
    ['death'] = love.audio.newSource('sounds/death.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
    ['pickup'] = love.audio.newSource('sounds/pickup.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['navigate'] = love.audio.newSource('sounds/navigate.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['kill'] = love.audio.newSource('sounds/kill.wav', 'static'),
    ['empty'] = love.audio.newSource('sounds/empty.wav', 'static'),
    ['powerup'] = love.audio.newSource('sounds/powerup.wav', 'static'),
    ['shoot'] = love.audio.newSource('sounds/shoot.wav', 'static'),
    ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
    ['bliss'] = love.audio.newSource('sounds/bliss.mp3', 'static'),
    ['explosion'] = love.audio.newSource('sounds/explosion.mp3', 'static')
}