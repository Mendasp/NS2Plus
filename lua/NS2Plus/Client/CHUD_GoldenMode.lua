local isPlaying = false
local globeModel, originalSKE, lastDown

local function GoldenMode()
	if trollModes["goldenMode"] then
	
		if not globeModel then
			globeModel = Client.CreateRenderModel(RenderScene.Zone_Default)
			globeModel:SetModel(PrecacheAsset("models/props/refinery/refinery_shipping_hologram.model"))
			globeModel:SetIsVisible(false)
		end
		
		local player = Client.GetLocalPlayer()
		if player ~= nil then
			local origin = player:GetEyePos()
			local coords = globeModel:GetCoords()
			coords.origin = origin + player:GetViewAngles():GetCoords().zAxis
			globeModel:SetCoords(coords)
		end
		
	end
	
	if globeModel then
		globeModel:SetIsVisible(trollModes["goldenMode"])
	end
end

local function ToggleGolden()
	trollModes["goldenMode"] = not trollModes["goldenMode"]
	
	Shared.Message("Golden mode: " .. ConditionalValue(trollModes["goldenMode"], "ENGAGED!", "Disabled :("))
end

Event.Hook("UpdateRender", GoldenMode)
Event.Hook("Console_mynameisgolden", ToggleGolden)
Event.Hook("Console_goldenmode", ToggleGolden)
Event.Hook("Console_iamgolden", ToggleGolden)