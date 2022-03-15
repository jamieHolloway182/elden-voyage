FlyAttackState = Class{__includes = BaseState}
--fly attack state constructor
function FlyAttackState:init(level, player, fly)
    self.fly = fly
    self.player = player

    self.startAttack = false

    self.fly.animation = Animation({
        frames = {46}
    })
    self.timePassed = 0

    self.fly.invincible = true

    Timer.after(0.5, function()
        self.fly.canDamage = true
        self.startAttack = true
    end)
end
--updates fly by handling its slam into ground and then its return to move state
function FlyAttackState:update(dt)
    if self.startAttack then
        if self.fly.y < self.fly.startY + TILE_SIZE * 2 then
            self.fly.y = self.fly.y + (FLY_ATTACK_SPEED * dt)
        else
            self.timePassed = self.timePassed + dt
            if self.timePassed > 0.5 then
                self.fly.canDamage = false
                Timer.after(0.7, function()
                    self.fly.invincible = false
                end)
                self.fly.timeSinceAttacking = 0
                self.fly:changeState('move')
            end
        end
    end
end