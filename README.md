# Race Victory Script — Launch Assist

A legitimate, no-cheat companion script for Roblox drag racing that helps you time your launch at the starting line. It does NOT control your vehicle, give you speed, or modify the game—it only displays a visual countdown on your screen so you can react consistently to the start lights. This is a client-side timing aid, not an auto-win tool, and it respects Roblox ToS by never injecting or manipulating the game state. The script works by monitoring the color of start-light parts in the workspace and flashing a "GO!" indicator when the green light appears, with configurable delays and color detection for flexibility across different game versions.

## Install

1. Copy the `LaunchAssist.client.lua` file into your Roblox Studio place.
2. Navigate to **StarterPlayer** in the Explorer panel.
3. Expand **StarterPlayerScripts** (create it if it doesn't exist).
4. Right-click on **StarterPlayerScripts** and select **Insert Object** → **LocalScript**.
5. Replace the default LocalScript content with the code from `LaunchAssist.client.lua`.

## Use

1. Open `LaunchAssist.client.lua` in Studio's script editor.
2. Adjust the `CONFIG` table at the top if needed:
   - Set `StartLightPath` to the exact hierarchy path of the start-light object (e.g., `"Map.StartLights"`). Leave `""` for automatic detection.
   - Modify `GreenLightColorKey` or `RedLightColorKey` if the game uses different colors.
   - Set `GoDelaySeconds` to add extra reaction time after green is detected.
   - Keep `ShowDebug = true` to see detection results in the Output console.
3. Play the game in Roblox Studio test mode or in a live server.
4. Drive to the starting line. The script activates automatically.
5. Watch for the "GO!" flash and launch at that exact moment.
6. Use the Output console messages to fine-tune color detection if lights aren't recognized.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/d845c09f-efdf-4c9d-9964-eb63acad0aa5?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=d845c09f-efdf-4c9d-9964-eb63acad0aa5
