# Crossgrounds — Relatório da primeira implementação

> Fotografia da primeira base (v0.3), anterior à autorização da Arena de testes. Para a etapa seguinte, os pacotes de Hub/Arena e a criação dos Places, consulte [Places e Arena de testes](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md).

**Data:** 22/10/2026  
**Estado real:** base local integrada implementada e exercitada no Roblox Studio; integração publicada entre Places pendente.  
**Publicação:** nenhuma. O Place legado e os pacotes anteriores foram preservados.

## 1. Leitura e situação encontrada

Foram lidos integralmente `CROSSGROUNDS-CODEX-MIGRACAO.md`, `roblox_hub_design.md` v0.2 e `ESTADO-DO-DESENVOLVIMENTO.md`. O inventário anterior às mudanças está em [CTF-MIGRATION-AUDIT.md](CTF-MIGRATION-AUDIT.md).

O código local correspondia às 38 fontes do CTF inspecionadas no Studio. Não há sincronização Rojo configurada neste workspace. A implementação foi aplicada às instâncias reais **e** salva em `src/`. Ao final, 58 fontes locais foram comparadas às respectivas instâncias: **zero diferenças**, normalizando finais de linha.

A consulta real a `AssetService:GetGamePlacesAsync()` retornou somente o Place **4375993208**, no Universe **1404405130**. Não foram encontrados destinos separados confirmados para hub e CTF. A janela/listagem já se chamava Crossgrounds (BETA), enquanto `game.Name` ainda trazia o nome antigo; esta tarefa não renomeou a experiência.

## 2. O que foi implementado

### Núcleo e fluxo de ingresso

- Catálogo com **CTF como único protótipo jogável**; Get Out, Duels e Arena aparecem como planejados, com cartões informativos e entrada bloqueada no cliente e no servidor.
- Não foram inventadas capacidades para os jogos futuros, nem implementadas suas variantes, habilidades ou filas.
- Coordenador com adaptadores registrados por ID, estados de sessão do modo e estados de solicitação: `idle → joining → ready → entering`, mais `travelling` e `failed`.
- Provedor local de solicitações, com confirmação, cancelamento antes da transição, ticket por solicitação e recusa de tickets expirados/consumo duplicado.
- **Não existe matchmaking ou reserva de vaga.** “Preparar entrada” verifica a rota e permite ir à preparação CTF neste servidor; a vaga na partida continua sendo verificada pelo serviço de equipes do CTF quando o jogador escolhe o kit.
- Protocolo novo em `ReplicatedStorage.Crossgrounds.Remotes`, separado de `ReplicatedStorage.Events`. O servidor valida formato, ações, ticket, modalidade, contexto e frequência. Place ID não é aceito do cliente.
- Snapshot com revisão para o cliente ignorar respostas antigas; espera local não é convertida em sucesso fictício.
- Erros de adaptador são capturados; transições e falhas de transporte têm feedback recuperável.

### Hub e acessibilidade

- Área provisória em torno de **(900, 80, 340)**, em `Workspace.CrossgroundsPrototype`, sem alteração de terreno. Piso, barreiras e placas simples; **não é cenário final**.
- Tela inicial Crossgrounds com catálogo, disponibilidade, descrição, confirmação/cancelamento e acesso a ajustes.
- Reutilização de `MenuNavigation`, `InputIcons` e `ControlRouter`: foco, D-pad, cursor artificial, confirmar/voltar, mouse e botões `Activated` compatíveis com toque.
- Navegação adicionada por setas, Enter, Tab/Shift+Tab e Escape, respeitando campos de texto.
- Ajustes globais existentes reutilizados: FOV, sensibilidade, volume, intensidade do feedback de dano e remapeamento. Nenhum schema ou binding padrão foi alterado.
- Corrigidas nesta integração a sobreposição dos atalhos na seleção de kit, a descrição fora da área visível em tela pequena e a sobreposição do catálogo durante os ajustes.
- No hub, comandos CTF ficam bloqueados. No papel de hub isolado, os controladores locais de combate não são iniciados e não aguardam remotes de combate inexistentes.

### Adaptação do CTF

