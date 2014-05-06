local originalGUIRequestUpdate
originalGUIRequestUpdate = Class_ReplaceMethod( "GUIRequestMenu", "Update",
	function(self, deltaTime)
		originalGUIRequestUpdate(self, deltaTime)
			
		local mouseX, mouseY = Client.GetCursorPosScreen()
		
		if CHUDGetOption("mingui") then
			local highlightColor = Color(1,1,0,1)
			local defaultColor = Color(1,1,1,1)
			
			self.background:SetTexture("ui/blank.dds")
			
			if GUIItemContainsPoint(self.ejectCommButton.Background, mouseX, mouseY) then
				self.ejectCommButton.CommanderName:SetColor(highlightColor)
			else
				self.ejectCommButton.CommanderName:SetColor(defaultColor)
			end
			self.ejectCommButton.Background:SetTexture("ui/blank.dds")
			
			if GUIItemContainsPoint(self.voteConcedeButton.Background, mouseX, mouseY) then
				self.voteConcedeButton.ConcedeText:SetColor(highlightColor)
			else
				self.voteConcedeButton.ConcedeText:SetColor(defaultColor)
			end
			self.voteConcedeButton.Background:SetTexture("ui/blank.dds")
				
			for _, button in pairs(self.menuButtons) do		
				if GUIItemContainsPoint(button.Background, mouseX, mouseY) then
					button.Description:SetColor(highlightColor)
				else
					button.Description:SetColor(defaultColor)
				end
				button.Background:SetTexture("ui/blank.dds")
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


local SendRequest = GetUpValue( GUIRequestMenu.SendKeyEvent, "SendRequest", { LocateRecurse = true } )
local function OnCommandImpulse( ... )
	local request = {}
	local impulseType = ""
	
	local playerClass = Client.GetIsControllingPlayer() and PlayerUI_GetPlayerClassName() or "Spectator"
	for k,v in pairs(impulseTypes) do
		if v[playerClass] then
			impulseType = k
			break
		end
	end

	for i,v in ipairs( { ... } ) do	
		if impulseMap[v] and impulseMap[v][impulseType] then
			request[ #request + 1 ] = impulseMap[v][impulseType]
			Shared.Message( "Found voice over for "..v);
		end
	end
	
	if #request > 0 then		
		SendRequest(nil, request[math.random(#request)] )
	end
end
    
Event.Hook("Console_impulse", OnCommandImpulse)
