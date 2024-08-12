SPAWN_UNIT_WITHOUT_AI_DISTANCE =180
SPAWN_UNIT_WITH_AI_DISTANCE = 170
DESPAWN_UNIT_COMPLETELY_DISTANCE = 200

SA2_FILTER_PATTERN="r SAM"
SA3_FILTER_PATTERN="SA-3"
AAA_FILTER_PATTERN="_AAA_"
AA_FILTER_PATTERN="_AA_"
SHORADS_FILTER_PATTERN="_SHORADS_"

CHECK_INTERVAL = 20
DEBUG_BUBBLE=true

bubble = {}
bubble.eventDead = {}
local _unitTable ={}
local _groupTable= {}
local _tableIsPrepared = false 
function bubble.log(message)
    if DEBUG_BUBBLE == true then
        env.info("BUBBLE SCRIPT: " .. message)
    end
end

function bubble.eventDead:onEvent(Event)
    if _tableIsPrepared == false then
        return
    end

    if Event.id == world.event.S_EVENT_DEAD and Event.initiator:getCategory() == 2 then
        Event.initiator:getID()
        for indexUnit, unit in ipairs( _unitTable) do
            if unit.id == Event.initiator:getID() then
                unit.Dead=true
            end
        end 
    end
end

local function recreateGroup(countryID, group)
    local _units = {}

    for i, unit in ipairs(_unitTable) do
        local _actUnit ={}
        
        
        if unit.group == group.Name then
            _actUnit.type=unit.type
            _actUnit.transportable = 
                    {
                        ["randomTransportable"] = false
                    }
            _actUnit.unitID = unit.id
            _actUnit.skill = "Excellent"
            _actUnit.y = unit.y
            _actUnit.x = unit.x
            _actUnit.Name = unit.Name
            _actUnit.playerCanDrive = false
            _actUnit.Dead = unit.Dead
            if _actUnit.Dead==false then
                table.insert(_units, _actUnit)  
            end
        end
    end
    
    
    local _groupData = {
        ["visible"] = true,
        ["taskSelected"] = true,
        ["route"] = {}, -- end of ["route"]
        ["groupId"] = group.id ,
        ["tasks"] = {}, -- end of ["tasks"]
        ["hidden"] = false,
        ["units"] = _units, -- end of ["units"]
        ["y"] = coord.LLtoLO(group.Lat, group.Long).z,
        ["x"] = coord.LLtoLO(group.Lat, group.Long).x,
        ["name"] = group.Name,
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
      } -- end of [1]

      
      coalition.addGroup(countryID , 2 ,_groupData )
      Group.getByName(group.Name):getController():setOnOff(false)
      group.units = {}
      if  redIADS ~= nil then
        redIADS:addSAMSite(group.Name)
      end
      bubble.log("recreated group " .. group.Name .. " with AI disabled")
    
end

local function fillUnitTables()
    local _counterUnits=0
    local _counterGroups=0
        bubble.log("preparing Units and Groups")
    for i = 1, 2, 1 do
        for indexGroup, group in ipairs( coalition.getGroups(i, 2)) do
            local _actGroup={["Name"]=""}

            if(string.find(group:getName(), SA2_FILTER_PATTERN) or string.find(group:getName(), SA3_FILTER_PATTERN) or string.find(group:getName(), AAA_FILTER_PATTERN) or string.find(group:getName(), AA_FILTER_PATTERN) or string.find(group:getName(), SHORADS_FILTER_PATTERN)) then
                _actGroup.Name = group:getName()
                _actGroup.id = group:getID()
                _actGroup.Lat, _actGroup.Long,_=coord.LOtoLL(group:getUnit(1):getPoint())
                _actGroup.disabled = false
                _actGroup.Dead = false
                _actGroup.units = {}
                _actGroup.country = group:getUnit(1):getCountry()

                table.insert(_groupTable, _actGroup)
                bubble.log("Group " .. _actGroup.Name .. " added to the table")
                _counterGroups=_counterGroups+1
            end
            for indexUnit, unit in ipairs( group:getUnits()) do
                local _actUnit ={}
               
                
                _counterUnits=_counterUnits+1
                _actUnit.group = group:getName()
                _actUnit.id = unit:getID()
                _actUnit.x = unit:getPoint().x
                _actUnit.y = unit:getPoint().z
                 
                _actUnit.Name = unit:getName()
                _actUnit.type = unit:getTypeName() 
                _actUnit.Dead = false
                table.insert( _unitTable, _actUnit )        
            end
        end
    end
    _unitTable.size=_counterUnits
    _groupTable.size=_counterGroups

    bubble.log(_counterUnits .. " units and ".. _counterGroups .. " groups prepared!")
    _tableIsPrepared = true
