StartState = Class{__includes = BaseState}
--start state constructor
function StartState:init()
    self.cursorValue = 0

    self.background = math.random(1, 3)

    self.elapsed = 0
    Timer.every(0.01,function()
        self.elapsed = self.elapsed + 0.01
    end)

    GAME_DIFFICULTY = CHOSEN_DIFFICULTY
end
--updates start state with navigation
function StartState:update(dt)
    Timer.update(dt)
    --when enter clicked, decides which state to begin
    if love.keyboard.keysPressed["return"] then
        gSounds['select']:play()
        if self.cursorValue == 0 then
            gStateMachine:change("play", {
                level = self.gameLevel,
                background = self.background
            })
        else 
            gStateMachine:change("options", {
                background = self.background
            })
        end
    end
--moves cursor up or down
    if love.keyboard.wasPressed('down') then
        gSounds['navigate']:play()
        self.cursorValue = (self.cursorValue + 1) % 2
    elseif love.keyboard.wasPressed('up') then
        gSounds['navigate']:play()
        self.cursorValue = (self.cursorValue - 1) % 2
    end
end
--renders start state
function StartState:render()
--renders background
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background],0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background],0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf(GAME_TITLE, 0, 5 , VIRTUAL_WIDTH, 'center')
--renders navigation options
    love.graphics.setFont(gFonts['small'])
    if (self.cursorValue == 0 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 0) then
        love.graphics.printf('Start Game', 0, 20 , VIRTUAL_WIDTH, 'center')
    end
    if (self.cursorValue == 1 and math.floor(self.elapsed / 0.1) % 2 == 0) or (self.cursorValue ~= 1) then
        love.graphics.printf('Options', 0, 30 , VIRTUAL_WIDTH, 'center')
    end
end