- `MainGameScript` passa a delegar a inicialização ao novo bootstrap.
- `CTFAdapter` inicia o GameManager e seu loop uma única vez. Conserva o loop interno de preparação, partida e resultados.
- Entrada local muda o contexto para CTF e leva à preparação/treino já existente, onde se escolhe kit e entra na partida.
- **Voltar ao treino/preparação CTF** conserva seu significado anterior. **Voltar ao Crossgrounds** é uma ação separada na seleção de kit e nos ajustes.
- Saída para o hub larga a bandeira, retira participação/equipe, remove voto, interrompe o acompanhamento de dano/regeneração do personagem e retira as ferramentas reconhecidas do CTF.
- HUD, indicadores de interação, feedback de combate e apresentação de arma ficam inativos fora do CTF; câmera e visibilidade são restauradas e o viewmodel é destruído.
- Conexões de transporte de bandeira são desconectadas ao limpar o carregador. `DamageService:Unwatch` permite desativar e reinstalar o acompanhamento do personagem ao mudar de contexto.
- A votação continua sendo apenas a votação de mapas do CTF, com **Travessia como única opção real**.

### Limite do ciclo de vida local

O protótipo integrado mantém o GameManager, as equipes Blue/Red e serviços globais do CTF inicializados no servidor. Sem participantes, o modo fica ocioso e sem bots. A saída limpa e bloqueia **a participação e apresentação daquele jogador**; não descarrega todo o jogo da memória.

Os três ciclos repetidos e a contagem de GUIs não constituem um perfil completo de conexões, CPU ou memória. A implantação final em Places separados continua sendo o caminho preparado para isolar processos de jogos distintos. Não há carregamento/descarregamento arbitrário de futuros jogos neste servidor.

O registro de adaptadores é uma fronteira inicial, não suporte automático a jogos novos: PlayerContext/ModeScope reconhecem hub e CTF nesta entrega. Cada modalidade futura precisa de adaptador, contexto e ciclo de vida próprios. O papel hub também não apaga nem desativa os scripts externos do mapa legado; se executado neste mesmo Place, esses objetos continuam presentes.

## 3. Configuração e viagem entre Places

Configuração atual em `ServerStorage.CrossgroundsConfiguration`:

```lua
PlaceRole = "combinedPrototype"
EnableLocalCTFPrototype = true
TeleportEnabled = false
ApprovedUniverseId = nil
HubPlaceId = nil
CTFPlaceId = nil
```

Os papéis `hub`, `ctf` e `legacy` estão previstos na configuração. O papel `hub` foi testado localmente com spawn e respawn próprios, preferências e catálogo, sem iniciar o loop CTF. Os papéis `ctf`/`legacy` não foram validados em Places separados. A configuração final foi restaurada para `combinedPrototype`.

`TravelService` contém a integração servidor-autoritativa com `TeleportAsync` e `TeleportOptions`, mas **permanece desativado**:

1. Exige ativação explícita, IDs inteiros válidos e Universe aprovado igual ao servidor atual.
2. Confere o destino no catálogo real de Places da experiência.
3. Recusa rota de viagem para o próprio Place e recusa teleporte no Studio.
4. Trata exceção imediata, `TeleportInitFailed`, solicitação duplicada e timeout sem confirmação.
5. Não afirma que o jogador chegou: `travelling` significa somente viagem solicitada.
6. Dados de chegada são informativos. O papel configurado no **servidor de destino** decide o contexto; TeleportData não concede entrada privada, recompensa ou autorização.

Não há MemoryStore, servidores reservados, grupos, filas entre servidores, confirmação de chegada distribuída ou controle de acesso privado configurados por este patch.

## 4. Preservação do legado

| Item | Evidência |
|---|---|
| Duas equipes, até seis combatentes por lado | Em Play: um humano Blue + cinco bots Blue e seis bots Red. |
| 200 HP | Confirmado no hub, preparação, arena e respawn. |
| Rodadas de 300 s, três capturas, preparação de oito segundos | Configurations e GameManager inalterados; início após preparação e fim na terceira captura exercitados. Não foi aguardado o término integral de cinco minutos. |
| Três kits, armas, dano, cadências, movimento e salto | KitDefinitions e Configurations inalterados. Não houve rebalanceamento. |
| Spawns e proteção | SpawnService inalterado; 24 pontos por equipe e atributo de proteção observados em Play. Todas as combinações de ocupação/linha de visão não foram testadas. |
| Travessia e coordenadas dos bots | 56 registros de CFrame/tamanho das bases iguais antes/depois; nenhum terreno foi movido ou regenerado. BotBrain e MapManager inalterados. |
| Templates e recursos Studio | CTFInfrastructure, CTFLobby, CTFMaps, CTFBotTemplate, KitTools e LegacyStarterTools preservados. |
| Armas nativas | Tools mantidas; WeaponFactory inalterado. |
| Preferências e controles | SettingsService, ExperienceSettings, ControlDefinitions, InputIcons e InputMode inalterados. Store CTF_ExperienceSettings_v1 e chaves anteriores preservados. |
| Chat | TextChatService permaneceu configurado; nenhuma alteração feita. |

