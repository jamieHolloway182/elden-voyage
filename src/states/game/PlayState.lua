PlayState = Class{__includes = BaseState}
--play state constructor
function PlayState:enter(def)
    self.sx = 1
    self:adjustDifficulty()

    self.backgroundX = 0
    self.renderDistance = 10 --number of tiles rendered in each direction
    self.gameLevel = def.level or GameLevel({
        width = def.width or 50,
        height = 9
    })

    self.gameOver = false

    self.levelNum = def.levelNum or 1
    self.background = def.background or math.random(1, 3)

    self.camX = 0
    self.camY = 0
--creates player with all their states
    self.player = Player({
        x = 0, y = -TILE_SIZE * 4,
        width = 15, height = 20,
        offsetX = 0,
        texture = PLAYER_TYPE,
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player) end,
            ['falling'] = function() return PlayerFallState(self.player) end,
            ['attacking'] = function() return PlayerAttackState(self.player) end,
            ['crouch'] = function() return PlayerCrouchState(self.player) end
        },
        health = PLAYER_HEALTH,
        level = self.gameLevel.level,
        score = def.score or 0,
        state = self
    })

    self.player:changeState('falling')

    self.paused = false
    self.timePlayed = def.timePlayed or 0
    self.levelTimePlayed = 0
    Timer.every(0.01, function()
        if not self.gameOver then 
            self.timePlayed = self.timePlayed + 0.01
            self.levelTimePlayed = self.levelTimePlayed + 0.01
            if GAME_MODE == "Screen Scroller" then
                if self.levelTimePlayed > 2 then
                    self.camX = math.min(self.camX + SCROLL_SPEED, self.gameLevel.width * TILE_SIZE - VIRTUAL_WIDTH)
                end
            end
        end
    end)

    Timer.every(1, function()
        print(love.timer.getFPS())
    end)

    self.alpha = 1

    self:spawnEnemies()
end
--updates play state
function PlayState:update(dt)
--handles pausing and unpausing
    if love.keyboard.wasPressed("p") and not self.gameOver then
        gSounds['pause']:play()
        self.paused = not self.paused
    end
--updates level, player and camera if not paused
    if not self.paused then
        if not self.gameOver then
            self.player:update(dt)
            if self.levelTimePlayed > 0.7 then 
                self:updateCamera()
            else
                self.player.x = 0
            end
        end
        Timer.update(dt)
        self.gameLevel:update(dt)
    end
--handles ending the game if player falls or runs out of health
    if not self.gameOver then
        if (self.player.health <= 0 or self.player.y > self.player.level.height * TILE_SIZE) then
            self:endGame()
        elseif GAME_MODE == "Screen Scroller" then
            if (self.camX > self.player.x + self.player.width) or (self.player.x > self.camX + VIRTUAL_WIDTH) then
                self:endGame()
            end
        end
    end
end
--renders play state
function PlayState:render()
--renders background
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], -self.backgroundX, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], -self.backgroundX,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.push()
--translates and scales camera
    love.graphics.translate(-math.floor(self.camX) * self.sx, -math.floor(self.camY) * self.sx)
    love.graphics.scale(self.sx, self.sx)
--renders objects and entities
    self.gameLevel:renderObjs(false)
    self.gameLevel:renderEnts(false)
--renders level and player
    self.gameLevel:renderLevel()
    self.player:render()

    self.gameLevel:renderObjs(true)
    self.gameLevel:renderEnts(true)

    love.graphics.pop()
--renders player health bar
    for i=0, PLAYER_HEALTH - 1 do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][self.player.health > i and 5 or 1],
        i*16 + 5, 5, 0, 0.9, 0.9)
    end
--renders powerup symbol
    if self.player.powerup then
        self.player.powerup:renderSymbol(5)
    end
--renders score and level num
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(tostring(self.player.score), -6, 5, VIRTUAL_WIDTH, "right")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(tostring(self.player.score), -7, 4, VIRTUAL_WIDTH, "right")
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(tostring(self.levelNum), -6, 19, VIRTUAL_WIDTH, "right")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(tostring(self.levelNum), -7, 18, VIRTUAL_WIDTH, "right")
--calculates and renders time played
    local minutes = math.floor(self.timePlayed / 60)
    local seconds = math.floor(self.timePlayed % 60)
    love.graphics.printf(string.format("%02d:%02d", minutes, seconds), 0, 0, VIRTUAL_WIDTH, "center")
    if not self.paused then
    end
--renders paused symbol
    if self.paused then 
        love.graphics.printf("paused", 0, 0, VIRTUAL_WIDTH, "center")
    end
