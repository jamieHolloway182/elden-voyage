GameLevel = Class{}
--game level constructor
function GameLevel:init(def)
    self.level = Level(def.width, def.height)

    self.width = def.width
    self.height = def.height

    self.objects = self.level.objects
    self.entities = self.level.entities

end
--update game level
function GameLevel:update(dt)
--updates all objects
    for k, object in pairs(self.objects) do
        if object.visible then
            object:update(dt)
        end
    end
--updates all entities
    for k, entity in pairs(self.entities) do
        if entity.alive then
            entity:update(dt)
        end
    end
end
--renders tiles
function GameLevel:renderLevel()
    self.level:render()
end
--renders all objects
function GameLevel:renderObjs(boolRenderAbove)
    for k,object in pairs(self.objects) do
        if object.visible and ((boolRenderAbove and object.renderAbove) or ((not boolRenderAbove) and (not object.renderAbove))) then
            object:render()
        end
        if object.visible and boolRenderAbove and RENDER_HITBOXES then
            object:renderHitbox()
        end
    end
end
--renders all entities
function GameLevel:renderEnts(boolRenderAbove)
    for k,entity in pairs(self.entities) do
        if entity.alive and ((boolRenderAbove and entity.renderAbove) or (not boolRenderAbove and not entity.renderAbove)) then
            entity:render()
        end
        if boolRenderAbove and entity.alive and RENDER_HITBOXES then
            entity:renderHitbox()
        end
    end
end