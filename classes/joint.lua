--- joint

local joint = SECS_class:new()

function joint:init(gameobject,b1,b2)
  
  self.type = "joint"
  self.b1 = b1
  self.b2 = b2

  local _x1,_y1 = b1:getWorldCenter()
  local _x2,_y2 = b2:getWorldCenter()
  self.joint = gameobject.world:addDistanceJoint (b1,b2,_x1,_y1,_x2,_y2,4,0.5)
  self.joint.branch = MOAIProp2D.new ()
  self.joint.branch:setDeck ( utils.MOAIGfxQuad2D_new (images.joint) )
  gameobject.layer:insertProp ( self.joint.branch )
end

function joint:update()
  local _x1,_y1 = self.b1:getWorldCenter()
  local _x2,_y2 = self.b2:getWorldCenter()
  self.joint.branch:setLoc((_x1+_x2)/2,(_y1+_y2)/2)
  local angle = math.atan2(_y2-_y1, _x2-_x1)*57.324
  self.joint.branch:setRot(angle)
  local distance = utils.distance(_x1,_y1,_x2,_y2)
  self.joint.branch:setScl(distance/40,1)
end

return joint