local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_necro = character_id == 6;
if not is_necro then
 return
end;

local menu = require("menu");
local equipped_skills = require("equipped_skills");
local build_profiles = require("build_profiles");
local advanced_settings = require("advanced_settings");

local spells =
{
    blood_mist                  = require("spells/blood_mist"),
    bone_spear                  = require("spells/bone_spear"),           
    bone_splinters              = require("spells/bone_splinters"),               
    corpse_explosion            = require("spells/corpse_explosion"),                     
    corpse_tendrils             = require("spells/corpse_tendrils"),                  
    decrepify                   = require("spells/decrepify"), 
    hemorrhage                  = require("spells/hemorrhage"),
    reap                        = require("spells/reap"),
    blood_lance                 = require("spells/blood_lance"),
    blood_surge                 = require("spells/blood_surge"),
    blight                      = require("spells/blight"),
    sever                       = require("spells/sever"),
    bone_prison                 = require("spells/bone_prison"),
    iron_maiden                 = require("spells/iron_maiden"),
    bone_spirit                 = require("spells/bone_spirit"),
    blood_wave                  = require("spells/blood_wave"),
    army_of_the_dead            = require("spells/army_of_the_dead"),
    bone_storm                  = require("spells/bone_storm"),

    raise_skeleton                  = require("spells/raise_skeleton"),
    golem_control                  = require("spells/golem_control"),
    decompose                  = require("spells/decompose"),
    soulrift                  = require("spells/soulrift"),
}

on_render_menu (function ()

    if not menu.main_tree:push("Necromancer_Karnage") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");
    
    -- Build Profile Selection
    build_profiles.render_menu();
    
    -- Advanced Settings (Phase 1)
    advanced_settings.render_menu();

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    -- Get equipped and non-equipped spells
    local equipped_modules, non_equipped_modules = equipped_skills.get_organized_spells()
    
    -- Equipped Skills Section - shows skills currently on skill bar
    if menu.equipped_skills_tree:push("Equipped Skills") then
        for _, module_name in ipairs(equipped_modules) do
            if spells[module_name] and spells[module_name].menu then
                spells[module_name].menu()
            end
        end
        menu.equipped_skills_tree:pop()
    end
    
    -- Ultra Instinct Section - shows skills NOT on skill bar
    if menu.ultra_instinct_tree:push("Ultra Instinct") then
        for _, module_name in ipairs(non_equipped_modules) do
            if spells[module_name] and spells[module_name].menu then
                spells[module_name].menu()
            end
        end
        menu.ultra_instinct_tree:pop()
    end

    menu.main_tree:pop();
    
end
)

local can_move = 0.0;
local cast_end_time = 0.0;

local blood_mist_buff_name = "Necromancer_BloodMist";
local blood_mist_buff_name_hash = blood_mist_buff_name;
local blood_mist_buff_name_hash_c = 493422;

local mount_buff_name = "Generic_SetCannotBeAddedToAITargetList";
local mount_buff_name_hash = mount_buff_name;
local mount_buff_name_hash_c = 1923;

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

-- Cache for current update cycle to avoid repeated calls (optimizes performance)
-- These values are refreshed at the beginning of each update cycle
local cached_profile = "Default"
local cached_equipped_spells = {}

-- Helper function to check if spell should be used based on filters
local function should_use_spell(spell_module_name, spell_id, target)
    -- Check build profile filter
    if not build_profiles.is_spell_enabled_in_profile(spell_module_name, cached_profile) then
        return false
    end
    
    -- Check equipped skills filter (always active - only cast spells on skill bar)
    if spell_id and cached_equipped_spells then
        if not cached_equipped_spells[spell_id] then
            return false
        end
    end
    
    -- Phase 1: Check elite/boss priority mode
    if not advanced_settings.check_elite_boss_priority(spell_module_name, target) then
        return false
    end
    
    -- Phase 1: Check essence management for expensive spells
    if not advanced_settings.check_essence_cost(spell_module_name) then
        return false
    end
    
    return true
end

