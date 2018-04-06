-- As seen here: http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function CHUDCopyTable(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[CHUDCopyTable(k, s)] = CHUDCopyTable(v, s) end
	return res
end

function CHUDWrapTextIntoTable( str, limit, indent, indent1 )

	limit = limit or 72
	indent = indent or ""
	indent1 = indent1 or indent
	
	local here = 1 - #indent1
	str = indent1..str:gsub( "(%s+)()(%S+)()",
		function( sp, st, word, fi )
			if fi-here > limit then
				here = st - #indent
				--Print(indent..word)
				return "\n"..indent..word
			end
		end )
	
	return StringSplit(str, "\n")
end

if Server then
	function SendCHUDMessage(message)
		
		if message then
		
			local messageList = CHUDWrapTextIntoTable(message, kMaxChatLength)
			
			for m = 1, #messageList do
				Server.SendNetworkMessage("Chat", BuildChatMessage(false, "[NS2+]", -1, kTeamReadyRoom, kNeutralTeamType, messageList[m]), true)
				Shared.Message("Chat All - [NS2+]: " .. messageList[m])
				Server.AddChatToHistory(messageList[m], "[NS2+]", 0, kTeamReadyRoom, false)
			end
		
		end
		
	end

	function CHUDServerAdminPrint(client, message)
		local kMaxPrintLength = 128
		
		if client then
		
			-- First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
			local messageList = CHUDWrapTextIntoTable(message, kMaxPrintLength)
			
			for m = 1, #messageList do
				Server.SendNetworkMessage(client:GetControllingPlayer(), "ServerAdminPrint", { message = messageList[m] }, true)
			end
			
		end
		
	end
	
	function GetCHUDTagBitmask()
		
		local tags = { }
		Server.GetTags(tags)
			
		for t = 1, #tags do
			local _, pos = string.find(tags[t], "CHUD_0x")
			if pos then
				return(tonumber(string.sub(tags[t], pos+1)))
			end
		end
		
	end
	
	function SetCHUDTagBitmask(bitmask)
		
		local tags = { }
		Server.GetTags(tags)
		
		for t = 1, #tags do
			if string.find(tags[t], "CHUD_0x") then
				Server.RemoveTag(tags[t])
			end
		end
		
		Server.AddTag("CHUD_0x" .. bitmask)
		
	end
	
	function AddCHUDTagBitmask(mask)
		local bitmask = GetCHUDTagBitmask() or 0
		bitmask = bit.bor(bitmask, mask)
		SetCHUDTagBitmask(bitmask)
	end
	
	function SubstractCHUDTagBitmask(mask)
		local bitmask = GetCHUDTagBitmask() or 0
		bitmask = bit.band(bitmask, bit.bnot(mask))
		SetCHUDTagBitmask(bitmask)
	end
	
end

function CheckCHUDTagOption(bitmask, option)
	return(bit.band(bitmask, option) > 0)
end

if Client then
	function CHUDGetGameTimeString()

		local gameTime, state = PlayerUI_GetGameLengthTime()
		if state < kGameState.PreGame then
			gameTime = 0
		end

		local minutes = math.floor(gameTime / 60)
		local seconds = math.floor(gameTime % 60)

		return(string.format("%d:%.2d", minutes, seconds))

	end

	function CHUDGetRealTimeString()
		local time = os.time()
		return os.date("%X", time)
	end
end

function CHUDFormatDateTimeString(dateTime)
	local tmpDate = os.date("*t", dateTime)
	local ordinal = "th"
	
	local lastDig = tmpDate.day % 10
	if (tmpDate.day < 11 or tmpDate.day > 13) and lastDig > 0 and lastDig < 4 then
		if lastDig == 1 then
			ordinal = "st"
		elseif lastDig == 2 then
			ordinal = "nd"
		else
			ordinal = "rd"
		end
	end
	
	return string.format("%s%s, %d @ %d:%02d", os.date("%A, %B %d", dateTime), ordinal, tmpDate.year, tmpDate.hour, tmpDate.min)
end

function CHUDGetWeaponAmmoString(weapon)
	local ammo = ""
	if weapon and weapon:isa("Weapon") then
		if weapon:isa("ClipWeapon") then
			ammo = string.format("%d", weapon:GetClip() or 0)
		elseif weapon:isa("GrenadeThrower") then
			ammo = string.format("%d", weapon.grenadesLeft or 0)
		elseif weapon:isa("LayMines") then
			ammo = string.format("%d", weapon:GetMinesLeft() or 0)
		elseif weapon:isa("ExoWeaponHolder") then
			local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
			local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)
			local leftAmmo = -1
			local rightAmmo = -1
			if rightWeapon:isa("Railgun") then
				rightAmmo = rightWeapon:GetChargeAmount() * 100
				if leftWeapon:isa("Railgun") then
					leftAmmo = leftWeapon:GetChargeAmount() * 100
				end
			elseif rightWeapon:isa("Minigun") then
				rightAmmo = rightWeapon.heatAmount * 100
				if leftWeapon:isa("Minigun") then
					leftAmmo = leftWeapon.heatAmount * 100
				end
			end
			if leftAmmo > -1 and rightAmmo > -1 then
				ammo = string.format("%d%% / %d%%", leftAmmo, rightAmmo)
			elseif rightAmmo > -1 then
				ammo = string.format("%d%%", rightAmmo)
			end
		elseif weapon:isa("Builder") or weapon:isa("Welder") and PlayerUI_GetUnitStatusPercentage() > 0 then
			ammo = string.format("%d%%", PlayerUI_GetUnitStatusPercentage())
		end
	end
	
	return ammo
