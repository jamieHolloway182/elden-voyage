BoombaAttackState = Class{__includes = BaseState}
--boomba attack state constructor, creates particle system and launches attack
function BoombaAttackState:init(level, player, boomba)
    self.level = level
    self.player = player
    self.boomba = boomba

    self.boomba.animation = Animation({
        frames = {41, 42},
        interval = 0.2
    })

    self.targetX = self.player.x + (self.player.width / 2)
    self.targetY = self.player.y + (self.player.height / 2)

    self:explosionPsystem()
    self:launchAttack()

    self.boomba.attacking = true
end
--updates boomba by determining if it should explode
function BoombaAttackState:update(dt)
    if ((self.targetX - self.boomba.x) ^ 2 + (self.targetY - self.boomba.y) ^ 2) > 30 then
        self.boomba.x = self.boomba.x + (self.attackdx * dt)
        self.boomba.y = self.boomba.y + (self.attackdy * dt)
    elseif not self.boomba.exploded then
        self:explode()
    end
end
--launches attack by calculating necessary velocity
function BoombaAttackState:launchAttack()
    local theta = math.atan((self.boomba.y - self.targetY) / (self.boomba.x - self.targetX))

    self.attackdx = math.abs(math.cos(theta) * BOOMBA_ATTACK_SPEED)
    self.attackdy = math.abs(math.sin(theta) * BOOMBA_ATTACK_SPEED)

    self.attackdx = self.boomba.x < self.targetX and self.attackdx or -self.attackdx
    self.attackdy = self.boomba.y < self.targetY and self.attackdy or -self.attackdy
end
--explodes boomba and kills it
function BoombaAttackState:explode()
    self.boomba.psystem:emit(64)
    gSounds['explosion']:play()
    Timer.after(1.5, function()
        self.boomba.alive = false
    end)
    self.boomba.exploded = true
    if math.sqrt(((self.player.x + (self.player.width / 2)- self.boomba.x) ^ 2 + (self.player.y + (self.player.height / 2) - self.boomba.y) ^ 2)) < 15 then
        self.player:negateHealth(2)
    end 
end
--creates boomba's particle system
function BoombaAttackState:explosionPsystem()
    self.boomba.psystem = love.graphics.newParticleSystem(gTextures['explosion'], 64)
    self.boomba.psystem:setColors(0, 0, 1, 0.7)
    self.boomba.psystem:setEmissionArea("uniform", 7, 7)
	self.boomba.psystem:setLinearAcceleration(0, 12.5, 0, 12.5)
	self.boomba.psystem:setParticleLifetime(0.7, 1.5)
	self.boomba.psystem:setRadialAcceleration(-100, -400)
	self.boomba.psystem:setRotation(-math.pi, math.pi)
	self.boomba.psystem:setSpeed(50, 50)
	self.boomba.psystem:setSpread(2*math.pi)
	self.boomba.psystem:setSpin(-math.pi, math.pi)
end