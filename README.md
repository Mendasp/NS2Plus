NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
- 02/12/2015
	- Hidden viewmodels option now only has the following entries: "Display all", "Hide all" and "Custom". Added individual customizable options for Marine, Alien, and Exo viewmodels for the Custom option.

- 06/11/2015
	- Made empty Tech Points and Resource Nodes colored so they're easier to distinguish. Color is customizable. Available in HUD tab.

- 18/10/2015
	- Added UI Scale slider.

- 17/10/2015
	- Fixed average team skill not showing under some circumstances.
	- Fixed gametime not adapting to resolution changes correctly.
	- Fixed script error when switching Caster Mode in certain conditions.
	- End game stats now displays class time distribution (time spent as Skulk, Fade, Rifle, Dead, etc).

- 15/10/2015
	- Updated for Build 276.
	- Removed NS2+ option to adjust map atmospherics intensity as it now available in vanilla.

- 01/08/2015
	- Fixed edge case where alien colored text would be faded when using disabled viewmodels and cloaking.
	- Fixed minimap/commander highlight colors not being applied.
	- Fixed nameplates distance setting not taking effect.
	- Fixed vanilla bug where dropped weapon expire timers and respawn timers didn't work for Commanders.
	- Fixed vanilla bug where nameplates would still show in addition to the Insight frames in Overhead Spectator if the camera was close enough.
	- Updated spectator help text with updated drawing/clearing binds.

- 29/07/2015
	- Removed NS2Stats button from End Game Stats and Scoreboard as the service is unavailable.
	- Removed changelog from ingame menu as noone seemed to even notice that it was different from the main menu one and proceeded to ignore it.
	- Added a toggle for the custom killfeed highlight color and the minimap arrow color to avoid certain instances of the setting getting reset to black.
	- Added toggle for the new overhead camera smoothing. Available in Misc. tab.
	- Added missing Derelict loading screens.
	- Fixed armor value not showing up for Exos with hidden viewmodels.

- 04/05/2015
	- Grouped personal stats in End Stats UI in differentiated blocks per team (Commander, Alien, Marine).
	- Added NS2+ version number to the top left with the NS2 build.
	- Removed Mine "deaths" from the Tech Log.
	- Removed redundant "Advanced Weaponry" entry in the Tech Log (shows with Advanced Armory research).
	- Fixed script error in Insight spectator player frames.

- 13/04/2015
	- Added nameplate distance slider to allow players to choose how far nameplates render. Higher values will decrease performance. Available in Visual tab.
	- Added Marine Commander stats to the Tech Log.
	- Fixed bug where picked up medpacks outside the accuracy timing would count as picked and expired at the same time.
	- Insight spectator now shows Alien upgrades in red if they have the upgrade, but have lost all the  chambers.
	- Improved end stats scrolling to be a constant amount instead of percentage based with the scrollwheel.
	- When toggling healthbars on for spectators, the nameplate backgrounds are now hidden so they don't get in the way.
	- Added weapon expiration bars to Insight and Phase Gate/Gorge Tunnel destinations.
	- Fixed "Reset All" button in NS2+ Options overlapping the back button on resolution change.
	- Fixed Insight HP/AP values being toggled while using chat or console.
	- Fixed tech tooltips being stuck on screen when NSL pause is active.

- 06/04/2015
	- Adjusted options menu elements so they all use the same space.
	- Adjusted accuracy text and column width when there's no accuracies without Onos hits.
	- Added kills to last life stats.
	- Added building highlight color option for Commanders that highlights the buildings of the same type that you're about to drop in the minimap in a different color. Available in Visual tab.
	- Added Caster mode to use default NS2+ values without overwriting your config. Available in Misc tab.
	- Free look spectators can now toggle the healthbars on and off by pressing the use key.
	- Increased nameplate range for free look spectators.
	- Added hint text to show the keys you can use in Insight spectator.
	- The state of the Insight HP/AP values now gets saved across map changes.
	- Made custom minimap colors appear correctly for the marine minimap on the top left.
	- Changed the options menu to only display the reset to default button if the value is different than default.
	- The options menu will now hide sub-options that depend on a main setting if it's disabled (Per-team sensitivies/FOV, Vanilla Hitsounds Pitch).
	- Added name change limiter, it will limit the amount of name changes allowed under a certain time.
	- Added "unbind" console command as an alias of "clear_binding", as it's easier to remember.

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
	
