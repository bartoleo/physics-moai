 -- STORAGE MANAGER

module ( "storagemgr", package.seeall )

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local storage = {}
DEVICE = true
local directory = ""


----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------
function init ( pdirectory )
	directory=pdirectory
	if directory and directory ~="" then
	  if string.sub(directory,-1)~="/" then
	  	directory=directory.."/"
	  end
	else
		directory=""
	end
end

function get ( filename, cache )

	if cache then
		if not storage [ filename ] then
			storage [ filename ] = makeStorage ( filename )
			storage [ filename ]:load ()
		end
        return storage [ filename ]
	else
		local _storage = makeStorage ( filename )
		_storage:load ()
		return _storage
	end

end

function put ( filename, data )
	local _storage = makeStorage ( filename )
	_storage.data = data
	_storage:save ()
end

function clearCache()
	storage={}
end


----------------------------------------------------------------
-- local functions
----------------------------------------------------------------
function makeStorage ( filename )

	local storage = {}

	storage.filename = filename
	storage.fileexist = false
	storage.data = nil

	----------------------------------------------------------------
	function storage.load ( self )

		local fullFileName = self.filename .. ".lua"
		local workingDir
		local changedworkingDir
		local currDir

        if MOAIEnvironment.documentDirectory then
			workingDir = MOAIFileSystem.getWorkingDirectory ()
			currDir = MOAIEnvironment.documentDirectory.."/"..directory
			MOAIFileSystem.setWorkingDirectory ( currDir )
			changedworkingDir=true
		elseif PLATFORM=="Nacl" then
			currDir = "NaClFileSys/"
			fullFileName =  currDir .. string.gsub(directory,"/","_") .. fullFileName
		else
			workingDir = MOAIFileSystem.getWorkingDirectory ()
			currDir = workingDir.."/"..directory
			MOAIFileSystem.setWorkingDirectory ( currDir )
			changedworkingDir=true
		end

		if PLATFORM~="Nacl" then
			print(currDir)
			MOAIFileSystem.affirmPath(currDir)
		end

		if MOAIFileSystem.checkFileExists ( fullFileName ) then
			local file = io.open ( fullFileName, 'rb' )
			storage.data = dofile ( fullFileName )
			self.fileexist = true
		else
			storage.data = {}
			self.fileexist = false
		end

		if changedworkingDir then
			MOAIFileSystem.setWorkingDirectory ( workingDir )
		end

		return self.fileexist
	end

	----------------------------------------------------------------
	function storage.save( self )

		local fullFileName = self.filename .. ".lua"
		local workingDir
		local serializer = MOAISerializer.new ()
		local currDir

		self.fileexist = true
		serializer:serialize ( self.data )
		local gamestateStr = serializer:exportToString ()

        if MOAIEnvironment.documentDirectory then
			workingDir = MOAIFileSystem.getWorkingDirectory ()
			currDir = MOAIEnvironment.documentDirectory.."/"..directory
			MOAIFileSystem.setWorkingDirectory ( currDir )
			changedworkingDir=true
		elseif PLATFORM=="Nacl" then
			currDir = "NaClFileSys/"
			fullFileName =  currDir .. string.gsub(directory,"/","_") .. fullFileName
		else
			workingDir = MOAIFileSystem.getWorkingDirectory ()
			currDir = workingDir.."/"..directory
			MOAIFileSystem.setWorkingDirectory ( currDir )
			changedworkingDir=true
		end

		if PLATFORM~="Nacl" then
			print(currDir)
			MOAIFileSystem.affirmPath(currDir)
		end

		local file = io.open ( fullFileName, 'wb' )
		file:write ( gamestateStr )
		file:close ()

		if changedworkingDir then
			MOAIFileSystem.setWorkingDirectory ( workingDir )
		end
	end

	return storage
end
