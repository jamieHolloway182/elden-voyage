OptionsState = Class{__includes = BaseState}
--options state constructor
function OptionsState:enter(def)
    self.background = def.background or 1

    self.cursorValue = 0

    self.numOptions = 6

    self.elapsed = 0
    Timer.every(0.01,function()
        self.elapsed = self.elapsed + 0.01
    end)
end
--handles navigating through settings and then updating key variables when options changed
function OptionsState:update(dt)
    Timer.update(dt)
--handles leaving state
    if love.keyboard.wasPressed('return') then
        gStateMachine:change('start')
    end
--handles moving up and down between settings
    if love.keyboard.wasPressed("down") then
        gSounds['navigate']:play()
        self.cursorValue = (self.cursorValue + 1) % self.numOptions
    elseif love.keyboard.wasPressed("up") then
        gSounds['navigate']:play()
        self.cursorValue = (self.cursorValue - 1) % self.numOptions
    end
--handles editing settings with left and right keys
    if love.keyboard.wasPressed('left') then
        gSounds['select']:play()
        if self.cursorValue == 0 then
            GAME_MODE_COUNTER = (GAME_MODE_COUNTER - 1) % #GAME_MODES
        elseif self.cursorValue == 1 then
            PLAYER_TYPE_COUNTER = (PLAYER_TYPE_COUNTER - 1) % #PLAYER_TYPES
        elseif self.cursorValue == 2 then
            GAME_DIFFICULTY_COUNTER = math.max(1, GAME_DIFFICULTY_COUNTER - 1)
        elseif self.cursorValue == 3 then
            CONTROL_SCHEME_COUNTER = (CONTROL_SCHEME_COUNTER - 1) % #CONTROL_SCHEMES
        elseif self.cursorValue == 4 then
            MUSIC_VOLUME = math.max(MUSIC_VOLUME - 1, 0)
        elseif self.cursorValue == 5 then
            MASTER_VOLUME = math.max(MASTER_VOLUME - 1, 0)
        end
    elseif love.keyboard.wasPressed('right') then
        gSounds['select']:play()
        if self.cursorValue == 0 then
            GAME_MODE_COUNTER = (GAME_MODE_COUNTER + 1) % #GAME_MODES
        elseif self.cursorValue == 1 then
            PLAYER_TYPE_COUNTER = (PLAYER_TYPE_COUNTER + 1) % #PLAYER_TYPES
        elseif self.cursorValue == 2 then
            GAME_DIFFICULTY_COUNTER = math.min(5, GAME_DIFFICULTY_COUNTER + 1)
        elseif self.cursorValue == 3 then
            CONTROL_SCHEME_COUNTER = (CONTROL_SCHEME_COUNTER + 1) % #CONTROL_SCHEMES
        elseif self.cursorValue == 4 then
            MUSIC_VOLUME = math.min(MUSIC_VOLUME + 1, 10)
        elseif self.cursorValue == 5 then
            MASTER_VOLUME = math.min(MASTER_VOLUME + 1, 10)
        end
    end
--edits key variables based on user's settings
    CHOSEN_DIFFICULTY = GAME_DIFFICULTIES[GAME_DIFFICULTY_COUNTER]
    PLAYER_TYPE = PLAYER_TYPES[PLAYER_TYPE_COUNTER + 1]
    CONTROL_SCHEME = CONTROL_SCHEMES[CONTROL_SCHEME_COUNTER + 1]
    GAME_MODE = GAME_MODES[GAME_MODE_COUNTER + 1]
    love.audio.setVolume(MASTER_VOLUME / 10)
    gSounds['bliss']:setVolume(MUSIC_VOLUME / 10)

    self:updateControlScheme()
end
--renders options state
function OptionsState:render()
--renders background
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background],0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background],0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Options Page", 0, 5 , VIRTUAL_WIDTH, 'center')
--renders all different settings and their current values    
    love.graphics.setFont(gFonts['small'])
    if (self.cursorValue == 0 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 0) then
        love.graphics.printf('Game Mode: <'.. GAME_MODE ..'>', 0, 30 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 1 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 1) then
        love.graphics.printf('Player Type: <'.. PLAYER_TYPE ..'>', 0, 40 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 2 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 2) then
        love.graphics.printf('Game Difficulty: <' .. CHOSEN_DIFFICULTY .. '>', 0, 50 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 3 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 3) then
        love.graphics.printf('Control Scheme: <' .. CONTROL_SCHEME .. '>', 0, 60 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 4 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 4) then
        love.graphics.printf('Music Volume: <' .. MUSIC_VOLUME .. '>', 0, 70 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 5 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 5) then
        love.graphics.printf('Master Volume: <' .. MASTER_VOLUME .. '>', 0, 80 , VIRTUAL_WIDTH, 'center')
    end

    love.graphics.draw(gTextures[PLAYER_TYPE], gFrames[PLAYER_TYPE][1], 5, 5)
end
--updates control scheme
function OptionsState:updateControlScheme()
    if CONTROL_SCHEME == "WASD" then
        JUMP_BUTTON = "w"
        LEFT_BUTTON = "a"
        RIGHT_BUTTON = "d"
        DOWN_BUTTON = "s"
    elseif CONTROL_SCHEME == "Arrows-Space" then
        JUMP_BUTTON = "space"
        LEFT_BUTTON = "left"
        RIGHT_BUTTON = "right"
        DOWN_BUTTON = "down"
    elseif CONTROL_SCHEME == "Arrows" then
        JUMP_BUTTON = "up"
        LEFT_BUTTON = "left"
        RIGHT_BUTTON = "right"
        DOWN_BUTTON = "down"
    end
end