Level = Class{}
--level constructor
function Level:init(width, height)
    self.width = width 
    self.height = height

    self.objects = {}
    self.entities = {}

    self.freeSpots = {}
    self.tiles = {}
    self:createLevel()

    self.updated = false

end
--creates procedurally generated level
function Level:createLevel()

    local tileID = TILE_ID_GROUND
    local tileset = math.random(#TILE_IDS / 2) * 2 --random tileset picked
    local topperset = math.random(20) --random topperset
    local waterType = math.random(2) + 2
    
    local lastHeight = 7 --height of first column

    local gap = false --start on solid column
    local gapSize = 0 --initialises gap size counter

    for x=1, self.width do --through width of entire level
        column = {} --new column
        if (gap or (math.random() > 1- PROB_SWITCH_TO_WATER and not gap)) and (x > 3 and x < self.width - 3) then --create gap column here
            for y=1, self.height do --creates column top to bottom
                table.insert(column, Tile(x, y, tileset, TILE_ID_EMPTY, false, topperset)) --creates gap tile
                if y == self.height - 1 then
                    --inserts water at bottom of column
                    table.insert(self.objects, Object{
                        texture = 'water',
                        x = (x-1) * TILE_SIZE,
                        y = (self.height - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        renderAbove = true,

                        frame = waterType,
                        load = function(obj)
                            Timer.every(0.3, function()
                                obj.scaleX = obj.scaleX * - 1
                                if obj.scaleX == -1 then
                                    obj.x = obj.x + obj.width
                                else
                                    obj.x = obj.x - obj.width
                                end
                            end)
                        end
                    })
                end
            end

            gap = math.random() > PROB_SWITCH_TO_LAND --picks if next column wil be gap randomly
            gapSize = gapSize + 1
        else --create land column here

            if gapSize > 5 then --platforms need to be created
                local numPlatforms = math.floor(gapSize / 6) --number of platforms needed
                if gapSize % 2 == 0 then
                    local startPoint = gapSize - ((gapSize - ((2*numPlatforms) + 4*(numPlatforms-1))) / 2) --start of first platform
                    for i=1, numPlatforms do --creates all necessary platforms
                        local platformStart = math.max(x-startPoint + (i-1)*6, x - gapSize + 1) --start of current platform
                        local platformEnd = platformStart + math.random(1,2) --random end of platform
                        local height = math.random(6,7) --random platform height
                        self:insertPlatform(platformStart, platformEnd, height, 
                        tileset, tileID, true, topperset) --creates platform
                    end
                else
                    local startPoint = gapSize - ((gapSize + 1 - ((2*numPlatforms) + 4*(numPlatforms-1))) / 2)
                    for i=1, numPlatforms do
                        local height = math.random(6,7)
                        self:insertPlatform(x-startPoint + (i-1)*6 , x-startPoint + (i-1)*6 + 1, height, 
                        tileset, tileID, true, topperset)
                    end
                    local startPoint = gapSize - ((gapSize - 3) / 2)
                    self:insertPlatform(x-startPoint, x-startPoint + 2, 6, tileset, tileID, true, topperset)
                end 
            end
            gap = false --not a gap column
            gapSize = 0 --gapsize counter reset
            local top = 0 --initialise top
            local maxHeight = 9 --maximum height of solid tiles
            local minHeight = 6 --minimum height of solid tiles
            top = math.max(minHeight, math.min(maxHeight,lastHeight + math.random(-1,1))) --new height based on last height
            lastHeight = top --sets last height to current heigh, so next column can repeat


            for y=1, self.height do --creates a column from top to bottom
                if y == top then --if top of column
                    table.insert(column, Tile(x, y, tileset, tileID, true, topperset)) --insert solid topper tle
                    local rand = math.random(8)
                    local xPos = (x-1) * TILE_SIZE
                    local yPos =  VIRTUAL_HEIGHT - 16 - (self.height - top + 1) * TILE_SIZE
                    if x > 3 and x < self.width - 3 then
                        --inserts random object
                        if rand == 1 then
                            self:insertTrap(xPos, yPos)
                        elseif rand == 2 then
                            self:insertBush(xPos, yPos)
                        elseif rand == 3 then
                            self:insertMushrooms(xPos, yPos)
                        elseif rand == 4 then
                            self:insertBlock(xPos,yPos - TILE_SIZE * 2)
                        else    
                            table.insert(self.freeSpots, x)
                        end
                    end
                elseif y < top then --if above column
                    table.insert(column, Tile(x, y, tileset, TILE_ID_EMPTY, false, topperset))--insert empty tile
                else
                    table.insert(column, Tile(x, y, tileset, tileID, false, topperset)) --insert solid tile
                end
            end
            --insert flag at end of level
            if x == self.width then
                self:insertFlag(VIRTUAL_HEIGHT - 48 - (self.height - top + 1) * TILE_SIZE)
            end
        end
        table.insert(self.tiles, column) --insert column into 2d array
    end
end
--insert platform, multiple tiles from start to end x coords
function Level:insertPlatform(startX, endX, y, tileset, tileId, topper, topperSet)
    for x=startX, endX do
        self.tiles[math.floor(x)][y] = Tile(x, y, tileset, tileId, topper, topperSet)
    end 
end
--inserts flag to level
function Level:insertFlag(yPos)
    local flagType = math.random(3, 6)
    table.insert(self.objects,
        Object({
            texture = 'flag-poles',
            x = (self.width - 1) * TILE_SIZE,
            y = yPos,
            width = 6,
            height = 48,

            offsetX = 5,

            -- make it a random variant
            frame = flagType,
            collidable = true,
            solid = false,

            -- collision function takes itself
            onCollide = function(state)
                state:newLevel()
            end
    }))

    table.insert(self.objects,
        Object({
            texture = 'flags',
            x = (self.width - 1) * TILE_SIZE + 8,
            y = yPos,
            width = 16,
            height = 16,
            scaleX = -1, 

            -- make it a random variant
            frame = 9 * (flagType - 2),
            animation = Animation({
                frames = {9 * (flagType - 2) - 2, 9 * (flagType - 2) - 1, 9 * (flagType - 2)},
                interval = 0.2
            })
    }))
end
--insert trap at the given x and y coordinate
function Level:insertTrap(xPos, yPos)
    table.insert(self.objects,
        Object({
            texture = 'traps',
            x = xPos,
            y = yPos,
            width = 12,
            height = 8,

            offsetX = 2,
            offsetY = 9,

            frame = math.random(2) == 1 and 7 or 14,
            collidable = true,
            solid = false,
            onCollide = function(state)
                state.player:negateHealth(1)
            end
        })
    )
end
--insert block into level
function Level:insertBlock(xPos, yPos)
    table.insert(self.objects, 
        Object({
            texture = 'blocks',
            x = xPos,
            y = yPos,
            width = 16,
            height = 16,
            params = {
                collided = false
            },
            solid = true,
            explodable = true,
            collidable = true,
            onCollide = function(state, obj)
                if state.player.dy < 0 and state.player.y > obj.y then --if player is jumping up onto bottom of block
                    if not obj.params.collided then
                        gSounds['powerup']:play()
                        obj.params.collided = true

                        table.insert(self.objects, self:insertPowerup(xPos, yPos, state, obj))
                    else
                        gSounds['empty']:play()
                    end
                end
            end,
            frame = math.random(30)
        })
    )
end
--returns random powerup that is at given x and y coordinate
function Level:insertPowerup(xPos, yPos, state, obj)
    local randNum = math.random(6)
    if randNum == 1 then
        return self:createGem(xPos, yPos, state, obj)
    elseif randNum == 2 then
        return self:createBomb(xPos, yPos, state, obj)
    elseif randNum == 3 then
        return self:createStar(xPos, yPos, state, obj)
    elseif randNum == 4 then
        return self:createHeart(xPos, yPos, state, obj)
    elseif randNum == 5 then
        return self:createFireball(xPos, yPos, state, obj)
    else
        return self:createWings(xPos, yPos, state, obj)
    end
end
--returns gem powerup
function Level:createGem(xPos, yPos, state, obj)
    local type = math.random(8)
    return Powerup ({
        texture = 'gems',
        x = obj.x,
        y = obj.y,
        width = 16,
        height = 16,
        frame = type,

        consumable = true,
        onConsume = function(state, obj)
            gSounds['pickup']:play()
            state.player.score = obj.frame > 4 and state.player.score + 50 or state.player.score + 30
        end
    })
end
--returns bomb powerup
function Level:createBomb(xPos, yPos, state, obj)
    return Powerup ({
        texture = 'bombs-coins',
        x = obj.x,
        y = obj.y,

        width = 16,
        height = 16,

        frame = 4,

        collectable = true,
        onCollect = function(state, obj)
            state.player:setPowerup(obj)
        end,

        onUse = function(state, obj)
            table.insert(self.objects, Projectile({
                x = state.player.x,
                y = state.player.y,

                state = state,

                dx = state.player.direction == 'right' and 80 or - 80,
                dy = -150, 

                width = 16,
                height = 16,

                texture = 'bombs-coins',
                frame = 4,
                renderAbove = true,

                updatePosition = function(dt, obj)
                    obj.dy = obj.dy + (250 * dt)
                end,

                onCollide = function(state, obj)
                    gSounds['explosion']:play()
                    obj:explosionPsystem()
                    obj.collisionX = obj.x
                    obj.collisionY = obj.y
                    obj.psystem:emit(150)

                    for k, entity in pairs(state.player.level.entities) do
                        if entity.alive and not entity.invincible then
                            if ((obj.x - entity.x) ^ 2) + ((obj.y - entity.y) ^ 2) < 1000 then
                                entity.alive = false
                            end
                        end
                    end  
                end
            }))
        end
    })
end
--returns fireball powerup
function Level:createFireball(xPos, yPos, state, obj)
    return Powerup ({
        texture = 'fireball',
        x = obj.x,
        y = obj.y,

        width = 16,
        height = 16,

        frame = 4,

        collectable = true,
        onCollect = function(state, obj)
            state.player:setPowerup(obj)
        end,

        onUse = function(state, obj)
            table.insert(self.objects, Projectile({
                x = state.player.x,
                y = state.player.y,

                state = state,

                dx = state.player.direction == 'right' and 150 or - 150,
                dy = 0,

                width = 16,
                height = 16,

                texture = 'fireball',
                frame = 4,
                renderAbove = true,
                animation = Animation({
                    frames = state.player.direction == 'right' and {3, 4, -3.5, -4.5} or {3.5, 4.5, -3, -4},
                    interval = 0.2
                }),
                onCollide = function(state, obj)
                    obj:explosionPsystem()
                    obj.collisionX = obj.x
                    obj.collisionY = obj.y
                    obj.psystem:emit(150)
                    gSounds['explosion']:play()

                    for k, entity in pairs(state.player.level.entities) do
                        if entity.alive and not entity.invincible then
                            if ((obj.x - entity.x) ^ 2) + ((obj.y - entity.y) ^ 2) < 1000 then
                                entity.alive = false
                            end
                        end
                    end  
                end
            }))
        end
    })
end
--return wings powerup
function Level:createWings(xPos, yPos, state, obj)
    return Powerup ({
        texture = 'wings',
        x = obj.x,
        y = obj.y,
        width = 16,
        height = 16,
        frame = 1,
        consumable = true,
        onConsume = function(state, obj)
            state.player:setPowerup(obj, 5)
            state.player.doubleJump = true
        end,
        onFinish = function(state, obj)
            state.player.doubleJump = false
        end
    })
end
--return star powerup
function Level:createStar(xPos, yPos, state, obj)
    return Powerup ({
        texture = 'hearts',
        x = obj.x,
        y = obj.y,
        width = 16,
        height = 16,
        frame = 6,
        consumable = true,
        onConsume = function(state, obj)
            gSounds['bliss']:setPitch(2)
            state.player:setPowerup(obj, 5)
            state.player.invincible = true
            state.player.crazyMode = true
            PLAYER_WALK_SPEED = 150
        end,
        onFinish = function(state, obj)
            state.player.invincible = false
            state.player.crazyMode = false
            gSounds['bliss']:setPitch(1)
            PLAYER_WALK_SPEED = 100
        end
    })
end
--return heart powerup
function Level:createHeart(xPos, yPos, state, obj)
    return Powerup ({
        texture = 'hearts',
        x = obj.x,
        y = obj.y,
        width = 16,
        height = 16,
        frame = 5,
        consumable = true,
        onConsume = function(state, obj)
            state.player.health = math.min(state.player.health + 1, PLAYER_HEALTH)
        end
    })
end
--inserts bush into level
function Level:insertBush(xPos, yPos)
    table.insert(self.objects,
        Object({
            texture = 'bushes',
            x = xPos,
            y = yPos,
            width = 16,
            height = 16,

            frame = math.random(14)
        })
    )
end
--insert mushroom into level
function Level:insertMushrooms(xPos, yPos)
    table.insert(self.objects,
        Object({
            texture = 'mushrooms',
            x = xPos,
            y = yPos,
            width = 4,
            height = 16,
            offsetX = 6,

            params = {
                numJumps = 0
            },

            frame = math.random(8) * 5 + math.random(3),
            collidable = true,
            onCollide = function(state, obj)--make player jump if they are falling, above mushroom and mushroom is large
                if state.player.dy > 0 and state.player.y + state.player.height / 2 <= obj.y and obj.frame % 5 == 3 then
                    if obj.params.numJumps < 40 then
                        state.player:changeState('jump')
                    end
                    if obj.params.numJumps == 40 then
                        obj.animation = Animation({
                            frames = {obj.frame - 2}
                        })
                    end 
                    obj.params.numJumps = obj.params.numJumps + 1
                end
            end
        })
    )
end
--renders all tiles
function Level:render()
    for k, column in pairs(self.tiles) do
        for k, tile in pairs(column) do
            tile:render()
        end
    end
end
--returns tile at given x y coord
function Level:findTile(x, y)
    if x < 0 or x > self.width * TILE_SIZE or y < 0 or y > self.height * TILE_SIZE then
        return nil
    end
    
    return self.tiles[math.min(math.floor(x / TILE_SIZE) + 1, self.width)][math.floor(y / TILE_SIZE) + 1]
end
