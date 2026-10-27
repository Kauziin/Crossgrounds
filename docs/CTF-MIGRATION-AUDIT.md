# Crossgrounds — Inventário e decisões da primeira migração

Data: 22/10/2026. Inventário realizado antes das alterações de arquitetura.

## Fontes lidas

Leitura integral de `CROSSGROUNDS-CODEX-MIGRACAO.md`, `roblox_hub_design.md` v0.2 e `ESTADO-DO-DESENVOLVIMENTO.md`, seguida de inspeção de fontes e instâncias reais. As notas dos patches anteriores fornecem contexto, mas não substituem o estado vivo do Studio.

## Git e sincronização

- Branch atual: `master`, ainda sem commits. Arquivos existentes estão não rastreados.
- Não foi criado branch, feito stash, removido arquivo nem descartado trabalho local.
- Foram encontrados 38 arquivos Luau em `src/`.
- Não foi encontrado projeto Rojo, configuração de sincronização, manifesto de pacote ou pipeline de build no workspace examinado.
- `src/` é uma cópia de fontes organizada por serviço. As alterações precisam ser aplicadas também às instâncias do Studio; não há sincronização automática comprovada.
- Os arquivos e instâncias anteriores serão preservados por backup. Os pacotes `.rbxm` anteriores não serão sobrescritos.

## Experiência e Places reais

| Campo | Valor observado |
|---|---|
| Janela do Studio | Crossgrounds (BETA) |
| `game.Name` | [SENTINELAS!]Capture a Bandeira!(BETA) |
| Place atual / legado | 4375993208 |
| Universe / `game.GameId` | 1404405130 |
| Consulta `AssetService:GetGamePlacesAsync()` | Sucesso; uma página final, com apenas Crossgrounds (BETA), Place 4375993208. |

A diferença entre o título da janela/listagem e `game.Name` já existia no inventário. Esta tarefa não renomeia a experiência. Não há IDs separados confirmados para hub e CTF. O ID legado não é usado como um novo HubPlaceId nem confundido com Universe ID.

## Inicialização e dependências

- `ServerScriptService.MainGameScript` inicializa `GameManager` e executa o loop legado.
- `GameManager` requer configurações, preferências, mapas, votação, equipes, jogadores, tempo, display, bandeiras e bots.
- `PlayerManager` possui `CharacterAutoLoads=false`, cria personagens, gerencia entrada/saída da partida, equipamentos, retorno à preparação e respawn.
- `SettingsService` usa `CTF_ExperienceSettings_v1`, com chave `u<UserId>`; no Studio a persistência é temporária. Não migrar nem renomear esse armazenamento.
- Scripts locais ativos: JoinMenu, WeaponController, SprintController, CombatHUD, ExperienceMenu, ExperienceFeedback e ControlHints.
- Módulos locais: CombatPresentation, InputMode, InputIcons, ControlRouter, MenuNavigation e InteractionController.
- `DisplayScript` legado está desativado; seus módulos e objetos permanecem preservados.
- Existem scripts adicionais de PlayerInput, Realism, gamepass e TopbarPlus. Não são substituídos pelo núcleo novo; efeitos sobre o hub devem ser observados nos testes.

## Instâncias que não estão integralmente em src/

| Instância | Dependência e tratamento |
|---|---|
| `Workspace.Terrain` | Terreno atual; não mover, limpar ou regenerar. Backup inclui região em células (-66,-16,-66) a (66,48,66), não todo terreno arbitrário fora dessa área. |
| `Workspace.CTFInfrastructure` | Bandeiras, bases, travessias, coberturas e 24 spawns por equipe. Coordenadas preservadas. |
| Geometria com atributo `CTFMapGeometry` | Construções, Noob, peças e teleporter do cenário atual. Não mover/rotacionar. |
| `Workspace.CTFLobby` | Lobby de preparação/treino do CTF. Não é convertido no hub central. |
| `ServerStorage.CTFMaps.riverside` | Único mapa real: Travessia. Contém infraestrutura, geometria e TerrainRegion. |
| `ServerStorage.CTFBotTemplate` | Rig, aparência, Animator e animações básicas do Roblox; não totalmente exportados como fontes Luau. |
| `ServerStorage.KitTools`, `LegacyStarterTools` | Templates e equipamentos anteriores; preservados. |
| `ReplicatedStorage.Events` | Protocolo legado, incluindo eventos de bandeira/placar; novos remotes do hub devem ficar em namespace separado. |
| `ReplicatedStorage.HitMarker`, `MenuMusic` | Assets e configuração de áudio. |
| `Teams.Blue`, `Teams.Red` | Equipes legadas, ambas com AutoAssignable=false. Não criar equipes genéricas extras que o loop legado interpretaria como bases. |
| `StarterGui.Configuration`, `Workspace.TopbarPlus` | Dependências preexistentes externas ao novo núcleo. |

