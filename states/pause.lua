-- pause state

local state = {}
state.layerTable = nil
state.IS_POPUP = true

----------------------------------------------------------------
function state.onFocus ( self, prevstatename )

	MOAIGfxDevice.setClearColor ( 0, 0, 0, 1 )

  self.startTime = MOAISim.getDeviceTime ()

end

----------------------------------------------------------------
function state.onInput ( self )

end

----------------------------------------------------------------
function state.onLoad ( self, prevstatename )

	self.layerTable = {}
	local layer = MOAILayer2D.new ()
	layer:setViewport ( viewport )
	self.layerTable [ 1 ] = { layer }

  self.box = MOAIProp2D.new ()
  self.box:setDeck ( utils.MOAIGfxQuad2D_new (images.box,300,80) )
  self.box:setColor ( 0,0,0,0.5)
  layer:insertProp ( self.box )

  self.textbox1 = MOAITextBox.new ()
  self.textbox1:setFont ( fonts["resource,64"] )
  self.textbox1:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
  self.textbox1:setYFlip ( true )
  self.textbox1:setRect ( -150, -32, 150, 32 )
  self.textbox1:setString ( "PAUSED" )
  self.textbox1:setLoc ( 0, 0)
  layer:insertProp ( self.textbox1 )

  statemgr.registerInputCallbacks()

end

----------------------------------------------------------------
function state.onLoseFocus ( self )
end

----------------------------------------------------------------
function state.onUnload ( self )

	for i, layerSet in ipairs ( self.layerTable ) do

		for j, layer in ipairs ( layerSet ) do

			layer:clear ()
			layer = nil
		end
	end

	self.layerTable = nil
end

----------------------------------------------------------------
function state.onUpdate ( self )

end

----------------------------------------------------------------
function state.onKey (self,source, up,key)
  if up and MOAISim.getDeviceTime () - self.startTime > 0.5 then
    statemgr.pop()
  end
end

----------------------------------------------------------------
function state.onTouch (self,source,up,idx,x,y,tapcount)
  if up and MOAISim.getDeviceTime () - self.startTime > 0.5 then
    statemgr.pop()
  end
end

return state