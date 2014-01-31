CustomHUD
=========

Custom HUD mod for Natural Selection 2

Latest changes - Build 263 (unreleased):
- You can now switch the official low lights setting with the NSL lights (chud_lowlights)
- New option to disable ambient sounds (chud_ambient), and added console command to remove them at any point in the game (stopsound)
- Minimal particles (chud_particles) now also removes map cinematics and holograms, like in NSL maps
- Removed "Objective completed" sound that still played if you had Waypoints disabled
- Removed "Upgrade complete" sound that still played even with Unlock alerts disabled
- Minimal particles additions:
	- Removed Exo jump/land/overheat/bullet particles
	- Removed first person low health warning for the Exo
	- Changed Minigun shooting/impact with rifle effects, looks a bit silly, but less vision obscuring
	- Removed the jetpack trail effect
	- Removed most flamethrower effects (really big FPS drain)
	- Replaced res node effect with older one (less vision obscuring, more like in NS1)
	- Removed shadowstep trail

You can type "chud" in console to see all available options or set them directly in your options menu.

Custom HUD Commands
===================
- **chud_alienbars:** Switches between default health/energy circles or thicker with gradients made by Oma.
- **chud_ambient:** Removes map ambient sounds. You can also remove all the ambient sounds during the game by typing "stopsound" in console.
- **chud_assists:** Removes assist score popup.
- **chud_banners:** Removes the banners in the center of the screen ("Commander needed", "Power node under attack", "Evolution lost", etc).
- **chud_blur:** Removes the background blur from menus/minimap.
- **chud_dmgcolor_a:** Alien damage numbers color. Either RGB or Hex values accepted. For example, you can enter red as 255 0 0 or 0xFF0000.
- **chud_dmgcolor_m:** Marine damage numbers color. Either RGB or Hex values accepted. For example, you can enter red as 255 0 0 or 0xFF0000.
- **chud_dmgcolor_reset:** Reset damage numbers colors to the default on both aliens and marines.
- **chud_gametime:** Adds or removes the game time on the top left (requires having the commander name as marines).
- **chud_hpbar:** Removes the health bars from the marine HUD.
- **chud_kda:** Switches the scoreboard from KAD to KDA.
- **chud_mingui:** Removes backgrounds/scanlines from all UI elements.
- **chud_minimap:** Removes the entire top left of the screen for the marines (minimap, comm name, team res, comm actions).
- **chud_minnps:** Removes building names and health/armor bars and replaces them with a simple %.
- **chud_minwps:** Removes all text/backgrounds and only leaves the waypoint icon.
- **chud_particles:** Reduces particle clutter.
- **chud_rtcount:** Removes RT count dots at the bottom and replaces them with a number.
- **chud_score:** Disables score popup (+5).
- **chud_showcomm:** Forces showing the commander and resources when disabling the minimap.
- **chud_smalldmg:** Makes the damage numbers smaller.
- **chud_smallnps:** Makes fonts in the nameplates smaller.
- **chud_tracers:** Disables weapon tracers.
- **chud_unlocks:** Removes the research completed notifications on the right side of the screen.
- **chud_wps:** Disables all waypoints except Attack orders (waypoints can still be seen on minimap).