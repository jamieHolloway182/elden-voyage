EndState = Class{__includes = BaseState}
--end state constructor
function EndState:enter(def)
    self.fScore = def.score or 0
    self.score = self.fScore * SCORE_MULTIPLIER
    self.levelNum = def.levelNum or 1
    self.timePlayed = def.timePlayed or 0
    self.background = def.background or 1
    self.deadEnemies = def.deadEnemies or 0

    self.cursorValue = 0
    self.elapsed = 0
    Timer.every(0.01,function()
        self.elapsed = self.elapsed + 0.01
    end)

    self.highScores = loadHighScores()
    self:updateHighScores()
end
--updates cursor and navigation
function EndState:update(dt)
    Timer.update(dt)
    if love.keyboard.wasPressed('return') then
        if self.cursorValue == 0 then
            gStateMachine:change('start')
        elseif self.cursorValue == 1 then
            gStateMachine:change('high-score', {
                background = self.background,
                entry = false
            })
        elseif self.cursorValue == 2 then
            gStateMachine:change('score', {
                background = self.background,
                score = self.fScore,
                deadEnemies = self.deadEnemies,
                timePlayed = self.timePlayed
            })
        end
    end

    if love.keyboard.wasPressed('up') then
        gSounds['navigate']:play()
        self.cursorValue = (self.cursorValue - 1) % 3
    elseif love.keyboard.wasPressed('down') then
        gSounds['navigate']:play()
        self.cursorValue = (self.cursorValue + 1) % 3
    end
end
--renders end state
function EndState:render()
    love.graphics.setColor(255, 255, 255, 1)
--renders background
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
--renders score and level number
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(tostring(self.score), -6, 5, VIRTUAL_WIDTH, "right")
    love.graphics.printf(tostring(self.levelNum), -6, 19, VIRTUAL_WIDTH, "right")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(tostring(self.score), -7, 4, VIRTUAL_WIDTH, "right")
    love.graphics.printf(tostring(self.levelNum), -7, 18, VIRTUAL_WIDTH, "right")
--calculates and renders time
    local minutes = math.floor(self.timePlayed / 60)
    local seconds = math.floor(self.timePlayed % 60)
    love.graphics.printf(string.format("%02d:%02d", minutes, seconds), 0, 0, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Game Over!", 0, VIRTUAL_HEIGHT / 6, VIRTUAL_WIDTH, "center")
--renders navigation options
    love.graphics.setFont(gFonts['small'])
    if (self.cursorValue == 0 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 0) then
        love.graphics.printf('Home Screen', 0, 60 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 1 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 1) then
        love.graphics.printf('High-Scores', 0, 70 , VIRTUAL_WIDTH, 'center')
    end
end


--updates high score list with players score
function EndState:updateHighScores()  
    local scoreIndex = 11

    for i = 10, 1, -1 do
        local score = self.highScores[i] or 0
        if self.score > score then
            scoreIndex = i
        end
    end

    for i = 10, scoreIndex, -1 do
        self.highScores[i + 1] =  self.highScores[i]
    end

    if scoreIndex <= 10 then
        self.highScores[scoreIndex] = self.score
    end

    local scoresStr = ''

    for i = 1, 10 do
        scoresStr = scoresStr .. tostring(self.highScores[i]) .. '\n'
    end

    love.filesystem.write('highscores.lst', scoresStr)
end