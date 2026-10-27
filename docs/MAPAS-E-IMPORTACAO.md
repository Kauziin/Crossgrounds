# Mapas e importação — atualizado em 23/10/2026

**Atualização posterior:** Factory usa 65 spawns em zonas internas explícitas; Arena exige primeira pessoa e mantém 20 HP. A biblioteca conferida em 26/10 tem 15 templates de Arena e 10 de Get Out; o catálogo de perseguição v0.5 aceita somente os que cumprem seu contrato, atualmente pursuit_lab. Conteúdo adicionado pelo usuário foi preservado. Os resultados da seção de testes abaixo registram a etapa original de organização; a entrega atual soma 78 contratos aprovados. [Testes e limites atuais](ARENA-CORRECOES-MOBILE-E-MIRA.md).

**Organização em 26/10/2026:** originais e ferramentas passaram para `ServerStorage.Development`; testes e backups históricos ficam fora do Place. [Estrutura atual e recuperação](STORAGE-ORGANIZATION.md). Os caminhos de importação abaixo já refletem essa mudança.

## Onde colocar os próximos mapas

**Spawns manuais:** originais com `AuthoredSpawns` usam seus marcadores explícitos. O importador valida cada um e recusa pontos inválidos; não executa o posicionamento automático nesse caso. Assault, Praia, Factory e Glacier usam esse fluxo. [Revisão atual](ARENA-MANUAL-SPAWNS-LIGHTING.md).

**Para editar os spawns dos mapas já preparados:** os 15 mapas estão visíveis e separados em `Workspace.ArenaSpawnEditor`. Use [o guia do editor de spawns](ARENA-SPAWN-EDITOR.md) para mover/duplicar os marcadores e salvar nos templates. O workshop abaixo continua destinado à importação de mapas completos.

Com Play parado, coloque cada mapa inteiro como **um Model ou Folder**, com nome próprio, em:

```text
Workspace
└─ CrossgroundsMapWorkshop
   ├─ Arena       ← novos mapas de Arena
   ├─ GetOut      ← novos mapas de Get Out
   └─ Pending     ← modalidade ainda não escolhida
```

Depois, abra a Command Bar e execute, trocando o nome:

```lua
require(game.ServerStorage.Development.Tools.MapTools).Import("Arena", "Meu Mapa")
-- Ou:
require(game.ServerStorage.Development.Tools.MapTools).Import("GetOut", "Meu Mapa")
```

O importador também reconhece mapas ainda soltos diretamente no Workspace. Ele prepara primeiro a geometria e os spawns; se não encontrar pelo menos seis pontos livres, interrompe a operação sem substituir o mapa anterior. Não funciona durante Play.

Após importar, o original sai do Workspace e fica em **ServerStorage.Development.MapSources.Arena/GetOut**. Esse é o material de edição, com hierarquia, scripts e posições originais preservados. Para editar novamente, mova o original para a pasta correspondente do workshop, altere e execute Import outra vez. Se estiver criando uma cópia com o mesmo nome, retire o original anterior dessa pasta antes da importação, evitando nomes duplicados.

O ID deriva do nome: espaços viram `_` e letras ficam minúsculas. Ao renomear um mapa já cadastrado, preserve o ID explicitamente para atualizar a mesma entrada:

```lua
require(game.ServerStorage.Development.Tools.MapTools).Import("Arena", "Nome Novo", "shipment")
```

Versões anteriores da cópia preparada são guardadas em **ServerStorage.Development.Revisions.Maps**. Guarde uma cópia do Place antes de importações grandes. Terrain não é incluído por este importador; ele trabalha com geometria de BaseParts/MeshParts.

## Organização usada pelo jogo

