local originalGUIRequestUpdate
originalGUIRequestUpdate = Class_ReplaceMethod( "GUIRequestMenu", "Update",
	function(self, deltaTime)
		originalGUIRequestUpdate(self, deltaTime)
		
		for _,button in ipairs( self.menuButtons ) do         
			-- Update KeyBind Strings
			local keyBindString = (button.KeyBind and BindingsUI_GetInputValue(button.KeyBind)) or ""
			if keyBindString ~= nil and keyBindString ~= "" and keyBindString ~= "None" then
				keyBindString = "[" .. string.sub(keyBindString, 1, 1) .. "]"
			else
				keyBindString = ""
			end
			
			button.KeyBindText:SetText(keyBindString)
		end
		
		if self.background:GetIsVisible() and CHUDGetOption("mingui") then
			local highlightColor = Color(1,1,0,1)
			local defaultColor = Color(1,1,1,1)
			
			self.background:SetTexture("ui/transparent.dds")
			
			if self.selectedButton == self.ejectCommButton then
				self.ejectCommButton.CommanderName:SetColor(highlightColor)
			else
				self.ejectCommButton.CommanderName:SetColor(defaultColor)
			end
			self.ejectCommButton.Background:SetTexture("ui/transparent.dds")
			
			if self.selectedButton == self.voteConcedeButton then
				self.voteConcedeButton.ConcedeText:SetColor(highlightColor)
			else
				self.voteConcedeButton.ConcedeText:SetColor(defaultColor)
			end
			self.voteConcedeButton.Background:SetTexture("ui/transparent.dds")
				
			for _, button in pairs(self.menuButtons) do
				if self.selectedButton == button then
					button.Description:SetColor(highlightColor)
				else
					button.Description:SetColor(defaultColor)
				end
				button.Background:SetTexture("ui/transparent.dds")
			end
		end
		
	end)

-- Thanks Dragon, I know you added this to your mod so I could add it mine one day
local origControlBindings = GetUpValue( BindingsUI_GetBindingsData, "globalControlBindings", { LocateRecurse = true } )
local newGlobalControlBindings = { }
for i = 1, #origControlBindings do
	table.insert(newGlobalControlBindings, origControlBindings[i])
	if origControlBindings[i] == "H" then
		table.insert(newGlobalControlBindings, "RequestWeld")
		table.insert(newGlobalControlBindings, "input")
		table.insert(newGlobalControlBindings, "REQUEST WELD")
		table.insert(newGlobalControlBindings, "None")

		table.insert(newGlobalControlBindings, "VoiceOverCovering")
		table.insert(newGlobalControlBindings, "input")
		table.insert(newGlobalControlBindings, "(MARINE) \"COVERING YOU\"")
		table.insert(newGlobalControlBindings, "None")
		
		table.insert(newGlobalControlBindings, "VoiceOverFollowMe")
		table.insert(newGlobalControlBindings, "input")
		table.insert(newGlobalControlBindings, "(MARINE) \"FOLLOW ME\"")
		table.insert(newGlobalControlBindings, "None")
		
		table.insert(newGlobalControlBindings, "VoiceOverHostiles")
		table.insert(newGlobalControlBindings, "input")
		table.insert(newGlobalControlBindings, "(MARINE) \"HOSTILES\"")
		table.insert(newGlobalControlBindings, "None")
		
		table.insert(newGlobalControlBindings, "VoiceOverAcknowledged")
		table.insert(newGlobalControlBindings, "input")
		table.insert(newGlobalControlBindings, "\"ACKNOWLEDGED\"/CHUCKLE")
		table.insert(newGlobalControlBindings, "None")
	end
end
ReplaceLocals(BindingsUI_GetBindingsData, { globalControlBindings = newGlobalControlBindings }) 

local defaults = GetUpValue( GetDefaultInputValue, "defaults", { LocateRecurse = true } )
table.insert(defaults, { "RequestWeld", "None" })
table.insert(defaults, { "VoiceOverCovering", "None" })
table.insert(defaults, { "VoiceOverFollowMe", "None" })
table.insert(defaults, { "VoiceOverHostiles", "None" })
table.insert(defaults, { "VoiceOverAcknowledged", "None" })

