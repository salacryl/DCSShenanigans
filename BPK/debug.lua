DEBUG_PREFIX = "DEBUG MISSION SCRIPTING"

debug = {}

function debug.logInfo(message)
    env.info(DEBUG_PREFIX .. " - Info: " .. message)
end

function debug.logWarning(message)
    env.info(DEBUG_PREFIX .. " - Warning: " .. message)
end

function debug.logError(message)
    env.info(DEBUG_PREFIX .. " - Warning: " .. message)
end

function debug.messageToPlayer(message)
    if message== nil then
        return
    end
    trigger.action.outText(message,5)
end

function debug.getTableSize(tableForCounting)
    local count = 0
    for _ in pairs(tableForCounting) do count = count + 1 end
    return count
    
end

function debug.tableDump(tableForDumping, depth )
    if tableForDumping == nil then 
        debug.logWarning("the variable given for dumping was nil (variable not set)" )
        return
    end
    if type(tableForDumping) ~= "table" then 
        debug.logWarning("the variable given for dumping was not a table! It was a " .. type(tableForDumping))
        return
    end

    if debug.getTableSize(tableForDumping) == 0 then
        debug.logWarning("the variable given for dumping was a table, but has a size of 0!")
        return
    end

    if type(depth) ~= "number" or depth == nil then
        depth=2
    end

    debug.logInfo("after conditions")
    for k, v in pairs(tableForDumping) do
        debug.logInfo("-- Dumping Table --")
        for i = 0, depth, 1 do
            debug.logInfo("\t Index: " .. k .. "; Type of value: "..  type(v) .. "; Value: " .. v)    
            if type(v) == "table" then
                 debug.tableDump(v)
            end

        end
        

    end
end

debug.logInfo("DEBUG FUNCTIONS ACTIVE")
debug.messageToPlayer("DEBUG FUNCTIONS ACTIVE")