```text
ServerStorage
├─ Development
│  └─ MapSources
│     ├─ Arena       ← originais e conteúdo em preparação
│     ├─ GetOut      ← originais e conteúdo em preparação
│     └─ Pending     ← modalidade ainda não escolhida
└─ CrossgroundsMaps
   ├─ Arena
   │  ├─ shipment
   │  ├─ dust
   │  ├─ factory
   │  ├─ courtyard
   │  ├─ outpost
   │  └─ house
   └─ GetOut
      ├─ meat_factory
      ├─ backrooms
      ├─ office
      ├─ facility
      ├─ shopping_center
      ├─ farmland
      ├─ abandoned_facility
      ├─ hotel
      └─ construct
```

Cada cópia preparada contém **Geometry** em lotes de até 100 partes para os mapas novos, **Spawns** com marcadores de personagem, nome exibido, ID, modalidade, estado e limites de queda. Os modelos antigos de Arena mantêm seus lotes existentes. Pátio e Posto foram migrados; a pasta vazia anterior foi preservada no histórico exportado como CrossgroundsArenaMaps_Migrated.

MapLibrary lê o catálogo dessas pastas, sem lista fixa em ArenaDefinitions. Mapas desativados com o atributo **Enabled=false**, sem geometria preparada ou sem marcadores suficientes ficam fora do catálogo. ArenaMaps revalida os marcadores na geometria carregada. Só o cenário escolhido é clonado para o Workspace e é removido ao terminar a sessão sem participantes.

A votação da Arena é uma grade com rolagem e nomes vindos do catálogo. D-pad e teclado percorrem os cartões e revelam os que estavam fora da área visível; mouse e toque mantêm os botões e rolagem. Não é mais necessário editar o HUD ao adicionar um mapa.

### Spawns

O preparo busca superfícies sólidas e relativamente horizontais perto do piso principal, confere apoio e espaço livre de **4 × 5,5 × 4 studs** e distribui até 24 pontos afastados. O personagem fica a 3,6 studs do piso. SpawnLocations originais servem como candidatos; nas cópias de jogo viram partes comuns, para não disputar o nascimento com o controlador do modo.

**Para limitar a área jogável:** adicione uma pasta **SpawnRegions** diretamente ao Model/Folder original. Dentro dela, crie Parts horizontais cobrindo somente os locais permitidos. Use Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false e Transparency=1. Coloque o atributo numérico **FloorY** em cada zona, com a altura do piso nas coordenadas originais; sem ele, a base da Part será usada como referência. Dê altura suficiente à zona para conter o centro do personagem, 3,6 studs acima do chão.

O importador exclui essas Parts da geometria e as converte para o espaço do template. Gera até 24 candidatos por zona, remove duplicados e recusa pontos externos. Ajuste as zonas no **original** e reimporte para conservá-las nas próximas versões. Factory usa PatioInterno, CorredorInterno e PassagemOeste, totalizando 65 pontos; plataformas externas e blocos decorativos sólidos ficam fora. Sem SpawnRegions, permanece o preparo automático anterior.

Os marcadores são Parts invisíveis em **Spawns**, com posição/orientação do personagem e SpawnRole=Player. Podem ser ajustados manualmente na cópia preparada; o carregamento recusará pontos bloqueados ou sem chão. Reimportar regenera esses marcadores. O posicionamento automático não comprova conectividade entre salas, equilíbrio competitivo, ausência de linhas de tiro ruins ou compatibilidade com avatares extremos; revisar os pontos em jogo continua necessário.

As cópias são normalizadas para piso em torno de **(1800, 80, 340)**. Os originais mantêm suas posições. O CTF/Travessia e seu terreno não foram movidos, nem seus spawns substituídos. Sua biblioteca e navegação de bots continuam separadas.

## Mapas organizados

