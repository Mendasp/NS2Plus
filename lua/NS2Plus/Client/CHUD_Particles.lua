local propCache = { }
local propValuesCache = { }
local propsRemoved = false
local cinematicsCache = { }
local cinematicsValuesCache = { }
local cinematicsRemoved = false
local ambientsValuesCache = { }
local ambientsRemoved = false

local blockedProps = set {
						"models/props/biodome/biodome_grass_01_01.model",
						"models/props/biodome/biodome_grass_01_02.model",
						"models/props/biodome/biodome_grass_01_03.model",
						"models/props/biodome/biodome_grass_01_04.model",
						"models/props/biodome/biodome_grass_02_tile.model",
						"models/props/biodome/biodome_waterfall_01.model",
						"models/props/descent/descent_hologram_planet_01.model",
						"models/props/descent/descent_hologram_planet_02.model",
						"models/props/descent/descent_hologram_planet_03.model",
						"models/props/descent/descent_hologram_spacestation_01.model",
						"models/props/refinery/refinery_shipping_hologram_animated.model",
						"models/props/veil/veil_hologram_01.model",
						"models/props/veil/veil_hologram_01_scanlines.model",
						"models/props/veil/veil_holosign_01_nanogrid.model",
					}

blockedProps["ns2_biodome"] = set {
						"models/marine/dropship/dropship.model",
						"models/props/biodome/biobome_outdoor_rock_01.model",
						"models/props/biodome/biobome_outdoor_rock_02.model",
						"models/props/biodome/biobome_outdoor_rock_03.model",
						"models/props/biodome/biobome_outdoor_rock_04.model",
						"models/props/biodome/biodome_bamboo_01_01_high.model",
						"models/props/biodome/biodome_bamboo_01_01_low.model",
						"models/props/biodome/biodome_bamboo_01_02_high.model",
						"models/props/biodome/biodome_bamboo_01_02_low.model",
						"models/props/biodome/biodome_bamboo_01_03_high.model",
						"models/props/biodome/biodome_bamboo_01_03_low.model",
						"models/props/biodome/biodome_bamboo_01_04_high.model",
						"models/props/biodome/biodome_bamboo_01_04_low.model",
						"models/props/biodome/biodome_bamboo_01_05_high.model",
						"models/props/biodome/biodome_bamboo_01_05_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_01_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_01_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_02_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_02_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_03_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_03_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_04_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_04_low.model",
						"models/props/biodome/biodome_bamboo_clump_01_05_high.model",
						"models/props/biodome/biodome_bamboo_clump_01_05_low.model",
						"models/props/biodome/biodome_bamboo_crown_01_01.model",
						"models/props/biodome/biodome_bamboo_crown_01_02.model",
						"models/props/biodome/biodome_bamboo_crown_01_03.model",
						"models/props/biodome/biodome_bamboo_crown_01_04.model",
						"models/props/biodome/biodome_carousel_plants_01.model",
						"models/props/biodome/biodome_carousel_plants_02.model",
						"models/props/biodome/biodome_carousel_plants_03.model",
						"models/props/biodome/biodome_carousel_plants_04.model",
						"models/props/biodome/biodome_container_tree_01.model",
						"models/props/biodome/biodome_container_tree_02.model",
						"models/props/biodome/biodome_container_tree_03.model",
						"models/props/biodome/biodome_container_tree_04.model",
						"models/props/biodome/biodome_flower_01_high.model",
						"models/props/biodome/biodome_flower_02_low.model",
						"models/props/biodome/biodome_flower_03_low.model",
						"models/props/biodome/biodome_fruit_pods_01.model",
						"models/props/biodome/biodome_fruit_pods_02.model",
						"models/props/biodome/biodome_fruit_pods_03.model",
						"models/props/biodome/biodome_fruit_pods_04.model",
						"models/props/biodome/biodome_fruit_pods_grapes_01.model",
						"models/props/biodome/biodome_fruit_pods_grapes_02.model",
						"models/props/biodome/biodome_fruit_pods_melone.model",
						"models/props/biodome/biodome_fruit_pods_tomato_01.model",
						"models/props/biodome/biodome_fruit_pods_tomato_02.model",
						"models/props/biodome/biodome_fruit_pods_tomato_03.model",
						"models/props/biodome/biodome_outdoor_rock_boulder_01.model",
						"models/props/biodome/biodome_outdoor_rock_boulder_02.model",
						"models/props/biodome/biodome_outdoor_rock_pile_01.model",
						"models/props/biodome/biodome_outdoor_rock_pile_02.model",
						"models/props/biodome/biodome_outdoor_rock_pile_03.model",
						"models/props/biodome/biodome_outdoor_rock_smallpile_01.model",
						"models/props/biodome/biodome_outdoor_rock_smallpile_02.model",
						"models/props/biodome/biodome_outdoor_rock_smallpile_03.model",
						"models/props/biodome/biodome_outdoor_rock_smallpile_04.model",
						"models/props/biodome/biodome_outdoor_sandbank_01.model",
						"models/props/biodome/biodome_outdoor_sandbank_02.model",
						"models/props/biodome/biodome_outdoor_sandbank_03.model",
						"models/props/biodome/biodome_outdoor_sandbank_04.model",
						"models/props/biodome/biodome_outdoor_sandbank_05.model",
						"models/props/biodome/biodome_outdoor_terrain.model",
						"models/props/biodome/biodome_outdoor_terrain_wet.model",
						"models/props/biodome/biodome_plant_01_high.model",
						"models/props/biodome/biodome_plant_01_low.model",
						"models/props/biodome/biodome_plant_02_high.model",
						"models/props/biodome/biodome_plant_02_low.model",
						"models/props/biodome/biodome_plant_03_01_high.model",
						"models/props/biodome/biodome_plant_03_02_high.model",
						"models/props/biodome/biodome_plant_03_03_high.model",
						"models/props/biodome/biodome_plant_04_01_high.model",
						"models/props/biodome/biodome_plant_04_01_low.model",
						"models/props/biodome/biodome_plant_04_01_red_high.model",
						"models/props/biodome/biodome_plant_04_01_red_low.model",
						"models/props/biodome/biodome_plant_04_02_high.model",
						"models/props/biodome/biodome_plant_04_02_low.model",
						"models/props/biodome/biodome_plant_04_02_red_high.model",
						"models/props/biodome/biodome_plant_04_02_red_low.model",
						"models/props/biodome/biodome_plant_05_01_high.model",
						"models/props/biodome/biodome_plant_05_01_low.model",
						"models/props/biodome/biodome_plant_05_02_high.model",
						"models/props/biodome/biodome_plant_05_02_low.model",
						"models/props/biodome/biodome_plant_05_03_low.model",
						"models/props/biodome/biodome_plant_06_01_high.model",
						"models/props/biodome/biodome_plant_06_02_high.model",
						"models/props/biodome/biodome_plant_06_03_high.model",
						"models/props/biodome/biodome_plant_07_high.model",
						"models/props/biodome/biodome_plant_07_low.model",
						"models/props/biodome/biodome_robot_arm.model",
						"models/props/biodome/biodome_special_plant_01.model",
						"models/props/biodome/biodome_tray_b_01.model",
						"models/props/biodome/biodome_tray_b_02.model",
						"models/props/biodome/biodome_tray_b_03.model",
						"models/props/biodome/biodome_tree_01_high.model",
						"models/props/biodome/biodome_tree_01_low.model",
						"models/props/biodome/biodome_tree_02_high.model",
						"models/props/biodome/biodome_tree_02_low.model",
						"models/props/biodome/biodome_tree_03.model",
						"models/props/descent/descent_satellitearray_dish.model",
						"models/props/docking/docking_landingshield_brace.model",
						"models/props/docking/docking_plants_01_plant1.model",
						"models/props/refinery/mining_light_04.model",
						"models/props/refinery/refinery_rockhard_09.model",
						"models/props/refinery/refinery_rock_bot_str_256.model",
						"models/props/refinery/refinery_rock_large_01.model",
						"models/props/refinery/refinery_rock_ledge_01.model",
						"models/props/refinery/refinery_rock_ledge_02.model",
						"models/props/refinery/refinery_rock_mid_str_128.model",
						"models/props/refinery/refinery_rock_pile_03.model",
						"models/props/refinery/refinery_skytowers_landingpad.model",
}

