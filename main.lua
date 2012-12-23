config =  require("config")
require "lib/SECS"
require "lib/utils"
require "lib/simplegui"
require "lib/statemgr"
require "lib/inputmgr"
require "lib/soundmgr"
require "lib/storagemgr"
require "lib/assetloader"
require "lib/directions"
require "lib/platforms"

GAME_VERSION = "0.0.1"

function main()

  print("Physics Moai "..GAME_VERSION.." starting...")

  storagemgr.init("physicsmoai")

  local _storage=storagemgr.get("_settings")
  if _storage.data then
    if _storage.data.landscape~=nil then
      config.landscape = _storage.data.landscape
      if config.forcelandscape~=nil then
        config.landscape = config.forcelandscape
      end
    end
  end

  utils.init_screen("Physics Moai",config,640,960)

  soundmgr.init(nil,16,44100,512,1)

  if _storage.data then
    if _storage.data.globalvolume then
      soundmgr.setGlobalVolume(_storage.data.globalvolume)
    end
  end

  -- seed random numbers
  math.randomseed ( os.time ())
  globalData = {}

  JUMP_TO = nil
  statemgr.push ( JUMP_TO or "intro" )

  -- Start the game!
  statemgr.begin ()

end

main()