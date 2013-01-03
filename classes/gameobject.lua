--- gameobject

local gameobject = SECS_class:new()

function gameobject:init(layer,  layerGui)
  --- common properties for gameobject
  self.entities={}
  self.entitiesId={}

  self.layer = layer

  self.paused = false

  -- scale set so screen is 20 meters tall
  scale = 20

  self.world = MOAIBox2DWorld.new()
  self.world:setGravity( 0, -10 )
  self.world:setUnitsToMeters( 1 / scale )
  self.world:setDebugDrawFlags( 0 )
  --self.world:setDebugDrawFlags( MOAIBox2DWorld.DEBUG_DRAW_SHAPES + MOAIBox2DWorld.DEBUG_DRAW_JOINTS + MOAIBox2DWorld.DEBUG_DRAW_PAIRS + MOAIBox2DWorld.DEBUG_DRAW_CENTERS )

  self.layer:setBox2DWorld( self.world )

  self.ground = {}
  self.ground.verts = {
  -400,-150,
  400,-150
  }
  self.ground.body = self.world:addBody( MOAIBox2DBody.STATIC, 0, -60 )
  self.ground.body.tag = 'ground'
  self.ground.fixtures = {
    self.ground.body:addChain( self.ground.verts )
  }
  self.ground.fixtures[1]:setFriction( 0.3 )

  self.box = MOAIProp2D.new ()
  self.box:setDeck ( utils.MOAIGfxQuad2D_new (images.grass,800,200) )
  self.box:setLoc ( 0,-310)
  self.layer:insertProp ( self.box )

  self.cloud = MOAIProp2D.new ()
  self.cloud:setDeck ( utils.MOAIGfxQuad2D_new (images.cloud) )
  self.cloud:setLoc ( -50,50)
  self.layer:insertProp ( self.cloud )

  --a dynamic body
  self:addcircle(-50,0,10,true,nil)

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

function gameobject:addcircle(x,y,r,force,type)

  local neighbours={}

  for i=1,#self.entities do
    if self.entities[i].type=="ball" then
      _x2,_y2 = self.entities[i].body:getWorldCenter()
      if utils.distance(x,y,_x2,_y2)<80 then
        table.insert(neighbours,self.entities[i])
      end
    end
  end

  if #neighbours>0 or force then
    local _ball = classes.ball:new(self,x,y,r,type)

    self:registerEntity(_ball)

    local _x1,_y1 = _ball.body:getWorldCenter()
    local _x2,_y2
    for i=1,#neighbours do
      self:addDistanceJoints(_ball.body,neighbours[i].body)
    end
    return _ball
  end

  return nil

end

function gameobject:addDistanceJoints(b1,b2)

  local _joint = classes.joint:new(self,b1,b2)
  self:registerEntity(_joint)
  
end

function gameobject:pause(paused)
  if paused then
    self.paused = true
    self.world:pause(true)
  elseif self.pause then
    self.paused = false
    self.world:pause(false)
  end
end

return gameobject