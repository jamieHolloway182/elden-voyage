BlobIdleState = Class{__includes = BaseState}
--blob idle state constructor
function BlobIdleState:init(level, player, blob)
    self.level = level
    self.player = player
    self.blob = blob

    self.blob.animation = Animation({
        frames = {(self.blob.type - 1) * 3 + math.floor((self.blob.type - 1) / 2) * 2 + 1, 
        (self.blob.type - 1) * 3 + math.floor((self.blob.type - 1) / 2) * 2 + 2,
        (self.blob.type - 1) * 3 + math.floor((self.blob.type - 1) / 2) * 2 + 3,
        (self.blob.type - 1) * 3 + math.floor((self.blob.type - 1) / 2) * 2 + 2},
        interval = 0.5
    })
    self.timePassed = 0
end
--updates blob by changing its direction and state randomly
function BlobIdleState:update(dt)
    self.timePassed = self.timePassed + dt
    if math.random(50) == 1 and self.timePassed > 1 and math.abs(self.player.x - self.blob.x) < TILE_SIZE * 7 then
        self.blob:changeState('attack')
    end
    if math.random(500) == 1 and self.timePassed > 1 then
        if self.blob.direction == 'left' then
            self.blob.direction = 'right'
        elseif self.blob.direction == 'right' then
            self.blob.direction = 'left'
        end
    end
end