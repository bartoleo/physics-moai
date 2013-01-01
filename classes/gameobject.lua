--- gameobject

local gameobject = SECS_class:new()

function gameobject:init(layer,  layerGui)
  --- common properties for gameobject
  self.entities={}
  self.entitiesId={}

  self.layer = layer

  -- scale set so screen is 20 meters tall
  scale = 20

  self.world = MOAIBox2DWorld.new()
  self.world:setGravity( 0, -10 )
  self.world:setUnitsToMeters( 1 / scale )
  --self.world:setDebugDrawFlags( MOAIBox2DWorld.DEBUG_DRAW_SHAPES + MOAIBox2DWorld.DEBUG_DRAW_JOINTS + MOAIBox2DWorld.DEBUG_DRAW_PAIRS + MOAIBox2DWorld.DEBUG_DRAW_CENTERS )

  self.layer:setBox2DWorld( self.world )

  self.ground = {}
  self.ground.verts = {
  -400,-200,
  400,-200
  }
  self.ground.body = self.world:addBody( MOAIBox2DBody.STATIC, 0, -60 )
  self.ground.body.tag = 'ground'
  self.ground.fixtures = {
    self.ground.body:addChain( self.ground.verts )
  }
  self.ground.fixtures[1]:setFriction( 0.3 )

  --a dynamic body
  self:addcircle(-50,0,10)

  self.world:start()
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

function gameobject:addcircle(x,y,r,type)
  
  local _ball = classes.ball:new(self,x,y,r,type)

  self:registerEntity(_ball)

  local _x1,_y1 = _ball.body:getWorldCenter()
  local _x2,_y2
  for i=1,#self.entities-1 do
    if self.entities[i].type=="ball" and self.entities[i]~=_ball then
      _x2,_y2 = self.entities[i].body:getWorldCenter()
      if utils.distance(_x1,_y1,_x2,_y2)<80 then
        self:addDistanceJoints(_ball.body,self.entities[i].body)
      end
    end
  end
end

function gameobject:addDistanceJoints(b1,b2)

  local _joint = classes.joint:new(self,b1,b2)
  self:registerEntity(_joint)
  
end

return gameobject