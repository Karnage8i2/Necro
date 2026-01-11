# Necromancer Rotation - Enhanced Edition

## Version 2.0 - Build Profiles + Equipped Skills

This enhanced version of the Necromancer rotation plugin adds two major features inspired by the Sorcerer build structure:

### New Features

#### 1. Build Profiles
Select from pre-configured build profiles that enable only relevant spells for specific playstyles:

- **Default**: All skills enabled based on individual menu settings (backward compatible)
- **Golem**: Golem-focused build using golems as main damage source with supporting skills
- **Shadowblight**: Blight and shadow damage focused build with curse synergies

**How to use:**
1. Open the plugin menu
2. Select your desired build from the "Build Profile" dropdown
3. The rotation will automatically filter spells based on the selected profile

#### 2. Equipped Skills Detection
Automatic detection of skills on your skill bar - only spells equipped will be cast during rotation.

**How it works:**
1. The plugin automatically detects your equipped spells from the skill bar
2. Only spells that are equipped will be cast during rotation
3. No manual configuration needed - it's always active

**Menu Organization:**
- **Equipped Skills** section: Shows all skills currently on your skill bar
- **Ultra Instinct** section: Shows all skills NOT on your skill bar
- This keeps the menu organized and helps you see at a glance which skills are active

### Features Combined
Both features work together:
- Select a build profile to focus on a specific playstyle
- Equipped skills detection ensures only your equipped abilities are used
- Menu is automatically organized based on your skill bar
- Individual spell settings in the menu still apply for fine-tuning

### Backward Compatibility
- Uses the "Default" profile by default, maintaining original behavior
- All existing spell configurations are preserved
- No changes required to existing spell modules

### Technical Implementation
Following the Sorcerer rotation structure:

1. **equipped_skills.lua**: Module for detecting and managing equipped skills
   - Auto-detects spells on skill bar using `get_equipped_spell_ids()`
   - Maps spell IDs to module names
   - Provides filtering functions

2. **build_profiles.lua**: Module for managing build profiles
   - Defines multiple build configurations
   - Provides profile selection and filtering
   - Menu integration for profile selection

3. **main.lua**: Enhanced with filtering logic
   - `should_use_spell()` helper function checks both filters
   - All spell calls updated to respect filters
   - Cleaner structure inspired by Sorcerer rotation

### Spell ID Reference
The plugin tracks all Necromancer skills:
- Blood Mist (493422)
- Bone Spear (432879)
- Bone Splinters (500962)
- Corpse Explosion (432897)
- Corpse Tendrils (463349)
- Decrepify (915150)
- Hemorrhage (484661)
- Reap (432896)
- Blood Lance (501629)
- Blood Surge (592163)
- Blight (481293)
- Sever (481785)
- Bone Prison (493453)
- Iron Maiden (915152)
- Bone Spirit (469641)
- Blood Wave (658216)
- Army of the Dead (497193)
- Bone Storm (499281)
- Raise Skeleton (1059157)
- Golem Control (440463)
- Decompose (463175)
- Soulrift (1644584)

### Usage Examples

**Example 1: Golem Build**
1. Equip Golem build skills on your skill bar
2. Select "Golem" profile
3. Result: Only Golem and supporting skills that are equipped will cast

**Example 2: Custom Build**
1. Select "Default" profile
2. Equip your desired skills on the skill bar
3. Configure individual spell settings in menu
4. Result: Full customization based on your equipped skills

**Example 3: Shadowblight Build**
1. Equip Blight and shadow skills on your skill bar
2. Select "Shadowblight" profile
3. Result: Only Blight and shadow damage skills that are equipped will be used
