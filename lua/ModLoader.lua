// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ModLoader.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Loads entry points for mods which don't use the game_setup.xml and wish to co exist with
//    with other mods. Mods using this loading method can use Class_Reload(className, netvars) 
//    for overriding, hooking into existing functions or extending classes. Usage:
//
//    Place a .entry file into lua/entry/ folder with the following syntax:
//
//    modEntry = [[
//	      Client: lua/TestClient.lua,
//	      Server: lua/TestServer.lua,
//	      Predict: lua/TestPredict.lua,
//        Shared: lua/TestShared.lua,
//	      Priority: 5
//    ]]
//
//    Priority defines the order of loading multiple mods. A mod of priority 10 will be
//    loaded first, mods with priority 1 last.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")

local modEntries = {}
local entryFiles = {}

function ModLoader_GetLoadedModNames()

	local modNames = {}
	
	for i = 1, #modEntries do		
		table.insert(modNames, modEntries[i].ModName)		
	end
	
	return modNames
	
end

function ModLoader_GetModInfo(modName)

	for i = 1, #modEntries do
		if modEntries[i].ModName == modName then
			return modEntries[i]
		end
	end

end

Shared.GetMatchingFileNames("lua/entry/*.entry", false, entryFiles)

local function ParseEntryFile(entryFileString)

	local parsed = {}

	for _, option in pairs(StringSplit(entryFileString, ",")) do
	
		local line = StringSplit(option, ":")
		name = StringTrim(line[1])
		value = StringTrim(line[2])
		
		parsed[name] = value
	
	end

	return parsed
	
end

for i = 1, #entryFiles do

	modEntry = nil
	Script.Load(entryFiles[i])
	
	if not modEntry then
		Shared.Message(string.format("Warning: %s invalid mod entry file.", entryFiles[i]))
	else
	
		local parsedEntry = ParseEntryFile(modEntry)
		
		local splittedPath = StringSplit(entryFiles[i], "/")
		local modName = string.gsub(splittedPath[#splittedPath], ".entry", "")		
		parsedEntry.ModName = modName
	
		table.insert(modEntries, parsedEntry)
	
	end

end

local function SortByModPriority(entry1, entry2)

	local priority1 = entry1.Priority and tonumber(entry1.Priority) or 10
	local priority2 = entry2.Priority and tonumber(entry2.Priority) or 10

	return priority1 > priority2

end

table.sort(modEntries, SortByModPriority)

if Client then
	function ModLoader_OnLoadComplete() 
		for i = 1, #modEntries do
			local modEntry = modEntries[i]
			
			if modEntry.GUIScripts then
				Script.Load( modEntry.GUIScripts )
			end
		end
	end
	
	Event.Hook("LoadComplete", ModLoader_OnLoadComplete)
end

for i = 1, #modEntries do

	local modEntry = modEntries[i]
	
	//Print("Loading entry point for mod '%s'", ToString(modEntry.ModName))

	if Client and modEntry.Client then
		Script.Load(modEntry.Client)
	elseif Predict and modEntry.Predict then
		Script.Load(modEntry.Predict)
	elseif Server and modEntry.Server then
		Script.Load(modEntry.Server)
	end
	
	if modEntry.Shared then
        Script.Load(modEntry.Shared)
	end
	
end


-- fsfod's Event Hook utility
-- This should only be called in cases when a Mod needs to Override an existing Event.Hook().
-- Example Client-Scope usage (in ModClient.lua):
-- Event.RemoveHook("OnUpdateRender")
-- 
-- function ModClientOnUpdateRender()
--     --do stuff
-- end
-- 
-- Add mod Event Hook
-- Event.Hook("OnUpdateRender", ModClientOnUpdateRender())
local dummyFunc = function()end
Event.Hook("a", dummyFunc)  //force the creation of the hook table

local HookTable = debug.getregistry()["Event.HookTable"]

setmetatable( HookTable, {
    __index = function(self, key)
        RawPrint(key)
        return rawget(self, key)
    end
})

Event.RemoveHook = function(event, hook)
  
    local hookList = HookTable[event]

    if(not hookList) then
        RawPrint("There are no hooks set for an event named %s", event)
        return false
    end
  
    for i,hookEntry in ipairs(hookList) do
        if(hook == hookEntry) then
            table.remove(hookList, i)   

            if(#hookList == 0) then
                HookTable[event] = nil
            end
            
            return true
        end
    end
  
    return false
end

Event.RemoveHook("a", dummyFunc)
