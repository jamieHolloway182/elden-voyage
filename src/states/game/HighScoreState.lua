HighScoreState = Class{__includes = BaseState}
--high score state constructor
function HighScoreState:enter(def)
    self.entry = def.entry
    self.background = def.background or 1
    self.highScores = loadHighScores()
end
--handles exiting high score state
function HighScoreState:update(dt)
    Timer.update(dt)

    if love.keyboard.wasPressed('return') then
        gStateMachine:change(self.entry and 'start' or 'end',{
        })
    end
end
--renders high score state
function HighScoreState:render()
    love.graphics.setColor(255, 255, 255, 1)
--render background
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("High Scores", 0, 0, VIRTUAL_WIDTH, "center")
--renders high score list
    love.graphics.setFont(gFonts['small'])
    for i = 1, 10 do
        love.graphics.printf(self.highScores[i], 0, 20 + 10 * i , VIRTUAL_WIDTH, "center")
    end
        
end