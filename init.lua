-- mods/luadebug/init.lua

print("[luadebug] Mod loaded. For help, use /help dprint or other /help d* commands.")

minetest.register_privilege("luadebug", {
    description = "Allows access to Luadebug commands.",
})

minetest.register_chatcommand("dprint", {
    privs = {luadebug = true},
    description = "Logs a message to the server console and chat.",
    func = function(name, param)
        if not param or param == "" then
            return false, "Usage: /dprint <message>"
        end
        local msg = "[DPRINT] " .. param
        minetest.log(msg)
        minetest.chat_send_player(name, msg)
        print(msg)
        return true
    end,
})

minetest.register_chatcommand("dget", {
    privs = {luadebug = true},
    description = "Gets the value of a global variable or expression.",
    func = function(name, param)
        if not param or param == "" then
            return false, "Usage: /dget <variable_path>"
        end

        local success, value_or_error = pcall(function()
            return assert(load("return " .. param))()
        end)

        local result_msg
        if success then
            local type_info = type(value_or_error)
            if type_info == "table" then
                result_msg = "Type: table | Address: " .. tostring(value_or_error) .. " (Table contents not fully displayed)"
            elseif type_info == "function" then
                result_msg = "Type: function | Address: " .. tostring(value_or_error)
            elseif type_info == "userdata" then
                local meta_str = ""
                local mt = getmetatable(value_or_error)
                if mt then
                    local output_table = {}
                    for k, v in pairs(mt) do
                        table.insert(output_table, tostring(k) .. ": " .. tostring(v))
                    end
                    meta_str = "{ " .. table.concat(output_table, ", ") .. " }"
                end
                result_msg = "Type: userdata | Metatable: " .. meta_str
            else
                result_msg = "Value: " .. tostring(value_or_error) .. " (Type: " .. type_info .. ")"
            end
        else
            result_msg = "Error evaluating expression: " .. value_or_error
        end

        minetest.chat_send_player(name, "[DGET] " .. result_msg)
        minetest.log("[DGET] " .. result_msg)
        return true
    end,
})

minetest.register_chatcommand("deval", {
    privs = {luadebug = true},
    description = "Executes arbitrary Lua code on the server. USE WITH EXTREME CAUTION!",
    func = function(name, param)
        if not param or param == "" then
            return false, "Usage: /deval <lua_code>"
        end

        local success, result_or_error = pcall(function()
            local func = load(param, "deval_chunk", "t", _G)
            if not func then error("Failed to load code.") end
            return {func()}
        end)

        local output_msg = ""
        if success then
            if result_or_error and #result_or_error > 0 then
                local results_str = {}
                for _, v in ipairs(result_or_error) do
                    table.insert(results_str, tostring(v))
                end
                output_msg = "Result: " .. table.concat(results_str, ", ")
            else
                output_msg = "Code executed successfully (no return value)."
            end
        else
            output_msg = "Error executing code: " .. result_or_error
        end

        minetest.chat_send_player(name, "[DEVAL] " .. output_msg)
        minetest.log("[DEVAL] " .. output_msg)
        return true
    end,
})

minetest.register_chatcommand("dclient", {
    privs = {luadebug = true},
    description = "Executes arbitrary Lua code on a player's client. USE WITH EXTREME CAUTION!",
    func = function(name, param)
        if not param or param == "" then
            return false, "Usage: /dclient <player_name> <lua_code>"
        end

        local parts_match = param:match("^([^ ]+)%s*(.*)$")
        if not parts_match then
            return false, "Usage: /dclient <player_name> <lua_code>"
        end

        local target_name = parts_match
        local code_to_run = parts_match:match("^[^ ]+%s*(.*)$")

        if not code_to_run or code_to_run == "" then
            return false, "Usage: /dclient <player_name> <lua_code>"
        end

        local target_player = minetest.get_player_by_name(target_name)
        if not target_player then
            return false, "Player '" .. target_name .. "' not found."
        end

        minetest.chat_send_player(name, "[DCLIENT] Sending code to " .. target_name .. ": " .. code_to_run)
        minetest.log("[DCLIENT] Sending code to " .. target_name .. ": " .. code_to_run)

        local success, err = pcall(minetest.send_cmd_to_player, target_player, "lua ".. code_to_run)
        if not success then
            return false, "Error sending client command: " .. err
        end

        return true, "Client command sent to " .. target_name
    end,
})

