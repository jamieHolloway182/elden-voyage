Player = Class{__includes = Entity}--player inherits from entity
--player constructor
function Player:init(def)
    Entity.init(self, def)
    self.score = def.score
    self.state = def.state
    self.floatState = false
    self.doubleJump = false

    self.crazyMode = false
end
--updates player by handling object and enemy collisions and powerup usage
function Player:update(dt)
    Entity.update(self, dt)
    self:collideObjects()
    self:collideEntities()

    if love.keyboard.wasPressed(POWERUP_BUTTON) then
        if self.powerup then
            if self.powerup.onUse then
                self.powerup.onUse(self.state, self.powerup)
                self.powerup = nil
            end
        end
    end
end
--handles collisions with objects
function Player:collideObjects()
    for k, object in pairs(self.level.objects) do
        if object:collides(self) and object.canInteract then
            if object.collidable then
                object.onCollide(self.state, object)
            elseif object.consumable and object.visible then
                object.onConsume(self.state, object)
                object.visible = false
            elseif object.solid then --sets player to be still
                self.dx = 0 
                self.dy = 0
            elseif object.collectable then
                if love.keyboard.isDown(DOWN_BUTTON) and self.dy == 0 then --down button needed to collect objects
                    object.onCollect(self.state, object)
                    object.visible = false
                    object.collectable = false
                end
            end
        end
    end
end
--handles collisions with entities
function Player:collideEntities()
    for k, entity in pairs(self.level.entities) do
        if entity:collides(self) and entity.alive then
            if self.crazyMode then 
                gSounds['kill']:play()
                entity.alive = false
                self.score = self.score + 30
            elseif entity.enemyType == 'snail' then
                if self.dy > 0 then
                    gSounds['kill']:play()
                    entity.alive = false
                    self.score = self.score + 30
                elseif entity.canDamage then
                    self:negateHealth(1)
                end
            elseif entity.enemyType == 'fly' then
                if not entity.invincible then
                    gSounds['kill']:play()
                    entity.alive = false
                    self.score = self.score + 20
                elseif entity.canDamage then
                    self:negateHealth(2)
                end
            elseif entity.enemyType == 'boomba' then
                if not entity.attacking then
                    gSounds['kill']:play()
                    entity.alive = false
                    self.score = self.score + 40
                end
            elseif entity.enemyType == 'fish' then
                self:negateHealth(1)
            elseif entity.enemyType == 'blob' then
                if self.dy > 0 then
                    entity.alive = false
                else
                    self:negateHealth(1)
                end
            end
        end
    end
end
--damages player and handles invincibility
function Player:negateHealth(damage)
    if not self.invincible then
        gSounds['hurt']:play()
        self.health = self.health - damage

        self.invincible = true
        Timer.after(INVINCIBILTY_SECS, function()
           self.invincible = false
        end)
    end
end
--sets powerup and creates timer to deactivate it after given time
function Player:setPowerup(powerup, endTime)
    if self.powerup then
        if self.powerup.onFinish then
            self.powerup.onFinish(self.state, self.powerup)
            self.powerup = nil
        end
    end
    self.powerup = powerup
    if endTime then
        Timer.after(endTime, function()
            if self.powerup == powerup then
                self.powerup.onFinish(self.state, powerup)
                self.powerup = nil
            end
        end)
    end
end
--draws player depending on whether they have star or are invincible or neither
function Player:render()
    if self.crazyMode then
        love.graphics.setColor(1,215/255,0) --filter set to rgb value of gold
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation.frame],
        math.floor(self.x) + 8, math.floor(self.y) + 10, 0, self.direction == 'right' and 1 or -1, 1, 8, 10)
        love.graphics.setColor(1,1,1) --filter reset
    elseif self.invincible and math.floor(self.state.timePlayed / 0.1) % 2 == 0 then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][5],
        math.floor(self.x) + 8, math.floor(self.y) + 10, 0, self.direction == 'right' and 1 or -1, 1, 8, 10)
    elseif not self.invincible then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation.frame],
        math.floor(self.x) + 8, math.floor(self.y) + 10, 0, self.direction == 'right' and 1 or -1, 1, 8, 10)
    end
end