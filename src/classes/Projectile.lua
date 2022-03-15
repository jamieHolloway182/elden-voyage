Projectile = Class{__includes = Object}--projectile inherits from object
--projectile constructor
function Projectile:init(def)
    Object.init(self, def)

    self.dx = def.dx
    self.dy = def.dy

    self.state = def.state

    self.updatePosition = def.updatePosition or function() end

    self.onCollide = def.onCollide or function() end

    self.collisionX = self.x
    self.collisionY = self.y

    self.collided = false

    self.timePassed = 0

    if def.attackEntities == nil then
        self.attackEntities = true
    else
        self.attackEntities = false
    end

    self.attackPlayer = not (def.attackPlayer == nil)
end
--updates projectile's position, particle system and collisions
function Projectile:update(dt)
    Object.update(self, dt)
    self.updatePosition(dt, self)
    self.timePassed = self.timePassed + dt
    
    self.x = self.x + (self.dx  * dt)
    self.y = self.y + (self.dy  * dt)

    if self.psystem then
        self.psystem:update(dt)
    end
--object collisions
    if self.state and not self.collided then
        for k, object in pairs(self.state.gameLevel.objects) do
            if object:collides(self) and object.visible and object.explodable then
                if object == self then
                else
                    self.onCollide(self.state, self)
                    self.collided = true
                end
            end
        end
--player collisions
        if self.attackPlayer then
            if self.state.player:collides(self) then
                self.onCollide(self.state, self)
                self.collided = true
            end
        end
--entity collisions        
        if self.attackEntities then
            for k, entity in pairs(self.state.gameLevel.entities) do
                if entity:collides(self) and entity.alive then
                    if entity == self then
                    else
                        self.onCollide(self.state, self)
                        self.collided = true
                    end
                end
            end
        end
--edge of map collisions
        if self.y > VIRTUAL_HEIGHT then
            self.collided = true
        end
        if self.x < 0 or self.x + self.width > self.state.gameLevel.width * TILE_SIZE then
            self.onCollide(self.state, self)
            self.collided = true
        end
--tile collisions        
        local tile = self.state.player.level:findTile(self.x + (self.width / 2), self.y + (self.height) / 2)
        if tile then
            if tile.id == 3 then
                self.onCollide(self.state, self)
                self.collided = true
            end
        end
    end
end
--renders projectile and its particle system
function Projectile:render()
    if not self.collided then
        Object.render(self)
    end
    if self.psystem then
        love.graphics.draw(self.psystem, self.collisionX, self.collisionY)
    end
end
--creates projectile's particle system
function Projectile:explosionPsystem()
    self.psystem = love.graphics.newParticleSystem(gTextures['explosion'], 150)
    self.psystem:setEmissionArea("uniform", 7, 7)
	self.psystem:setLinearAcceleration(0, 12.5, 0, 12.5)
	self.psystem:setParticleLifetime(0.7, 1.5)
	self.psystem:setRadialAcceleration(-100, -400)
	self.psystem:setRotation(-math.pi, math.pi)
	self.psystem:setSpeed(70, 70)
	self.psystem:setSpread(2*math.pi)
	self.psystem:setSpin(-math.pi, math.pi)
end