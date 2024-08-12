
--[[
@@@@@@@@@@@@@@@@@@@PERSISTENT MISSION CONCEPT by Jinx / ChrisofSweden@@@@@@@@@@@@@@@@@@@
--]]


msn = {}






--[[------------------------------USER CONFIG------------------------------]]--

--Mission name (I suggest setting the same name as the DCS mission file to be able to easily identify what mission the save file belongs to)
msn.strMissionName = 'BPK-test' --results in save file name 'Persistence_demo_persistentData.lua'


--Save file subdir
msn.strSaveFileSubDir = '/Saved Games/DCS.openbeta/Missions/BPK/' --path must start and end with a forward slash / (this path is prefixed programatically to %userprofile%)


--Saving method and interval
msn.strSavingMethod = 'auto' -- valid options: 'manual' or 'auto'
msn.intAutoSaveInterval = 5 --Seconds; Used when saving method is set to 'auto'


--Choose which coalition(s) to have persistence enabled for.
--All three valid options will also track neutral coalition units in addition to chosen coalition.
msn.strPersistenceEnabledCoalition = 'all' --Valid options: 'all', 'red', 'blue'. | 

--[[------------------------------END USER CONFIG------------------------------]]--







--Mission init
msn.tblDeadUnits = {}
msn.event_dead = {}
world.addEventHandler(msn.event_dead)
--End Mission init


--Adds destroyed ground units to table tblDeadUnits
function msn.event_dead:onEvent(Event)
	
	--If event is EVENT_DEAD and Initiator is object category Unit
	
	if (Event.id == world.event.S_EVENT_DEAD or Event.id == world.event.S_EVENT_UNIT_LOST) and Event.initiator:getCategory() == 1 then
				
			initObjName = Event.initiator:getName()
			initObjID = Event.initiator:getID()
	
			if msn.strPersistenceEnabledCoalition == 'all' then 
				
				table.insert(msn.tblDeadUnits,
								{
									["unitID"] = initObjID,
									["name"] = initObjName
								}
							)
						
			else
			
					if msn.strPersistenceEnabledCoalition == 'red' then
						msn.strPersistenceEnabledCoalition = 1
					else 
						msn.strPersistenceEnabledCoalition = 2
					end
			
					initObjCoa = Event.initiator:getCoalition()
					if initObjCoa == msn.strPersistenceEnabledCoalition or initObjCoa ==  0 then
					
						table.insert(msn.tblDeadUnits,
										{
											["unitID"] = initObjID,
											["name"] = initObjName
										}
									)
					
					end
					
			end
							
	end
	--env.info("BPK-debug: Table-debug:" .. msn.tblDeadUnits[0][unitID])
	
end

function msn.save_State()

	local strSaveFileName = msn.strMissionName .. '_persistentData.lua'
	
	--Saves deadUnits table to file strSaveFileName
	table.save(msn.tblDeadUnits, msn.strSaveFilePath .. strSaveFileName)
	
	
	if msn.strSavingMethod == 'auto' then
		timer.scheduleFunction(msn.save_State, {}, timer.getTime() + msn.intAutoSaveInterval)
	else
		trigger.action.outText('Mission state saved.',5)
	end


end

function msn.load_State() --function called at mission start

	local strSaveFileName = msn.strMissionName .. '_persistentData.lua'
	
	--Loads deadUnits table from file strSaveFileName
	msn.tblDeadUnits = table.load(msn.strSaveFilePath .. strSaveFileName)
	if msn.tblDeadUnits == nil then
		msn.tblDeadUnits = {}
		trigger.action.outText('INFO: Saved dead units state not found. New round started.',5)

	else
	
		for k,v in pairs(msn.tblDeadUnits) do 

			if Unit.getByName(v.name) then
				Unit.getByName(v.name):destroy()
			end

		end
		
		trigger.action.outText('Existing saved state was loaded.',5)

		
		
	end
	
	if msn.strSavingMethod == 'auto' then
		timer.scheduleFunction(msn.save_State, {}, timer.getTime() + msn.intAutoSaveInterval)
	else
		missionCommands.addCommand('Save Mission State', nil, msn.save_State)
	end
	
	
end
 

 
msn.strSaveFilePath = os.getenv('USERPROFILE') .. msn.strSaveFileSubDir
msn.load_State()


			
