local _renderMask       = 0x80
local _invRenderMask    = bit.bnot(_renderMask)
local _maxDistance      = 30
local _maxDistance_Commander = 60
local _enabled          = true

function HiveVisionExtra_Initialize()
	HiveVisionExtra_camera = Client.CreateRenderCamera()
	HiveVisionExtra_camera:SetTargetTexture("*hive_vision_extra", true)
	HiveVisionExtra_camera:SetRenderMask( _renderMask )
	HiveVisionExtra_camera:SetIsVisible( false )
	HiveVisionExtra_camera:SetCullingMode( RenderCamera.CullingMode_Frustum )
	HiveVisionExtra_camera:SetRenderSetup( "shaders/Mask.render_setup" )

	HiveVisionExtra_screenEffect = Client.CreateScreenEffect("shaders/HiveVisionExtra.screenfx")
	HiveVisionExtra_screenEffect:SetActive(false)    
end

function HiveVisionExtra_Shutdown()
	Client.DestroyRenderCamera(HiveVisionExtra_camera)
	HiveVisionExtra_camera = nil

	Client.DestroyScreenEffect(HiveVisionExtra_screenEffect)
	HiveVisionExtra_screenEffect = nil
end

-- Enables or disabls the hive vision effect. When the effect is not needed it should
-- be disabled to boost performance.
function HiveVisionExtra_SetEnabled(enabled)
	HiveVisionExtra_camera:SetIsVisible(enabled and _enabled)
	HiveVisionExtra_screenEffect:SetActive(enabled and _enabled) 
end

-- Must be called prior to rendering
function HiveVisionExtra_SyncCamera(camera, forCommander)
	local distance = ConditionalValue(forCommander, _maxDistance_Commander, _maxDistance)

	HiveVisionExtra_camera:SetCoords( camera:GetCoords() )
	HiveVisionExtra_camera:SetFov( camera:GetFov() )
	HiveVisionExtra_camera:SetFarPlane( distance + 1 )
	HiveVisionExtra_screenEffect:SetParameter("time", Shared.GetTime())
	HiveVisionExtra_screenEffect:SetParameter("maxDistance", distance)
end

-- Adds a model to the hive vision
function HiveVisionExtra_AddModel(model)

	local renderMask = model:GetRenderMask()
	model:SetRenderMask( bit.bor(renderMask, _renderMask) )

end

-- Removes a model from the hive vision
function HiveVisionExtra_RemoveModel(model)

	local renderMask = model:GetRenderMask()
	model:SetRenderMask( bit.band(renderMask, _invRenderMask) )

end

function InitCHUDOutlines()
	HiveVisionExtra_Initialize()
end

function UpdateCHUDOutlines()
	local player = Client.GetLocalPlayer()
	-- If we have a player, use them to setup the camera.
	if player ~= nil then
		local outlinePlayers = Client.GetOutlinePlayers() and Client.GetLocalClientTeamNumber() == kSpectatorIndex

		HiveVisionExtra_SetEnabled( GetIsAlienUnit(player) or outlinePlayers )
		HiveVisionExtra_SyncCamera( gRenderCamera, player:isa("Commander") or outlinePlayers )
	else
		HiveVisionExtra_SetEnabled( false )
	end
end

local function GetMaxDistanceFor(player)
	if player:isa("AlienCommander") then
		return 63
	end
	return 33
end

local oldHVUpdate = HiveVisionMixin.OnUpdate
function HiveVisionMixin:OnUpdate(deltaTime)
	oldHVUpdate(self, deltaTime)
	
	local player = Client.GetLocalPlayer()
	if player:isa("Alien") or player:isa("AlienSpectator") then
		local model = self:GetRenderModel()
		if self.timeHiveVisionChanged == Shared.GetTime() then
			if model ~= nil then
				-- This basically duplicates the outlines for players
				-- Achieves seeing marines through buildings but not the other way around
				-- Which is what we actually want to do
				if self.hiveSightVisible then
					-- "male" is found both in male and female! Woo!
					if string.find(self:GetModelName(), "male") or string.find(self:GetModelName(), "exo") then
						HiveVisionExtra_AddModel(model)
					end
				else
					if string.find(self:GetModelName(), "male") or string.find(self:GetModelName(), "exo") then
						HiveVisionExtra_RemoveModel(model)
					end
				end
			end
		end
	end
end

local oldHVDestroy = HiveVisionMixin.OnDestroy
function HiveVisionMixin:OnDestroy()

	oldHVDestroy(self)
	if self.hiveSightVisible then
		local model = self:GetRenderModel()
		if model ~= nil then
			HiveVisionExtra_RemoveModel(model)
		end
	end
	
end

Event.Hook("LoadComplete", InitCHUDOutlines)
Event.Hook("UpdateRender", UpdateCHUDOutlines)
