# Organização do armazenamento — 26/10/2026

Aplicada ao Place Crossgrounds (ALPHA), 4375993208, com Play parado. A raiz de ServerStorage passou de 76 para 7 objetos.

```text
ServerStorage
├─ CrossgroundsMaps                 # templates usados por Arena e Get Out
├─ CTFMaps                          # biblioteca usada pelo CTF
├─ CTFBotTemplate
├─ Configurations
├─ CrossgroundsConfiguration
├─ MACRO_PLUGIN                     # o plugin exige este caminho
└─ Development
   ├─ MapSources                    # originais editáveis: Arena, GetOut, Pending, Lobby, Duels
   ├─ Assets
   │  ├─ AudioSources
   │  ├─ ImportedModels
   │  ├─ KitTools
   │  └─ CTFExpansionSources
   └─ Tools
      ├─ MapTools
      ├─ ArenaSpawnEditor
      ├─ ArenaManualSpawns
      ├─ CTFWideAuthoring
      ├─ GetOutFacilityAuthoring
      └─ GetOutSliceAuthoring
```

Novas revisões são criadas sob `Development.Revisions.Maps` pelo importador e `Development.Revisions.Hub` pelo autoramento do hub. Essas pastas aparecem quando uma revisão é necessária. Revisões antigas foram exportadas junto com o histórico.

## Edição e importação

Com Play parado, mova o original de `Development.MapSources.Arena` ou `.GetOut` para `Workspace.CrossgroundsMapWorkshop` na pasta do modo, edite e execute na Command Bar:

```lua
require(game.ServerStorage.Development.Tools.MapTools).Import("Arena", "Meu Mapa")
-- Para preservar o ID ao mudar o nome:
require(game.ServerStorage.Development.Tools.MapTools).Import("Arena", "Nome Novo", "shipment")
```

Os spawns da cópia preparada continuam em `ServerStorage.CrossgroundsMaps.Arena.<id>.Spawns`. Ajustes manuais nessa cópia são substituídos por uma nova importação; use `SpawnRegions` no original para preservar a delimitação da área permitida. Veja [mapas e importação](MAPAS-E-IMPORTACAO.md).

As ferramentas de Get Out agora são acessadas por `game.ServerStorage.Development.Tools.GetOutSliceAuthoring` e `.GetOutFacilityAuthoring`. Construir um mapa continua sendo uma operação manual; a organização não executa essas ferramentas.

## Testes e histórico fora do Place

Os testes foram movidos de `src` para [tests](../tests/README.md), e seus quatro objetos foram retirados do Studio. Foram removidos também os pontos de entrada exclusivos da suíte P0 no bootstrap e no cliente. O protocolo normal de carregamento dos mapas permanece ativo.

Os 61 grupos históricos de baselines, patches, bundles e recuperações foram exportados e retirados de ServerStorage. Os arquivos `.rbxm` foram desserializados e conferidos antes da retirada; os hashes foram relidos do disco. A lista completa e as instruções de recuperação estão no [manifesto](../artifacts/storage-organization-2026-10-26/ARCHIVE-MANIFEST.md).

- [Histórico exportado](../artifacts/storage-organization-2026-10-26/historical-packages.rbxm)
- [ServerStorage completo antes da organização](../artifacts/storage-organization-2026-10-26/server-storage-before.rbxm)
- [Objetos de teste originais](../tests/studio-tests-before-organization.rbxm)

Guarde esses arquivos com o projeto. Para consultar uma versão antiga, insira o `.rbxm` em um Place separado. As cópias históricas contêm scripts antigos e não devem ser ativadas indiscriminadamente no jogo atual.