local kSoundData = GetUpValue( GetVoiceKeyBind, "kSoundData", { LocateRecurse = true } )
kSoundData[kVoiceId.MarineCovering]["KeyBind"] = "VoiceOverCovering"
kSoundData[kVoiceId.MarineFollowMe]["KeyBind"] = "VoiceOverFollowMe"
kSoundData[kVoiceId.MarineHostiles]["KeyBind"] = "VoiceOverHostiles"
kSoundData[kVoiceId.MarineAcknowledged]["KeyBind"] = "VoiceOverAcknowledged"
kSoundData[kVoiceId.AlienChuckle]["KeyBind"] = "VoiceOverAcknowledged"

ReplaceUpValue(GetVoiceKeyBind, "kSoundData", kSoundData, { LocateRecurse = true })

local origReqSendKeyEvent
origReqSendKeyEvent = Class_ReplaceMethod("GUIRequestMenu", "SendKeyEvent", 
	function(self, key, down)
		local consumed = origReqSendKeyEvent(self, key, down)
		if not consumed and down then
			if GetIsBinding(key, "RequestWeld") then
				Shared.ConsoleCommand("requestweld")
				consumed = true
			elseif GetIsBinding(key, "VoiceOverCovering") then
				Shared.ConsoleCommand("impulse Covering")
				consumed = true
			elseif GetIsBinding(key, "VoiceOverFollowMe") then
				Shared.ConsoleCommand("impulse FollowMe")
				consumed = true
			elseif GetIsBinding(key, "VoiceOverHostiles") then
				Shared.ConsoleCommand("impulse Hostiles")
				consumed = true
			elseif GetIsBinding(key, "VoiceOverAcknowledged") then
				Shared.ConsoleCommand("impulse Chuckle")
				consumed = true
			end
		end
		return consumed
	end
)

local impulseTypes =
{
	marineType = set{ "Marine", "JetpackMarine", "Exo" },
	alienType = set{ "Skulk", "Gorge", "Lerk", "Fade", "Onos" },
	embryoType = set { "Embryo" },
}

local impulseMap = {
	Taunt = 
	{ 
		marineType = kVoiceId.MarineTaunt,
		alienType  = kVoiceId.AlienTaunt,
		embryoType = kVoiceId.AlienTaunt,
	},
	FollowMe = 
	{
		marineType = kVoiceId.MarineFollowMe,
		alienType  = kVoiceId.AlienFollowMe,
	},
	Covering =
	{
		marineType = kVoiceId.MarineCovering,
	},
	Chuckle = 
	{
		marineType = kVoiceId.MarineAcknowledged,
		alienType  = kVoiceId.AlienChuckle,
		embryoType = kVoiceId.EmbryoChuckle,
	},
	Hostiles =
	{
		marineType = kVoiceId.MarineHostiles,
	},
	LetsMove =
	{
		marineType = kVoiceId.MarineLetsMove,
	},
}

local function PrintOnCommandImpulseHelp()
	local keys = {}
	for k,v in pairs( impulseMap ) do
		keys[#keys+1] = k
	end
	Shared.Message( "Usage: \"impulse arg1 [arg2 [...]]\"\n"..
					"\tArguments may be one or more of: [ \""..table.concat( keys , "\", \"" ).."\" ]\n"..
					"\tIf more than one of the provided arguments is available to the player's class, it will randomly select between them." )
end

local SendRequest = GetUpValue( GUIRequestMenu.SendKeyEvent, "SendRequest", { LocateRecurse = true } )
local function OnCommandImpulse( ... )
	local args = {...}
	if #args == 0 then
		PrintOnCommandImpulseHelp()
		return
	end
		
	local request = {}
	local impulseType = ""
	
	local playerClass = Client.GetIsControllingPlayer() and PlayerUI_GetPlayerClassName() or "Spectator"
	for k,v in pairs(impulseTypes) do
		if v[playerClass] then
			impulseType = k
			break
		end
	end
	
	for i,v in ipairs( args ) do
		if not impulseMap[v] then
			Shared.Message( "Invalid argument: \""..v.."\"" )
			PrintOnCommandImpulseHelp()
			return
		end
		if impulseMap[v][impulseType] then
			request[ #request + 1 ] = impulseMap[v][impulseType]
		end
	end
	
	if #request > 0 then
		SendRequest(nil, request[math.random(#request)] )
	end
end

Event.Hook("Console_impulse", OnCommandImpulse)
