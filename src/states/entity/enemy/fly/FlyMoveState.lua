FlyMoveState = Class{__includes = BaseState}
--fly move state constructor
function FlyMoveState:init(level, player, fly)
    self.fly = fly

    self.fly.animation = Animation({
        frames = {33 + (self.fly.type - 1) * 3, 33 + (self.fly.type - 1) * 3 + 1},
        interval = 0.4
    })
    self.timePassed = 0

    self.fly.shooting = false
    self.shotDx = 0
    self.shotDy = 0

    self.fly.shotX = 0
    self.shotY = 0

    self.player = player
end
--updates fly by changing its direction and state randomly and moving it up and down
--and randomly firing and then updating bullet
function FlyMoveState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(50) == 1 and self.timePassed > 1 and not self.fly.bullet then
        self.fly:changeState('idle')
    end

    if self.fly.goingUp then
        if self.fly.y >= self.fly.startY - TILE_SIZE * 2 then
            self.fly.y = self.fly.y - (FLY_MOVE_SPEED * dt)
        else
            self.fly.goingUp = false
        end
    else
        if self.fly.y <= self.fly.startY + (TILE_SIZE / 2 ) then
            self.fly.y = self.fly.y + (FLY_MOVE_SPEED * dt)
        else 
            self.fly.goingUp = true
        end
    end

    if math.random(50) == 1 and self.timePassed > 1 then
        if self.fly.direction == 'left' then
            self.fly.direction = 'right'
        elseif self.fly.direction == 'right' then
            self.fly.direction = 'left'
        end
    end

    if math.random(400) == 1 and not self.fly.bullet then
        self.fly:changeState('attack')
    end
--fires bullet
    if not self.fly.bullet and self.fly.timeSinceAttacking > 2 and math.random(5) == 1 and math.abs(self.player.x - self.fly.x) < TILE_SIZE * 8 then
        self:fireShot()
    end
--updates bullet
    if self.fly.bullet then
        if self.player:collides(self.fly.bullet) then
            self.player:negateHealth(1)
        end
    end
end
--creates bullet projectile for fly
function FlyMoveState:fireShot()
    gSounds['shoot']:play()

    self.fly.timeSinceAttacking = 0
--calculates velocity
    local theta = math.atan((self.fly.y - self.player.y) / (self.fly.x - self.player.x))

    local shotdx = math.abs(math.cos(theta) * SHOT_MOVE_SPEED)
    local shotdy = math.abs(math.sin(theta) * SHOT_MOVE_SPEED)
--creates fly's projectile
    self.fly.bullet = Projectile({
        x = self.fly.x,
        y = self.fly.y,

        dx = self.fly.x < self.player.x and shotdx or -shotdx,
        dy = self.fly.y < self.player.y and shotdy or -shotdy,

        width = 6,
        height = 6,

        scaleX = 3/4,
        scaleY = 3/4,

        texture = 'particle',
        frame = 1
    })

    Timer.after(1, function()
        self.fly.bullet = false
    end)
end
