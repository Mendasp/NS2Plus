Custom HUD
==========

This mod for Natural Selection 2 allows the players to customize a number of settings of their HUD and game behavior (sounds, visuals).

If the server allows mods that use the entry system, you can use it as it's 100% client-side, otherwise you need the server to be running it.

You can type "chud" in console to see all available options or set them directly in your options menu.

Latest changes
==============
- 28/02/2014 (Build 263):
	- Fixed lifeform stat tracking (accuracy without Onos hits)
	- Enabled Alien Vision switcher (chud_av). Switches between default and [Huze's Old Alien Vision](http://steamcommunity.com/sharedfiles/filedetails/?id=201163952).
	- Added marine upgrade level toggle (chud_uplvl). This enables or disables the weapon/armor level icons on the side of the marine HUD.
	- Added classic ammo counter toggle (chud_classicammo). Adds an ammo counter on the lower right, like in classic FPS games. Based on Dragon's NS2c ammo display code.

- 19/02/2014 (Build 263):
	- Disabled the toggling of the build number as it caused weird issues for reasons I fail to understand

- 17/02/2014 (Build 263):
	- Exos show only armor value in Minimal Nameplates/Exo HUD (since they don't have health)
	- Parasited friendlies (players or structures) will use a different font color in nameplates (yellow)
	- Added new option to disable friends highlighting in the minimap/nameplates (chud_friends)
	- Moved biomass display to avoid overlap with game timer

- 16/02/2014 (Build 263):
	- Reduced skulk jump sound volume to 50%
	- Removed build number in Minimal GUI (chud_mingui)

- 14/02/2014 (Build 263):
	- Added stat tracking. You'll get info in console when you die (the player and structure damage you did while alive) and a more complete overview when the round ends or you go to the ReadyRoom.
	- No more file overwrites, the mod works only with the entry system
	- Phase Gates and Gorge Tunnels now show destination in Minimal Nameplates settings (chud_minnps)
	- You can now switch the official low lights setting with the NSL lights (chud_lowlights)
	- New option to disable ambient sounds (chud_ambient), and added console command to remove them at any point in the game (stopsound)
	- Minimal particles (chud_particles) now also removes map cinematics and holograms, like in NSL maps
	- Removed "Objective completed" sound that still played if you had Waypoints disabled (chud_wps)
	- Removed "Upgrade complete" sound that still played even with Unlock alerts disabled (chud_unlocks)
	- Minimal particles additions:
		- Removed Exo jump/land/overheat/bullet particles
		- Removed first person low health warning for the Exo
		- Changed Minigun shooting/impact with rifle effects, looks a bit silly, but less vision obscuring
		- Removed the jetpack trail effect
		- Removed most flamethrower effects (really big FPS drain)
		- Replaced res node effect with older one (less vision obscuring, more like in NS1)
		- Removed shadowstep trail
		- Damaged extractor only shows fire (no smoke)

Custom HUD Commands
===================
- **chud_alienbars:** Switches between default health/energy circles or thicker with gradients made by Oma.
- **chud_ambient:** Removes map ambient sounds. You can also remove all the ambient sounds during the game by typing "stopsound" in console.
- **chud_assists:** Removes assist score popup.
- **chud_av:** Switches between default alien vision or Huze's old alien vision
- **chud_banners:** Removes the banners in the center of the screen ("Commander needed", "Power node under attack", "Evolution lost", etc).
- **chud_classicammo:** Adds an ammo counter on the lower right, like in classic FPS games.
- **chud_blur:** Removes the background blur from menus/minimap.
- **chud_dmgcolor_a:** Alien damage numbers color. Either RGB or Hex values accepted. For example, you can enter red as 255 0 0 or 0xFF0000.
- **chud_dmgcolor_m:** Marine damage numbers color. Either RGB or Hex values accepted. For example, you can enter red as 255 0 0 or 0xFF0000.
- **chud_dmgcolor_reset:** Reset damage numbers colors to the default on both aliens and marines.
- **chud_friends:** Toggle the friend highlighting in the minimap/nameplates.
- **chud_gametime:** Adds or removes the game time on the top left (requires having the commander name as marines).
- **chud_hpbar:** Removes the health bars from the marine HUD.
- **chud_kda:** Switches the scoreboard from KAD to KDA.
- **chud_lowlights:** Changes between the default map low quality lights and the NSL lights.
- **chud_mingui:** Removes backgrounds/scanlines from all UI elements.
- **chud_minimap:** Removes the entire top left of the screen for the marines (minimap, comm name, team res, comm actions).
- **chud_minnps:** Removes building names and health/armor bars and replaces them with a simple %.
- **chud_minwps:** Removes all text/backgrounds and only leaves the waypoint icon.
- **chud_particles:** Reduces particle clutter and certain map props (holograms).
- **chud_rtcount:** Removes RT count dots at the bottom and replaces them with a number.
- **chud_score:** Disables score popup (+5).
- **chud_showcomm:** Forces showing the commander and resources when disabling the minimap.
- **chud_smalldmg:** Makes the damage numbers smaller.
- **chud_smallnps:** Makes fonts in the nameplates smaller.
- **chud_tracers:** Disables weapon tracers.
- **chud_unlocks:** Removes the research completed notifications on the right side of the screen.
- **chud_uplvl:** Removes the weapon/armor level indicator on the right side of the marine HUD
- **chud_wps:** Disables all waypoints except Attack orders (waypoints can still be seen on minimap).

Credits/Thanks to
=================
- **Unknown Worlds Entertainment** for creating Natural Selection 2. This is a classic in mod credits.
- **Dragon** for rewriting my horrible light switching code (which I've stolen back from the NSL mod) and answering my stupid questions.
- **bawNg** for his awesome injection code (from SparkMod: https://github.com/SparkMod/SparkMod). Tip: Never mention CS:GO to him.
- **lwf** for the tracer code from Better NS2 (http://steamcommunity.com/sharedfiles/filedetails/?id=113116595)
- **Ghoul** (https://github.com/BrightPaul)
- **Sewlek** 