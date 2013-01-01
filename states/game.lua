-- game state

local state = {}
state.updates = 0
state.layerTable = nil
state.layerGui = nil
state.layer = nil
state.commands_queue = {}

----------------------------------------------------------------
function state.onLoad ( self, prevstatename, plevel )

  self.layerTable = {}
  local layer = MOAILayer2D.new ()
  layer:setViewport ( viewport )
  local layerGui = MOAILayer2D.new ()
  layerGui:setViewport ( viewport )
  self.layerTable [ 1 ] = { layer, layerGui }

  self.layerGui = layerGui
  self.layer = layer

  self.updates = 0

  GAMEOBJECT = classes.gameobject:new(layer, layerGui)

  if MOAIInputMgr.device.keyboard and MOAIInputMgr.device.keyboard.keyIsDown and false then
    -- keyboard events
  else
    -- touch/mouse pause
    self.pausebutton = MOAIProp2D.new ()
    self.pausebutton:setDeck ( utils.MOAIGfxQuad2D_new (images.button) )
    self.pausebutton:setLoc(utils.screen_middlewidth-80,-utils.screen_middleheight+85)
    layerGui:insertProp ( self.pausebutton )
    self.pause = MOAITextBox.new ()
    self.pause:setFont ( fonts["Peralta-Regular,12"] )
    self.pause:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
    self.pause:setYFlip ( true )
    self.pause:setRect ( -30, -20, 30, 20 )
    self.pause:setString ( "| |\npause" )
    self.pause:setLoc(utils.screen_middlewidth-80,-utils.screen_middleheight+85)
    layerGui:insertProp ( self.pause )
    -- touch/mouse exit
    self.exitbutton = MOAIProp2D.new ()
    self.exitbutton:setDeck ( utils.MOAIGfxQuad2D_new (images.button) )
    self.exitbutton:setLoc(utils.screen_middlewidth-80,utils.screen_middleheight-80)
    layerGui:insertProp ( self.exitbutton )    self.exit = MOAITextBox.new ()
    self.exit:setFont ( fonts["Peralta-Regular,12"] )
    self.exit:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
    self.exit:setYFlip ( true )
    self.exit:setRect ( -30, -20, 30, 20 )
    self.exit:setString ( "X\nexit" )
    self.exit:setLoc(utils.screen_middlewidth-80,utils.screen_middleheight-80)
    layerGui:insertProp ( self.exit )
  end

  statemgr.registerInputCallbacks()

end

----------------------------------------------------------------
function state.onFocus ( self, prevstatename )
  MOAIGfxDevice.setClearColor ( 0, 0, 0, 1 )
end

----------------------------------------------------------------
function state.onUpdate ( self )
  self.updates = self.updates + 1
  local _return = false
  if self.commands_queue then
    for i=#self.commands_queue,1,-1 do
      local cmd = self.commands_queue[i]
      if cmd=="pop" then
        statemgr.pop(statemgr.fadein_fadeout_black)
        _return = true
      end
      table.remove(self.commands_queue,i)
    end
  end
  if _return then
    return
  end

  local _return = GAMEOBJECT:update()

  if _return then
    if _return == "LOSE" then
      GAMEOBJECT.lifes = GAMEOBJECT.lifes  -1
      soundmgr.playSound(sounds.lostlife)
      statemgr.push("lostlife")
    elseif _return == "WIN" then
      statemgr.push("winlevel")
    end
  end

end

----------------------------------------------------------------
function state.onInput ( self )

  if MOAIInputMgr.device.keyboard and MOAIInputMgr.device.keyboard.keyIsDown then
    if MOAIInputMgr.device.keyboard:keyIsDown(119) or MOAIInputMgr.device.keyboard:keyIsDown(87) then
      GAMEOBJECT.player:input("n")
    elseif MOAIInputMgr.device.keyboard:keyIsDown(115) or MOAIInputMgr.device.keyboard:keyIsDown(83) then
      GAMEOBJECT.player:input("s")
    elseif MOAIInputMgr.device.keyboard:keyIsDown(97) or MOAIInputMgr.device.keyboard:keyIsDown(65) then
      GAMEOBJECT.player:input("w")
    elseif MOAIInputMgr.device.keyboard:keyIsDown(100) or MOAIInputMgr.device.keyboard:keyIsDown(68) then
      GAMEOBJECT.player:input("e")
    end
  end
  if self.pause then
    local mousex, mousey = self.layerGui:wndToWorld ( inputmgr:getTouch ())
    if inputmgr:isDown() then
    elseif inputmgr:up() then
      if self.pause:inside(mousex,mousey) then
        statemgr.push("pause")
      elseif self.exit:inside(mousex,mousey) then
        GAMEOBJECT:unload()
        table.insert(self.commands_queue,"pop")
      end
    end
   end

end

----------------------------------------------------------------
function state.onKey (self,source, up,key)
  if up and key==112 then
    statemgr.push("pause")
  end
  if up and key==27 then
    GAMEOBJECT:unload()
    table.insert(state.commands_queue,"pop")
  end
end

----------------------------------------------------------------
function state.onUnload ( self )

  GAMEOBJECT:unload()

  if self.pausebutton then
    self.layerGui:removeProp ( self.pausebutton )
  end
  if self.pause then
    self.layerGui:removeProp ( self.pause )
  end
  if self.exitbutton then
    self.layerGui:removeProp ( self.exitbutton )
  end
  if self.exit then
    self.layerGui:removeProp ( self.exit )
  end

  soundmgr.stop(musics.TheHaunting)

  for i, layerSet in ipairs ( self.layerTable ) do
    for j, layer in ipairs ( layerSet ) do
      layer = nil
    end
  end

  self.layerTable = nil

end

----------------------------------------------------------------
function state.onTouch (self,source,up,idx,x,y,tapcount)
  if up then
    local _x,_y = self.layer:wndToWorld(x,y)
    GAMEOBJECT:addcircle(_x,_y,10)
  end
end

return state