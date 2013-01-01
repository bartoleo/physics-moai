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


  local _fixture = _body:addCircle( 0, 0, r )
  self.body = _body
  self.fixture = _fixture
end

return ball