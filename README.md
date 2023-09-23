# Factorio-Inbuilt-Lighting



Features
---------

- Options to add a free inbuilt light to power poles. It can either use no power and run without a power connection, or have a configurable power usage.
- Optionally can add a free inbuilt light to turrets. Various configuration options.
- Is a pure QOL mod designed for streamers, YouTube or anyone who wants to be able to see their base early game when zoomed out.
- Blueprint friendly as they are regular power poles, so no modded entities in your exported Blueprint, just no lights either.



Options
---------

- The size of the light for each type of power pole is controlled by the mod settings for it's powering range and connection distance. The largest size between the powered ranged and connection distance is used. These settings allow from none to 100+ percent of each range to be used to set the light size. Defaults to 100% powered range, 0% connection distance.
- The mod can light up turrets (default off). If the feature is enabled it will light up the building plus the set number of tiles around the edge from 0 upwards. Note, large quantities of turrets (500+) with this feature enabled can impact UPS and cause game slowdown. Turn this feature off later in the game when turrets have power and power pole lighting is suitable.
- Option to add a power usage per light (defaults to no power usage). 0 power usage will work when not on a power network. Anything above 0 watts requires active electricity on a power network like regular lamps. There will never be any low power or no electric connection icons shown for the inbuilt lights regardless of the power usage setting.
- Option to require a technology to enable inbuilt lighting (defaults not required).
- Other minor options to fine tune the behavior and appearance of the lights.



Limitations
-----------

- The maximum lighted radius is limited to 75 due to the Factorio game engine.
- Lights in Factorio illuminate the in-game picture you see and so tall building pictures may be half in light and half out, despite their footprint being fully within the lighted area.
- If the lights have a power usage set then the Electric Network Info screen will have 1 listing for each radius of light present (1 entry per power pole type). This is unavoidable in the Factorio engine.



Mod Compatibility
-------------

The mod doesn't change or replace buildings or power poles in any way and so if the mod is removed the game will just remove the inbuilt lights and not affect existing power poles.

The mod should be compatible with all other mods that don't move entities around the map. It reacts when entities are placed in the game via standard actions. No changes to any base or other mod entities occur. Hidden lamps are created for all sizes between 1 and 75 tiles at game start.

Support for mods that place & move entities in the map:
- Creative Mode mod - Instant Construction & Deconstruction
- Picker Extended - Dollies feature

Should mod compatibility issues occur the command "inbuilt-lighting-reset" is included to tidy up any legacy issues that had occurred prior to support being added. It removes and then re-adds all inbuilt lighting entities on the map.
