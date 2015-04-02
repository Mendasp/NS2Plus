NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
- /04/2015
	- Adjusted options menu elements so they all use the same space.
	- Changed the options menu to only display the reset to default button if the value is different than default.
	- The options menu will now hide sub-options that depend on a main setting if it's disabled (Per-team sensitivies/FOV, Vanilla Hitsounds Pitch).
	- Made custom minimap colors appear correctly for the marine minimap on the top left.

- 01/04/2015
	- Added accuracies without Onos hits to the Last Life Stats.
	- Added a color picker for all the options with customizable colors.
	- End games stats now uses different commader icons to distinguish the Commander with most commanding time.
	- Enabled last life stats and the ability to check the previous round stats during PreGamePlus.
	- Fixed tooltip still being visible when closing the stats while hovering the Commander badge.
	- Fixed Stomp not showing up properly on the personal weapon stats.

- 29/03/2015
	- Fixed drifter abilities requiring to click empty space to be used.
	- Added outline to the wrench icon if you have a welder.
	- Added option to disable the new wrench icon coloring and revert to the previous behavior. Available in Misc. tab.
	- Reduced size of last life stats.
	- Fixed Spurs not being tracked in the tech log.
	- Fixed upgraded Hives counting as separate buildings lost.

- 28/03/2015
	- Fixed wrench icon not being color coded if you had a welder.
	- Made dropped welders display the outline even if you already have a welder for easy recycling.

- 27/03/2015
	- Added played time and Commander time to the stats UI.
	- Added Kill Graph to end game stats.
	- Player stats are now kept when switching teams so one player can show up on both teams.
	- Last life stats now use the same graphics style as the End game stats.
	- Added "Weapon Inventory" option to customize the behavior for the inventory, the options allow you to have it always on, disabled, or showing weapon ammo for marines. Available in HUD tab.
	- Added option to display a welder icon under the armor and weapon levels when there's one equipped. Available in HUD tab.
	- Renamed "Minimal Nameplates" option to "Nameplate style" and added a third style to show only the bars. The options now are: "Default", "Percentages", "Bars only".
	- Changed crosshair resolution scaling option with a slider that allows users to choose scaling themselves (from 1% to 200%).
	- The Classic Ammo and HUD Bars options now use the same code to fetch weapon info. They now also display mines and grenades.
	- Added "Request Weld" and other voiceover menu options to the Bindings menu.
	- Added range circles for Mucous, Enzyme, Hallucination Cloud, Nutrient Mist and Rupture.
	- Hovering over the player cards in Insight will display their current HP/AP values.
	- The use key will toggle displaying HP/AP values over the healthbars in Insight.
	- Color coded marine wrench icon for teammates and buildings depending on the damage received.
	- Moving the mouse over the tech icons in Insight will now display the tech name.
	- NS2+ console output will now wrap the text correctly on low resolutions.
	- NS2+ console commands now allow you to reset settings to their individual defaults.
	- Improved tooltips, some of them now include an example image for the NS2+ options.
	- Fixed vanilla bug where server browser tooltips could get stuck on the screen.
	- Removed message about players not being able to join when detecting mod updates if the server has a mod backup server enabled. Now it will just display the mods updated once.

- 19/03/2015
	- Classic Ammo now supports the Exo.
	- Added Tech Log and RT Graph to end game stats.

- 16/03/2015
	- Added a structure counter (current/max) for the Gorge building "weapon" inside the energy circle.
	- Added player and structure damage stats per-weapon to the end stats.
	
- 12/03/2015
	- Added button to NS2+ options menu to reset values individually.
	- Replaced Changelog button that noone ever noticed with "Reset all NS2+ settings" in the NS2+ options menu.
	- Added console command to export NS2+ settings to a text file (plus_export). The file will be in %APPDATA%\Natural Selection 2\NS2Plus\ExportedSettings.txt
	- Added server option to disable all connections to Hive. Disabling this will break the Force Even Teams vote, badges, player skill display and player skill reporting. It's an option purely just in case Hive is acting up. Servers can toggle it with "sv_plus hiveconnection true/false" in console or modifying NS2PlusServerConfig.json.

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