## 5. Testes executados

Ambiente: Roblox Studio conectado, um cliente local, fontes reais aplicadas. Remotes de jogo foram exercitados sem requerer novamente os serviços ativos por ferramentas de teste.

| Teste | Resultado real |
|---|---|
| Referência anterior à migração | Playing, 200 HP, Kastov equipado, 11 bots e 24 spawns por lado. |
| Inicialização integrada | Jogador no hub em (900, ~83.5, 352), neutro, pronto, fora da arena/partida, zero bots. |
| Catálogo e modos planejados | CTF disponível localmente; tentativa direta de entrar em Arena rejeitada, mantendo idle. |
| Injeção de Place ID pelo cliente | Rejeitada como campo não permitido; nenhuma viagem. |
| JoinMatch legado enviado do hub | Não inseriu o jogador na partida, não criou armas/bots. |
| Preparar/cancelar/repreparar | ready → idle → novo ticket; cancelamento com ticket errado preservou ready. |
| Entrada pela UI simulada de controle | Preparação CTF e escolha de kit; confirmação iniciou a partida. |
| Equipes | Um humano + 11 bots, divididos 6/6. |
| Bandeira inimiga | Coletada e visual de transporte ativado. |
| Morte carregando | Bandeira mudou para dropped. |
| Recuperação pelo dono | Bot da equipe dona foi colocado sobre a bandeira caída; estado voltou a home. A primeira tentativa com bot ancorado não disparou interação; a repetição desancorada funcionou. |
| Entrega e placar | Capturas 1, 2, 3; terceira encerrou em Results e removeu os bots. |
| Retorno ao hub carregando | Jogador neutro, sem ferramentas CTF, câmera Custom, HUD/JoinMenu ocultos, viewmodel ausente; bandeiras home e zero bots após o loop sem participantes. |
| Três ciclos consecutivos preparação ↔ hub | Seis transições prontas; bootstrap, coordenador e loop CTF continuaram em 1. Na verificação cliente, uma instância de cada GUI, sem duplicação observada. |
| Disparo e dano | RT consumiu munição; alvo temporário inimigo no servidor caiu de 200 para 171 HP. Alvo e ajustes de QA existiram somente em Play. |
| Recarga | X repôs a munição do Kastov de 24 para 26. A chamada de inspeção chegou depois da animação lógica; a fase intermediária Reloading=true não foi capturada nesta medição. |
| Corrida | Alternância ativou SprintActive e houve consumo de estamina. Curva completa de esgotamento e aumento de FOV não foram medidos neste patch; código de movimento e fórmula de FOV foram preservados. |
| Câmera | Scriptable com arma; RS ativou primeira pessoa e FirstPersonWeapon; retorno ao hub restaurou Custom e removeu o modelo. |
| Preferência entre contextos | FOV definido em 82 foi conservado ao voltar do CTF ao hub, na mesma sessão. |
| Ajustes no hub | Abertura/fechamento com controle e mouse de PC; D-pad alterou FOV 70 → 71 e mostrou ícones apenas no campo focado. |
| Teclado | Setas/Tab/Enter exerceram o foco e a confirmação; LastMenuInput e mudança de menu observados. |
| Simulador Xbox One | UI capturada em viewport 1920×1080, navegação com entradas simuladas de gamepad; cursor nativo reportou false. Não equivale a console físico. |
| Simulador iPhone 17 Pro | LandscapeSensor, viewport reportado 749×381; catálogo e descrição visíveis. Clique sintético de ajustes por caminho nessa simulação não acionou o menu. Toque físico e teclado virtual continuam pendentes; clique de PC foi confirmado separadamente. |
| Destino indisponível | Local temporariamente desabilitado, teleporte desligado: canEnter=false, rota unconfigured e solicitação direta failed com motivo; permaneceu no hub. Configuração restaurada. |
| Papel hub isolado | Sem loop CTF e sem GUIs de combate; spawn e respawn após morte em (900, ~83.5, 352), 200 HP. |
| Compilação | 58 fontes verificadas com loadstring em edição, zero erros de sintaxe. |
| Integridade | 58 fontes iguais local/Studio; 56 transformações/tamanhos das bases preservados. |

