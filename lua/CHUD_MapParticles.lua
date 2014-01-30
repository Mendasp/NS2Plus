Script.Load("lua/Class.lua")

mapCinematicNames = {	"cinematics/environment/biodome/flying_papers.cinematic",
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
						"cinematics/environment/light_c12_ambientflicker.cinematic",
						"cinematics/environment/light_c12_downflicker.cinematic",
						"cinematics/environment/light_repair_downflicker.cinematic",
						"cinematics/environment/lightrays_blue.cinematic",
						"cinematics/environment/lightrays_orange.cinematic",
						"cinematics/environment/sparks.cinematic",
						"cinematics/environment/sparks_loop_3s.cinematic",
						"cinematics/environment/steam.cinematic",
						"cinematics/environment/steam_ambiant.cinematic",
						"cinematics/environment/steam_rise.cinematic",
						"cinematics/environment/steamjet_ceiling.cinematic",
						"cinematics/environment/steamjet_ceiling_burst_4s.cinematic",
						"cinematics/environment/steamjet_large_soft.cinematic",
						"cinematics/environment/steamjet_wall.cinematic",
						"cinematics/environment/tram_skybox_tram1.cinematic",
						"cinematics/environment/tram_skybox_tram2.cinematic",
						"cinematics/environment/tram_skybox_tram3.cinematic",
						"cinematics/environment/water_bubbles_01.cinematic",
						"cinematics/environment/water_drip.cinematic",
						"cinematics/environment/water_drips_rapid.cinematic",
						"cinematics/environment/waterfall_basemist.cinematic",
						"cinematics/environment/waterfall_emerge.cinematic",
						"cinematics/environment/waterfall_fine.cinematic",
						"cinematics/environment/waterfall_large_basemist.cinematic" }
							
// Precache all the new cinematics
PrecacheAsset("chud_cinematics/blank.cinematic")
for i, cinematic in pairs(replacedCinematics) do
	PrecacheAsset(cinematic)
end

local originalSetCinematic
originalSetCinematic = Class_ReplaceMethod( "Cinematic", "SetCinematic", 
	function(self, cinematicName)
		//Print(cinematicName)
		if CHUDSettings["particles"] then
			if table.contains(replacedCinematics, cinematicName) then
				originalSetCinematic(self, "chud_" .. cinematicName)
			elseif table.contains(blockedCinematics, cinematicName) then
				originalSetCinematic(self, "chud_cinematics/blank.cinematic")
			else
				originalSetCinematic(self, cinematicName)
			end
		else
			originalSetCinematic(self, cinematicName)
		end
	end
)