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
function debug.printTable(table, indent)
    if not indent then
        indent = ""
    end

    for key, value in pairs(table) do
        if type(value) == "table" then
            debug.logInfo(indent .. key .. ":")
            debug.printTable(value, indent .. "  ") -- Recursively print sub-tables with additional indentation
        else
            if value == nil then
                debug.logInfo(indent .. key .. ": nil")
            else
                debug.logInfo(indent .. key .. ": " .. tostring(value))
            end
        end
    end

    local mt = getmetatable(table)
    if mt and type(mt) == "table" then
        debug.logInfo(indent .. "Methods:")
        for key, value in pairs(mt) do
            if type(value) == "function" then
                debug.logInfo(indent .. "  " .. key .. "(): " .. tostring(value))
            end
        end
    end
end



debug.logInfo("DEBUG FUNCTIONS ACTIVE")
debug.messageToPlayer("DEBUG FUNCTIONS ACTIVE")
