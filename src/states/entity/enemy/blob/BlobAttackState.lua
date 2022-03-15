BlobAttackState = Class{__includes = BaseState}
--blob attack state constructor, spawns projectile
function BlobAttackState:init(level, player, blob)
    self.level = level
    self.player = player
    self.blob = blob

    self.blob.direction = self.blob.x - self.player.x > 0 and "right" or "left"

    self:spawnProjectile()
end
--updates blob and its projectile
function BlobAttackState:update(dt)
    self.blob.projectile:update(dt)
    if (self.blob.projectile.collided) then

        if not(self.exploded) then 
            self.exploded = true
            Timer.after(2, function()
                self.blob.projectile = nil
                self.blob:changeState('idle')
            end)
        end
    end
end
--spawns blob's projectile
function BlobAttackState:spawnProjectile()
    --calculates particle's velocity
    local theta = math.atan((self.blob.y - self.player.y) / (self.blob.x - self.player.x))

    local attackdx = math.abs(math.cos(theta) * SHOT_MOVE_SPEED)
    local attackdy = math.abs(math.sin(theta) * SHOT_MOVE_SPEED)

    attackdx = self.blob.x < self.player.x and attackdx or -attackdx
    attackdy = self.blob.y < self.player.y and attackdy or -attackdy
--gives blob a projectile
    self.blob.projectile = Projectile({
        x = self.blob.x,
        y = self.blob.y,

        state = self.player.state,

        dx = attackdx,
        dy = attackdy,

        width = 16,
        height = 16,

        texture = 'fireball',
        frame = 5,
        renderAbove = true,
        attackEntities = false,
        attackPlayer = true,
        animation = Animation({
            frames = self.blob.direction == 'left' and {5.5, 6.5, -5, -6} or {5.5, 6.5, -5.5, -6.5},
            interval = 1
        }),
        --on collide, checks whether it should damage player
        onCollide = function(state, obj)
            obj:explosionPsystem()
            obj.collisionX = obj.x
            obj.collisionY = obj.y
            obj.psystem:emit(64)
            gSounds['explosion']:play()
            if math.sqrt( (((obj.x + 8) - (self.player.x + self.player.width / 2)) ^ 2) + (((obj.y + 8) - (self.player.y + self.player.height / 2)) ^ 2)) < 25 then
                self.player:negateHealth(1)
            end
        end
    })
end