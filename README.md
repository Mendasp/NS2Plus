NS2+
==========

This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

To be able to search for servers running NS2+ you can use [NS2+ Browser](http://steamcommunity.com/sharedfiles/filedetails/?id=236685163). Remember to set it to Active in your Mods list.

Latest changes
==============
- 28/04/2014 (Build 264):
	- Voice chat now shows the team color correctly when alltalk is on. (Thanks remi.D!)
	- The scoreboard now keeps the time of the previous round until the next round starts. (Thanks remi.D!)
	- Minimap is now square under Minimal GUI setting.
	- Added last comm actions to be toggleable instead of hiding it with the minimap.
	- Minimap option now only toggles minimap and location text.
	- Show commander name option is now independent of minimap option.
	- Game time now doesn't depend on commander minimap on marines.
	- Added grenades and mines to Insight's equipment display (only shows 3 icons max with this priority/order: JP > Welder > Grenades > Mines).
	- Added parasited name color to Insight names on the sides.
	- Added a new Alien bars option made by Rantology.
	- Added map atmospherics slider, available in the Misc. tab.
	- Added server toggle for Hive stats reporting.
	- Hitsounds also work in pregame now.
	- Disabled backgrounds for the Voice/Request menu under Minimal GUI setting.

- 21/04/2014 (Build 264):
	- Added "respawn" cheat command. It restores your last class (with team), weaponry and teleports you to your last valid death position.
	- Added "respawn_clear" cheat command to clear everything that the new cheat commands remember (position, weapons, upgrades and class).
	- Respawn commands no longer respawn you at last death position. They spawn you where you are. Still remembers upgrades and weapons.
	- Respawn commands now ignore your team, so you can type "skulk" as a marine without having to type "switch" first, for example.

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

Credits/Thanks to
=================
- **Unknown Worlds Entertainment** (http://unknownworlds.com)
- **Dragon** (https://github.com/xToken)
- **bawNg** (https://github.com/bawNg)
- **lwf** [Better NS2](http://steamcommunity.com/sharedfiles/filedetails/?id=113116595)
- **Ghoul** (https://github.com/BrightPaul)
- **Sewlek**
- **Person8880** (https://github.com/Person8880)
- **remi.D** (https://github.com/sclark39)
