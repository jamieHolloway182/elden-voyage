require 'src/dependencies'
--code run on starting program
function love.load()
    math.randomseed(os.time())
    love.window.setTitle(GAME_TITLE)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.audio.setVolume(MASTER_VOLUME / 10)
    gSounds['bliss']:setVolume(MUSIC_VOLUME / 10)
--create virtual resolution screen
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    love.keyboard.keysPressed = {}
--create all game states
    gStateMachine = StateMachine {
        ['play'] = function() return PlayState() end,
        ['start'] = function() return StartState() end,
        ['end'] = function() return EndState() end,
        ['options'] = function() return OptionsState() end,
        ['high-score'] = function() return HighScoreState() end,
        ['score'] = function () return ScoreState() end
    }
    gStateMachine:change('start')
--play music
    gSounds['bliss']:setLooping(true)
    gSounds['bliss']:play()

end
--resizes screen
function love.resize(w, h)
    push:resize(w, h)
end
--updates state machine
function love.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end
--renders state machine
function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()

end
--called when any key pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    love.keyboard.keysPressed[key] = true
end
--returns boolean whether key was just pressed
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end
--loads high score list from file
function loadHighScores()
    love.filesystem.setIdentity('highscores')

    if not love.filesystem.getInfo('highscores.lst') then
        local scores = ''
        for i = 1, 10 do
            scores = scores .. tostring((10 - i) * 100) .. '\n'
        end
        love.filesystem.write('highscores.lst', scores)
    end

    local scores = {}
    local counter = 1

    for line in love.filesystem.lines('highscores.lst') do
        scores[counter] = tonumber(line)
        counter = counter + 1
    end

    return scores
end