local blockedCinematics = set {
							"cinematics/alien/commander_arrow.cinematic",
							"cinematics/alien/cyst/enzymecloud_splash.cinematic",
							"cinematics/alien/death_1p_alien.cinematic",
							"cinematics/alien/fade/blink_view.cinematic",
							"cinematics/alien/fade/shadowstep.cinematic",
							"cinematics/alien/fade/shadowstep_silent.cinematic",
							"cinematics/alien/fade/trail_dark_1.cinematic",
							"cinematics/alien/fade/trail_dark_2.cinematic",
							"cinematics/alien/fade/trail_light_1.cinematic",
							"cinematics/alien/fade/trail_light_2.cinematic",
							"cinematics/alien/tunnel/entrance_use_1p.cinematic",
							"cinematics/death_1p.cinematic",
							"cinematics/marine/commander_arrow.cinematic",
							"cinematics/marine/exo/hurt_severe_view.cinematic",
							"cinematics/marine/exo/hurt_view.cinematic",
							"cinematics/marine/flamethrower/burning_surface.cinematic",
							"cinematics/marine/flamethrower/burning_vertical_surface.cinematic",
							"cinematics/marine/flamethrower/burn_big.cinematic",
							"cinematics/marine/flamethrower/burn_huge.cinematic",
							"cinematics/marine/flamethrower/burn_med.cinematic",
							"cinematics/marine/flamethrower/burn_small.cinematic",
							"cinematics/marine/flamethrower/burn_small_continuous.cinematic",
							"cinematics/marine/flamethrower/burn_tiny.cinematic",
							"cinematics/marine/flamethrower/canister_explosion.cinematic",
							"cinematics/marine/flamethrower/flame.cinematic",
							"cinematics/marine/flamethrower/flameout.cinematic",
							"cinematics/marine/flamethrower/flame_1p.cinematic",
							"cinematics/marine/flamethrower/flame_impact3.cinematic",
							"cinematics/marine/flamethrower/flame_residue_1p_part1.cinematic",
							"cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic",
							"cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic",
							"cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic",
							"cinematics/marine/flamethrower/flame_trail_1p_part3.cinematic",
							"cinematics/marine/flamethrower/flame_trail_full.cinematic",
							"cinematics/marine/flamethrower/flame_trail_half.cinematic",
							"cinematics/marine/flamethrower/flame_trail_light.cinematic",
							"cinematics/marine/flamethrower/flame_trail_part2.cinematic",
							"cinematics/marine/flamethrower/flame_trail_part3.cinematic",
							"cinematics/marine/flamethrower/flame_trail_short.cinematic",
							"cinematics/marine/flamethrower/impact.cinematic",
							"cinematics/marine/flamethrower/pilot.cinematic",
							"cinematics/marine/flamethrower/scorched.cinematic",
							"cinematics/marine/ghoststructure_destroy.cinematic",
							"cinematics/marine/heavy/land.cinematic",
							"cinematics/marine/infantryportal/death.cinematic",
							"cinematics/marine/jetpack/impact.cinematic",
							"cinematics/marine/jetpack/trail_2.cinematic",
							"cinematics/marine/jetpack/trail_2.cinematic",
							"cinematics/marine/jetpack/trail_2.cinematic",
							"cinematics/marine/jetpack/trail_3.cinematic",
							"cinematics/marine/minigun/mm_left_shell.cinematic",
							"cinematics/marine/minigun/mm_shell.cinematic",
							"cinematics/marine/minigun/mm_left_shell.cinematic",
							"cinematics/marine/minigun/overheat.cinematic",
							"cinematics/marine/sentry/death.cinematic",
							"cinematics/marine/structures/death_large.cinematic",
							"cinematics/marine/structures/death_small.cinematic",
						}

