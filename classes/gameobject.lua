--- gameobject

local gameobject = SECS_class:new()

function gameobject:init(layer,  layerGui)
  --- common properties for gameobject
  self.entities={}
  self.entitiesId={}
  self.layer = layer

  -- scale set so screen is 20 meters tall
  scale = 10

  self.world = MOAIBox2DWorld.new()
  self.world:setGravity( 0, -10 )
  self.world:setUnitsToMeters( 1 / scale )
  self.world:setDebugDrawFlags( MOAIBox2DWorld.DEBUG_DRAW_SHAPES + MOAIBox2DWorld.DEBUG_DRAW_JOINTS +
   MOAIBox2DWorld.DEBUG_DRAW_PAIRS + MOAIBox2DWorld.DEBUG_DRAW_CENTERS )

  self.layer:setBox2DWorld( self.world )

  ground = {}
  ground.verts = {
  -160, 100,
  -160, 10,
  -120, 10,
  -120, -10,
  -15, -10,
  -15, 5,
  5, 5,
  20, 20,
  40, 20,
  40, -18,
  140, -18,
  140, 20,
  160, 20,
  160, 100
  }
  ground.body = self.world:addBody( MOAIBox2DBody.STATIC, 0, -60 )
  ground.body.tag = 'ground'
  ground.fixtures = {
  ground.body:addChain( ground.verts )
  }
  ground.fixtures[1]:setFriction( 0.3 )

end

function gameobject:update()
  -- level custom update
  if self.level and self.level.update then
    self.level:update()
  end
  -- entities do update
  self:entitiesDo("update",nil)
  -- check win or lose
  if self:checkWin() then
    self:entitiesDo("stop",nil)
    return "WIN"
  elseif self:checkLose()==true then
    self:entitiesDo("stop",nil)
    return "LOSE"
  end
end

function gameobject:registerEntity(entity)
  if entity.id == nil then
    entity.id = utils.generateId(entity.type)
  end
  table.insert(self.entities,entity)
  self.entitiesId[entity.id]=entity
end

function gameobject:unload()
end

function gameobject:checkWin()
  return false
end

function gameobject:checkLose()
  return false
end

function gameobject:clearEntities()
  for i=#self.entities,1,-1 do
    local v = self.entities[i]
    if v.unload then
      v:unload()
    end
    self.entitiesId[v.id]=nil
    table.remove(self.entities,i)
  end
end

function gameobject:entitiesDo(action,filtertype,...)
  for i,v in ipairs(self.entities) do
    if filtertype==nil or v.type==filtertype then
      if v[action] then
        v[action](v,...)
      end
    end
  end
end

return gameobject