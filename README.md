# Luadebug - A Debugging Utility Mod for Minetest
Luadebug is a powerful and versatile debugging utility mod designed to help developers and server administrators inspect, interact with, and troubleshoot their Minetest environments directly from the in-game chat. It provides essential commands for logging messages, retrieving variable values, executing arbitrary Lua code, and inspecting player and server information.
## Installation
 * Download: Get the Luadebug mod files.
 * Locate Mods Folder: Place the luadebug folder (containing init.lua and mod.conf) inside your Minetest mods/ directory.
 * Enable Mod: Launch Minetest. In the main menu, go to "Configure Game", then select your world and click "Configure". Navigate to the "Mods" tab and ensure luadebug is enabled for your world.
 * Grant Privilege: Once in-game, open the chat (T key by default) and grant yourself the necessary privilege:
   /grant <your_player_name> luadebug

## Commands
All commands require the luadebug privilege.
 * /dprint <message>
   * Logs the specified message to the server console and sends it back to your in-game chat.
   * Example: /dprint My custom debug message!
 * /dget <variable_path>
   * Retrieves and displays the value of a global variable or Lua expression. Be aware that complex tables might only show their memory address.
   * Examples:
     * /dget _G.minetest.player_count()
     * /dget _G.minetest.registered_nodes["default:dirt"]
     * /dget _G.minetest.get_current_map_name()
 * /deval <lua_code>
   * USE WITH EXTREME CAUTION! Executes arbitrary Lua code directly on the server. This command provides full server access and can be dangerous if used improperly. Only use it for debugging on trusted environments.
   * Examples:
     * /deval minetest.set_timeofday(0.5)
     * /deval return minetest.get_player_by_name("YOUR_NICK"):get_pos()
     * /deval local players = minetest.get_connected_players(); for i,p in ipairs(players) do minetest.chat_send_player(p, "Hello!") end
 * /dclient <player_name> <lua_code>
   * USE WITH EXTREME CAUTION! Sends and executes arbitrary Lua code on a specific player's client. This can be used for client-side debugging but carries significant security risks.
   * Example: /dclient PlayerName minetest.chat_send_player(minetest.localplayer, "Client-side message!")
 * /dplayer <self | name>
   * Displays detailed information about a specific player, including their position, health, satiety, breath, creative mode status, server admin status, and all granted privileges. Use self to view your own information.
   * Examples:
     * /dplayer self
     * /dplayer AnotherPlayer
 * /dservinfo
   * Shows general information about the server, such as its name, current player count, map name, game name, server version, and uptime.
   * Example: /dservinfo

## Creator
48Hz