local replacedCinematics = set {
							"cinematics/alien/cyst/enzymecloud_large.cinematic",
							"cinematics/alien/fade/blink_in_silent.cinematic",
							"cinematics/alien/fade/blink_out_silent.cinematic",
							"cinematics/alien/mucousmembrane.cinematic",
							"cinematics/alien/nutrientmist.cinematic",
							"cinematics/alien/nutrientmist_hive.cinematic",
							"cinematics/alien/nutrientmist_onos.cinematic",
							"cinematics/alien/nutrientmist_structure.cinematic",
							"cinematics/alien/tracer_residue.cinematic",
							"cinematics/common/resnode.cinematic",
							"cinematics/marine/infantryportal/spin.cinematic",
							"cinematics/marine/minigun/muzzle_flash.cinematic",
							"cinematics/marine/minigun/muzzle_flash_left.cinematic",
							"cinematics/marine/rifle/muzzle_flash.cinematic",
							"cinematics/marine/rifle/muzzle_flash2.cinematic",
							"cinematics/marine/rifle/muzzle_flash3.cinematic",
							"cinematics/marine/spawn_item.cinematic",
							"cinematics/marine/structures/hurt.cinematic",
							"cinematics/marine/structures/hurt_severe.cinematic",
							"cinematics/marine/structures/hurt_small.cinematic",
							"cinematics/marine/structures/hurt_small_severe.cinematic",
							"cinematics/materials/metal/ricochet.cinematic",
							"cinematics/materials/metal/ricochetHeavy.cinematic",
							"cinematics/materials/rock/ricochet.cinematic",
							"cinematics/materials/rock/ricochetHeavy.cinematic",
							"cinematics/materials/thin_metal/ricochet.cinematic",
							"cinematics/materials/thin_metal/ricochetHeavy.cinematic",
						}