## Referência de funcionamento antes da migração

Play Test executado com um cliente, solicitando entrada Regular pelo protocolo existente e aguardando a preparação:

- Estado Playing; jogador em arena.
- 200 HP; Kastov 545 equipado.
- 11 bots com um humano.
- 24 spawns por equipe; ambas as bandeiras em estado home.
- Teste encerrado e Studio devolvido ao modo de edição.

Este teste não validou captura/queda/entrega, console físico, vários humanos, persistência publicada nem teleporte. Esses itens precisam de verificações próprias na etapa de integração.

## Backup anterior à migração

- Instância: `ServerStorage.CrossgroundsMigrationBaseline_1792655809`.
- Arquivo: `artifacts/pre-crossgrounds-1792655809.rbxm`.
- 588123 bytes; SHA-256 `C5257CD9CB4DC47AEDE8103CD3DF24F978E7023FE4264A6A48A4181223AA72C1`.
- Inclui fontes e objetos organizados por serviço, geometria e a região de terreno descrita acima. Não é um Place completo nem instalador.
- Backups e exports temporários ficam fora de `src/`; pacotes anteriores preservados.
- Foram registrados 56 conjuntos de posição/tamanho dos objetos das duas bases para comparar após a migração.

## Decisão de implementação para esta etapa

1. Usar um protótipo local integrado no Place existente, identificado como tal na UI. Não é matchmaking entre servidores nem teleporte simulado como sucesso real.
2. Criar uma área provisória isolada para Crossgrounds, fora das coordenadas do mapa/lobby legado, sem editar o terreno.
3. Manter o loop interno do CTF, iniciado uma única vez por um adaptador. Núcleo coordena ingresso na preparação, estados e retorno ao hub.
4. CTF continua com duas equipes, até seis humanos/bots por lado, 200 HP, 300 segundos, três capturas, oito segundos de preparação e os kits atuais.
5. Catálogo contém CTF protótipo e Get Out/Duels/Arena planejados, sem filas ou capacidades inventadas para os jogos futuros.
6. Manter os remotes legados; adicionar validação de contexto para impedir jogadores no hub de usar entrada/combate/votação CTF indevidamente. Remotes do hub em `ReplicatedStorage.Crossgrounds.Remotes`.
7. Reutilizar navegação, ícones e preferências existentes com adaptadores de contexto. Não migrar dados nem assumir compartilhamento entre Universes.
8. Saída local deve largar bandeira, remover equipe/participação, limpar ferramentas e apresentação CTF, e levar ao hub. Retorno à preparação da partida permanece separado.
9. Teleporte fica condicionado a configuração explícita de IDs reais e confirmação de que pertencem ao Universe esperado. Sem destino válido, a operação deve falhar com feedback verdadeiro.

## Riscos e operações manuais

- Travessia não pode ser movido: BotBrain usa X=±32/±42, Y=41 e Z=-70/0/70. Generalizar navegação não faz parte desta entrega.
- Equipes e vários serviços inicializam ao serem requeridos. Não chamar require nos serviços de jogo por ferramentas de teste em execução: isso pode criar outro estado de módulo/handlers. Exercitar remotes e instâncias reais.
- Preferências só compartilham dados dentro do escopo correto de experiência. A migração para outro Universe permanece sem plano/autorização.
- Criar/associar os futuros Places de hub e CTF, configurar acesso e informar IDs requer Studio/Creator Dashboard. Não alterar acesso privado ou publicar automaticamente.
- TeleportService não funciona em Play Test do Studio. Testes reais exigem cliente Roblox e publicação privada expressamente autorizada.
- Animações, empunhadura, viewmodel e equilíbrio de armas permanecem fora do escopo desta migração.

## Referências técnicas consultadas

- [Teleporte entre Places e limites do Studio](https://create.roblox.com/docs/projects/teleport).
- [TeleportService e TeleportInitFailed](https://create.roblox.com/docs/reference/engine/classes/TeleportService).
- [Validação da fronteira cliente/servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary).

Os resultados posteriores à implementação serão registrados em `CROSSGROUNDS-IMPLEMENTATION-REPORT.md`.