--renders game over on death
    if self.gameOver then 
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("Game Over!", 0, VIRTUAL_HEIGHT / 6, VIRTUAL_WIDTH, "center")
    end
end
--updates camera with player's x coord
function PlayState:updateCamera()
    if GAME_MODE== "Classic" then
        self.camX = math.max(0,
            math.min(TILE_SIZE * self.gameLevel.width - VIRTUAL_WIDTH, self.player.x -(VIRTUAL_WIDTH / 2 - 8)))
    end
    self.camY = math.min(0, self.player.y - 2)
    self.backgroundX = (self.camX / 3) % 256
end
--spawns enemies into the level
function PlayState:spawnEnemies()
    for x = 1, self.gameLevel.level.width do
        local groundFound = false

        for y = 1, self.gameLevel.level.height do
            if not groundFound then
                if self.gameLevel.level.tiles[x][y].id == TILE_ID_GROUND then
                    groundFound = true
                    if math.random(SPAWN_ENEMY_CHANCE) == 1 and contains(self.gameLevel.level.freeSpots, x) and x ~= self.gameLevel.width and x > 3 then
                        local eT = math.random(4)
                        if eT == 1 then --spawn snail
                            local snail
                            snail = Snail{
                                texture = 'enemies',
                                x = (x - 1) * TILE_SIZE,
                                y = (y - 2) * TILE_SIZE,
                                width = 14,
                                height = 10,
                                offsetX = 1,
                                offsetY = 6,
                                type = math.random(2),
                                stateMachine = StateMachine {
                                    ['idle'] = function() return SnailIdleState(self.gameLevel, self.player, snail) end,
                                    ['walk'] = function() return SnailWalkState(self.gameLevel, self.player, snail) end
                                },
                                level = self.gameLevel.level,
                                enemyType = 'snail'
                            }
                            snail:changeState('idle')

                            table.insert(self.gameLevel.entities, snail)
                        elseif eT >= 2 then --spawn fly
                            local fly
                            fly = Fly{
                                texture = 'enemies',
                                x = (x - 1) * TILE_SIZE,
                                y = (y - 4) * TILE_SIZE,
                                width = 16,
                                height = 16,
                                type = math.random(2),
                                stateMachine = StateMachine {
                                    ['idle'] = function() return FlyIdleState(self.gameLevel, self.player, fly) end,
                                    ['move'] = function() return FlyMoveState(self.gameLevel, self.player, fly) end,
                                    ['attack'] = function() return FlyAttackState(self.gameLevel, self.player, fly) end
                                },
                                level = self.gameLevel.level,
                                enemyType = 'fly'
                            }
                            fly:changeState('idle')

                            table.insert(self.gameLevel.entities, fly)
                        elseif eT == 3 then --spawn blob
                            local blob
                            blob = Blob{
                                texture = 'enemies',
                                x = (x - 1) * TILE_SIZE,
                                y = (y - 2) * TILE_SIZE,
                                width = 16,
                                height = 8,
                                offsetY = 8,
                                type = math.random(6),
                                stateMachine = StateMachine {
                                    ['idle'] = function() return BlobIdleState(self.gameLevel, self.player, blob) end,
                                    ['attack'] = function() return BlobAttackState(self.gameLevel, self.player, blob) end
                                },
                                level = self.gameLevel.level,
                                enemyType = 'blob'
                            }
                            blob:changeState('idle')
                            table.insert(self.gameLevel.entities, blob)
                        elseif eT == 4 then --spawn boomba
                            local boomba
                            boomba = Boomba{
                                texture = 'enemies',
                                x = (x - 1) * TILE_SIZE,
                                y = (y - 4) * TILE_SIZE,
                                width = 16,
                                height = 16,
                                stateMachine = StateMachine {
                                    ['idle'] = function() return BoombaIdleState(self.gameLevel, self.player, boomba) end,
                                    ['attack']  = function() return BoombaAttackState(self.gameLevel, self.player, boomba) end,
                                    ['move']  = function() return BoombaMoveState(self.gameLevel, self.player, boomba) end
                                },
                                level = self.gameLevel.level,
                                enemyType = 'boomba'
                            }
                            boomba:changeState('move')

                            table.insert(self.gameLevel.entities, boomba)
                        end
                    end
                end
            end
        end
        if not groundFound then
            if math.random(math.floor(SPAWN_ENEMY_CHANCE * 1.5)) == 1 then  --spawn fish
                local fish
                fish = Fish{
                    texture = 'enemies',
                    x = (x - 1) * TILE_SIZE,
                    y = VIRTUAL_HEIGHT - 20,
                    width = 16,
                    height = 16,
                    renderAbove = false,
                    stateMachine = StateMachine {
                        ['idle'] = function() return FishIdleState(self.gameLevel, self.player, fish) end,
                        ['attack'] = function() return FishAttackState(self.gameLevel, self.player, fish) end
                    },
                    level = self.gameLevel.level,
                    enemyType = 'fish'
                }
                fish:changeState('idle')
                table.insert(self.gameLevel.entities, fish)
            end
        end
    end
