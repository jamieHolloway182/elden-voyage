Animation = Class{}
--animation constructor
function Animation:init(def)
    self.frames = def.frames 
    self.currentFrame = def.startFrame or 0

    self.interval = def.interval or 1
    self.looping = def.looping or true

    self.time = 0

    self.frame = self.frames[self.currentFrame + 1]
end
--updates animation by changing the frame according to interval
function Animation:update(dt)
    if #self.frames > 1 then
        self.time = self.time + dt
        if self.time > self.interval then
            self.currentFrame = (self.currentFrame + 1) % #self.frames
            self.time = 0
        end
        self.frame = self.frames[self.currentFrame + 1]
    end
end