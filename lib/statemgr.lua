-- STATE MANAGER

module ( "statemgr", package.seeall )

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local curState = nil
local loadedStates = {}
local stateStack = {}
local renderLayers = {}
local interactive = true

----------------------------------------------------------------
-- run loop
----------------------------------------------------------------
local updateThread = MOAIThread.new ()

local function updateFunction ()

  while true do

    coroutine.yield ()

    if curState then

      if type ( curState.onInput ) == "function" and interactive then
        curState:onInput ()
      end

      if type ( curState.onUpdate ) == "function" then
        curState:onUpdate ()
      end

    else
      print ( "WARNING - There is no current state. Please call state.push/state.swap to add a state." )
    end

  end
end


----------------------------------------------------------------
-- local functions
----------------------------------------------------------------
local function rebuildRenderStack ( )

  MOAISim.forceGarbageCollection ()

  renderLayers = {}
  local firststate = 0
  local laststate = 0
  local state
  for i=1,#stateStack do
    state = stateStack[i]
    if state.IS_POPUP then
      laststate = i
    else
      firststate = i
      laststate = i
    end
  end
  if laststate>0 then
    for i=firststate,laststate do
      state = stateStack[i]
      if state.layerTable then
        for j, stacklayer in ipairs ( state.layerTable) do
          for jj, layer in  ipairs ( stacklayer ) do
            table.insert(renderLayers,layer)
          end
        end
      end
    end
  end

  MOAIRenderMgr.setRenderTable(renderLayers)

  MOAISim.forceGarbageCollection ()

end

----------------------------------------------------------------
local function loadState ( stateFile )

  if not loadedStates [ stateFile ] then

    local newState = dofile ( "states/"..stateFile..".lua" )
    loadedStates [ stateFile ] = newState
    loadedStates [ stateFile ].__statename = stateFile
  end

  return loadedStates [ stateFile ]
end

----------------------------------------------------------------
-- functions
----------------------------------------------------------------
function begin ()
  updateThread:run ( updateFunction )
end

----------------------------------------------------------------
function getCurState ( )
  return curState
end

----------------------------------------------------------------
function makePopup ( state )
  state.IS_POPUP = true
end