local mapCinematicNames = set {
						"cinematics/environment/biodome/flying_papers.cinematic",
						"cinematics/environment/biodome/leaves_folliage_01.cinematic",
						"cinematics/environment/biodome/mosquitos_glow.cinematic",
						"cinematics/environment/biodome/sand_storm.cinematic",
						"cinematics/environment/biodome/sprinklers_top_long.cinematic",
						"cinematics/environment/biodome/sprinklers_top_long_narrow.cinematic",
						"cinematics/environment/biodome/waterfall_basemist.cinematic",
						"cinematics/environment/descent/descent_club_holo_ball.cinematic",
						"cinematics/environment/descent/descent_droid.cinematic",
						"cinematics/environment/descent/descent_energyflow_lightflash.cinematic",
						"cinematics/environment/dust_motes.cinematic",
						"cinematics/environment/eclipse/search_light.cinematic",
						"cinematics/environment/eclipse/skyline.cinematic",
						"cinematics/environment/eclipse/skyline_endless.cinematic",
						"cinematics/environment/emergency_light_flash.cinematic",
						"cinematics/environment/fire_light_flicker.cinematic",
						"cinematics/environment/fire_small.cinematic",
						"cinematics/environment/fire_small_sidebarrel.cinematic",
						"cinematics/environment/fire_tiny.cinematic",
						"cinematics/environment/halo_aqua_large.cinematic",
						"cinematics/environment/halo_blue_large.cinematic",
						"cinematics/environment/halo_orange_large.cinematic",
						"cinematics/environment/lightrays_blue.cinematic",
						"cinematics/environment/lightrays_orange.cinematic",
						"cinematics/environment/light_c12_ambientflicker.cinematic",
						"cinematics/environment/light_c12_downflicker.cinematic",
						"cinematics/environment/light_repair_downflicker.cinematic",
						"cinematics/environment/sparks.cinematic",
						"cinematics/environment/sparks_loop_3s.cinematic",
						"cinematics/environment/steam.cinematic",
						"cinematics/environment/steamjet_ceiling.cinematic",
						"cinematics/environment/steamjet_ceiling_burst_4s.cinematic",
						"cinematics/environment/steamjet_large_soft.cinematic",
						"cinematics/environment/steamjet_wall.cinematic",
						"cinematics/environment/steam_ambiant.cinematic",
						"cinematics/environment/steam_rise.cinematic",
						"cinematics/environment/tram_skybox_tram1.cinematic",
						"cinematics/environment/tram_skybox_tram2.cinematic",
						"cinematics/environment/tram_skybox_tram3.cinematic",
						"cinematics/environment/waterfall_basemist.cinematic",
						"cinematics/environment/waterfall_emerge.cinematic",
						"cinematics/environment/waterfall_fine.cinematic",
						"cinematics/environment/waterfall_large_basemist.cinematic",
						"cinematics/environment/water_bubbles_01.cinematic",
						"cinematics/environment/water_drip.cinematic",
						"cinematics/environment/water_drips_rapid.cinematic",
					}

