local my_utility = require("my_utility/my_utility");

local menu_elements_decompose = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_decompose_base")),
}

local function menu()
    
    if menu_elements_decompose.tree_tab:push("Decompose") then
        menu_elements_decompose.main_boolean:render("Enable Spell", "")
 
        menu_elements_decompose.tree_tab:pop()
    end
end

local spell_id_decompose = 463175
local next_time_allowed_cast = 0.0;
local decompose_spell_data = spell_data:new(
    1.0,                        -- radius
    10.0,                       -- range
    0.10,                       -- cast_delay
    1.0,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_decompose,         -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local function logics(target)

    local menu_boolean = menu_elements_decompose.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_decompose);

    if not is_logic_allowed then
        return false;
    end;

    local target_position = target:get_position();

    if cast_spell.target(target, decompose_spell_data, false) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;
        
        console.print("Necro Plugin, Casted Decompose");
        return true;
    end

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}