Para isolar interações de bandeira e dano, bots foram temporariamente afastados/ancorados em alguns testes. O primeiro ingresso verificou população e movimento sem essa intervenção. Isso **não** valida uma partida longa de IA natural; todos os ajustes desapareceram ao parar o Play.

### Contratos automatizados

**25 executados, 25 aprovados, zero falhas**, com a skill `rbx-unit-test` e um runner manual, sem framework prévio detectado:

- GameCatalog: 3 casos.
- SessionProtocol: 4 casos.
- QueueProvider: 7 casos.
- TravelService: 11 casos com dependências simuladas.

Incluem modalidades planejadas, cópias do catálogo, formato de comandos, tickets inválidos, duplicidade, cancelamento tardio, estado por jogador, destinos ausentes/externos, Universe incorreto, bloqueio no Studio, falhas imediatas/tardias e timeout.

Resultado resumido: [crossgrounds-contract-tests-2026-10-22.md](../artifacts/crossgrounds-contract-tests-2026-10-22.md).

Para reproduzir, iniciar Play e executar **no servidor**:

```lua
require(game.ServerStorage.UnitTest.RunUnitTest)(nil, 5)
```

`ServerScriptService.UnitTestRunner` está **desativado**. Não executá-lo junto com a chamada manual. Os IDs sintéticos das fixtures não são configuração real e nenhum teste automatizado envia teleporte ou usa DataStore/rede.

### Falhas observadas e limites da verificação

- O plugin externo `cloud_340936329.GUIEditor.PluginTool` continua lançando “attempt to call a nil value”. Não foi modificado.
- `Workspace.Teleporter.Tele1.Script` e `Tele2.Script`, que não foram alterados, lançam erro ao acessar Humanoid em objetos do cenário. Precisam de correção própria antes de declarar o Output inteiro limpo.
- A ferramenta registrou avisos de `TestService.Folder.StarterPlayerScripts` durante suas operações e `Player:Move` quando ainda não havia personagem. As fontes/instâncias arquivadas e as 58 fontes finais foram conferidas.
- Na primeira implementação do papel hub, o carregamento do avatar sobrescrevia o Pivot e clientes esperavam remotes ausentes. A ordem de spawn e o escopo dos clientes foram corrigidos; repetição confirmou posição/respawn e deixou de registrar aqueles avisos de espera por remotes CTF.
- Não foram encontrados erros de sintaxe ou exceções atribuídas aos novos módulos nos percursos finais testados. Isso não significa ausência total de erros no projeto ou cobertura de todos os caminhos.

## 6. Arquivos e instâncias alterados

### Novos fontes de runtime: 14

- `ServerStorage/CrossgroundsConfiguration.luau`.
- `ReplicatedStorage/Crossgrounds/{GameCatalog,SessionProtocol}.luau`.
- `ServerScriptService/Crossgrounds/{HubBootstrap,HubScene,PlayerContext,SessionCoordinator,QueueProvider,TravelService,PreferenceAdapter,CTFAdapter}.luau`.
- `StarterPlayer/StarterPlayerScripts/{ModeScope,HubBridge,HubController}.luau`.

### Fontes legados alterados: 18

| Grupo | Arquivos | Mudança |
|---|---|---|
| Bootstrap | MainGameScript | Delegação ao Crossgrounds. |
| Servidor CTF | PlayerManager, KitService, MovementService, MapVotingService | Contexto, ingresso/saída e bloqueio fora do modo. |
| Limpeza CTF | DamageService, FlagService | Unwatch/regeneração e conexões de transporte. |
| Cliente compartilhado | MenuNavigation, ControlRouter, ExperienceMenu | Foco, teclado, escopo e acesso ao hub. |
| Cliente CTF | JoinMenu, CombatHUD, CombatPresentation, ExperienceFeedback, ControlHints, InteractionController, WeaponController, SprintController | Visibilidade, entrada/saída, restauração e bloqueio/inicialização por papel. |

### Novos fontes de teste: 6

`ServerStorage/UnitTest/RunUnitTest.luau`, quatro módulos em `UnitTest/Cases/` e `ServerScriptService/UnitTestRunner.luau` desativado.

**Total:** 38 fontes anteriores + 14 de runtime + 6 de teste = **58**. Nenhum fonte ou recurso legado foi removido.

