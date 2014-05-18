NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
- /05/2014 (Build 265):
	- Ammo, medpacks and catpacks now ignore the vertical element for pickup by marines. This should mitigate some of the problems commanders have with weird geometry in levels blocking their drops. (Thanks kmg!)
	- Shift Echo now updates the buttons faster when trying to echo upgrade chambers, and updates immediately after the shift is echoed to a new location (Thanks remi.D!)

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

- 09/05/2014 (Build 265):
	- Added pickup expire bar. You can now see how much time left you have to pick up things on the ground. Default is off. Available in the Misc. tab.
	- Fixed lights staying red if the power node was under attack (infestation). (Thanks remi.D!)

- 08/05/2014 (Build 265):
	- When Autopickup is enabled Welders, Mines and Pistols will no longer show a pickup hint when running over them. (Thanks remi.D)
	- Autopickup will now pick up a weapon more quickly if it was not the last weapon you dropped. (Thanks remi.D)
	- Fixed autopickup better weapons getting stuck in a loop of weapon switching sometimes. (Thanks remi.D)
	- Fixed commander selection bug that made buildings selected with hotgroups not respond properly sometimes.
	
- 07/05/2014 (Build 265):
	- Added "impulse" command to trigger voice overs without using the request menu. (Thanks remi.D!)
	- Added showing number of connecting players to the scoreboard. (Thanks remi.D!)
	- Added showing if a marine has a jetpack to the scoreboard. (Thanks Wyzcrack and remi.D!)
	- Fixed scoreboard not showing spectators to players on teams. (Thanks Wyzcrack and remi.D!)
	- Extra checks in main menu functionality so it doesn't break on mod updates.
	- Commanders can now see building ranges before dropping them.
	- Added Lerk deaths to Insight alerts.
	- Added hints to option inputs.
	- Added autopickup better primary weapon option (default off). Available in Misc. tab.
	- Reset autopickup options so they default to off.

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
