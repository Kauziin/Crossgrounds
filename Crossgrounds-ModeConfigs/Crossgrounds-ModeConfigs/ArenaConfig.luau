--!strict
-- Crossgrounds | Arena: configuracao individual (base conceitual, sem implementacao).
return {
    Id = "arena",
    DisplayName = "Arena",
    SchemaVersion = 1,
    ImplementationStatus = "design_only",
    PlayerCount = "pending", -- Deve ser igual entre as variantes, valor ainda nao definido.
    QueueStrategy = "shared_queue_then_vote_variant",
    Variants = {
        Classic = { Status = "defined", OneHitElimination = true, EqualWeaponCombatStats = true },
        TeamDeathmatch = { Status = "defined", TeamBasedEliminations = true },
        HealthBased = { Status = "pending", OneHitElimination = false },
    },
    SpawnSafetyNeedsImprovement = true,
}
