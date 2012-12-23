-- lostlife state

local state = {}
state.layerTable = nil
state.IS_POPUP = true

----------------------------------------------------------------
function state.onFocus ( self, prevstatename )

	MOAIGfxDevice.setClearColor ( 0, 0, 0, 1 )

	self.waitSeconds = 2
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
	self.box:setDeck ( utils.MOAIGfxQuad2D_new (images.box,600,80) )
	self.box:setColor ( 0,0,0,0.5)
	layer:insertProp ( self.box )

    self.textbox1 = MOAITextBox.new ()
    self.textbox1:setFont ( fonts["resource,64"] )
    self.textbox1:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
    self.textbox1:setYFlip ( true )
    self.textbox1:setRect ( -300, -32, 300, 32 )
    self.textbox1:setString ( "they caught you... "..GAMEOBJECT.lifes.." lifes left" )
    self.textbox1:setLoc ( 0, 0)
    layer:insertProp ( self.textbox1 )

    GAMEOBJECT.player.prop:seekScl(2,2,2)
    GAMEOBJECT.player.prop:seekColor(0,0,0,0,2)

    GAMEOBJECT.propsLifes[GAMEOBJECT.lifes+1]:seekScl(2,2,2)
    GAMEOBJECT.propsLifes[GAMEOBJECT.lifes+1]:seekColor(0,0,0,0,2)

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

   	if self.waitSeconds < ( MOAISim.getDeviceTime () - self.startTime ) then
   		if GAMEOBJECT.lifes == 0 then
		  statemgr.swap ( "gameover" )
		else
		  GAMEOBJECT:reinitLevel()
		  statemgr.swap ( "enterlevel")
		end
	end
end

return state