| Modo | Mapa | Partes da geometria | Spawns preparados | Uso atual |
|---|---|---:|---:|---|
| Arena | Shipment | 220 | 24 | Votação e carregamento |
| Arena | Dust | 189 | 24 | Votação e carregamento |
| Arena | Factory | 2392 | 65 | Zonas internas explícitas; votação e respawn testados |
| Arena | Pátio | 189 | 24 | Preservado na votação |
| Arena | Posto | 3671 | 24 | Preservado na votação |
| Arena | House | 1326 | 19 | Encontrado no catálogo atual; preservado |
| Get Out | Meat Factory | 7116 | 24 | Geometria preparada |
| Get Out | Backrooms | 604 | 24 | Geometria preparada |
| Get Out | Office | 1037 | 24 | Geometria preparada |

**Registro da etapa inicial, superado em 26/10:** Get Out estava planejado e indisponível no hub. O recorte atual de perseguição está descrito em [Get Out v0.5](GET-OUT-V05-IMPLEMENTATION.md). A atribuição dos mapas está feita, mas não implementa suas regras, votação jogável, objetivos de fuga, portas, itens, perseguidores ou spawns específicos por papel. Os pontos neutros preparados não definem a lotação final do modo.

Na etapa inicial, House estava em Pending. Na inspeção de 23/10 já estava em Arena, com template preparado e 19 spawns, e foi preservado nessa condição. Também foram encontrados templates adicionais de Get Out, além de Crossroads/Nuketown entre os originais da Arena. Essa presença não comprova preparação jogável, conectividade ou gameplay testado. Este patch não atribuiu novas modalidades a esses conteúdos.

### Tratamento dos assets

- Originais preservados em ServerStorage, incluindo seus scripts.
- Cópias de jogo sem scripts importados, SpawnLocations, assentos ativos, prompts, ClickDetectors ou joints/constraints externos.
- Partes ancoradas. Em Office, 82 peças originalmente soltas ficam estáticas na cópia.
- Factory continha dois scripts de porta/luz. Meat Factory continha 16 scripts, incluindo trechos de porta incompletos e referências incorretas. Não são executados nas cópias preparadas; portas ficam estáticas e precisam de integração própria com Get Out.
- Sons embutidos não iniciam automaticamente. Luzes e texturas são preservadas. Backrooms possui 400 luzes; Meat Factory tem mais de sete mil partes. Ambos exigem avaliação de desempenho em aparelhos modestos.
- Os seis mapas novos foram fornecidos pelo usuário. Autoria/IDs de origem não foram inferidos. Créditos conhecidos de Pátio e Posto permanecem preservados.

## Testes realizados

| Verificação | Resultado |
|---|---|
| Contratos | **53 aprovados, zero falhas**; seis novos casos de catálogo, suporte, teto e distribuição de spawns. |
| Fontes e pacotes | 81 fontes comparadas entre disco e Studio, sem diferenças de conteúdo após normalizar espaços finais. Os 69 fontes de cada pacote também foram comparados com os atuais, exceto a configuração de papel intencional. |
| Preparação | Oito mapas com 24 marcadores cada; nenhuma peça solta, script, SpawnLocation ou prompt nas cópias jogáveis. |
| Carregamento Arena | Os cinco mapas foram carregados pelo ArenaMaps e limpos em QA no servidor; todos os 24 pontos de cada mapa passaram pela revalidação física. |
| Get Out | Geometria dos três mapas instanciada temporariamente; todos os 24 pontos de cada mapa passaram pela validação. Não foi testado gameplay de Get Out. |
| Cancelamento | Carregamento interrompido sem deixar cenário ou spawns ativos. |
| UI | Cinco cartões visíveis pelo catálogo; navegação simulada por D-pad até Posto fez a lista rolar. Captura da interface inspecionada. |
| Fluxo da partida | Voto real via remoto em Factory: 1 voto; mapa vencedor carregado e jogador com 200 HP a aproximadamente 0,60 stud de um spawn preparado após acomodação física. |
| Retorno | Hub ativo, mundo da Arena removido e câmera de combate desativada. Get Out permaneceu planned e canEnter=false. |

