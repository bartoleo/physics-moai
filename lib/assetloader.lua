-- ASSET LOADER WITH LAZY LOADING

assetloader =  {}
assetloader.initialized = false
assetloader.assets =  {}
assetloader.charcodes='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-+<>[]|%'

-- Compatibility: Lua-5.0
function assetloader.split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
      return { str }
    end
    if maxNb == nil or maxNb < 1 then
      maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
      nb = nb + 1
      result[nb] = part
      lastPos = pos
      if nb == maxNb then break end
    end
  -- Handle the last field
  if nb ~= maxNb then
    result[nb + 1] = string.sub(str, lastPos)
  end
  return result
end

--- recursively load all files in the a dir and run them through a function
-- @param targettable target store table
-- @param path path of files
-- @param extension extension of files
-- @param func func to call for every file
function assetloader.loadfromdir(targettable, path, extension, func, methodset)
  local extmatch = "%." .. extension .. "$"
  local _files = MOAIFileSystem.listFiles (path)
  if _files then
    for i, v in ipairs(_files) do
      if PLATFORM=="Android" and string.find(v,path.."/")==1 then
        v=string.sub(v,string.len(path)+2)
      end
      if v:match(extmatch) then
        if func==require then
          targettable[v:sub(1, -5)] = func(path .. "/" .. v:sub(1, -5))
        else
          if methodset and methodset ~="" then
            targettable[v:sub(1, -5)] = func()
            targettable[v:sub(1, -5)][methodset](targettable[v:sub(1, -5)],path .. "/" .. v)
          else
            targettable[v:sub(1, -5)] = func(path .. "/" .. v)
          end
        end
      end
    end
  end
  local _dirs = MOAIFileSystem.listDirectories (path)
  if _dirs then
    for i, v in ipairs(_dirs) do
      targettable[v] = {}
      loadfromdir(targettable[v], path .. "/" .. v, extension, func)
    end
  end
end

-- This function search for a file in the folder and in all subfolders
function assetloader.recursiveSearchFile(folder, filesearched)
  local filesTable = MOAIFileSystem.listFiles(folder)
  if filesTable and #filesTable>0 then
    for i,v in ipairs(filesTable) do
      if PLATFORM=="Android" and string.find(v,folder.."/")==1 then
        v=string.sub(v,string.len(folder)+2)
      end
      local file = folder.."/"..v
      if string.upper(v)==string.upper(filesearched) then
        return folder.."/"..v
      end
    end
  end
  local dirsTable = MOAIFileSystem.listDirectories(folder)
  if dirsTable and #dirsTable>0 then
    for i,v in ipairs(dirsTable) do
      local file = folder.."/"..v
      local filetrovato = assetloader.recursiveSearchFile(file, filesearched)
      if filetrovato ~= "" then
        return filetrovato
      end
    end
  end
  return ""
end

function assetloader.lazyload(pkey,pdir,pextensions,pfunction,pset)
  local f
  for _,v in pairs(pextensions) do
    if MOAIFileSystem.checkFileExists ( pdir.."/"..pkey..v  ) then
      if pfunction==require then
        f = pfunction( pdir.."/"..pkey..v:sub(1, -5) )
      elseif pset and pset ~="" then
        f = pfunction()
        f[pset](f, pdir.."/"..pkey..v )
      else
        f = pfunction( pdir.."/"..pkey..v )
      end
      break
    else
      local filesearch=assetloader.recursiveSearchFile(pdir.."/",pkey..v)
      if filesearch ~= "" then
        if pfunction==require then
          f = pfunction(filesearch:sub(1, -5) )
        elseif pset and pset ~="" then
          f = pfunction()
          f[pset](f, filesearch)
        else
          f = pfunction( filesearch )
        end
      end
    end
  end
  return f
end

function assetloader.addAssetLoader(pTableName,pPath,pExtensions,pFunction,pSet)
  if _G[pTableName] == nil then
    _G[pTableName] = {}
  end
  _G[pTableName].__path = pPath
  _G[pTableName].__extensions = pExtensions
  _G[pTableName].__function = pFunction
  _G[pTableName].__setter = pSet
  setmetatable(_G[pTableName], {__index = function(t,k)
    local f = assetloader.lazyload(k,t.__path,t.__extensions,t.__function,t.__setter)
    rawset(t, k, f)
    return f
  end })
  if assetloader.assets[pTableName]==nil then
    assetloader.assets[pTableName]=true
  end
end

if fonts == nil then
  fonts = {}
end

-- lazy font loading
setmetatable(fonts, {__index = function(t,k)
  local s = assetloader.split(k,",")
  local f
  local fontname = t.__path.."/"..s[1]
  local fontsize = tonumber(s[2])
  if MOAIFileSystem.checkFileExists (fontname..".ttf"  ) then
    f = MOAIFont.new ()
    f:loadFromTTF ( fontname..".ttf", assetloader.charcodes, fontsize )
  elseif MOAIFileSystem.checkFileExists ( fontname..".fnt"  ) then
    f = MOAIFont.new ()
    f:loadFromBMFont ( fontname..".fnt")
  elseif MOAIFileSystem.checkFileExists ( fontname..".png"  ) then
    f = MOAIFont.new ()
    local bitmapFontReader = MOAIBitmapFontReader.new ()
    bitmapFontReader:loadPage ( fontname..".png", assetloader.charcodes, fontsize )
    f:setReader ( bitmapFontReader )
    local glyphCache = MOAIGlyphCache.new ()
    glyphCache:setColorFormat ( MOAIImage.COLOR_FMT_RGBA_8888 )
    f:setCache ( glyphCache )
    f:setDefaultSize (fontsize,72)
  end

  rawset(t, k, f)
  return f
end })

fonts.__path = "fonts"
assetloader.addAssetLoader("images","images",{".png",".jpg",".gif"},utils.MOAIImage_new,"")
assetloader.addAssetLoader("classes","classes",{".lua"},require,"")
assetloader.addAssetLoader("sounds","sounds",{".ogg",".wav"},soundmgr.newSound,"")
assetloader.addAssetLoader("musics","musics",{".ogg"},soundmgr.newMusic,"")

function assetloader.load()
  assetloader.loadfromdir(classes, "classes", "lua", require,"")
  assetloader.loadfromdir(images, "images/autoload", "png",utils.MOAIImage_new,"")
  assetloader.loadfromdir(sounds, "sounds/autoload", "ogg",soundmgr.newSound,"")
  assetloader.loadfromdir(sounds, "sounds/autoload", "wav",soundmgr.newSound,"")
  assetloader.loadfromdir(musics, "musics/autoload", "ogg",soundmgr.newMusic,"")
  assetloader.initialized = true
end

function assetloader.reload()
  for k,v in pairs(assetloader.assets) do
    if _G[k] and _G[k].__function~=require then
      for kk,vv in pairs(_G[k]) do
        if string.sub(kk,2)~="__" then
          local f = lazyload(k,_G[k].__path,_G[k].__extensions,_G[k].__function)
          if f then
            rawset(_G[k], k, f)
          end
        end
      end
    end
  end
end