local viewModelCinematics = set {
						"cinematics/marine/gl/muzzle_flash.cinematic",
						"cinematics/marine/gl/shell.cinematic",
						"cinematics/marine/minigun/muzzle_flash.cinematic",
						"cinematics/marine/minigun/muzzle_flash_left.cinematic",
						"cinematics/marine/minigun/muzzle_flash_loop.cinematic",
						"cinematics/marine/pistol/muzzle_flash.cinematic",
						"cinematics/marine/pistol/shell.cinematic",
						"cinematics/marine/railgun/muzzle_flash.cinematic",
						"cinematics/marine/railgun/steam_1p_left.cinematic",
						"cinematics/marine/railgun/steam_1p_right.cinematic",
						"cinematics/marine/rifle/muzzle_flash.cinematic",
						"cinematics/marine/rifle/muzzle_flash2.cinematic",
						"cinematics/marine/rifle/muzzle_flash3.cinematic",
						"cinematics/marine/rifle/shell.cinematic",
						"cinematics/marine/rifle/shell_looping_1p.cinematic",
						"cinematics/marine/shotgun/muzzle_flash.cinematic",
						"cinematics/marine/shotgun/shell.cinematic",
}

-- Precache all the new cinematics
PrecacheAsset("chud_cinematics/blank.cinematic")
for cinematic,_ in pairs(replacedCinematics) do
	PrecacheAsset("chud_" .. cinematic)
end

local originalSetCinematic
originalSetCinematic = Class_ReplaceMethod( "Cinematic", "SetCinematic", 
	function(self, cinematicName)
		--Print(cinematicName)
		if Client.fullyLoaded then

			if gCHUDHiddenViewModel and viewModelCinematics[cinematicName] then
				cinematicName = "chud_cinematics/blank.cinematic"
			end

			if CHUDGetOption("particles") then
				if replacedCinematics[cinematicName] then
					cinematicName = "chud_" .. cinematicName
				elseif blockedCinematics[cinematicName] then
					cinematicName = "chud_cinematics/blank.cinematic"
				-- Easier than doing this in like 10 folders
				elseif string.find(cinematicName, "ricochetMinigun.cinematic") then
					cinematicName = string.gsub(cinematicName, "ricochetMinigun.cinematic", "ricochet.cinematic")
				end
			end

		end
		originalSetCinematic(self, cinematicName)
	end
)