----------------------------------------------------------------
function pop (effects,...)

  interactive = false

  if curState.callbacks then
    for k,v in pairs(curState.callbacks) do
      MOAIInputMgr.device[k]:setCallback(nil)
    end
  end

  if effects and effects.exit then
    doEffect(effects.exit)
  end

  -- do the state's onLoseFocus
  if type ( curState.onLoseFocus ) == "function" then
    curState:onLoseFocus ()
  end

  -- do the state's onUnload
  if type ( curState.onUnload ) == "function" then
    curState:onUnload ()
  end

  local prevstatename=nil
  if curState then
    prevstatename = curState.__statename
  end

  curState = nil
  table.remove ( stateStack, #stateStack )
  curState = stateStack [ #stateStack ]

  rebuildRenderStack ()
  MOAISim.forceGarbageCollection ()

  if curState then

    -- do the new current state's onFocus
    if type ( curState.onFocus ) == "function" then
      curState:onFocus (prevstatename,... )
    end

    if effects and effects.enter then
      doEffect(effects.enter)
    end

    if curState.callbacks then
      for k,v in pairs(curState.callbacks) do
        MOAIInputMgr.device[k]:setCallback(v)
      end
    end

  end

  interactive = true

end

----------------------------------------------------------------
function push ( stateFile,effects, ... )

  interactive = false

  -- do the old current state's onLoseFocus
  if curState then

    if curState.callbacks then
      for k,v in pairs(curState.callbacks) do
        MOAIInputMgr.device[k]:setCallback(nil)
      end
    end

    if effects and effects.exit then
      doEffect(effects.exit)
    end

    if type ( curState.onLoseFocus ) == "function" then
      curState:onLoseFocus ( )
    end

  end

  local prevstatename=nil
  if curState then
    prevstatename = curState.__statename
  end

  -- update the current state to the new one
  local newState = loadState ( stateFile )
  table.insert ( stateStack, newState )
  curState = stateStack [ #stateStack ]

  -- do the state's onLoad
  if type ( curState.onLoad ) == "function" then
    curState:onLoad (prevstatename, ... )
  end

  -- do the state's onFocus
  if type ( curState.onFocus ) == "function" then
    curState:onFocus (prevstatename)
  end

  rebuildRenderStack ()

  if effects and effects.enter then
    doEffect(effects.enter)
  end

  interactive = true

end

----------------------------------------------------------------
function swap ( stateFile,effects, ... )
  local _effects_enter=nil
  local _effects_exit=nil
  if effects then
    _effects_enter={enter=effects.enter}
    _effects_exit={exit=effects.exit}
  end
  pop ( _effects_exit ,...)
  push ( stateFile, _effects_enter ,... )
end

----------------------------------------------------------------
function stop ( )
  updateThread:stop ()
end

----------------------------------------------------------------
function popTo (stateName, effects,...)
  while curState.__statename ~= stateName do
    pop(effects,...)
  end
end

----------------------------------------------------------------
function setCallback (event,func )
  if curState.newcallbacks==nil then
    curState.callbacks={}
  end
  if MOAIInputMgr.device[event] then
    curState.callbacks[event] = func
    MOAIInputMgr.device[event]:setCallback(func)
  end
end

-----------------------------------------------------------------
function registerInputCallbacks()
  if MOAIInputMgr.device.pointer then
    setCallback("pointer", function(x,y) dispatchevent("move","pointer",false,1,x,y,0) end )
  end
  if MOAIInputMgr.device.mouseLeft then
    setCallback("mouseLeft", function(up) local x,y = MOAIInputMgr.device.pointer:getLoc () dispatchevent("touch","pointer",up,1,x,y,1) end )
  end
  if MOAIInputMgr.device.touch then
    setCallback("touch", function(eventType, idx, x, y, tapCount) dispatchevent("touch","touch",eventType,idx,x,y,tapCount) end )
  end
  if MOAIInputMgr.device.keyboard then
    setCallback("keyboard", function ( key, down ) dispatchevent("key","keyboard",not down,key,nil,nil,nil) end )
  end
end

-----------------------------------------------------------------
function dispatchevent(pevent,psource,pup,pidx,px,py,ptapcount)
  if pevent =="move" then
    if curState.onMove then
      curState:onMove(psource,pup,pidx,px,py)
    end
  elseif pevent =="touch" then
    if curState.onTouch then
      curState:onTouch(psource,pup,pidx,px,py,ptapcount)
    end
  elseif pevent =="key" then
    if curState.onKey then
      curState:onKey(psource,pup,pidx)
    end
  end
end

-----------------------------------------------------------------
function interpolate(from,to,currtiming, total)
  local timing = currtiming/total
  if timing <= 0 or from==to then
    return from
  elseif timing >= 1 then
    return to
  end
  return from+(to-from)*timing
end

-----------------------------------------------------------------
function doEffect(effect)
  if effect and effect.type then
    local _frames=effect.frames or 30
    local _layer=renderLayers[#renderLayers]
    if effect.type=="fade" then
      local box = MOAIProp2D.new ()
      box:setDeck ( utils.MOAIGfxQuad2D_new (images.box,utils.screen_width,utils.screen_height) )
      box:setColor ( effect.r1,effect.g1,effect.b1,effect.a1)
      _layer:insertProp ( box )
      for i=1,_frames do
        coroutine.yield ()
        box:setColor (interpolate(effect.r1,effect.r2,i,_frames),
                      interpolate(effect.g1,effect.g2,i,_frames),
                      interpolate(effect.b1,effect.b2,i,_frames),
                      interpolate(effect.a1,effect.a2,i,_frames))
      end
      _layer:removeProp ( box )
    end
  end
end

-----------------------------------------------------------------
fadein_fadeout_black = {exit={type="fade",frames=20,r1=0,g1=0,b1=0,a1=0,r2=0,g2=0,b2=0,a2=1},enter={type="fade",frames=20,r1=0,g1=0,b1=0,a1=1,r2=0,g2=0,b2=0,a2=0}}