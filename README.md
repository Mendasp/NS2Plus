NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
- 14/11/2014
	- Fixed bug where end round stats would display all players as aliens.
	- Made scoreboard not take up the entire width at high res.
	- Marine Commanders can now always see if a player has a welder.
	- Added server option to display player skill pre-game on the scoreboard. Servers can enable it by typing "sv_plus showplayerskill true" in console or modifying NS2PlusServerConfig.json.

- 09/11/2014
	- Fixed server crash related to parented entities.
	- Made scoreboard behave more like the old one at high resolutions.
	- Made Commander player background yellow in the scoreboard as to identify rookie commanders.

- 08/11/2014
	- Added average skill (if enabled by the server) to the server name/game time UI element at the top of the scoreboard.
	- Added toggle for the auto-centering on your player in the scoreboard. Available in Misc. tab.
	- Fixed issue where players that left the server before the round ended wouldn't show up in the final stats.
	- Fixed small issue with scoreboard element uninitialization.
	- Fixed bug where the killfeed was displaying behind the death screen.

- 07/11/2014
	- Modified vanilla scoreboard to make it usable at low resolutions. It will automatically scroll to your position if you are in RR or in a team. You can use the mousewheel, home/end/pgup/pgdn or click and drag to scroll.
	- Formatted server console output on load to display more of the current NS2+ settings.

- 31/10/2014
	- Updated for Build 270.
	- Added team average Hive skill to the scoreboard. Off by default. Servers can enable it by typing "sv_plus showavgteamskill true" in console or modifying NS2PlusServerConfig.json.
	- Added pages to console help for NS2+ commands.

- 12/10/2014
	- Added reload indicator to Classic Ammo and HL2 HUD bar options. (Thanks Bi()ha2arD!)
	- Added indicators for scan/obs, cloaking, umbra and enzyme when using the no viewmodel option.
	- Added build/weld percentage to Classic Ammo and HL2 HUD bar options.
	- Added stats for all the players at round end in the console with average team accuracies.
	- Improved tunnel collision. It is now slightly higher and more closely matches the shape of the tunnel. (Thanks Samusdroid!)
	- Grenade Launcher rounds are now highlighted in Alien vision and the visual model is slightly larger (collision is still the same). (Thanks Samusdroid!)
	- Clogs no longer have decals projected onto them. (Thanks Samusdroid!)
	- Added option to allow spectators to keep auto-following a player without reselecting it on respawn.

- 20/09/2014
	- Added map-specific prop blocking.
	- Removed more props from biodome under the map particles setting.

- 19/09/2014
	- Made the viewmodel toggle available for aliens too, the option has been reset.

- 18/09/2014
	- Added option to make crosshairs scale with resolution. Available in HUD tab.
	- Added viewmodel toggle for marines. It is always allowed on CompMod servers and disabled by default on vanilla servers (can be enabled by server admins).
	- Server browser will now tell you the NS2+ options that are blocked by the server in conflict with your own settings.
	- Added option for the marine commander alert queue to only respond to player alerts.

- 10/09/2014
	- Improved request menu option selection (Thanks remi.D!)
	- Added the time spent building to the end round stats.
	- Fixed some weapons not reporting the correct number of kills on round end.

- 01/09/2014
	- Added option to delay ending recording after releasing the microphone binding (default 0.15 seconds).
	- Fixed issue with microphone being cut off when switching in/out of commander mode.

- 31/08/2014
	- Changed method of doing the player colors in the minimap to be more mod friendly.
	- Fixed rounding error in HL2 style bars.
	- Fixed white box around health/armor in marine HUD when not displaying the vanilla bars.
	- Compatibility with build 269.

- 24/08/2014
	- Precached some textures to avoid potential hitching.
	- Improved mucous display making it an extra ring in the health bars.
	- Fixed super small rounding error caused by saving slider settings twice.
	- Fixed phase gate lines not being applied correctly.
	- Changed drop/select range circles from models to decals so they represent better the area that they cover.
	- Reduced Fade Blink volume.

- 22/08/2014
	- Updated for Build 268. Removed all the stuff that is now part of vanilla.