end

-- Function to calculate the distance between two coordinates in nautical miles
local function haversine(lat1, lon1, lat2, lon2)
    local function toRadians(degrees)
        return degrees * (math.pi / 180)
    end

    local R = 3440.065  -- Radius of the Earth in nautical miles

    local dLat = toRadians(lat2 - lat1)
    local dLon = toRadians(lon2 - lon1)

    local a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(toRadians(lat1)) * math.cos(toRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2)
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    local distance = R * c

    return distance
end

local function switchGroupState()
    if _tableIsPrepared == false then return end

    bubble.log("Checking group proximity")
    local _counter=0
    
    local _groupSwitched
    debug.printTable(_groupTable)
    for indexGroup, group in ipairs(_groupTable) do
        
        local _distanceLevel =0
        for i = 1, 2, 1 do
            for indexPlayer, player in ipairs( coalition.getPlayers(i)) do
                local _playerLat, _playerLong, _playerAlt = coord.LOtoLL(player:getPoint())
                local _distance = haversine(_playerLat, _playerLong, group.Lat, group.Long)
                
                bubble.log("distance of player " .. player:getPlayerName() .. " to group "..group.Name .." : " .. _distance)

                
                if _distance >= DESPAWN_UNIT_COMPLETELY_DISTANCE  and _distanceLevel <3 then
                    _distanceLevel = 3
                end 
                if _distance >= SPAWN_UNIT_WITHOUT_AI_DISTANCE and _distance < DESPAWN_UNIT_COMPLETELY_DISTANCE and _distanceLevel <2 then
                    _distanceLevel = 2
                end
                if _distance >= SPAWN_UNIT_WITH_AI_DISTANCE and _distance < SPAWN_UNIT_WITHOUT_AI_DISTANCE and _distanceLevel < 1 then
                    _distanceLevel = 1
                end
            end
        end                                          
        bubble.log("_distanceLevel: " .. _distanceLevel )
        if _distanceLevel == 3 then 
            if group.disabled == false and group.Dead == false then
                    Group.getByName(group.Name):destroy()
                    bubble.log("Group " .. group.Name .. " destroyed!")
                    group.disabled=true
                    group.Dead = true
            end
        end
        if _distanceLevel == 2 then
            if group.disabled == false and group.Dead  == false then
                Group.getByName(group.Name):getController():setOnOff(false)
                bubble.log("Group " .. group.Name .. " AI disabled!")
                
                group.disabled=true
            end
            if group.disabled == true and group.Dead  == true  then
                recreateGroup(group.country, group)
                Group.getByName(group.Name):getController():setOnOff(false)
                bubble.log("Group " .. group.Name .. " spawned with AI disabled!")
                group.Dead=false
                group.disabled=true
            end
        end
        if _distanceLevel == 1 then
            if group.disabled == true and group.Dead  == false then
                Group.getByName(group.Name):getController():setOnOff(true)
                bubble.log("Group " .. group.Name .. " AI enabled!")
                group.disabled=false
            end
            if group.disabled == true and group.Dead  == true  then
                recreateGroup(group.country, group)
                Group.getByName(group.Name):getController():setOnOff(true)
                bubble.log("Group " .. group.Name .. " spawned with AI enabled!")
                group.disabled = false
                group.disabled=true
            end
        end
        _counter=_counter+1
    end                    
    bubble.log(_counter .. " groups checked!")
    timer.scheduleFunction(switchGroupState, {}, timer.getTime() + CHECK_INTERVAL)
end

world.addEventHandler(bubble.eventDead)

fillUnitTables()
switchGroupState()
