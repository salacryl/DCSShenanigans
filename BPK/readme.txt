BASIC PERSISTENCE KIT by Jinx / ChrisofSweden

What this does:
It stores dead ground unit names and ID's to a table that is then saved to a file via manual or automatic saving.
On mission start/restart, loads saved file containing table of dead units, and removes them from the mission.

What this does NOT:
It does not save unit positions or routes so any units that moved during the mission will be back at initial position at mission start/restart.
It does not save destroyed static objects or scenery/buildnings.
It does not work with dynamically spawned ground units.

FILE CONTENTS

readme.txt
This text.

Mission.lua
Contains mission configuration variables, an event handler for logging destroyed units and calls to save and load file functions.

File_IO_functions.lua
Contains the actual file IO functions that creates/saves and loads dead units table to/from file.

Persistence_demo.miz
Example DCS mission file


PREREQUISITES:


To allow DCS Scripting Environment to create the save state file in your file system you also need to modify file:
"DCS World\Scripts\MissionScripting.lua"

Change:

do
    sanitizeModule('os')
    sanitizeModule('io')
    sanitizeModule('lfs')
    require = nil
    loadlib = nil
end

--To:

do
    --sanitizeModule('os')
    --sanitizeModule('io')
    --sanitizeModule('lfs')
    require = nil
    loadlib = nil
end



USAGE:

Put the unzipped folder "Basic Persistance Kit" into your Saved Games\DCS\Missions\ folder

Open file Mission.lua and configure the few variables in the USER CONFIG section, they are all explained and examples supplied.
Save and close Mission.lua.

Open DCS Mission Editor.
Create a mission and populate it how you want, or open an existing mission you would like to add persistence to.
Give the mission the same name you put in Mission.lua and save it.
Add a trigger TYPE "ONCE" with CONDITION "TIME MORE" set to 3, and add two ACTIONS:
    DO SCRIPT FILE and load the "File_IO_functions.lua" script.
    DO SCRIPT FILE and load the "Mission.lua" script.

Save your mission and play.

Enjoy!
