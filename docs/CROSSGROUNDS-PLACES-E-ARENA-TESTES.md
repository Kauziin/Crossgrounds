# Crossgrounds — Places e Arena de testes

**23/10/2026 — atualizado após as correções de Arena, mobile e mira.** Arena com 20 HP e primeira pessoa obrigatória. O novo Place foi criado pelo usuário; nenhum Place foi criado ou publicado pelo agente. [Testes e limites atuais](ARENA-CORRECOES-MOBILE-E-MIRA.md); [importação de mapas](MAPAS-E-IMPORTACAO.md). Os testes da seção 6 descrevem a etapa original.

## 1. Como criar os Places na mesma experiência

A consulta mais recente retornou **4375993208** e **84561729907420**, dentro do Universe **1404405130**. O segundo, **KAuZiiN_4k's Place: 10222026_1**, foi confirmado pelo usuário como **Arena**. Preserve o Place integrado/legado durante os testes.

Para cada novo Place:

1. Abra um novo template **Baseplate**, ou uma cópia local do arquivo desejado, no Roblox Studio.
2. Use **File → Publish As** (em versões anteriores: **Publish to Roblox As…**).
3. Selecione a experiência **Crossgrounds** existente. Não crie outra experiência.
4. Escolha **Add as a new place** e clique em **Create**. Não selecione um Place existente para sobrescrever.
5. Dê um nome claro e anote o novo **Place ID**. Confirme que ele aparece nos Places da mesma experiência, com Universe 1404405130.

Esse processo salva/publica o novo Place na nuvem. Ele não exige tornar a experiência pública; confira separadamente as permissões dos testadores. A operação não foi executada pelo agente.

