--- cloud

local cloud = SECS_class:new()

function cloud:init(gameobject,x,y,scl)
  
  self.type = "cloud"
  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( utils.MOAIGfxQuad2D_new (images.cloud) )
  self.prop:setLoc ( x,y)
  self.prop:setScl ( scl)
  self.speed = 0.3*scl
  gameobject.layer:insertProp ( self.prop )
end

function cloud:update()
  local _x,_y = self.prop:getLoc ()
  if _x > 400 then
    _y = _y+math.random()*40-20
    _x = -400
  end
  self.prop:setLoc ( _x+self.speed,_y)
end

return cloud