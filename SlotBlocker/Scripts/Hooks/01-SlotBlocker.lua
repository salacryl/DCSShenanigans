MISSION_NAME = "test"
slotBlock = {}

function slotBlock.onMissionLoadEnd( )
	slotBlock.checkMission()
end

function slotBlock.onPlayerTrySendChat(id, msg, all)
	slotBlock.checkMission()
end

function slotBlock.onPlayerChangeSlot(playerId )
	slotBlock.checkMission()
	local slotID = net.get_player_info(playerId, 'slot')
    local side = net.get_player_info(playerId, 'side')
	if  (side ~=0 and  (slotID ~='' or slotID ~= nil))   then
		net.log("Rejection Player: " .. playerId)
		slotBlock.rejectPlayer(playerId)
	end
end

function slotBlock.rejectPlayer (playerID)
    net.log("Reject Slot - force spectators - "..playerID)

    -- put to spectators
    net.force_player_slot(playerID, 0, '')

    local _playerName = net.get_player_info(playerID, 'name')

    if _playerName ~= nil then
        --Disable chat message to user
        local _chatMessage = string.format("*** Sorry %s - Slot DISABLED, Pilot has been shot down and needs to be rescued by CSAR ***",_playerName)
        net.send_chat_to(_chatMessage, playerID)
    end
end

function slotBlock.checkMission()
	local missionName = DCS.getMissionName( )
	local _status,_error  = net.dostring_in('server', "return trigger.misc.getUserFlag('slotBlock');")
	

	if (not (MISSION_NAME == missionName) or (_status=='disabled') ) then 
		slotBlock={} --Hook table, set to an empty one
		net.log("Hook not set. Different Mission")	
		DCS.setUserCallbacks(slotBlock) -- register empty Hook.
	else
		net.log("Hook set. Mission: " .. missionName)	
	end
	
end

DCS.setUserCallbacks(slotBlock)
