local my_utility = require("my_utility/my_utility");

local menu_elements_soulrift = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_soulrift_base")),
    min_enemies_aoe       = slider_int:new(0, 30, 3, get_hash(my_utility.plugin_label .. "min_enemies_soulrift_aoe")),
    aoe_range             = slider_float:new(0.0, 15.0, 8.0, get_hash(my_utility.plugin_label .. "aoe_range_soulrift")),
    min_cast_range        = slider_float:new(0.0, 20.0, 0.0, get_hash(my_utility.plugin_label .. "min_cast_range_soulrift")),
}

local function menu()
    
    if menu_elements_soulrift.tree_tab:push("Soulrift") then
        menu_elements_soulrift.main_boolean:render("Enable Spell", "")
 
        if menu_elements_soulrift.main_boolean:get() then
            menu_elements_soulrift.min_enemies_aoe:render("Min Enemies for AoE", "Minimum enemies around to cast (0 = always cast)")
            menu_elements_soulrift.aoe_range:render("AoE Detection Range", "Range to detect enemies for AoE casting", 1)
            menu_elements_soulrift.min_cast_range:render("Min Cast Range", "Minimum distance to target before casting (0 = no minimum)", 1)
        end

        menu_elements_soulrift.tree_tab:pop()
    end
end

local spell_id_soulrift = 1644584
local next_time_allowed_cast = 0.0;
local soulrift_spell_data = spell_data:new(
    1.0,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    1.0,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_soulrift,          -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local function logics(target)

    local menu_boolean = menu_elements_soulrift.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_soulrift);

    if not is_logic_allowed then
        return false;
    end;

    -- Check minimum cast range
    local min_cast_range = menu_elements_soulrift.min_cast_range:get()
    if min_cast_range > 0 then
        local player_pos = get_player_position()
        local target_pos = target:get_position()
        local distance = player_pos:dist_to(target_pos)
        
        if distance < min_cast_range then
            return false;
        end
    end

    -- AoE logic: Check if enough enemies around
    local min_enemies = menu_elements_soulrift.min_enemies_aoe:get()
    if min_enemies > 0 then
        local player_pos = get_player_position()
        local aoe_range = menu_elements_soulrift.aoe_range:get()
        local area_data = target_selector.get_most_hits_target_circular_area_light(player_pos, aoe_range, aoe_range, false)
        local units = area_data.n_hits
        
        if units < min_enemies then
            return false;
        end
    end

    local target_position = target:get_position();

    if cast_spell.target(target, soulrift_spell_data, false) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;
        
        console.print("Necro Plugin, Casted Soulrift");
        return true;
    end

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
