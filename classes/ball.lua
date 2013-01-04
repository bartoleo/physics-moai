--- ball

local ball = SECS_class:new()

function ball:init(gameobject,x,y,r,type)
  
  self.type = "ball"

  local _body = gameobject.world:addBody( type or MOAIBox2DBody.DYNAMIC )
  _body:setTransform( x, y )

  _body.ball = MOAIProp2D.new ()
  _body.ball:setDeck ( utils.MOAIGfxQuad2D_new (images.ball) )
  _body.ball:setParent(_body)
  gameobject.layer:insertProp ( _body.ball )

  self.curvex = MOAIAnimCurve.new ()

  self.curvex:reserveKeys ( 5 )
  self.curvex:setKey ( 1, 0.00, 1, MOAIEaseType.LINEAR )
  self.curvex:setKey ( 2, 0.25, 1.15, MOAIEaseType.LINEAR )
  self.curvex:setKey ( 3, 0.50, 1, MOAIEaseType.LINEAR )
  self.curvex:setKey ( 4, 0.75, 0.85, MOAIEaseType.LINEAR )
  self.curvex:setKey ( 5, 1, 1, MOAIEaseType.LINEAR )



  self.animx = MOAIAnim:new ()
  self.animx:reserveLinks ( 1 )
  self.animx:setLink ( 1, self.curvex, _body.ball, MOAIProp2D.ATTR_X_SCL )
  self.animx:setMode ( MOAITimer.LOOP )
  self.animx:start ()
  self.animy = MOAIAnim:new ()
  self.animy:reserveLinks ( 1 )
  self.animy:setLink ( 1, self.curvex, _body.ball, MOAIProp2D.ATTR_Y_SCL )
  self.animy:setMode ( MOAITimer.LOOP )
  self.animy:start ()
  self.animy:setTime ( 0.5)

  local _fixture = _body:addCircle( 0, 0, r )
  self.body = _body
  self.fixture = _fixture
end

return ball