minetest.register_chatcommand("dplayer", {
    privs = {luadebug = true},
    description = "Shows information about a specific player or self.",
    func = function(name, param)
        local target_player_name = param
        local self_info = false

        if param == "self" or param == "" then
            target_player_name = name
            self_info = true
        end

        local player = minetest.get_player_by_name(target_player_name)
        if not player then
            return false, "Player '" .. target_player_name .. "' not found."
        end

        local pos = player:get_pos()
        local hp = player:get_hp()
        local max_hp = player:get_max_hp()
        local satiety = player:get_satiety()
        local breath = player:get_breath()
        local max_breath = player:get_max_breath()
        local is_creative_enabled = minetest.is_creative_enabled_for_player(target_player_name)
        local is_admin = minetest.check_player_privs(target_player_name, {server = true})
        local all_privs_table = minetest.get_player_privs(target_player_name)
        local all_privs_str = ""
        if all_privs_table then
            local privs_list = {}
            for priv, state in pairs(all_privs_table) do
                if state then
                    table.insert(privs_list, priv)
                end
            end
            all_privs_str = table.concat(privs_list, ", ")
        end


        local msg = "Player '" .. target_player_name .. "' Info:\n" ..
                    "  Position: X=" .. string.format("%.2f", pos.x) .. ", Y=" .. string.format("%.2f", pos.y) .. ", Z=" .. string.format("%.2f", pos.z) .. "\n" ..
                    "  HP: " .. hp .. "/" .. max_hp .. "\n" ..
                    "  Satiety: " .. string.format("%.2f", satiety) .. "\n" ..
                    "  Breath: " .. breath .. "/" .. max_breath .. "\n" ..
                    "  Creative Mode: " .. tostring(is_creative_enabled) .. "\n" ..
                    "  Server Admin: " .. tostring(is_admin) .. "\n" ..
                    "  All Privileges: " .. (all_privs_str == "" and "None" or all_privs_str)

        minetest.chat_send_player(name, msg)
        minetest.log("[DPLAYER] " .. msg)
        return true
    end,
})

minetest.register_chatcommand("dservinfo", {
    privs = {luadebug = true},
    description = "Shows general server information.",
    func = function(name, param)
        local server_name = minetest.get_server_properties().name or "Unnamed Server"
        local player_count = minetest.get_player_count()
        local map_name = minetest.get_current_map_name()
        local game_name = minetest.get_game_name()
        local server_version = minetest.get_version().string
        local uptime = minetest.get_uptime()

        local days = math.floor(uptime / 86400)
        local hours = math.floor((uptime % 86400) / 3600)
        local minutes = math.floor(((uptime % 86400) % 3600) / 60)
        local seconds = math.floor(((uptime % 86400) % 3600) % 60)

        local uptime_str = string.format("%d days, %d hours, %d minutes, %d seconds", days, hours, minutes, seconds)

        local msg = "Server Info:\n" ..
                    "  Name: " .. server_name .. "\n" ..
                    "  Players Online: " .. player_count .. "\n" ..
                    "  Map Name: " .. map_name .. "\n" ..
                    "  Game Name: " .. game_name .. "\n" ..
                    "  Server Version: " .. server_version .. "\n" ..
                    "  Uptime: " .. uptime_str

        minetest.chat_send_player(name, msg)
        minetest.log("[DSERVINFO] " .. msg)
        return true
    end,
})

print("[luadebug] Mod initialized successfully.")