Instâncias novas de edição: pasta de servidor Crossgrounds, configuração, catálogo/protocolo, três fontes de cliente, infraestrutura de testes, área provisória e pacote de recuperação. Remotes do hub e GUIs são criados no runtime, sem dependência de edição manual desses objetos.

## 7. Backups, recuperação e sincronização

| Pacote local | Tamanho | SHA-256 |
|---|---:|---|
| `artifacts/pre-crossgrounds-1792655809.rbxm` | 588123 bytes | C5257CD9CB4DC47AEDE8103CD3DF24F978E7023FE4264A6A48A4181223AA72C1 |
| `artifacts/crossgrounds-base-2026-10-22.rbxm` | 615686 bytes | 35418C130E358F39931CD5942D08CBBE386A1B4BE18D1CDB7CFFF7FF032CF7B1 |

Correspondem a `ServerStorage.CrossgroundsMigrationBaseline_1792655809` e `ServerStorage.CrossgroundsRecovery_1792659800`. Ambos organizam conteúdo por serviço, incluindo dependências e a região de terreno registrada no inventário. O pacote novo contém as 58 fontes finais e a área provisória.

**São pacotes de recuperação, não Places completos nem instaladores.** Não arrastar a pasta inteira para Workspace esperando que os scripts funcionem. Restaurar em uma cópia de trabalho do Place, distribuindo o conteúdo aos serviços correspondentes e preservando classes e Enabled dos scripts; as pastas arquivadas de serviços são contêineres organizacionais. O terreno cobre apenas a região documentada.

O backup anterior conserva as fontes/recursos anteriores. Nenhuma restauração foi executada sobre o projeto vivo. Não há sincronização automática: fontes locais e instâncias do Studio precisam continuar sendo atualizadas juntas, ou um fluxo de sincronização deverá ser configurado explicitamente.

Git continua no branch master sem commits, com os arquivos do projeto não rastreados. Não houve reset, clean, stash, commit, push ou publicação.

## 8. Pendências e próximos passos

### Integração que depende do Studio/Creator Dashboard

1. Criar/associar Places reais de hub e CTF na experiência escolhida; confirmar propriedade, Universe e destinos. O único Place comprovado nesta tarefa foi 4375993208.
2. Importar e distribuir os recursos por serviço em cópias, mantendo mapa/terreno/templates do CTF e os módulos compartilhados necessários aos ajustes.
3. Configurar PlaceRole, HubPlaceId, CTFPlaceId e ApprovedUniverseId com IDs reais. A configuração atual não contém destinos fictícios.
4. Rever acesso privado, permissões e ingresso direto no Creator Dashboard; este patch não habilitou acesso a Places privados.
5. Somente com autorização, publicar versões privadas e testar em cliente Roblox: hub → CTF → hub, falhas, reconexão e dados persistidos. Esta etapa não foi feita nem autorizada.
6. Decidir e implementar o provedor de fila/reserva entre servidores quando houver necessidade real e budgets verificados. Não ligar MemoryStore automaticamente.

### Testes ainda pendentes

- Xbox e PlayStation físicos, ícones reais por plataforma, analógicos, remapeamento completo e teclado virtual.
- Toque em aparelho físico, alvos mínimos de toque/legibilidade e orientação em dispositivos modestos.
- Vários humanos, entrada no limite das equipes, desconexão durante transição/partida, partida integral por tempo e latência.
- Perfil de CPU/memória/conexões, longas sessões e IA natural sem reposicionamento de QA.
- Teleporte real e confirmação de chegada, persistência após reconexão/publicação e permissões de áudio/avatar.
- Matriz completa de armas, melee, friendly fire, proteção/ocupação de todos os spawns e todas as opções dos ajustes.

### Recursos que continuam incompletos

Empunhadura com duas mãos, animações de combate próprias, acabamento do viewmodel, naturalidade dos bots, áudio completo, arte do hub, mapas adicionais e navegação de bots independente de coordenadas continuam como no relatório do legado. Não foram declarados concluídos por esta migração.

Para mapas futuros, propõe-se um contrato de marcadores de bases, objetivos, spawns e rotas por mapa, com validação antes de ativação. Essa generalização **não está implementada**. Get Out Especial 5/7/9, capacidades de filas de Duels e lotação comum da Arena permanecem decisões abertas.

## 9. Estado final entregue

Studio parado em edição, viewport padrão restaurado, configuração local integrada ativa, teleporte desativado, runner de testes desativado, sem objetos de QA persistidos. Base local e adaptação exercitadas; liberação em produção permanece pendente.

