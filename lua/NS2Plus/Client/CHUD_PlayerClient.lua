originalBlur = Class_ReplaceMethod( "Player", "SetBlurEnabled",
	function(self, blurEnabled)
		if not CHUDGetOption("blur") then
			Player.screenEffects.blur:SetActive(false)
		else
			originalBlur(self, blurEnabled)
		end
	end
)

--[[
originalUpdateScreenEff = Class_ReplaceMethod( "Player", "UpdateScreenEffects",
	function(self, deltaTime)
		originalUpdateScreenEff(self, deltaTime)

		Player.screenEffects.lowHealth:SetActive(false)
	end
)
--]]

local originalSESetActive
originalSESetActive = Class_ReplaceMethod("ScreenEffect", "SetActive",
	function(self, setActive)
		if CHUDGetOption("particles") and self == Player.screenEffects.gorgetunnel then
			setActive = false
		end

		originalSESetActive(self, setActive)
	end
)

-- Disables low health effects
function UpdateDSPEffects()
	-- We're not doing anything in this function
	-- but leave this for future generations to wonder why this was an option in the first place

	-- Most ancient piece of code in this mod - Archaeologists pls be careful, this code has a curse
	--if Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
		--originalDSPEff()
	--end
end

local lastIngameNumPlayers = 0
local totalNumPlayers = 0
local nextUpdateTotalNumPlayers = 0

local chatInterval = 15
local lastChatCommand = -chatInterval

local function ClientSay(...)

	local args = {...}
	local message = ""
	
	for _, word in ipairs(args) do
		if message == "" then
			message = word
		else
			message = message .. " " .. word
		end
	end
	
	if message ~= nil and string.len(message) > 0 and Shared.GetTime(true) > lastChatCommand + chatInterval then

		lastChatCommand = Shared.GetTime(true)
		message = string.sub(message, 1, kMaxChatLength)
		Client.SendNetworkMessage("ChatClient", BuildChatClientMessage(false, message), true)
		
	end

end

local function ClientTeamSay(...)
	local args = {...}
	local message = ""
	
	for _, word in ipairs(args) do
		if message == "" then
			message = word
		else
			message = message .. " " .. word
		end
	end
	
	if message ~= nil and string.len(message) > 0 and Shared.GetTime(true) > lastChatCommand + chatInterval then

		lastChatCommand = Shared.GetTime(true)
		message = string.sub(message, 1, kMaxChatLength)
		Client.SendNetworkMessage("ChatClient", BuildChatClientMessage(true, message), true)
		
	end
end

local originalPlayerOnInit
originalPlayerOnInit = Class_ReplaceMethod("Player", "OnInitialized",
	function(self)
		originalPlayerOnInit(self)
		
		local message = { }
		message.overkill = CHUDGetOption("overkilldamagenumbers")
		Client.SendNetworkMessage("SetCHUDOverkill", message)
		
		local message = { }
		message.serverblood = CHUDGetOption("serverblood")
		Client.SendNetworkMessage("SetCHUDServerBlood", message)

		local message = {
			slotMode = CHUDGetOption("alien_weaponslots")
		}
		Client.SendNetworkMessage("SetCHUDAlienWeaponSlot", message)
	end)

Event.Hook("Console_say", ClientSay)
Event.Hook("Console_team_say", ClientTeamSay)