Fonte: [Roblox — criação de Places adicionais](https://create.roblox.com/docs/production/publishing/publish-games-and-places#create-additional-places).

### Organização para estes testes

| Place | Papel configurado | Situação |
|---|---|---|
| Atual, 4375993208 | combinedPrototype | CTF e Arena acessíveis localmente pelo hub; legado preservado. |
| Hub dedicado | hub | Pacote local preparado; Place ID ainda não definido. |
| KAuZiiN_4k's Place: 10222026_1 — 84561729907420 | arena | Criado pelo usuário; pacote atualizado preparado. Instalação nesse Place ainda não executada pelo agente. |
| Crossgrounds CTF — Teste | ctf | Opcional para a próxima integração; exige mapa, terreno e dependências do CTF. |

**Um mapa não precisa ser outro Place.** Os cenários da Arena ficam no mesmo Place de Arena, em ServerStorage.CrossgroundsMaps.Arena, e a votação escolhe qual carregar no Workspace. O catálogo encontrado nesta etapa inclui seis templates.

Não foi alterado o start place da experiência. Para futuramente transformar o hub no ponto de entrada público, planejar a substituição do conteúdo do start place após preservar o legado. A documentação atual descreve sobrescrita do start place, não uma troca instantânea entre IDs; isso não faz parte desta etapa.

## 2. Pacotes para instalar nos novos Places

- [Hub — pacote de teste atualizado](../artifacts/crossgrounds-hub-arena-mobile-2026-10-23.rbxm)
- [Arena — pacote atualizado com seis templates e 20 HP](../artifacts/crossgrounds-arena-mobile-2026-10-23.rbxm)

São **pacotes organizados por serviço**, não Places completos e não instaladores automáticos. Use novos Baseplates/cópias, em modo de edição, e só inicie Play depois de distribuir o conteúdo:

| Conteúdo do pacote | Destino |
|---|---|
| ServerScriptService/* | Serviço ServerScriptService real |
| ReplicatedStorage/* | Serviço ReplicatedStorage real |
| ServerStorage/* | Serviço ServerStorage real |
| StarterPlayer/StarterPlayerScripts/* | StarterPlayer.StarterPlayerScripts real |

Copie o **conteúdo** dessas pastas; não crie outro serviço nem outra pasta StarterPlayerScripts dentro da existente. Preserve as classes e Enabled dos scripts. O módulo GameManager e seus filhos devem continuar dentro do Script MainGameScript, como no pacote.

O pacote de Hub já possui PlaceRole=hub. O de Arena possui PlaceRole=arena e inclui CrossgroundsMaps.Arena com seis templates, incluindo House preservado como encontrado. Ambos iniciam com **TeleportEnabled=false** e **ArenaPlaceId=84561729907420**. HubPlaceId, CTFPlaceId e ApprovedUniverseId continuam vazios. Os pacotes anteriores estão preservados.

**Se o destino já possui Realism Mod/Blood**, substitua também a [fonte desse script pela versão corrigida](../src/ServerScriptService/Realism%20Mod/Blood.luau). A versão antiga destrói equipamentos dos sobreviventes após uma morte. Esse script legado não é acrescentado a um Baseplate limpo pelos pacotes dedicados.

Os cenários do hub e da sala de votação da Arena são criados pelo código; não é necessário copiar a geometria antiga do CTF, seus teleporters externos, TopbarPlus ou o GUIEditor para esses Baseplates. Os módulos antigos de armas/preferências permanecem no pacote como dependências; o loop do CTF não é iniciado no papel hub/arena.

### Configuração de ligação

Depois de criar os Places e confirmar seus IDs, preencher **ServerStorage.CrossgroundsConfiguration em cada Place**, mantendo os mesmos destinos e alterando apenas PlaceRole:

```lua
return {
 PlaceRole = "hub", -- "arena" no Place de Arena; "ctf" no de CTF
 EnableLocalCTFPrototype = false,
 EnableLocalArenaPrototype = false,
 TeleportEnabled = false, -- habilitar somente após confirmar IDs/permissões
 ApprovedUniverseId = 1404405130,
 HubPlaceId = nil, -- substituir pelo ID REAL do Hub
 ArenaPlaceId = 84561729907420, -- Arena confirmada pelo criador
 CTFPlaceId = nil, -- opcional até existir destino de CTF
 ProtocolVersion = 1,
}
```

- Não usar o Universe ID como Place ID.
- Não preencher os campos com o ID do legado por conveniência.
- Após confirmação, habilitar TeleportEnabled nas versões de teste e salvar/publicar manualmente com acesso apropriado.
- O servidor confere se o destino pertence à experiência e trata falhas de TeleportAsync. O cliente não escolhe Place ID.
- **F5/Play do Studio não executa teleporte real.** Os testes entre Places exigem cliente Roblox e versões publicadas com permissões adequadas. [Limitação oficial do TeleportService](https://create.roblox.com/docs/projects/teleport).
- O hub dedicado não hospeda localmente as partidas. Enquanto seus destinos estiverem vazios/desligados, os cartões exibem indisponibilidade. O modo integrado atual continua sendo a alternativa local de teste.

## 3. O que já pode ser testado agora

No projeto atual, iniciar Play, escolher **Arena · testes**, preparar e confirmar a entrada.

Fluxo implementado:

1. Entrada na sala de preparação da Arena.
2. Votação de **12 segundos** entre Shipment, Dust, Factory, Pátio e Posto, um voto por jogador, com possibilidade de mudar a escolha.
3. Carregamento real do cenário vencedor.
4. Combate livre de teste, com **20 HP**, pistola e Executor. Escolha entre M1911, Magnum e Glock 18; a escolha entra no próximo respawn. Sem números de dano; eliminações exibem arma, headshot e XP de sessão.
5. Respawn de **3 segundos**, proteção temporária, estamina e corrida alternada.
6. Rodada de **120 segundos**, resultados de 6 segundos e nova votação.
7. Retorno explícito ao Crossgrounds, com limpeza de armas, cenário, voto, câmera e participação.

Esses números são **parâmetros provisórios do teste do hub**, em ArenaDefinitions. Não substituem o design de Arena Clássico de um acerto para eliminar, não definem a capacidade final e não implementam as variantes. Get Out e Duels continuam planejados e inacessíveis.

Há três **alvos estáticos de treino** por cenário para testar tiros sem um segundo humano. Não são bots da Arena; eliminá-los não aumenta a contagem de eliminações PvP. Combate entre jogadores está implementado no servidor, mas ainda não foi validado com múltiplos humanos nesta etapa.

### Controle e interface

- Mantidos LS corrida, RS câmera, Y troca de arma, LB Shift Lock, X recarga/interação, RB ombro, RT/LT ataque/mira, conforme remapeamento existente.
- D-pad/A/B, cursor artificial e foco funcionam na votação.
- D-pad baixo abre novamente o painel de votação; B pode fechá-lo para explorar a sala.
- Configurações globais e remapeamento continuam disponíveis.
- Retorno ao Crossgrounds disponível no painel da Arena e nos ajustes.
- HUD próprio da Arena mostra vida, munição, estamina, fase, tempo e contagens. Usa câmera, viewmodel e feedback visual já existentes, com escopo de combate compartilhado.
- O HUD de objetivos/bandeiras do CTF permanece exclusivo do CTF.

## 4. Mapas importados e procedência

Shipment, Dust e Factory foram acrescentados pelo usuário e agora entram na Arena. Meat Factory, Backrooms e Office estão preparados em CrossgroundsMaps.GetOut; Get Out continua indisponível no hub. House está preservado em CrossgroundsMapSources.Pending. Autoria dos seis mapas novos não foi inferida. Estrutura atual, spawns e fluxo para os próximos mapas: [mapas e importação](MAPAS-E-IMPORTACAO.md). A tabela abaixo registra a origem dos dois mapas da etapa inicial.

| Nome no teste | Asset original | Autor informado pelo Creator Store | Geometria |
|---|---|---|---:|
| Pátio / courtyard | [Simple Team Deathmatch Map, 335611392](https://create.roblox.com/store/asset/335611392) | DevelopmentStatus | 189 partes |
| Posto / outpost | [Basic Team Deathmatch Map, 1350851853](https://create.roblox.com/store/asset/1350851853) | CHeesEnuT | 3671 partes |

Os dois assets foram encontrados como gratuitos no Creator Store e importados para ServerStorage.CrossgroundsImportedAssets. Os créditos são preservados em ArenaDefinitions e nos atributos dos templates.

Tratamento das cópias usadas em jogo:

- Apenas geometria/elementos visuais; **zero scripts, SpawnLocations ou Seats ativos** nos templates finais.
- O script READ ME do primeiro asset foi inspecionado e mantido desativado no original guardado. Não foi transferido para o cenário jogável.
- Partes ancoradas; joints/câmeras/scripts externos não foram incorporados ao runtime.
- SpawnLocations/assentos do modelo original convertidos em partes comuns para não disputar o spawn do jogo.
- Cenários deslocados para a região de Arena em torno de (1800, 80, 340), sem mover o CTF e sem regenerar terreno.
- Templates atualmente em ServerStorage.CrossgroundsMaps.Arena; somente o vencedor é clonado para Workspace.CrossgroundsArenaRound.
- Pontos de respawn derivados de superfície e espaço livre, com preferência por distância de oponentes e penalidade para pontos usados recentemente.
- Na etapa original, Pátio gerou **20** pontos e Posto, **50**. A atualização da biblioteca preparou **24** pontos em cada um dos cinco mapas de Arena, revalidados durante o carregamento.

Os mapas são conteúdo provisório de terceiros, sem aprovação artística ou avaliação completa de desempenho. Não foram incorporados à votação do CTF: sua IA ainda depende de Travessia, que continua sendo a única opção real desse modo.

## 5. Implementação e isolamento

Novos fontes:

- ReplicatedStorage.Crossgrounds.ArenaDefinitions
- ServerScriptService.Crossgrounds.MapBallot
- ServerScriptService.Crossgrounds.ArenaMaps
- ServerScriptService.Crossgrounds.ArenaCombat
- ServerScriptService.Crossgrounds.ArenaAdapter
- StarterPlayer.StarterPlayerScripts.ArenaHUD
- ServerStorage.UnitTest.Cases.MapBallot_Test

Catálogo, bootstrap, coordenador, contexto, viagem e interface foram estendidos para Arena. ArenaPlaceId está preenchido com 84561729907420; teleporte permanece desativado. O contexto de combate compartilhado permite reutilizar entrada/câmera/apresentação sem transformar Arena em uma partida CTF.

Os servidores de combate/movimento/voto do CTF recusam contexto Arena. PlayerManager não reposiciona nem agenda o respawn dos personagens da Arena. Ela possui membros, ballot, dano, spawn, cronômetro e limpeza próprios; não usa Blue/Red, bandeiras ou preenchimento com bots. Os ajustes posteriores de armas compartilhadas estão registrados no relatório atual.

## 6. Testes executados e limites

Ambiente: um cliente de Play Test, com entradas simuladas de controle e ações de QA no servidor.

| Verificação | Resultado |
|---|---|
| Compilação e integridade | 65 fontes iguais entre disco e Studio, zero erros de sintaxe; 56 posições/tamanhos das bases CTF preservados. Pacotes conferidos sem diferenças de fonte, exceto PlaceRole intencional de cada configuração. |
| Contratos | **32/32 aprovados**, incluindo 7 novos casos de ballot. |
| Catálogo | CTF e Arena protótipos; Get Out/Duels planejados; Arena sem capacidade fictícia. |
| Voto e carregamento | Voto em Posto registrado como 1×0; carregamento efetivo de outpost confirmado. |
| Navegação completa por controle | Hub → selecionar Arena → preparar → confirmar → focar Posto → A para votar; foco e cursor artificial observados, cursor nativo false. |
| Retorno por controle | D-pad baixo → painel → Crossgrounds → A; hub pronto, câmera Custom, ArenaHUD oculto, mundo da Arena removido. |
| Ciclo de rodada | Partida chegou à votação seguinte após o tempo configurado. A tela intermediária de resultados não foi capturada individualmente. |
| Morte/respawn | Novo personagem, 200 HP, ArenaPlaying=true e pronto após o respawn. |
| Armas e câmera | RT consumiu munição; RS ativou primeira pessoa/viewmodel; recarga solicitada e reposição observada no percurso. |
| Dano autoritativo | Três tiros no alvo de treino reduziram 200 → 113 HP; o posicionamento do jogador/alvo foi controlado para QA. |
| Arena → hub → CTF | CTF Playing, 200 HP, 11 bots, equipe atribuída, ArenaHUD oculto e mundo da Arena ausente. |
| Arena ociosa | Último jogador saiu: cenário removido, zero bots CTF; uma inicialização de Arena e uma de CTF no modo integrado. |
| Papel arena isolado | Entrada automática, votação, mapa Posto carregado, 200 HP; loop CTF ausente. |
| Geometria importada | 3860 partes no total; nenhum script, SpawnLocation ou Seat nos templates jogáveis. |

Os testes de catálogo foram atualizados porque o criador autorizou a Arena como segundo protótipo; isso altera o contrato anterior de “somente CTF”. Os demais contratos mantiveram suas verificações. Para reproduzir:

```lua
-- Play Test, contexto servidor:
require(game.ServerStorage.UnitTest.RunUnitTest)(nil, 5)
```

UnitTestRunner continua desativado.

### Problemas encontrados e corrigidos nesta etapa

- Snapshot inicial de hub chegando ao HUD da Arena antes da sessão: guardas por id/opções adicionadas.
- Atalho de configurações sobrepondo a votação: ocultado enquanto o painel está visível.
- Spawns em superfícies altas: limitado o conjunto a superfícies próximas do piso.
- Inicialização duplicada do contexto sobrescrevia o autoingresso do papel arena com hub: inicialização por jogador tornada idempotente e CharacterAutoLoads controlado; repetição confirmou o funcionamento.

### Ainda não validado / problemas externos

- Teleporte real, instalação dos pacotes em Places novos publicados e permissões de retorno.
- Vários humanos em PvP, entrada no limite do servidor, latência, exploração de todos os cantos dos mapas e todas as condições de respawn.
- Console físico Xbox/PlayStation, celular físico e teclado virtual; desempenho do mapa Posto em aparelhos modestos.
- Matriz completa de melee, sons e assets publicados. Houve aviso isolado de asset 81504106 indisponível; ele não foi identificado nas texturas/decals dos templates novos e não foi removido de recursos legados.
- Persistem os erros externos já registrados de GUIEditor e dos teleporters do mapa legado. Não foram copiados como dependências de Workspace nos novos pacotes de Hub/Arena.
- Scripts da ferramenta emitiram avisos de câmera/StarterPlayerScripts. Uma consulta de QA foi recusada pelo intervalo mínimo de GetState; isso não equivale a falha de solicitação de jogador.
- Os testes desta seção descrevem a etapa original da Arena. O patch posterior implementou modelos e pegada procedural; animações completas e acabamento continuam pendentes. Ver [resultados atualizados](ARMAS-PEGADA-PULO-CAMERA.md).

## 7. Pacotes e preservação

| Pacote | Bytes | SHA-256 |
|---|---:|---|
| Hub atualizado — Arena/mobile | 169236 | B6DD440DF9F36676D20956F52F0344ABEBE234A13E967F03A91D6B0E99FE5549 |
| Arena atualizada — mobile/mira | 1038080 | 016F8C0A9C957CC8C5A50282E2F9768819A73D9EE84815895C3C16B89588EDB7 |

Instâncias atualizadas: ServerStorage.Crossgrounds_hub_ArenaBugfixBundle e Crossgrounds_arena_ArenaBugfixBundle, com 80 fontes de runtime/autoramento cada. Os pacotes anteriores permanecem preservados. Backups: ArenaAccessibilityBaseline_1792728366 e ArenaBugfixSourcesBaseline_1792729964; originais dos mapas preservados em CrossgroundsMapSources. Os mapas de Get Out ficam fora dos dois pacotes. O relatório atual registra 78 contratos aprovados e os limites de hardware/PvP.

Os pacotes foram gerados de fontes e instâncias do projeto, mas sua instalação em um **novo Place remoto** ainda precisa ser realizada e testada. Não contêm terreno completo nem representam atualização publicada.

Estado entregue do projeto atual: combinedPrototype, entradas locais CTF/Arena habilitadas, TeleportEnabled=false, ArenaPlaceId=84561729907420, HubPlaceId/CTFPlaceId/ApprovedUniverseId vazios, Studio em edição. Nenhum acesso público, start place, dado persistido ou conteúdo de Place remoto foi alterado pelo agente. A instalação no novo Place e o teleporte real continuam pendentes.

## 8. Pacotes atuais — menu e bugs de 23/10

**Cumulativo mais recente:** [controle, foco e som](CONTROLE-CURSOR-FOCO-SOM.md). Contém 27 fontes incrementais sobre Bugs23, incluindo cascatas sólidas, lobby/playlist/progresso e aim assist. Projeto aberto já atualizado; instalação remota ainda não testada.

**Pacote cumulativo mais recente:** [acessibilidade e aim assist](AIM-ASSIST-COMPONENTES.md), com 27 fontes incrementais sobre Bugs23 e 106 fontes totais de runtime. Inclui as entregas de UI e lobby/playlist/progresso. Sem instalação remota testada.

**Incremental mais recente:** [lobby, playlist, XP e estatísticas](LOBBY-PLAYLIST-XP-ESTATISTICAS.md). Inclui a correção acrílica anterior; aplicar sobre Bugs23 sem duplicar controladores. São 23 fontes incrementais, totalizando 106 de runtime. Instalação remota ainda não testada.

**Atualização posterior:** aplicar também o [incremental de UI acrílica](UI-CASCATA-ACRILICO.md) sobre estes pacotes. Dez fontes substituídas/adicionadas, total de 101 fontes de runtime. Sem instalação remota testada.

- [Hub](../artifacts/crossgrounds-hub-bugs23-2026-10-23.rbxm): 98 fontes e fonte do lobby; o protótipo anterior pertencente ao Crossgrounds é arquivado intacto durante a migração.
- [Arena](../artifacts/crossgrounds-arena-bugs23-2026-10-23.rbxm): 98 fontes e sete templates, com spawns revisados em Dust.

Incluem loadouts pendentes, renderização dedicada, editor de HUD, controle do cronômetro no Studio e correções do relato. Integrações recentes de progresso/lobby foram preservadas. Os pacotes da seção anterior são históricos.

Distribua por serviço sem duplicar os inicializadores. Teleporte continua desligado; HubPlaceId/CTFPlaceId/ApprovedUniverseId ainda precisam de configuração apropriada. Não houve instalação no Place remoto nem publicação. Os testes integrados não substituem teste de instalação e teleporte entre Places.

Hashes, evidências e pendências: [relatório atual](MENU-LOADOUT-VIEWMODEL-ARENA.md).