As alterações de tempo feitas em tabelas de QA não modificaram as definições persistidas nem foram usadas como prova de mudança de duração da partida. Os testes ocorreram com um cliente de Studio; não cobrem multiplayer humano, controle/celular físico, desempenho, conectividade de todas as salas, cada canto dos mapas ou publicação.

O console manteve os erros já conhecidos do plugin GUIEditor e avisos da ferramenta sobre StarterPlayerScripts; houve aviso de movimento antes de existir personagem. Não apareceram erros dos novos módulos no percurso testado.

## Fontes, pacotes e recuperação

Novos módulos da etapa original de mapas: MapLibrary, MapSpawns e CrossgroundsMapTools. Naquela etapa, o patch ampliou importação/validação com SpawnRegions e incluiu testes de contrato. Em 26/10, as fontes de teste foram movidas para tests, fora de src e do Place; MapTools passou para Development.Tools.

O backup histórico **CrossgroundsMapOrganizationBaseline_1792708993** está no arquivo historical-packages.rbxm descrito no [manifesto de recuperação](../artifacts/storage-organization-2026-10-26/ARCHIVE-MANIFEST.md). Os originais atuais ficam em Development.MapSources.

| Pacote | Bytes | SHA-256 |
|---|---:|---|
| [Hub atualizado](../artifacts/crossgrounds-hub-arena-mobile-2026-10-23.rbxm) | 169236 | B6DD440DF9F36676D20956F52F0344ABEBE234A13E967F03A91D6B0E99FE5549 |
| [Arena com seis templates](../artifacts/crossgrounds-arena-mobile-2026-10-23.rbxm) | 1038080 | 016F8C0A9C957CC8C5A50282E2F9768819A73D9EE84815895C3C16B89588EDB7 |

São pacotes por serviço, com 80 fontes cada, não Places completos ou instaladores. O pacote de Arena inclui os seis templates desse modo; originais e templates de Get Out ficam no projeto atual do Studio. O pacote de Hub não carrega geometria de mapas. As instâncias Crossgrounds_hub_ArenaBugfixBundle e Crossgrounds_arena_ArenaBugfixBundle foram exportadas junto do histórico em 26/10 e retiradas do Place.

Para atualizar um Place de teste, distribua os conteúdos por serviço conforme o [guia de Places](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md), usando **CrossgroundsMaps.Arena** como biblioteca atual. Não mantenha cópias duplicadas dos scripts de inicialização.

Estado daquela etapa: Studio em edição, combinedPrototype, entradas locais CTF/Arena habilitadas, TeleportEnabled=false. Sem publicação, alteração de start place ou instalação no Place remoto 84561729907420.

## Atualização de 23/10 — Dust e pacotes atuais

Dust recebeu sete regiões de spawn, verificação de saídas e 56 pontos preparados. Três ficam reservados aos alvos de treino; 53 são elegíveis para jogadores. A seleção de nascimento também penaliza linhas de visão de inimigos. Originais e os 24 pontos anteriores foram preservados no backup ArenaBugsBaseline_20261023.

O catálogo real passou a incluir **Nuketown**, preservado sem exploração neste patch. Os pacotes atuais têm **98 fontes**: [Hub com fonte do lobby](../artifacts/crossgrounds-hub-bugs23-2026-10-23.rbxm) e [Arena com sete templates](../artifacts/crossgrounds-arena-bugs23-2026-10-23.rbxm). O snapshot local tem 119 fontes e 84 contratos aprovados. As tabelas anteriores registram pacotes históricos.

Continue deixando originais em ServerStorage.Development.MapSources, separados por modalidade, e os templates preparados em CrossgroundsMaps. Novos spawns internos devem usar SpawnRegions com FloorY e passar pela validação. Não espalhe cópias jogáveis no Workspace persistente.

Detalhes e limites: [relatório atual](MENU-LOADOUT-VIEWMODEL-ARENA.md).