end

function CHUDGetWeaponAmmoFraction(weapon)
	local fraction = -1
	if weapon and weapon:isa("Weapon") then
		if weapon:isa("ClipWeapon") then
			fraction = weapon:GetClip()/weapon:GetClipSize()
		elseif weapon:isa("GrenadeThrower") then
			fraction = weapon.grenadesLeft/kMaxHandGrenades
		elseif weapon:isa("LayMines") then
			fraction = weapon:GetMinesLeft()/kNumMines
		elseif weapon:isa("ExoWeaponHolder") then
			local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
			local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)

			if rightWeapon:isa("Railgun") then
				fraction = rightWeapon:GetChargeAmount()
				if leftWeapon:isa("Railgun") then
					fraction = (fraction + leftWeapon:GetChargeAmount()) / 2.0
				end
			elseif rightWeapon:isa("Minigun") then
				fraction = rightWeapon.heatAmount
				if leftWeapon:isa("Minigun") then
					fraction = (fraction + leftWeapon.heatAmount) / 2.0
				end
				fraction = 1 - fraction
			end
		elseif weapon:isa("Builder") or weapon:isa("Welder") then
			fraction = PlayerUI_GetUnitStatusPercentage()/100
		end
	end
	
	return fraction
end

function CHUDGetWeaponReserveAmmoString(weapon)
	local ammo = ""
	if weapon and weapon:isa("Weapon") then
		if weapon:isa("ClipWeapon") then
			ammo = string.format("%d", weapon:GetAmmo() or 0)
		end
	end
	
	return ammo
end

function CHUDGetWeaponReserveAmmoFraction(weapon)
	local fraction = -1
	if weapon and weapon:isa("Weapon") then
		if weapon:isa("ClipWeapon") then
			fraction = weapon:GetAmmo()/weapon:GetMaxAmmo()
		end
	end
	
	return fraction
end

