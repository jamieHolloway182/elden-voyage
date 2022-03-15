Entity = Class{}
--entity constructor
function Entity:init(def)
    self.x = def.x 
    self.y = def.y

    self.health = def.health or 1

    self.dx = 0
    self.dy = 0
 
    self.width = def.width
    self.height = def.height

    self.hitboxOffsetX = def.offsetX or 0
    self.hitboxOffsetY = def.offsetY or 0
 
    self.texture = def.texture
    self.stateMachine = def.stateMachine

    self.level = def.level
    self.tiles = self.level.tiles
 
    self.direction = 'left'

    self.invincible = false

    self.alive = true

    if nil == def.renderAbove then 
        self.renderAbove = true
    else
        self.renderAbove = false
    end
end
--change movement state of the entity
function Entity:changeState(state, params)
    self.stateMachine:change(state, params)
end
--update entity by updating its state machine and animation
function Entity:update(dt)
    self.stateMachine:update(dt)
    self.x = math.min((self.level.width -1) * TILE_SIZE, math.max(self.x, 0))
    self.animation:update(dt)
end
--returns boolean indicating whether the entity is colliding with the one given as arguement
function Entity:collides(entity)
    return not (self.x + self.hitboxOffsetX > entity.x + entity.width + entity.hitboxOffsetX or entity.x + entity.hitboxOffsetX > self.x + self.width + self.hitboxOffsetY or
                self.y + self.hitboxOffsetY > entity.y + entity.height + entity.hitboxOffsetY or entity.y + entity.hitboxOffsetY > self.y + self.height + self.hitboxOffsetY)
end
--draws entity at its current x y coords and facing in the correct direction
function Entity:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation.frame],
        math.floor(self.x) + 8, math.floor(self.y) + 10, 0, self.direction == 'right' and 1 or -1, 1, 8, 10)
end
--returns tile below the entity if it is solid, if both are empty tiles return false
function Entity:checkDownwardCollisions()
    for x=1, self.level.width do
        for y=1, self.level.height do
            local tileLeft = self.level:findTile(self.x + 1, self.y + self.height)
            local tileRight = self.level:findTile(self.x + self.width - 1, self.y + self.height)
            if tileLeft then
                if (tileLeft.id == 3) then
                    self.y = tileLeft.yPos - self.height
                    return tileLeft
                end
            end
            if tileRight then
                if tileRight.id == 3 then
                    self.y = tileRight.yPos - self.height
                    return tileRight 
                end
            end
        end
    end
    return false
end
--returns tile left of the entity if it is solid, if both are empty tiles return false
function Entity:checkLeftCollisions()
    local tileTop = self.level:findTile(self.x + self.hitboxOffsetX - 1, self.y)
    local tileBottom = self.level:findTile(self.x + self.hitboxOffsetX - 1, self.y + self.height - 1)
    if tileTop then
        if (tileTop.id == 3) then
            return true
        end
    end
    if tileBottom then
        if tileBottom.id == 3 then
            return true 
        end
    end
    return false
end
--returns tile to the right of the entity if it is solid, if both are empty tiles return false
function Entity:checkRightCollisions()
    local tileTop = self.level:findTile(self.x + self.width + self.hitboxOffsetX + 1, self.y)
    local tileBottom = self.level:findTile(self.x + self.width + self.hitboxOffsetX + 1, self.y + self.height - 1)
    if tileTop then
        if (tileTop.id == 3) then
            return true
        end
    end
    if tileBottom then
        if tileBottom.id == 3 then
            return true 
        end
    end
    return false
end
--returns object entity is colliding with or false if they arent colliding with one
function Entity:checkObjectCollisions()
    local objects = {}
    for k, object in pairs(self.level.objects) do
        if object.solid and object.collidable and object:collides(self) then
            table.insert(objects, object)
        end
    end
    
    local topObj = false
    local topScore = -1
    for k, object in pairs(objects) do
        if object.x + object.width > self.x + self.width then
            score = self.x + self.width - object.x
        else
            score = object.x + object.width - self.x
        end
        if score > topScore then
            topObj = object
            topScore = score
        end
    end
    return topObj
end