local my_utility = require("my_utility/my_utility");

local menu_elements_reap = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_reap_base")),
    max_range_slider      = slider_float:new(1.0, 10.0, 3.0, get_hash(my_utility.plugin_label .. "reap_max_range_slider")),
}

local function menu()
    
    if menu_elements_reap.tree_tab:push("Reap") then
        menu_elements_reap.main_boolean:render("Enable Spell", "")

        if menu_elements_reap.main_boolean:get() then
            menu_elements_reap.max_range_slider:render("Max Range", "Maximum distance to target for melee casting", 1)
        end

        menu_elements_reap.tree_tab:pop()
    end
end

local spell_id_reap= 432896
local next_time_allowed_cast = 0.0;
local reap_spell_data = spell_data:new(
    1.0,                        -- radius
    1.0,                       -- range
    0.10,                       -- cast_delay
    1.0,                       -- projectile_speed
    true,                       -- has_collision
    spell_id_reap,        -- spell_id
    spell_geometry.rectangular,    -- geometry_type
    targeting_type.skillshot     --targeting_type
)
local function logics(target)

    local menu_boolean = menu_elements_reap.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_reap);

    if not is_logic_allowed then
    return false;
    end;

    local target_position = target:get_position();
    local player_position = get_player_position();
    local distance_to_target = player_position:dist_to(target_position);
    local max_range = menu_elements_reap.max_range_slider:get();

    if distance_to_target > max_range then
        return false;
    end

    cast_spell.target(target, reap_spell_data, false)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.8;
        
    console.print("Necro Plugin, Casted reap");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}