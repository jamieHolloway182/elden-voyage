--generates list of sprites from one sprite sheet
function GenerateQuads(atlas, tilewidth, tileheight, xS, yS)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    local xGap = xS or 0
    local yGap = yS or 0

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth + x * xGap, y * tileheight + y * yGap, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end
--finds if table contains a value
function contains(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
    end
    return false
end