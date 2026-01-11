-- build_profiles.lua
-- Module for managing different Necromancer build profiles

local my_utility = require("my_utility/my_utility")

-- Build profile configurations
local build_profiles = {
    Default = {
        name = "Default",
        description = "All skills enabled based on menu settings",
        enabled_spells = "all", -- special value indicating all spells
    },
    Golem = {
        name = "Golem",
        description = "Golem-focused build with supporting skills",
        enabled_spells = {
            "golem_control",
            "raise_skeleton",
            "corpse_explosion",
            "corpse_tendrils",
            "decrepify",
            "blood_mist",
            "bone_spear",
            "bone_prison",
            "hemorrhage",
            "reap",
            "soulrift",
            "decompose",
        },
    },
    Shadowblight = {
        name = "Shadowblight",
        description = "Blight and shadow damage focused build",
        enabled_spells = {
            "blight",
            "decrepify",
            "corpse_tendrils",
            "blood_mist",
            "bone_storm",
            "reap",
            "hemorrhage",
            "raise_skeleton",
            "golem_control",
            "soulrift",
        },
    },
}

-- Get available profile names for menu
local function get_profile_names()
    local names = {}
    for profile_name, _ in pairs(build_profiles) do
        table.insert(names, profile_name)
    end
    table.sort(names)
    return names
end

-- Get profile by name
local function get_profile(profile_name)
    return build_profiles[profile_name]
end

-- Check if a spell is enabled in the current profile
local function is_spell_enabled_in_profile(spell_module_name, profile_name)
    local profile = get_profile(profile_name)
    
    if not profile then
        return true -- If profile not found, enable all
    end
    
    if profile.enabled_spells == "all" then
        return true -- All spells enabled
    end
    
    -- Check if spell is in the profile's enabled list
    for _, enabled_spell in ipairs(profile.enabled_spells) do
        if enabled_spell == spell_module_name then
            return true
        end
    end
    
    return false
end

-- Build profile menu state
local menu_elements = {
    profile_combo = combo_box:new(0, get_hash(my_utility.plugin_label .. "build_profile_combo")),
}

-- Get current selected profile name
local function get_current_profile()
    local profile_names = get_profile_names()
    local selected_index = menu_elements.profile_combo:get()
    
    -- Ensure Default is first in the list
    local ordered_names = {"Default"}
    for _, name in ipairs(profile_names) do
        if name ~= "Default" then
            table.insert(ordered_names, name)
        end
    end
    
    -- Convert 0-based combo box index to 1-based Lua array index
    if selected_index >= 0 and selected_index < #ordered_names then
        local lua_index = selected_index + 1
        return ordered_names[lua_index]
    end
    
    return "Default"
end

-- Render build profile menu
local function render_menu()
    -- Build profile names list for combo box
    local profile_names = get_profile_names()
    
    -- Ensure Default is first
    local ordered_names = {"Default"}
    for _, name in ipairs(profile_names) do
        if name ~= "Default" then
            table.insert(ordered_names, name)
        end
    end
    
    menu_elements.profile_combo:render("Build Profile", ordered_names, "Select which build profile to use")
end

return {
    build_profiles = build_profiles,
    get_profile_names = get_profile_names,
    get_profile = get_profile,
    is_spell_enabled_in_profile = is_spell_enabled_in_profile,
    get_current_profile = get_current_profile,
    render_menu = render_menu,
    menu_elements = menu_elements,
}