local is_blood_mist = false
on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end
    
    if menu.main_boolean:get() == false then
        -- if plugin is disabled dont do any logic
        return;
    end;

    -- Cache filter settings at the start of update cycle for better performance
    cached_profile = build_profiles.get_current_profile()
    -- Always detect equipped skills to only cast spells on skill bar
    cached_equipped_spells = equipped_skills.get_equipped_spells()

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    is_blood_mist = false;
    local local_player_buffs = local_player:get_buffs();
    for _, buff in ipairs(local_player_buffs) do
        --   console.print("buff name ", buff:name());
        --   console.print("buff hash ", buff.name_hash);
          if buff.name_hash == blood_mist_buff_name_hash_c then
              is_blood_mist = true;
              break;
          end
    end

    if not my_utility.is_action_allowed() then
        return;
    end  
    

    if should_use_spell("raise_skeleton", 1059157, best_target) and spells.raise_skeleton.logics()then
        cast_end_time = current_time + 0.5;
        return;
    end;

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { true, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end

    local is_auto_play_active = auto_play.is_active();
    local max_range = 10.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   



    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local distance_sqr = best_target_position:squared_dist_to_ignore_z(player_position);

    if distance_sqr > (max_range * max_range) then            
        best_target = target_selector_data.closest_unit;
        local closer_pos = best_target:get_position();
        local distance_sqr_2 = closer_pos:squared_dist_to_ignore_z(player_position);
        if distance_sqr_2 > (max_range * max_range) then
            return;
        end
    end


    if should_use_spell("golem_control", 440463, best_target) and spells.golem_control.logics()then
        cast_end_time = current_time + 0.5;
        return;
    end;

    -- Phase 1: Priority health threshold casting for defensive spells (overrides normal rotation)
    if advanced_settings.should_cast_defensive_spell("blood_mist") then
        if should_use_spell("blood_mist", 493422, best_target) and spells.blood_mist.logics()then
            cast_end_time = current_time + 0.5;
            return;
        end;
    end;

    if advanced_settings.should_cast_defensive_spell("bone_storm") then
        if should_use_spell("bone_storm", 499281, best_target) and spells.bone_storm.logics()then
            cast_end_time = current_time + 0.2;
            return;
        end;
    end;

    -- Normal rotation priority - these only execute if health threshold wasn't triggered above
    
    if should_use_spell("blood_mist", 493422, best_target) and spells.blood_mist.logics()then
        cast_end_time = current_time + 0.5;
        return;
    end;

    if should_use_spell("decrepify", 915150, best_target) and spells.decrepify.logics()then
        cast_end_time = current_time + 0.50;
        return;
    end;  

    if should_use_spell("blood_wave", 658216, best_target) and spells.blood_wave.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("army_of_the_dead", 497193, best_target) and spells.army_of_the_dead.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if should_use_spell("corpse_tendrils", 463349, best_target) and spells.corpse_tendrils.logics()then
        cast_end_time = current_time + 0.30 
        return;
    end

    if should_use_spell("corpse_explosion", 432897, best_target) and spells.corpse_explosion.logics()then
        cast_end_time = current_time + 0.50;
        return;
    end;

    if should_use_spell("bone_spear", 432879, best_target) and spells.bone_spear.logics(best_target, entity_list)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("bone_splinters", 500962, best_target) and spells.bone_splinters.logics(best_target)then
        cast_end_time = current_time + 0.5;
        return;
    end;

    if should_use_spell("reap", 432896, best_target) and spells.reap.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("blood_lance", 501629, best_target) and spells.blood_lance.logics(best_target)then
        cast_end_time = current_time + 0.6;
        return;
    end;

    if should_use_spell("blood_surge", 592163, best_target) and spells.blood_surge.logics()then
        cast_end_time = current_time + 0.6;
        return;
    end;

    if should_use_spell("blight", 481293, best_target) and spells.blight.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("sever", 481785, best_target) and spells.sever.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("bone_prison", 493453, best_target) and spells.bone_prison.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("iron_maiden", 915152, best_target) and spells.iron_maiden.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("bone_spirit", 469641, best_target) and spells.bone_spirit.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("bone_storm", 499281, best_target) and spells.bone_storm.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if should_use_spell("hemorrhage", 484661, best_target) and spells.hemorrhage.logics(best_target)then
        cast_end_time = current_time + 0.5;
        return;
    end;

    if should_use_spell("decompose", 463175, best_target) and spells.decompose.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if should_use_spell("soulrift", 1644584, best_target) and spells.soulrift.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    -- auto play engage far away monsters
    local move_timer = get_time_since_inject()
    if move_timer < can_move then
        return;
    end;

    local is_auto_play = my_utility.is_auto_play_enabled();
    if is_auto_play then
        local player_position = local_player:get_position();
        local is_dangerous_evade_position = evade.is_dangerous_position(player_position);
        if not is_dangerous_evade_position then
            local closer_target = target_selector.get_target_closer(player_position, 15.0);
            if closer_target then
                if is_blood_mist then
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, -5.0);
                    if pathfinder.move_to_cpathfinder(move_pos) then
                        cast_end_time = current_time + 0.40;
                        can_move = move_timer + 1.5;
                        --console.print("auto play move_to_cpathfinder - 111")
                    end
                else
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, 4.0);
                    if pathfinder.move_to_cpathfinder(move_pos) then
                        can_move = move_timer + 1.5;
                        --console.print("auto play move_to_cpathfinder - 222")
                    end
                end
                
            end
        end
    end
    
end);

local draw_player_circle = false;
local draw_enemy_circles = false;

on_render(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    local player_position = local_player:get_position();
    local player_screen_position = graphics.w2s(player_position);
    if player_screen_position:is_zero() then
        return;
    end

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end    

    if draw_enemy_circles then
        local enemies = actors_manager.get_enemy_npcs()

        for i,obj in ipairs(enemies) do
        local position = obj:get_position();
        local distance_sqr = position:squared_dist_to_ignore_z(player_position);
        local is_close = distance_sqr < (8.0 * 8.0);
            -- if is_close then
                graphics.circle_3d(position, 1, color_white(100));

                local future_position = prediction.get_future_unit_position(obj, 0.4);
                graphics.circle_3d(future_position, 0.5, color_yellow(100));
            -- end;
        end;
    end


    -- glow target -- quick pasted code cba about this game

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end

    local is_auto_play_active = auto_play.is_active();
    local max_range = 10.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   

    if not best_target then
        return;
    end

    if best_target and best_target:is_enemy()  then
        local glow_target_position = best_target:get_position();
        local glow_target_position_2d = graphics.w2s(glow_target_position);
        graphics.line(glow_target_position_2d, player_screen_position, color_red(180), 2.5)
        graphics.circle_3d(glow_target_position, 0.80, color_red(200), 2.0);
    end


end);

console.print("Lua Plugin - Necromancer_Karnage - Version 2.0 (Build Profiles + Equipped Skills)");