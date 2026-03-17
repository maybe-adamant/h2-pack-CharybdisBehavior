local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib'].public

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "CharybdisBehaviorAdjustment",
    name     = "Adjust Charybdis Behavior",
    category = "RunModifiers",
    group    = "World & Combat Tweaks",
    tooltip  = "At phase transition, Tentacles despawn in 1s (not 9s). Charybdis fires 6 spits instead of 8.",
    default  = false,
    dataMutation = true,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    backup(UnitSetData.Charybdis.CharybdisTentacle.AIStages[3], "WaitDuration")
    backup(WeaponData.CharybdisSpit3.AIData, "FireTicks")
    backup(WeaponDataEnemies.CharybdisSpit3.AIData, "FireTicks")

    UnitSetData.Charybdis.CharybdisTentacle.AIStages[3].WaitDuration = 1.0
    WeaponData.CharybdisSpit3.AIData.FireTicks = 6
    WeaponDataEnemies.CharybdisSpit3.AIData.FireTicks = 6
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if config.Enabled then apply() end
        if public.definition.dataMutation and not mods['adamant-Core'] then
            SetupRunData()
        end
    end)
end)

lib.standaloneUI(public.definition, config, apply, restore)