function CacheCinematics(className, groupName, values)
	if className == "cinematic" and mapCinematicNames[values.cinematicName] then
		table.insert(cinematicsCache, Client.cinematics[#Client.cinematics])
		if not Client.fullyLoaded then
			table.insert(cinematicsValuesCache, {className = className, groupName = groupName, values = values})
		end
		table.remove(Client.cinematics, #Client.cinematics)
	end
	
	if className == "ambient_sound" then
		if not Client.fullyLoaded then
			table.insert(ambientsValuesCache, {className = className, groupName = groupName, values = values})
		end
	end
end

function CreateCinematic(className, groupName, values)
	if className == "cinematic" then
	
		local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
		
		cinematic:SetCinematic(values.cinematicName)
		cinematic:SetCoords(values.angles:GetCoords(values.origin))
		
		local repeatStyle = Cinematic.Repeat_None
		
		if values.repeatStyle == 0 then
			repeatStyle = Cinematic.Repeat_Loop
		elseif values.repeatStyle == 1 then
			repeatStyle = Cinematic.Repeat_Loop
		elseif values.repeatStyle == 2 then
			repeatStyle = Cinematic.Repeat_Endless
		end
				
		cinematic:SetRepeatStyle(repeatStyle)
		
		cinematic.commanderInvisible = values.commanderInvisible
		cinematic.className = className
		cinematic.coords = coords
		
		if className == "cinematic" and mapCinematicNames[values.cinematicName] then
			table.insert(cinematicsCache, cinematic)
		end
	end
end

local originalSetCommanderPropState = SetCommanderPropState
function SetCommanderPropState(isComm)
	originalSetCommanderPropState(isComm)
	if propCache ~= nil then
		for index, propPair in ipairs(propCache) do
			local prop = propPair[1]
			if prop.commAlpha < 1 then
				prop:SetIsVisible(not isComm)
			end
		end
	end
end

local originalLoadMapEntity = LoadMapEntity
function LoadMapEntity(className, groupName, values)
	local success = originalLoadMapEntity(className, groupName, values)
	if success and className == "prop_static" then
		-- Biodome seems to be using a different case for some models than what the actual files show
		local modelName = string.lower(values.model)
		local mapName = string.lower(Shared.GetMapName())
		local mapSpecificBlockedProp = blockedProps[mapName] and blockedProps[mapName][modelName]
		if (blockedProps[modelName] or mapSpecificBlockedProp) then
			table.insert(propCache, Client.propList[#Client.propList])
			if not Client.fullyLoaded then
				table.insert(propValuesCache, {className = className, groupName = groupName, values = values})
			end
			table.remove(Client.glowingProps, #Client.glowingProps)
			table.remove(Client.propList, #Client.propList)
		end
	end
	return success
end

function RemovePropDynamics()
	local mapName = string.lower(Shared.GetMapName())
	for _, entity in ientitylist(Shared.GetEntitiesWithClassname("PropDynamic")) do
		-- Biodome seems to be using a different case for some models than what the actual files show
		local modelName = string.lower(entity:GetModelName())
		local mapSpecificBlockedProp = blockedProps[mapName] and blockedProps[mapName][modelName]
		if (blockedProps[modelName] or mapSpecificBlockedProp) and not CHUDGetOption("mapparticles") then
			entity:SetModel(nil)
		end
	end
end
		
function SetCHUDCinematics()
	if not CHUDGetOption("mapparticles") then
		if cinematicsCache ~= nil then
			for index, cinematic in ipairs(cinematicsCache) do
				Client.DestroyCinematic(cinematic)
			end
			cinematicsCache = { }
			cinematicsRemoved = true
		end
		if propCache ~= nil then
			for index, models in ipairs(propCache) do
				Client.DestroyRenderModel(models[1])
				Shared.DestroyCollisionObject(models[2])
			end
			propCache = { }
			propsRemoved = true
		end
	else
		if cinematicsRemoved then
			for i, cinematic in pairs(cinematicsValuesCache) do
				CreateCinematic(cinematic.className, cinematic.groupName, cinematic.values)
			end
			cinematicsRemoved = false
		end
		if propsRemoved then
			for i, prop in pairs(propValuesCache) do
				LoadMapEntity(prop.className, prop.groupName, prop.values)
			end
			propsRemoved = false
		end		
	end
end

function SetCHUDAmbients()
	if not CHUDGetOption("ambient") then
		for a = 1, #Client.ambientSoundList do
			Client.ambientSoundList[a]:OnDestroy()
		end
		Client.ambientSoundList = { }
		ambientsRemoved = true
	elseif ambientsRemoved then
		for _, ambient in pairs(ambientsValuesCache) do
		
			local entity = AmbientSound()
			LoadEntityFromValues(entity, ambient.values)
			Client.PrecacheLocalSound(entity.eventName)
			table.insert(Client.ambientSoundList, entity)

		end
		ambientsRemoved = false
	end
end

Event.Hook("UpdateClient", RemovePropDynamics)
Event.Hook("MapLoadEntity", CacheCinematics)