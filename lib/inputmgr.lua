-- INPUT MANAGER

module ( "inputmgr", package.seeall )
----------------------------------------------------------------
-- local interface
----------------------------------------------------------------

----------------------------------------------------------------
-- public interface
----------------------------------------------------------------
function down ( )
	if MOAIInputMgr.device.touch then
		return MOAIInputMgr.device.touch:down ()
	elseif MOAIInputMgr.device.pointer then
		return (
			MOAIInputMgr.device.mouseLeft:down ()
		)
	end
end
function getTouch ()
	if MOAIInputMgr.device.touch then
		return MOAIInputMgr.device.touch:getTouch ()
	elseif MOAIInputMgr.device.pointer then
		local _x,_y = MOAIInputMgr.device.pointer:getLoc ()
		return _x, _y, 1
	end
end
function isDown ( )
	if MOAIInputMgr.device.touch then
		return MOAIInputMgr.device.touch:isDown ()
	elseif MOAIInputMgr.device.pointer then
		return (
			MOAIInputMgr.device.mouseLeft:isDown ()
		)
	end
end
function up ( )
	if MOAIInputMgr.device.touch then
		return MOAIInputMgr.device.touch:up ()
	elseif MOAIInputMgr.device.pointer then
		return (
			MOAIInputMgr.device.mouseLeft:up ()
		)
	end
end
function keyboardPresent()
	if MOAIInputMgr.device.keyboard then
		return true
	end
	return false
end