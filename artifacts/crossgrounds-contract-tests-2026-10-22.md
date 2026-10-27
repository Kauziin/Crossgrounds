# Crossgrounds — resultado dos contratos

Execução manual no servidor do Play Test do Roblox Studio, 22/10/2026.

**25 executados, 25 aprovados, 0 falhas.**

| Módulo | Casos |
|---|---:|
| GameCatalog | 3 |
| SessionProtocol | 4 |
| QueueProvider | 7 |
| TravelService | 11 |

Os testes de TravelService usam IDs sintéticos e dependências simuladas. Não executam rede, DataStore nem teleporte real. A aprovação não valida publicação, controle físico ou persistência.

No Play, Command Bar / contexto servidor:

```lua
require(game.ServerStorage.UnitTest.RunUnitTest)(nil, 5)
```

`ServerScriptService.UnitTestRunner` fica desativado para evitar testes durante partidas normais. Resultados individuais aparecem no Output.
