local originalGUIRequestUpdate
originalGUIRequestUpdate = Class_ReplaceMethod( "GUIRequestMenu", "Update",
	function(self, deltaTime)
		originalGUIRequestUpdate(self, deltaTime)
			
		local mouseX, mouseY = Client.GetCursorPosScreen()
		
		if CHUDGetOption("mingui") then
			local highlightColor = Color(1,1,0,1)
			local defaultColor = Color(1,1,1,1)
			
			self.background:SetTexture("ui/transparent.dds")
			
			if GUIItemContainsPoint(self.ejectCommButton.Background, mouseX, mouseY) then
				self.ejectCommButton.CommanderName:SetColor(highlightColor)
			else
				self.ejectCommButton.CommanderName:SetColor(defaultColor)
			end
			self.ejectCommButton.Background:SetTexture("ui/transparent.dds")
			
			if GUIItemContainsPoint(self.voteConcedeButton.Background, mouseX, mouseY) then
				self.voteConcedeButton.ConcedeText:SetColor(highlightColor)
			else
				self.voteConcedeButton.ConcedeText:SetColor(defaultColor)
			end
			self.voteConcedeButton.Background:SetTexture("ui/transparent.dds")
				
			for _, button in pairs(self.menuButtons) do		
				if GUIItemContainsPoint(button.Background, mouseX, mouseY) then
					button.Description:SetColor(highlightColor)
				else
					button.Description:SetColor(defaultColor)
				end
				button.Background:SetTexture("ui/transparent.dds")
			end
		end
		
	end)



function set( table )
	local ret = {}
	for i,v in ipairs( table ) do
		ret[v] = true
	end
	return ret
end

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
