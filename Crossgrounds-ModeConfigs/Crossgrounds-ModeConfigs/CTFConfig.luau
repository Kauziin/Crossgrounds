--!strict
-- Crossgrounds | CTF: descricao de integracao, NAO substitui as configuracoes legadas.
-- A migracao deve preservar o codigo jogavel e consultar o projeto real antes de conectar.
return {
    Id = "ctf",
    DisplayName = "Capture a Bandeira",
    SchemaVersion = 1,
    ImplementationStatus = "legacy_adapter_pending",
    PublicLaunchIncluded = "pending",
    CurrentLegacy = {
        PlayerSlots = 12,
        TeamSlots = 6,
        FillEmptySlotsWithBots = true,
        MatchDurationSeconds = 300,
        CapturesToWin = 3,
        PreparationSeconds = 8,
        MapId = "riverside",
    },
    ExistingConfiguration = "src/ReplicatedStorage/ExperienceSettings.luau",
    Note = "Nao aplicar estes valores sobre os sistemas legados ate auditar o codigo e testar a integracao.",
}
