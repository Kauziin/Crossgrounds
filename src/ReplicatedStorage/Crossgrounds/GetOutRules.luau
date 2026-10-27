--!strict
-- Approved Get Out rules. Values still marked pending in the design are intentionally absent.
local Rules = {
    Version = 1,
    BaseSeconds = 600,
    EnragedSeconds = 300,
    TotalSeconds = 900,
    VaultLockoutSeconds = 30,
    DemolitionFuseSeconds = 15,
    Routes = { "locks", "vault_code", "laser_shutdown", "thermal_tool", "demolition" },
    RouteNames = {
        locks = "Travas",
        vault_code = "Cofre",
        laser_shutdown = "Lasers",
        thermal_tool = "Ferramenta térmica",
        demolition = "Demolição",
    },
    -- Test-only Classic tuning. These numbers are not approved balance rules.
    Prototype = {
        MinPlayers = 2,
        MaxPlayers = 5,
        IntermissionSeconds = 8,
        ResultsSeconds = 12,
        HackHoldSeconds = 8,
        CrankHoldSeconds = 10,
        CaptureHoldSeconds = 2,
        RescueHoldSeconds = 4,
        PodSeconds = 45,
        RescueProtectionSeconds = 5,
        BeastWalkSpeed = 18,
        EnragedWalkSpeed = 21,
        SurvivorWalkSpeed = 16,
        HackerRollbackCooldownSeconds = 150,
        ContainmentPanelHoldSeconds = 8,
        ContainmentLeverHoldSeconds = 4,
    },
}

return table.freeze(Rules)