=================
Past NS2+ features now included in vanilla NS2:
=================
- [276] Added extra bindings for voiceover options: "Weld me", "Follow me", etc.
- [276] Dropped weapon expire times now are displayed for the commander.
- [273] You can click on the scoreboard to check a player's Steam/NS2 profile.
- [273] Scoreboard displays if someone is your steam friend.
- [273] You can mute voice/text independently and it's persistent across map changes up to 6 hours.
- [273] The scoreboard now truncates player names if they overlap with the rest of the elements.
- [272] Modified vanilla scoreboard to make it usable at low resolutions. It will automatically scroll to your position if you are in RR or in a team. You can use the mousewheel, home/end/pgup/pgdn or click and drag to scroll.
- [272] Scoreboard shows the Commander background in yellow instead of the name, so you can identify rookie players that are commanding.
- [272] Medpacks, ammo, and catpacks can be picked up from any height difference.
- [270] Scoreboard displays the number of connecting players.
- [270] In the voice request menu you can now select items by moving the mouse past them (similar to NS1).
- [270] Building range circles now use decals instead of models.
- [270] Added an option in the sound tab to continue recording after the microphone button has been released for a fraction of a second to help ensure your last word isn't cut off (defaults to 150ms).
- [268] Marine weapons now reload automatically upon firing the last bullet.
- [268] Commanders can marquee select enemy units when there's no friendly units in the marquee.
- [268] Grenade collision radius is more representative of the visual model (proximity detonation radius is unchanged).
- [268] You can click on the player frames on the sides to autofollow a player. Click again to stop following.
- [268] Shotgun lights in the model reflect ammo count.
- [268] Weapon displays flash red when low on ammo.
- [268] Added unsocketed and blueprint states for Power Nodes in the minimap. You can now see all Power Node states.
- [268] Alien Commanders can see the energy for their teammates.
- [268] High contrast colors for health/armor in Insight spectator.
- [267] Marine players and the Marine Commander can see the time until the weapon disappears when it's been dropped.
- [267] Make the outline color yellow for parasited players and purple when they have received a catpack in overhead.
- [267] Added bonewall icon to map.
- [267] Items that disappear after some time on the ground now display an expiration bar for all Marine players (including the Marine Commander).
- [267] Server-confirmed hitsounds.
- [267] The armory and infantry portal arms don’t block bullets anymore.
- [267] Lerks can see damage numbers for the poison bite's damage over time.
- [267] When a structure bleeds out the killfeed will show the killer as whoever hit it last.
- [267] You can see the class of your evolving teammates.
- [267] The kill feed highlights your player kills. Icons in the killfeed are properly scaled too.
- [267] Dropped weapons outlines are color coded for improved readability.
- [267] Infantry Portals will show the name and progress of the player that is about to spawn.
- [267] Evolving alien players will show their evolution progress for their teammates.
- [267] Scoreboard keeps the time of the previous round until the next one starts.
- [267] Dropped marine weapons are outlined for the marine commander and spectators.
- [267] Spectators can see deployed mines highlighted with a blue outline, and the outline will turn yellow if the mine has been parasited.
- [267] Added slight impulse to dropped weapons.
- [267] Enabled weapon specific ammo models for dropped weapons.
- [266] Marine commanders can see the marine ammo bar with the color that's used in the overview spectator mode to easily identify the weapon the marine is carrying.
- [266] Commanders can see building ranges before dropping them.
- [266] Adds player upgrades to the Insight player frames.
- [266] Adds Lerk deaths to Insight alerts.
- [266] Alltalk displays the correct team color/background for voice chat.
- [266] Mods list is sorted automatically as Active > Subscribed > Alphabetically. You can also sort by column.
- [266] Connections between Phase Gates or Gorge Tunnels are now colored depending on the team. If there’s more than 2 PGs it will switch to lines with animated arrows.
- [265] Parasited players display their name yellow for teammates and spectators.

=================
Past NS2+ fixes now included in vanilla NS2:
=================
- [274] Fixed scoreboard hiding the GUIHoverMenu every frame as long as the scoreboard wasn't up.
- [274] Fixed jetpacks left behind by dead marines not dissolving with the body on death.
- [274] Fixed Medpacks/Ammo/Catpacks not showing the pickup icons.
- [272] Fixed server crash related to picking up a jetpack and a weapon at the same time.
- [272] Fixed kill feed being obscured by the death screen fade to black.
- [270] Fixed players having voice communication cut off while entering or exiting commander mode.
- [270] Fixed occasional error when attempting to enter the Mods menu.
- [268] Fixed bug that made trigger volumes bigger than their representation in the editor. This affected some map locations (power node issues).
- [268] Fixed bug where the Commander would log out attacking.
- [267] Made location text for marines left aligned so long location names can fit in the UI
- [267] Fixed Bonewall not having pre-drop range.
- [267] Fixed bug where Shotguns and Exo Minigun didn't shoot through soft targets.
- [267] Fixed drifters trying to build structures they can't and fake-building them forever.
- [266] Fixed sentries not being able to be dropped until the first sentry battery is finished.
- [266] Fixed scoreboard not showing Spectators to players on teams.
- [266] Fixed commander selection bug that made buildings selected with hotgroups not respond properly sometimes.
- [266] Fixed lights staying red if the power node was under attack (infestation).
- [266] Fixed bug where damage numbers wouldn't show the damage done in the killing blow.
- [265] Fixed skulk jump sound loudness (50% reduced). 
- [265] Fixed skulk growl sound when walking.
- [265] Fixed inactive/unbuilt structures not blinking red when under attack.
- [265] Fixed alien structures not blinking red when uncysted.
