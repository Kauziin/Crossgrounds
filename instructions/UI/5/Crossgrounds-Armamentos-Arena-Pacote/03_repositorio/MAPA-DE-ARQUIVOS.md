# Mapa do repositório — referências para o Codex

Consultado na branch `master`, em 31/10/2026. As fontes abaixo podem evoluir depois da auditoria.

| Arquivo | URL | Observação |
|---|---|---|
| `LoadoutMenuView.luau` | https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/LoadoutMenuView.luau | Grid 2×3 e ViewportFrames da Arena; ramificação para Gunsmith no CTF. |
| `ExperienceMenu.luau` | https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau | `render("Loadout")` passa callback de escolha ao módulo visual. |
| `MenuNavigation.luau` | https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau | `Nav:Connect`, `Nav:Focus`, `FocusChanged`, direções e saída. |
| `LoadoutDefinitions.luau` | https://github.com/Kauziin/Crossgrounds/blob/master/src/ReplicatedStorage/Crossgrounds/LoadoutDefinitions.luau | `List`, `ActiveAttribute`, `PendingAttribute`. |
| `KitDefinitions.luau` | https://github.com/Kauziin/Crossgrounds/blob/master/src/ReplicatedStorage/KitDefinitions.luau | Lista de seis visuais e Executor (`Sword`). |
| `LoadoutService.luau` | https://github.com/Kauziin/Crossgrounds/blob/master/src/ServerScriptService/Crossgrounds/LoadoutService.luau | Valida e grava atributos pendentes; aplicação no respawn. |
| `LOADOUT-UI-2026-10-27.md` | https://github.com/Kauziin/Crossgrounds/blob/master/docs/LOADOUT-UI-2026-10-27.md | Relatório de uma versão anterior já implementada no Studio. |

Verificar o estado real do projeto antes de editar. A documentação de 27/10 descreve testes daquela data; **não representa testes deste pacote**. `GunsmithView` atende o CTF e não deve ser alterado nesta tarefa.
