-- UTILS

utils = utils or {}

function utils.init_screen (name, config, adaptwidth, adaptheight)
  local lwidth, lheight, screenlwidth, screenHeight
  local screenX, screenY = MOAIEnvironment.screenWidth, MOAIEnvironment.screenHeight
  print("MOAIEnvironment.screenWidth, MOAIEnvironment.screenHeight:",screenX,screenY)
  if screenX ~= nil then --if physical screen
    lwidth, lheight, screenlwidth, screenHeight = screenX, screenY, screenX, screenY
  else
    lwidth, lheight, screenlwidth, screenHeight = config.sizes[config.device][1], config.sizes[config.device][2], config.sizes[config.device][3], config.sizes[config.device][4]
    print("missing native resolution using from config:",lwidth, lheight, screenlwidth, screenHeight)
  end

  if config.landscape == true then -- flip lwidths and Hieghts
    print("Landscape mode")
    lwidth, lheight = lheight, lwidth
    screenlwidth, screenHeight = screenHeight, screenlwidth
    adaptwidth, adaptheight = adaptheight, adaptwidth
  end

  landscape, device, sizes, screenX, screenY = nil


  if name == nil then
    name = "mainwindow"
  end

  --  lwidth, lheight from the SDConfig.lua

  MOAISim.openWindow(name, screenlwidth, screenHeight)

  if adaptwidth and adaptheight then
    SCREEN_X_OFFSET = 0
    SCREEN_Y_OFFSET = 0

    local gameAspect = adaptheight / adaptwidth
    local realAspect = screenHeight / screenlwidth

    if realAspect > gameAspect then
      SCREEN_WIDTH = screenlwidth
      SCREEN_HEIGHT = screenlwidth * gameAspect
    else
      SCREEN_WIDTH = screenHeight / gameAspect
      SCREEN_HEIGHT = screenHeight
    end

    if SCREEN_WIDTH < screenlwidth then
      SCREEN_X_OFFSET = ( screenlwidth - SCREEN_WIDTH ) * 0.5
    end

    if SCREEN_HEIGHT < screenHeight then
      SCREEN_Y_OFFSET = ( screenHeight - SCREEN_HEIGHT ) * 0.5
    end

    viewport = MOAIViewport.new ()
    viewport:setSize ( SCREEN_X_OFFSET, SCREEN_Y_OFFSET, SCREEN_X_OFFSET + SCREEN_WIDTH, SCREEN_Y_OFFSET + SCREEN_HEIGHT )
    viewport:setScale ( adaptwidth, adaptheight )
    utils.screen_width,utils.screen_height = adaptwidth, adaptheight
  else
    SCREEN_X_OFFSET = 0
    SCREEN_Y_OFFSET = 0
    viewport = MOAIViewport.new ()
    viewport:setSize ( 0, 0, screenlwidth, screenHeight )
    viewport:setScale ( lwidth, lheight )
    utils.screen_width,utils.screen_height = lwidth, lheight
  end

  utils.screen_middlewidth,utils.screen_middleheight = utils.screen_width/2,utils.screen_height/2

  if config.fullscreen then
   MOAISim.enterFullscreenMode ()
  end

end

function utils.MOAIGfxQuad2D_new (image,width,height)
  local gfxQuad = MOAIGfxQuad2D.new()
  gfxQuad:setTexture ( image, MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA + MOAIImage.POW_TWO )
  local w,h
  if width and height then
    w, h = width,height
  else
    w, h = image:getSize ()
  end
  gfxQuad:setRect(-w/2, -h/2, w/2, h/2 )
  return gfxQuad
end

function utils.MOAIImage_new(image)
  local im = MOAIImage.new()
  im:load(image,MOAIImage.TRUECOLOR)
  return im
end

function utils.generateId(ptype)
  if _G.counterid == nil then
    _G.counterid = 0
  end
  _G.counterid = _G.counterid + 1
  return ptype.._G.counterid
end

function utils.distance(x1,y1,x2,y2)
  local dx=x2-x1
  local dy=y2-y1
  return math.sqrt(math.pow(dx,2)+math.pow(dy,2))
end