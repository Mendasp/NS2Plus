NS2+
==========

This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

To be able to search for servers running NS2+ you can use [NS2+ Browser](http://steamcommunity.com/sharedfiles/filedetails/?id=236685163). Remember to set it to Active in your Mods list.

Latest changes
==============
- 20/04/2014 (Build 264):
	- Fixed bug where Escape key wouldn't work when hovering over the news page.
	- Fixed news showing up behind main menu graphics.
	- Properly disabled background graphics in main menu under Minimal GUI setting.
	- Fixed problem where Options menu and NS2+ Options would overlap with Minimal GUI setting turned off.
	- News script now gets destroyed on menu close to solve potential performance issue.
	
- 19/04/2014 (Build 264):
	- Renamed "Only request menu" to "Only voiceover menu" and updated tooltip to hopefully clear up which menu it is that shows the Last life stats.
	- Respawn cheat commands now make you respawn at your death position (unless you die to map death triggers).
	- Respawn cheat commands now save your equipment/upgrades.
	- Added "jetpack" cheat command to spawn as a Jetpack Marine.
	- Added player upgrades to player frames in Insight.
	- Added Uke's Alien Vision.
	- Made hitsounds scale with game volume in addition to their own volume slider.

- 18/04/2014 (Build 264):
	- Fixed bug where menu would stop responding in some cases while trying to open the options.

- 17/04/2014 (Build 264):
	- Tweaked Lerk spikes tracers and Infantry Portal spawning particles for Minimal particles setting.
	- Menu open sound will now use the user's game sound volume.
	- Added server configurable options. Type sv_plus if you have the appropriate permissions for more information. You can also edit NS2PlusServerConfig.json.
	- Solved problem where the Death Stats UI would still show up when alive (beacon, respawning with cheats, etc).
	- Added Death Stats UI toggle (Fully disabled/Only request menu/Enabled). You can still access the stats, if partially enabled, by holding the request menu button (default: X).
	- Respawn cheat commands now always spawn the player in first person view.
	- Added ingame news webpage.
	- Fixed bug where flashlight atmospherics would get applied to the player's first person flashlight.

- 15/04/2014 (Buld 264):
	- Fixed non-snow rock prop variant size.
	- Potentially fixed issue that'd let aliens see marines that are not parasited with an outline

- 11/04/2014 (Build 264):
	- When a mod update is found, the message will get repeated every 5 minutes until map restart.
	- Reworked friends highlighting again, in a better way this time. (Thanks remi.D!)
	- Added flashlight atmospherics slider. Available in the Misc. tab.
	- The Minimal GUI setting now also removes the background of the main menu.
	- Fixed bug where having the map ambient sounds enabled would make the mod not play the hitsounds.
	- Fixed bug where stats wouldn't show up on round end.

Credits/Thanks to
=================
- **Unknown Worlds Entertainment** for creating Natural Selection 2. This is a classic in mod credits.
- **Dragon** for rewriting my horrible light switching code (which I've stolen back from the NSL mod) and answering my stupid questions.
- **bawNg** for his awesome injection code (from SparkMod: https://github.com/SparkMod/SparkMod). Tip: Never mention CS:GO to him.
- **lwf** for the tracer code from Better NS2 (http://steamcommunity.com/sharedfiles/filedetails/?id=113116595)
- **Ghoul** (https://github.com/BrightPaul)
- **Sewlek**
- **Person8880** (https://github.com/Person8880) GetGamemode function to reenable Hive stats.
- **remi.D**
