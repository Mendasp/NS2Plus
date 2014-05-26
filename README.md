NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
- /05/2014 (Build 265)
	- Integrated 'Ready Room Special' mod (Thanks remi.D!)
	
- 28/05/2014 (Build 265):
	- You can now sort by column in the mods window.
	- Fixed bug where Last life stats would show up as "nan%" sometimes.
	- Dropped marine weapons and deployed mines are now outlined for spectators.
	- Fixed invisible collision/hitboxes for the following models:
		- refinery_tram_door1.model
		- refinery_tram_door2.model
		- docking_loadingdoor_closed.model
		- docking_loadingdoor_closed_var.model
		- refinery_gantrycrane.model
		- biodome_elevator.model
		- biodome_wallmods_01_corner_in_90_01.model
		- biodome_wallmods_01_corner_in_90_02.model

- 22/05/2014 (Build 265):
	- Added new BoneWall icon for the minimap (Thanks remi.D!)
	- Mod updater now shows a list of the mods that have been updated.

- 21/05/2014 (Build 265):
	- Ammo, medpacks and catpacks now ignore the vertical element for pickup by marines. This should mitigate some of the problems commanders have with weird geometry in levels blocking their drops. (Thanks kmg!)
	- Added Bonewall minimap icon. (Thanks kmg, remi.D!)
	- Shift Echo now updates the buttons faster when trying to echo upgrade chambers, and updates immediately after the shift is echoed to a new location (Thanks remi.D!)
	- Fixed Grenade collision radius to be more representative of the visual model -- proximity detonation radius is unchanged (Thanks remi.D!)
	- Fixed drifters trying to build structures they can't and fake-building them forever (Thanks remi.D!)
	- Bonewalls now show range before dropping.
	- Fixed bug where the Unique Shotgun Hits setting would affect Flamethrower damage numbers sometimes.
	- Minimap connectors display as a line when there's only 2 PGs.
	- Minimap connectors now display with the team color.

- 17/05/2014 (Build 265):
	- Added Marine Commander stats. At the end of the round they will show up in console for people that have been in the chair.

- 14/05/2014 (Build 265):
	- Fixed bug with NS2+ console commands where the example usage would not be displayed correctly.
	- Added "cycle" parameter to console commands that cycles through int and boolean values.
	- Crosshair damage indicator now only shows up if we're hitting enemies.
	- Fixed NS2 bug where damage numbers wouldn't show the damage for the killing blow.
	- Fixed "Unknown" player info in server browser. Big, gigantic thanks to Person8880 (Shine author) for the fix.

- 13/05/2014 (Build 265):
	- Enabled weapon specific ammo models for dropped weapons.
	- Ammo for dropped weapons now follow the parent weapon. They also have outlines now.
	- Added new option for Phase Gate lines. Default/Static arrows/Animated lines/Animated arrows. Available in HUD tab.
	- Fixed bug where the Faster damage numbers option would not get applied after map load.
	- Replaced Small damage numbers option with Damage numbers scale option. The scale goes between 50% and 100%.

- 10/05/2014 (Build 265):
	- Changed pickup expire bar options. You can now toggle between Disabled/Equipment Only/All pickupables. Available in Misc. tab.
	- Added option to disable click selecting for Marine players (only Marine Commander). You can still do marquee selection. Available in Misc. tab.
	- You can now make the minimap key act as a toggle. Available in the Misc. tab.
	- Added marquee selection for enemy units. If the marquee selection contains units from both teams it will default to your team's units.
	- Fixed bug where some elements of the Marine UI would remain on screen after death.
	- Changed last life stats helper text to use the normal graphics for showing key binds with their actions.
	- Added assists/score popup color selection. Available in the HUD tab.
	- Mines now still show their pickup icon even if already holding mines. (Thanks remi.D!)
	- Made weapons that were actively picked up get swapped to (pistols, mines). (Thanks remi.D!)
	- Added option to prevent shotgun damage numbers from accumulating. Available in the HUD tab. (Thanks remi.D!)
	- Added option to speed up damage number accumulation. Available in the HUD tab. (Thanks remi.D!)

=================
Credits/Thanks to
=================
- **Unknown Worlds Entertainment** (http://unknownworlds.com)
- **Dragon** (https://github.com/xToken)
- **bawNg** (https://github.com/bawNg)
- **lwf** [(Better NS2)](http://steamcommunity.com/sharedfiles/filedetails/?id=113116595)
- **Ghoul** (https://github.com/BrightPaul)
- **Sewlek**
- **Person8880** (https://github.com/Person8880)
- **remi.D** (https://github.com/sclark39)
