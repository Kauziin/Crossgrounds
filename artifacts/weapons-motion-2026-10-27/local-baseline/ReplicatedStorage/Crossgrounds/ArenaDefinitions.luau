-- Temporary hub-test rules. Not the final Arena capacity, variants or balance.
return {
 Version="0.1.0-hubtest", VoteDuration=12, RoundDuration=300, ResultsDuration=6,
 RespawnDelay=3, ProtectionDuration=3, Health=20, Profile="Regular", -- movement only; loadout is KitDefinitions.ArenaWeapons
 KillSound="rbxassetid://135358622908846",
 Origin=Vector3.new(1800,80,340), Staging=Vector3.new(1800,110,1050),
 -- ServerStorage.CrossgroundsMaps.Arena is the authoritative map catalog.
}