if Client then
	function CHUDEvaluateGUIVis()
		local player = Client.GetLocalPlayer()
		
		if not player then return end
		
		local teamNumber = player:GetTeamNumber()
		local drawviewmodel = CHUDGetOption("drawviewmodel")
		local drawviewmodel_a = CHUDGetOption("drawviewmodel_a")
		-- Cannot use the gCHUDHiddenViewModel global as it changes in the frame after this is run
		local isViewModelHidden = drawviewmodel == 1 or
			drawviewmodel == 2 and
			(
				player:isa("Marine") and not CHUDGetOption("drawviewmodel_m") or
				player:isa("Exo") and not CHUDGetOption("drawviewmodel_exo") or
				player:isa("Alien") and drawviewmodel_a ~= 0 and
				(
					drawviewmodel_a == 1 or
					player:isa("Skulk") and not CHUDGetOption("drawviewmodel_skulk") or
					player:isa("Gorge") and not CHUDGetOption("drawviewmodel_gorge") or
					player:isa("Lerk") and not CHUDGetOption("drawviewmodel_lerk") or
					player:isa("Fade") and not CHUDGetOption("drawviewmodel_fade") or
					player:isa("Onos") and not CHUDGetOption("drawviewmodel_onos")
				)
			)

		local classicammo = false
		local customhud = false
		local hiddenviewmodel = false
		
		local classicammoScript = "NS2Plus/Client/CHUDGUI_ClassicAmmo"
		local hudbarsScript = "NS2Plus/Client/CHUDGUI_HUDBars"
		local hiddenviewmodelScript = "NS2Plus/Client/CHUDGUI_HiddenViewmodel"
		if not player:isa("Commander") then
			if teamNumber == kTeam1Index then
				if CHUDGetOption("classicammo") then
					GetGUIManager():CreateGUIScriptSingle(classicammoScript)
					classicammo = true
				end
				
				if CHUDGetOption("hudbars_m") > 0 then
					GetGUIManager():CreateGUIScriptSingle(hudbarsScript)
					customhud = true
				end
				
				if player:isa("Exo") then
					if isViewModelHidden then
						hiddenviewmodel = true
					end
				end
			elseif teamNumber == kTeam2Index then
				if CHUDGetOption("hudbars_a") > 0 then
					GetGUIManager():CreateGUIScriptSingle(hudbarsScript)
					customhud = true
				end
				
				if isViewModelHidden then
					hiddenviewmodel = true
				end
			end
		end

		if GetGUIManager():GetGUIScriptSingle(classicammoScript) and not classicammo then
			GetGUIManager():DestroyGUIScriptSingle(classicammoScript)
		end
		if GetGUIManager():GetGUIScriptSingle(hudbarsScript) and not customhud then
			GetGUIManager():DestroyGUIScriptSingle(hudbarsScript)
		end
		if GetGUIManager():GetGUIScriptSingle(hiddenviewmodelScript) then
			GetGUIManager():DestroyGUIScriptSingle(hiddenviewmodelScript)
		end
		if hiddenviewmodel then
			GetGUIManager():CreateGUIScriptSingle(hiddenviewmodelScript)
		end
	end
	
	function CHUDApplyTeamSpecificStuff()
		local player = Client.GetLocalPlayer()
		local teamNumber = player:GetTeamNumber()
		local isMarine = teamNumber == kTeam1Index
		
		local sensitivity = ConditionalValue(isMarine, CHUDGetOption("sensitivity_m"), CHUDGetOption("sensitivity_a"))
		local fov = ConditionalValue(isMarine, CHUDGetOption("fov_m"), CHUDGetOption("fov_a"))
		
		local sensitivity_perteam = CHUDGetOption("sensitivity_perteam")
		local fov_perteam = CHUDGetOption("fov_perteam")
		
		-- Aliens with per-lifeform sens will have it set separately.
		if CHUDGetOption("sensitivity_perteam") and
			(isMarine or not CHUDGetOption("sensitivity_perlifeform")) then

			OptionsDialogUI_SetMouseSensitivity(sensitivity)
		end
		
		if CHUDGetOption("fov_perteam") then
			Client.SetOptionFloat("graphics/display/fov-adjustment", fov)
		end
	end

	function CHUDApplyLifeformSpecificStuff()
		local player = Client.GetLocalPlayer()
		local eggTechId = player:isa("Embryo") and player:GetGestationTechId()
		local sensitivity_perlifeform = CHUDGetOption("sensitivity_perteam") and CHUDGetOption("sensitivity_perlifeform")
		local sensitivity

		if player:isa("Skulk") or eggTechId == kTechId.Skulk then
			sensitivity = CHUDGetOption("sensitivity_skulk")
		elseif player:isa("Gorge") or eggTechId == kTechId.Gorge then
			sensitivity = CHUDGetOption("sensitivity_gorge")
		elseif player:isa("Lerk") or eggTechId == kTechId.Lerk then
			sensitivity = CHUDGetOption("sensitivity_lerk")
		elseif player:isa("Fade") or eggTechId == kTechId.Fade then
			sensitivity = CHUDGetOption("sensitivity_fade")
		elseif player:isa("Onos") or eggTechId == kTechId.Onos then
			sensitivity = CHUDGetOption("sensitivity_onos")
		end

		if sensitivity_perlifeform and sensitivity then
			OptionsDialogUI_SetMouseSensitivity(sensitivity)
		end
	end
	
	local kScreenScaleAspect = 1280

	local function ScreenSmallAspect()
		return ConditionalValue(Client.GetScreenWidth() > Client.GetScreenHeight(), Client.GetScreenHeight(), Client.GetScreenWidth())
	end

	function GUILinearScale(size)
		-- 25% bigger so it's similar size to the "normal" GUIScale
		local scale = 1.25
		-- Text is hard to read on lower res, so make it bigger for them
		if Client.GetScreenWidth() < 1920 then
			scale = 1.5
		end
		return (ScreenSmallAspect() / kScreenScaleAspect)*size*scale
	end
	
	function ColorToColorInt(color)
		return math.floor(bit.lshift(color.r*255, 16) + bit.lshift(color.g*255, 8) + color.b*255)
	end
end

-- Todo: Add this to vanilla DebugUltility.lua and Class.lua
function Class_AddMethod( className, methodName, method )
	assert( _G[className][methodName] == nil or _G[className][methodName] == method, "Attempting to add new method when class already has one -- use Class_ReplaceMethod instead" )

	_G[className][methodName] = method

	local derived = Script.GetDerivedClasses(className)
	if derived == nil then return end

	for _, d in ipairs(derived) do
		Class_AddMethod(d, methodName, method )
	end
end