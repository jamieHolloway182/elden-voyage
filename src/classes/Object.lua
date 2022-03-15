Object = Class{}
--object constructor
function Object:init(def)
    self.x = def.x
    self.y = def.y

    self.width = def.width
    self.height = def.height
    
    self.texture = def.texture
    self.frame = def.frame or 1

    self.collidable = def.collidable or false
    self.consumable = def.consumable or false
    self.collectable = def.collectable or false
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.onCollect = def.onCollect

    self.solid = def.solid or false
    
    self.hitboxOffsetX = def.offsetX or 0
    self.hitboxOffsetY = def.offsetY or 0

    self.loadObj = def.load or function () end
    self.updateObj = def.update
    
    
    self.rotation = def.rotation or 0 
    self.scaleX = def.scaleX or 1
    self.scaleY = def.scaleY or 1

    self.params = def.params or {}

    self.loadObj(self)

    if nil == def.renderAbove then 
        self.renderAbove =  false
    else
        self.renderAbove = def.renderAbove
    end

    if def.explodable then 
        self.explodable = true
    else
        self.explodable = false
    end

    self.animation = def.animation or Animation({
        frames = {self.frame}
    })

    self.visible = true

    self.canInteract = true
    
end
--updates object's animation
function Object:update(dt)
    if self.updateObj then
        self.updateObj(dt, self)
    end
    self.animation:update(dt)
end
--returns boolean indicating whether object is colliding with target given as arguement
function Object:collides(target)
    return not (target.x + target.hitboxOffsetX > self.x + self.width + self.hitboxOffsetX or self.x + self.hitboxOffsetX > target.x + target.width + target.hitboxOffsetX or
            target.y + target.hitboxOffsetY > self.y + self.height + self.hitboxOffsetY or self.y + self.hitboxOffsetY > target.y + target.height + target.hitboxOffsetY)
end
--renders object at its x y coord
function Object:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][math.floor(math.abs(self.animation.frame))], self.x, self.y, self.rotation, self.animation.frame % 1 == 0 and self.scaleX or -self.scaleX, self.animation.frame > 0 and self.scaleY or -self.scaleY, self.animation.frame % 1 == 0 and 0 or self.width, self.animation.frame > 0 and 0 or self.height)
end