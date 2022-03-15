BoombaMoveState = Class{__includes = BaseState}
--boomba move state construcor
function BoombaMoveState:init(level, player, boomba)
    self.boomba = boomba

    self.boomba.animation = Animation({
        frames = {41, 42},
        interval = 0.4
    })
    self.timePassed = 0

    self.shotDx = 0
    self.shotDy = 0

    self.player = player
end
--updates boomba by changing its direction and state randomly and moving it up and down
function BoombaMoveState:update(dt)
    self.timePassed = self.timePassed + dt

    if self.boomba.goingUp then
        if self.boomba.y >= self.boomba.startY - TILE_SIZE * 2 then
            self.boomba.y = self.boomba.y - (BOOMBA_MOVE_SPEED * dt)
        else
            self.boomba.goingUp = false
        end
    else
        if self.boomba.y <= self.boomba.startY + (TILE_SIZE / 2 ) then
            self.boomba.y = self.boomba.y + (BOOMBA_MOVE_SPEED * dt)
        else 
            self.boomba.goingUp = true
        end
    end

    if math.random(50) == 1 and self.timePassed > 1 then
        if self.boomba.direction == 'left' then
            self.boomba.direction = 'right'
        elseif self.boomba.direction == 'right' then
            self.boomba.direction = 'left'
        end
    end

    if math.random(70) == 1 and math.abs(self.boomba.x - self.player.x) < TILE_SIZE * 7 then
        self.boomba:changeState('idle')
    end
end