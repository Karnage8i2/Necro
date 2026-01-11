-- Phase 1: Advanced Settings Module for Necromancer Rotation
local my_utility = require("my_utility/my_utility")

local advanced_settings = {
    -- Health Threshold Casting settings
    health_threshold = {
        enabled = checkbox:new(true, get_hash(my_utility.plugin_label .. "health_threshold_enabled")),
        blood_mist_hp = slider_float:new(0.0, 1.0, 0.50, get_hash(my_utility.plugin_label .. "health_blood_mist_hp")),
        bone_storm_hp = slider_float:new(0.0, 1.0, 0.40, get_hash(my_utility.plugin_label .. "health_bone_storm_hp")),
    },
    
    -- Elite/Boss Priority Mode settings
    elite_boss_priority = {
        enabled = checkbox:new(false, get_hash(my_utility.plugin_label .. "elite_boss_priority_enabled")),
        -- Spells that should only cast on elite/boss when enabled
        priority_spells = {
            "bone_spirit",
            "army_of_the_dead",
            "iron_maiden",
            "decrepify"
        }
    },
    
    -- Essence Management settings
    essence_management = {
        enabled = checkbox:new(true, get_hash(my_utility.plugin_label .. "essence_management_enabled")),
        min_essence_percent = slider_float:new(0.0, 1.0, 0.30, get_hash(my_utility.plugin_label .. "essence_min_percent")),
        -- Expensive spells that require essence check
        expensive_spells = {
            bone_spear = 25,
            bone_spirit = 40,
            blood_lance = 30,
            blood_surge = 30,
        }
    },
    
    tree_node = tree_node:new(1),
}

-- Render the advanced settings menu
function advanced_settings.render_menu()
    if advanced_settings.tree_node:push("Advanced Settings [Phase 1]") then
        
        -- Health Threshold Casting
        if advanced_settings.tree_node:push("Health Threshold Casting") then
            advanced_settings.health_threshold.enabled:render("Enable Health-Based Defensive Casts", 
                "Automatically cast defensive spells when health drops below threshold")
            
            if advanced_settings.health_threshold.enabled:get() then
                advanced_settings.health_threshold.blood_mist_hp:render("Blood Mist HP Threshold", 
                    "Cast Blood Mist when health drops below this % (overrides spell-specific setting)", 2)
                advanced_settings.health_threshold.bone_storm_hp:render("Bone Storm HP Threshold", 
                    "Cast Bone Storm when health drops below this %", 2)
            end
            advanced_settings.tree_node:pop()
        end
        
        -- Elite/Boss Priority Mode
        if advanced_settings.tree_node:push("Elite/Boss Priority Mode") then
            local spell_list = table.concat(advanced_settings.elite_boss_priority.priority_spells, ", ")
            advanced_settings.elite_boss_priority.enabled:render("Enable Elite/Boss Priority", 
                "Reserve certain powerful spells only for elite and boss enemies. Priority spells: " .. spell_list)
            
            advanced_settings.tree_node:pop()
        end
        
        -- Essence Management
        if advanced_settings.tree_node:push("Essence Management") then
            local spell_costs = {}
            for spell, cost in pairs(advanced_settings.essence_management.expensive_spells) do
                table.insert(spell_costs, spell .. " (" .. cost .. ")")
            end
            local costs_text = "Expensive spells: " .. table.concat(spell_costs, ", ")
            
            advanced_settings.essence_management.enabled:render("Enable Essence Management", 
                "Don't cast expensive spells if essence is below threshold. " .. costs_text)
            
            if advanced_settings.essence_management.enabled:get() then
                advanced_settings.essence_management.min_essence_percent:render("Min Essence Reserve %", 
                    "Keep at least this % of essence for primary damage spells", 2)
            end
            advanced_settings.tree_node:pop()
        end
        
        advanced_settings.tree_node:pop()
    end
end

-- Check if health threshold requires defensive spell casting
function advanced_settings.should_cast_defensive_spell(spell_name)
    if not advanced_settings.health_threshold.enabled:get() then
        return false
    end
    
    local local_player = get_local_player()
    if not local_player then
        return false
    end
    
    local current_hp = local_player:get_current_health()
    local max_hp = local_player:get_max_health()
    local hp_percent = current_hp / max_hp
    
    if spell_name == "blood_mist" then
        return hp_percent <= advanced_settings.health_threshold.blood_mist_hp:get()
    elseif spell_name == "bone_storm" then
        return hp_percent <= advanced_settings.health_threshold.bone_storm_hp:get()
    end
    
    return false
end

-- Check if target is valid for elite/boss priority spells
function advanced_settings.check_elite_boss_priority(spell_name, target)
    if not advanced_settings.elite_boss_priority.enabled:get() then
        return true -- Priority mode disabled, allow all targets
    end
    
    -- Check if this spell is in the priority list
    local is_priority_spell = false
    for _, priority_spell in ipairs(advanced_settings.elite_boss_priority.priority_spells) do
        if spell_name == priority_spell then
            is_priority_spell = true
            break
        end
    end
    
    if not is_priority_spell then
        return true -- Not a priority spell, allow all targets
    end
    
    -- Priority spell - only allow on elite or boss
    if not target then
        return false
    end
    
    return target:is_elite() or target:is_boss()
end

-- Check if player has enough essence for expensive spell
function advanced_settings.check_essence_cost(spell_name)
    if not advanced_settings.essence_management.enabled:get() then
        return true -- Essence management disabled, allow cast
    end
    
    local essence_cost = advanced_settings.essence_management.expensive_spells[spell_name]
    if not essence_cost then
        return true -- Not an expensive spell, allow cast
    end
    
    local local_player = get_local_player()
    if not local_player then
        return false
    end
    
    local current_resource = local_player:get_primary_resource_current()
    local max_resource = local_player:get_primary_resource_max()
    
    if max_resource == 0 then
        return true -- Avoid division by zero
    end
    
    local resource_percent = current_resource / max_resource
    local min_reserve = advanced_settings.essence_management.min_essence_percent:get()
    
    -- Check if we have enough essence above the reserve threshold
    local available_essence = (resource_percent - min_reserve) * max_resource
    
    return available_essence >= essence_cost
end

return advanced_settings