- 18/08/2014
	- Made medpack accuracy stricter, pickups have to occur in 25ms for it to count as a hit instead of the previous 100ms.
	- Enabled tvglare element in the main menu so the Fastload menu mods work again.
	- Added kills per weapon and the longest killstreak to the endgame stats.
	- Fixed bug where the follow mode would try to follow entities that weren't players.
	- Made spectator follow mode keep following the player through class changes.

- 16/08/2014
	- Fixed amazing bug that made the Endgame Stats show every time the request key was released ignoring all laws of physics, common sense, and other stuff. Seriously, wtf.
	- Added improved follow mode to Insight. When clicking on a player frame it will autofollow that player until it dies or changes classes (or the frame is clicked again).

- 13/08/2014
	- Added Gorge Spit accuracy back.
	- Added some rounding to the options menu so people don't freak out about floating point precision.

- 07/08/2014
	- Fixed alien armor still showing up in rare instances for alien HUD bars.
	- Made HL2 HUD bars thinner and slightly more transparent.

- 05/08/2014
	- Added NS2+ Options to the main menu if the mod is mounted.
	- Autopickup Better Weapon option now keeps your current weapon as long as it's better than the LMG.
	- Added HUD bars option. You can choose to have HUD info next to your crosshair (HL2 style) or to the sides at the bottom (NS1 style). Available in HUD tab. Thanks to rantology for the art!
	- Fixed crosshair hit indicator fade time not being applied on map load properly.
	- Added team specific sensitivities. Available in Misc. tab.
	- Added team specific FOVs. Available in Misc. tab.
	- Tweaked the rifle muzzleflash and some ricochet particles under Minimal Particles setting.

- 20/07/2014
	- Fixed vanilla bug where the Commander would log out attacking.
	- Fixed vanilla bug that made trigger volumes bigger than their representation in the editor. This affected some map locations (power node issues).
	- Made powered room effect for Commanders with the same accuracy as the actual volume they cover.

- 16/07/2014
	- Added a toggle for the low ammo warning. Available in HUD tab.

- 15/07/2014
	- Made endgame stats appear as soon as they are received.
	- Endgame stats are now a toggle, tap the Request menu key (default: X) to see them.
	- Commander stats now show up with the other endgame stats.
	- Endgame stats now get saved locally so you can check them after map or server changes.
	- You can now check the endgame stats as long as a new game hasn't started or you're in the ReadyRoom.

- 12/07/2014
	- Made weapons reload automatically after shooting the last bullet.
	- Added option to make ragdolls dissolve instantly. Available in Misc. tab.
	- Added weapon expire bars for Commanders.

- 11/07/2014
	- Fixed problem where going from overhead spectator to free cam would not apply the custom map atmospheric density.
	- Added custom color option for players in the minimap to easily tell apart players from buildings. Available in HUD tab.
	- Made weapon ammo displays flash red with low ammo counts.
	- Classic ammo flashes red with low ammo counts.
	- Added custom minimap icons for the unsocketed/blueprint Power Nodes.

- 10/07/2014
	- Unsocketed power nodes are now grey.
	- Made alien energy bar for Commanders the same color as it is in Insight.

- 09/07/2014
	- Added Lerk Bite icon.
	- Enabled hitsounds for Grenade Launcher.
	- Made unsocketed/blueprint Power Nodes show up properly in the minimap.
	- Added option to choose the color of the minimap arrow representing your position. Available in HUD tab.
	- Alien Commanders can now see the energy of the players.
	- Added high contrast colors for armor in Insight.
	- Added max decal lifetime option. You can set how long decals last (still affected by the vanilla setting). Available in Visual tab.

=================
Credits/Thanks to
=================
- Regular contributors
	- [**remi.D**](https://github.com/sclark39)
	- **rantology**

- Also thanks to
	- [**Unknown Worlds Entertainment**](http://unknownworlds.com)
	- [**Dragon**](https://github.com/xToken)
	- [**bawNg**](https://github.com/bawNg)
	- **lwf** - [(Better NS2)](http://steamcommunity.com/sharedfiles/filedetails/?id=113116595)
	- [**Ghoul**](https://github.com/BrightPaul)
	- **Sewlek**
	- [**Person8880**](https://github.com/Person8880)
