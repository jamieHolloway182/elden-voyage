Tile = Class{}
--tile constructor
function Tile:init(x, y, tileset, id, topper, topperset)
    self.x = x
    self.y = y

    self.xPos = (self.x - 1) * TILE_SIZE
    self.yPos = (self.y - 1) * TILE_SIZE

    self.tileset = tileset
    self.id = id

    self.hitboxOffsetX = 0
    self.hitboxOffsetY = 0

    self.topper = topper
end
--renders tile
function Tile:render()
    if self.id ~= TILE_ID_EMPTY then
        love.graphics.draw(gTextures['sheet'], gFrames['sheet'][TILE_IDS[self.topper and self.tileset or self.tileset - 1]],
            (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE, 0 , 16/70, 16/70)
    end
end