NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
- //2015
	- Added button to NS2+ options menu to reset values individually.
	- Replaced Changelog button that noone ever noticed with "Reset all NS2+ settings" in the NS2+ options menu.
	- Added console command to export NS2+ settings to a text file (plus_export). The file will be in %APPDATA%\Natural Selection 2\NS2Plus\ExportedSettings.txt

- 18/02/2015
	- Fixed expiration bar being visible for items without an expiration time.
	- Fixed mouse cursor disappearing for Commanders on round end.
	- Added ability to sort by columns in the stats UI.

- 04/02/2015
	- Added option to enable or disable server-side hit effects. Available in Visual tab.
	- Added option to choose the order of the stats UI from Team first to Personal first. Available in Misc tab.
	- Fixed bug where scroll bar could be stuck on the screen if the game restarted immediatly after round end.

- 03/02/2015
	- Added a way for server operators to disable showing the team stats section of the end game stats. Servers can toggle it with "sv_plus endstatsteambreakdown true/false" in console or modifying NS2PlusServerConfig.json.
	- Adjusted stats UI colors and added a few sounds.
	- Changed stats UI so it only shows up when tapping the request key instead of whenever it was released.
	- Reworked average skill display so it looks more integrated with the scoreboard.
	- Fixed bug with the profile option in the stats menu where it wouldn't react when clicking.
    
- 31/01/2015
	- Fixed bug where opening the stats before they'd show up automatically at end-round would leave the mouse cursor stuck on the screen.
	- Fixed edge case where if the only stats available were Marine Commander drops, the client would not display any stats even after receiving them.
	- The Commanders now show up in the final stats regardless of their field player stats.
	- Made the stats UI highlight your own row.
	- Added a way for server operators to disable autoshowing the end game stats (clients can still bring them up with the Request/Voiceover key, default X). Servers can toggle it with "sv_plus autodisplayendstats true/false" in console or modifying NS2PlusServerConfig.json.
	
- 29/01/2015
	- Fixed bug where opening/closing the scoreboard would reset the HUD.
	- Changed the way the stats were sorted from Accuracy first to Kills first.
	- Improved readability of the stats UI on resolutions lower than 1920x1080.
	- Added ability to check the player profiles from the stats UI.
	- Made the stats UI show on top of the rest of the UI.
	- Fixed problems with the cursor staying on screen after seeing the stats UI.

- 23/01/2015
	- Fixed Average/Total stats being covered up for Marines.
	- Fixed Average/Total stats only showing NaN%.
	- Fixed cursor disappearing when looking at the stats as a Spectator.
	- Fixed not being able to bring up the stats mid-round as Spectator.
	- Fixed script error when killing an Exo with Bilebomb.
	- Fixed cursor still being visible after logging out of the CC after seeing the stats UI.

- 22/01/2015
	- Updated for build 273.
	- Revamped end-game stats UI.
	- Reset the Alien Vision setting as the Vanilla AV has changed and added the old Fanta Vision to the list of selectable AVs.

- 18/12/2014
	- Updated for build 272.
	- Fixed unresponsive menu bug. (Thanks Samusdroid!)
	- Fixed bug that would reset certain settings to default every time NS2+ updated.
	- Added console message when NS2+ force-resets a setting because of updated defaults.

- 09/12/2014
	- Added ability to click on a player's row in the scoreboard to check their Steam/Hive/NS2Stats profiles.
	- Added option to mute Text chat.
	- Added icon to the scoreboard indicating if someone is your friend on Steam.
	- Made it so the scoreboard shortens the player name if it overlaps.
	- Muting a player's voice/text chat will last 6 hours so it's persistent across map changes.
	- Rookies will always show the "(rookie)" tag in chat even if they're not in your own team.

- 15/11/2014
	- Made the pregame skill display compatible with Pregame Plus.

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