end
--changes current difficulty determined by player's performance
function PlayState:adjustGameDifficulty()
    local lostHealth = PLAYER_HEALTH - self.player.health
    if GAME_DIFFICULTY == "Easy" then
        if lostHealth == 0 then
            GAME_DIFFICULTY = "Normal"
        end
    elseif GAME_DIFFICULTY == "Normal" then
        if lostHealth == 0 then
            GAME_DIFFICULTY = "Hard"
        elseif lostHealth >= 3 then
            GAME_DIFFICULTY = "Easy"
        end
    elseif GAME_DIFFICULTY == "Hard" then
        if lostHealth == 0 then
            GAME_DIFFICULTY = "Extreme"
        elseif lostHealth == 3 then
            GAME_DIFFICULTY = "Normal"
        end
    elseif GAME_DIFFICULTY == "Extreme" then
        if lostHealth == 2 then
            GAME_DIFFICULTY = "Hard"
        end
    end
end
--uses current difficulty to change in game difficulty ie level gen, enemy spawn amount etc.
function PlayState:adjustDifficulty()
    if GAME_DIFFICULTY == "Easy" then
        SCORE_MULTIPLIER = 1.2
        PLAYER_HEALTH = 6
        SPAWN_ENEMY_CHANCE = 10
        PROB_SWITCH_TO_WATER = 0.1
        SCROLL_SPEED = 0.4
    elseif GAME_DIFFICULTY == "Normal" then
        SCORE_MULTIPLIER = 1.4
        PLAYER_HEALTH = 5
        SPAWN_ENEMY_CHANCE = 8
        PROB_SWITCH_TO_WATER = 0.15
        SCROLL_SPEED = 0.5
    elseif GAME_DIFFICULTY == "Hard" then
        SCORE_MULTIPLIER = 1.6
        PLAYER_HEALTH = 4
        SPAWN_ENEMY_CHANCE = 7 
        PROB_SWITCH_TO_WATER = 0.2
        PROB_SWITCH_TO_LAND = 0.7
        SCROLL_SPEED = 0.6
    elseif GAME_DIFFICULTY == "Extreme" then
        SCORE_MULTIPLIER = 1.8
        PLAYER_HEALTH = 3
        SPAWN_ENEMY_CHANCE = 6
        PROB_SWITCH_TO_WATER = 0.25
        PROB_SWITCH_TO_LAND = 0.65
        SCROLL_SPEED = 0.75
    elseif GAME_DIFFICULTY == "Impossible" then
        SCORE_MULTIPLIER = 2
        PLAYER_HEALTH = 1
        SPAWN_ENEMY_CHANCE = 4
        PROB_SWITCH_TO_WATER = 0.3
        PROB_SWITCH_TO_LAND = 0.6
        SCROLL_SPEED = 0.95
    end
    if GAME_MODE == "Screen Scroller" then
        PLAYER_HEALTH = 4
    end
end
--handles starting a new level once player completes one
function PlayState:newLevel()
    gSounds['victory']:play()
    self.player.score = self.player.score + 100
    self:finishPowerup()
    self:adjustGameDifficulty()
    gStateMachine:change("play", {
        score = self.player.score,
        width = self.gameLevel.width + 10,
        levelNum = self.levelNum + 1,
        timePlayed = self.timePlayed
    })
end
--end's game when player dies
function PlayState:endGame()
    gSounds['death']:play()
    self.gameOver = true
    self:finishPowerup()
    Timer.after(GAME_END_TIME, function()
        gStateMachine:change('end', {
            score = self.player.score,
            levelNum = self.levelNum,
            timePlayed = self.timePlayed,
            background = self.background
        })
    end)
    Timer.tween(GAME_END_TIME, {
        [self] = {alpha = 0}
    })
end
--removes powerup
function PlayState:finishPowerup()
    if self.player.powerup then
        if self.player.powerup.onFinish then
            self.player.powerup.onFinish(self, self.player.powerup)
            self.player.powerup = nil
        end
    end
end