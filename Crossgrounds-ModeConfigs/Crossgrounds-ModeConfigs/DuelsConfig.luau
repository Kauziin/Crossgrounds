--!strict
-- Crossgrounds | Duels: configuracao individual (base conceitual, sem implementacao).
-- Nao altera kits/armas ou scripts de CTF.
return {
    Id = "duels",
    DisplayName = "Duels",
    SchemaVersion = 1,
    ImplementationStatus = "design_only",
    Rules = { Weapons = { "pistol", "knife" }, AbilitySlots = 2, Status = "defined" },
    Variants = {
        Classic = { Status = "defined", PlayerCounts = { 2, 4, 6, 8 } },
        FreeForAll = { Status = "defined", MinPlayers = 3, MaxPlayers = 8 },
        Confrontation = { Status = "defined", Players = 16, Teams = 2, MapShrinks = true, AntiCamping = true },
        Epidemic = { Status = "defined", MinPlayers = 8, MaxPlayers = 12, InitialInfected = 1, UsesHealth = true },
    },
    Modifiers = {
        OnlyKnife = { Status = "defined", AllowedWeapons = { "knife" } },
        OnlyRevolver = { Status = "defined", AllowedWeapons = { "revolver" } },
    },
    QueueStrategy = "pending",
}
