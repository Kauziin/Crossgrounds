# Contrato de seleção existente — Arena

```text
Abrir Loadout -> recuperar seleção ativa ou pendente -> mostrar prévia
Focar card (D-pad/hover) -> SOMENTE alterar a prévia
Ativar card (A/click) -> config.Select(id)
ExperienceMenu -> SelectLoadout:FireServer("arena", id)
LoadoutService -> valida modo, id, transição e cooldown; grava PendingArenaLoadout
Replicação -> UI mostra selecionado para próximo nascimento
Respawn -> LoadoutService.ApplyPending -> ArenaPistolVisual atualizado
```

Regras de feedback: texto 'Agendado para o próximo nascimento' somente depois de `PendingArenaLoadout` replicado. Não confundir `ArenaPistolVisual` (vida atual) com `PendingArenaLoadout` (próxima vida). Não criar segundo sistema de persistência.
