--Thanks grimes and graywolf, this script is handy AF for updating multiple mission files without needing to do it manually. -Chaos
--to the guy lurking around here trying to learn from my stuff like I did with grimes and gray's work, just come ask me.

--FilePath = "C:\\Users\\Chaos\\Downloads\\DCS LUA scripts\\" --local path
--local FilePathServer = "C:\\Users\\maintain\\Saved Games\\DCS.openbeta_server\\Missions\\scripts\\" --server path
FilePath = "C:\\Users\\BjoernMeier\\Saved Games\\DCS.openbeta\\Missions\\bubble\\"                                       --local path
local FilePathServer = "C:\\Users\\BjoernMeier\\Saved Games\\DCS.openbeta\\Missions\\scripts\\" --server path

env.info("Chaos Log: Loading scripts in NonMiz init", 3)

if lfs and lfs.attributes then
    local anything
    env.info('lfs attributes exists')
    anything = lfs.attributes(FilePathServer, 'size')

    if anything then
        env.info('Chaos Log: Server enviroment detected')
        FilePath = FilePathServer
    else
        env.info("Chaos Log: Defaulting to Chaos enviroment")
    end
else
    env.error("Chaos Log: NO LFS - GO CHANGE THIS AT: DCS World\\Scripts\\MissionScripting.lua")
    trigger.action.outText("LFS IS NOT ENABLED, GO CHANGE THIS AT: DCS World\\Scripts\\MissionScripting.lua", 1000)
end

local fList = { "mist.lua",}
for i = 1, #fList do
    env.info("Chaos Log: Loading: " .. fList[i])
    assert(loadfile(FilePath .. fList[i]))()
end
