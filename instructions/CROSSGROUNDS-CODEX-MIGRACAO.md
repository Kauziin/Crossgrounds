# CROSSGROUNDS — Instrução de implementação para o Codex

**Data:** 22/10/2026  
**Objetivo:** criar a primeira base modular de **Crossgrounds** e adaptar, de modo incremental e verificável, o protótipo de Capture a Bandeira (CTF) já existente para funcionar como o primeiro jogo do hub.  
**Classificação:** ordem de execução **com guardrails**. Executar alterações efetivas de código, não apenas produzir uma proposta. Não publicar sem autorização.

---

## Contexto e fontes obrigatórias

Você (Codex) está trabalhando na máquina do desenvolvedor. O projeto CTF original foi descrito como:

- Workspace: `C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio`
- Experiência legada: `[SENTINELAS!]Capture a Bandeira!(BETA)`
- **Place ID legado:** `4375993208` — **não** assumir que seja o Place inicial de Crossgrounds ou um Universe ID.
- Documento de estado da implementação: `ESTADO-DO-DESENVOLVIMENTO.md`, anexado pelo desenvolvedor e que deve ser localizado no workspace ou recebido como referência. Se não existir localmente, informar a ausência e usar o conteúdo encaminhado na conversa; não afirmar que você o abriu.
- Documento de design atualizado: `roblox_hub_design.md` (v0.2), ou o arquivo equivalente que o usuário inserir no repositório.

**Leia primeiro o projeto real**, inclusive mapeamento de sincronização Studio/Rojo, arquivos de configuração, pastas `src/`, scripts, notas de patches, templates e instâncias acessíveis via Studio. O relatório é uma fotografia do estado de desenvolvimento, **não uma verdade superior ao código vivo**.

Arquivos citados no relatório (os caminhos efetivos devem ser verificados):

- `src/ServerScriptService/MainGameScript/GameManager/WeaponFactory.luau`
- `src/ServerScriptService/MainGameScript/GameManager/KitService.luau`
- `src/ServerScriptService/MainGameScript/GameManager/BotBrain.luau`
- `src/StarterPlayer/StarterPlayerScripts/CombatPresentation.luau`
- `src/ReplicatedStorage/ExperienceSettings.luau`
- `src/ReplicatedStorage/KitDefinitions.luau`
- `ExperienceMenu.luau`, `MenuNavigation.luau`, `ControlRouter.luau`, `InputIcons.luau`, `SettingsService.luau`, `BotManager.luau`, `AvatarService.luau`.

Atenção especial a `ServerStorage.CTFBotTemplate`, `ServerStorage.CTFMaps`, terreno, lobby, bandeiras, spawns e objetos criados/guardados no Studio. O estado registrou **38 arquivos em `src`**, mas também recursos que **não são completamente representados em arquivos de origem**. Os `artifacts/*.rbxm` relatados são pacotes de recuperação por serviço, **não Places completos**.

## Decisões do criador que não podem ser substituídas por suposições

1. O projeto chama-se **Crossgrounds**.
2. O hub poderá reunir **Get Out**, **Duels**, **Arena** e **Capture a Bandeira**; o CTF é o **primeiro módulo técnico a integrar**, mas ainda pode não integrar o lançamento público.
3. Acessibilidade para **controle físico (Xbox e PlayStation)** é prioridade, e PC/celular também precisam ser considerados.
4. Os jogos terão votações. A Arena pretende votar em variantes **depois de formar uma sala**, desde que todas usem a mesma lotação.
5. Get Out será dividido em **Clássico** e **Especial**; os especiais têm **5, 7 e 9 participantes**. **O método de votação/matchmaking para essas lotações não foi decidido.** Não implementar escolha automática arbitrária, nem remover participantes de uma sala montada.
6. Duels e suas filas também têm regras e capacidades ainda indefinidas.
7. O CTF hoje opera em **duas equipes de até seis jogadores/bots**; futuras ideias de múltiplas equipes e mapas militares são **futuras**, não requisitos deste patch.
8. O nome do CTF dentro do hub pode permanecer descritivo (*Capture a Bandeira*) até futura definição; não inventar uma marca separada.

---

## Meta técnica da primeira entrega

Ao terminar esta tarefa, deve haver uma **base do Crossgrounds navegável e extensível**, um **catálogo de modalidades**, um **fluxo de entrada no CTF compatível com a situação de Places disponível**, e o **CTF legado ainda jogável** com suas principais regras preservadas.

A migração deve criar **fronteiras claras**:

- **Núcleo de Crossgrounds:** catálogo/estado de disponibilidade de jogos, navegação do hub, preferências compartilháveis, serviços de ingresso/saída, abstração da fila, comunicação e erros.
- **CTF:** bandeiras, kits, armas, bots, mapa Travessia, regras de vitória, spawns, placar, HUD próprio, loop de partida e compatibilidade com controles existentes.
- **Futuras modalidades:** interfaces/registradores preparados, **sem implementar Get Out, Duels ou Arena nesta tarefa**.

A primeira entrega deve funcionar **mesmo que o sistema global de filas entre servidores e a divisão definitiva dos Places ainda não tenham sido autorizados**. A implementação deve explicitar esse limite em vez de simular um serviço de produção.

## Fase 0 — Inventário, segurança e retorno possível

1. Inspecione `git status`, branch, mapeamento de Places, arquivos de projeto, todos os pontos de inicialização de servidor/cliente e dependências locais.
2. Não use `git reset --hard`, `git clean`, sobrescrita indiscriminada ou `git stash` automático. Não apague alterações locais do desenvolvedor. Se houver alterações não commitadas, preserve-as e documente-as. Use um branch de trabalho apenas quando isso for seguro e não interferir no estado atual.
3. Prepare um registro de **arquivos e instâncias dependentes do Studio** para que a migração não deixe recursos invisíveis para a ferramenta de sincronização.
4. Registre a referência anterior de funcionamento (o que efetivamente consegue executar/testar). Diferencie código compilável, testes de Studio e testes publicados.
5. **Não renomeie nem publique a experiência antiga automaticamente.** Não migre dados de DataStore sem planejamento explícito: o CTF legado pode estar em outro Universe, e as preferências/dados não estarão necessariamente no mesmo escopo da nova experiência.
6. Se usar backup, mantenha-o fora das pastas sincronizadas automaticamente, sem sobrescrever os pacotes `.rbxm` existentes.

**Entrega desta fase:** `docs/CTF-MIGRATION-AUDIT.md`, contendo inventário e riscos, bem como o que exigirá intervenção manual no Roblox Studio/Creator Dashboard.

## Fase 1 — Base de Crossgrounds e registro de modalidades

Criar os módulos efetivamente necessários ao MVP, respeitando o formato e a organização do projeto que você encontrar. Os nomes seguintes são **sugestões de responsabilidade**, não obrigação de árvore de arquivos exata:

- `GameCatalog` / `GameRegistry`: metadados e disponibilidade de Get Out, Duels, Arena e CTF.
- `HubBootstrap` / `HubController`: inicialização e navegação do hub.
- `SessionCoordinator`: coordenação do ingresso, preparação, jogo, resultados e saída; o código do CTF pode conservar inicialmente seu loop interno por trás do adaptador.
- `QueueProvider` / `QueueService`: interface para entrar, cancelar, consultar estado e reagir a lotação; uma versão **local explicitamente rotulada como protótipo** é aceitável nesta fase.
- `TravelService`: entrada no Place do modo e retorno ao hub por APIs servidor-autoritativas; sem IDs inventados.
- `PreferenceAdapter`: reutilizar configurações acessíveis sem quebrar chaves já persistidas do CTF.
- `Input/NavigationAdapter`: menus coerentes com teclado, toque e gamepad, de preferência reutilizando `MenuNavigation` e `ControlRouter` onde fizer sentido.

**GameCatalog** deve conter apenas dados confirmados:

| Modalidade | Disponibilidade nesta etapa | Tratamento |
|---|---|---|
| CTF | **Protótipo jogável**, após integração e verificação | Entrada funcional quando o destino existir; fallback claro se não estiver configurado |
| Get Out | Planejado | Card informativo/desabilitado; sem fila funcional fictícia |
| Duels | Planejado | Card informativo/desabilitado |
| Arena | Planejado | Card informativo/desabilitado |

Usar configuração para IDs reais dos Places; **não** usar `4375993208` como ID do hub sem provar que a organização dos Places o permite. Para variantes ainda não definidas, não forçar `minPlayers/maxPlayers` falsos: aceitar campos opcionais e estados explícitos como `planned`, `prototype`, `available`.

Não gerar cenário completo ou arte final nesta etapa. Se não houver Place de Hub criado, montar a lógica/UI e um **cenário provisório isolado**, de forma que o desenvolvedor possa depois associá-lo manualmente a um novo Place sem prejudicar o CTF original.

## Fase 2 — Adaptador do CTF e isolamento de responsabilidades

Refatore com o menor desvio de comportamento possível. **Não reescreva o CTF do zero.**

- Identifique o bootstrap legado que hoje sobe a partida, lobby, mapas, bots, armas e UI. Deixe seu acionamento explícito e evite inicializações duplicadas quando o Crossgrounds passar a iniciar o jogo.
- Crie uma interface/adaptador para o CTF fornecer ao núcleo: `id`, versão/estado do modo, entrada/saída, estados da sessão, eventos de início/fim e solicitação de retorno. Não imponha que futuros jogos tenham `KitService`, `Tool`, bandeiras, duas equipes ou exatamente o mesmo loop.
- Reutilize os módulos atuais de HUD, câmeras, combate, bots, inventário visual e menus **com escopo CTF**. Só extraia funções para o `Shared` quando sua API for realmente genérica e puder ser testada sem parâmetros específicos de CTF.
- Mantenha namespaces de `RemoteEvent`, módulos de servidor, controle local e configurações suficientemente separados para evitar colisões quando outros modos forem adicionados.
- Implemente ciclo de vida/limpeza: conexões de eventos, tarefas, objetos temporários, times, HUD e estado local não devem permanecer ativos após a saída da sessão. Se for mais seguro delegar isso ao teletransporte entre Places, documente a escolha.
- **Não troque as `Tool` nativas por um sistema novo agora.** O relatório mostra que isso ainda é uma migração parcial; reescrevê-la junto com o hub introduziria riscos desnecessários.
- **Não corrija as pendências de animações, empunhadura e viewmodel durante a migração** salvo um bug diretamente introduzido pelo refactor.
- **Não altere armas, dano, velocidade, kits, objetivo ou contagem de jogadores.**

Preservar explicitamente os parâmetros atuais: duas equipes, até 6 combatentes por lado entre jogadores e bots, 200 HP, rodadas de 5 minutos, 3 capturas para vitória, preparação de 8 segundos, três kits leve/regular/pesado, mapa `riverside`/Travessia, 24 spawns por equipe e recursos de proteção/ocupação. Usar definições realmente presentes no código se houver divergência; documentar a divergência em vez de ocultá-la.

### Dependência especialmente perigosa: IA e mapas

`BotBrain` utiliza coordenadas fixas relativas ao mapa Travessia (`X = ±32/±42`, `Y = 41`, `Z = -70/0/70`). Não mover nem rotacionar o mapa como efeito colateral do hub. A navegação generalizada para outros mapas **não é parte desta primeira entrega**; documente um contrato futuro de marcadores de navegação/objetivos por mapa.

`ServerStorage.CTFMaps` possui o catálogo, mas apenas `riverside` é real. Não criar opções falsas na votação de mapas.

## Fase 3 — Lobby inicial e fluxo de entrada no CTF

Implementar no MVP:

1. Tela/área inicial identificada como **Crossgrounds**, em vez de tratar o menu inteiro como se o CTF fosse a experiência principal.
2. Seleção visual dos jogos, com **CTF como única opção protótipo acessível**, e demais opções visualmente desabilitadas por estarem em desenvolvimento.
3. Navegação integral por gamepad, usando D-pad/analógico quando adequado, botões de confirmar/voltar e feedback de foco. Preservar a capacidade de navegação por mouse/toque e não depender de hover.
4. Fluxo de **entrar no CTF, cancelar antes de viajar, acompanhar estado, receber erro e voltar**. Definir estados explícitos (`idle`, `joining`, `ready`, `travelling`, `failed`, ou equivalentes) para prevenir ações duplicadas. Não afirmar que saiu de uma fila se a operação falhou.
5. Reutilizar o lobby próprio do CTF como **área de preparação/treinamento do modo**, sem torná-lo obrigatoriamente o lobby central dos outros jogos.
6. Tratar a votação existente do CTF como **votação de mapas do próprio CTF**, distinta da votação de variantes de Arena/Get Out. Uma única opção real não pode ser apresentada como variedade de mapas.
7. Preservar o caminho de retorno ao lobby já existente, decidindo explicitamente se significa `lobby de preparação CTF` ou `hub de Crossgrounds`; oferecer destino claro para ambas as ações quando cabível.

### Viagem entre Places

**Arquitetura recomendada, ainda pendente de confirmação no Studio:** Place inicial de Crossgrounds + um Place próprio de CTF na **mesma experiência/Universe**. Não presumir que o Place legado `4375993208` já pertence a esse Universe ou que o Codex pode transferir sua propriedade. Se a associação não for possível, registrar os passos manuais e **não** ativar botões que simulem teleporte bem-sucedido.

- Preparar a integração real com `TeleportService:TeleportAsync()` a partir do servidor e `TeleportOptions` somente quando IDs, permissões e destinos estiverem confirmados.
- Implementar tratamento de falhas de teleporte e estado de retorno com feedback ao jogador.
- O cliente **não** deve decidir sozinho que pode entrar em uma sessão privada, receber recompensas ou selecionar arbitrariamente o modo. Tratar dados de chegada de teleporte como não confiáveis até verificação pelo servidor.
- O Roblox **não oferece teleporte funcional no Play Test do Studio**: criar um adaptador/mock de teste local que simule somente o **estado da UI e o fluxo**, claramente marcado como simulação; fazer os testes reais entre Places com versões privadas publicadas e autorização do desenvolvedor.
- Não habilitar acesso direto a Places privados de teste inadvertidamente; configurar restrições de acesso no Creator Dashboard quando apropriado.

### Filas: escopo exato do patch

O objetivo é **estabelecer o contrato do serviço e validar a interface/fluxo com CTF**, não lançar um grande matchmaking entre servidores. Um provedor local simples é suficiente no primeiro patch, contanto que esteja marcado como **não pronto para produção**, não invente reservas, não prometa entrada numa sessão que não existe e evite filas falsas.

Projetar a interface para uma implementação futura usando mecanismos oficiais de fila entre servidores, sem ativar `MemoryStoreService` automaticamente. O uso de Memory Stores pode exigir habilitação/configurações/budgets de serviços estendidos conforme as regras atuais da Roblox. Não assumir acesso sem verificação.

Não decidir o modelo dos **Get Out Especial 5/7/9**, não expulsar usuários para adaptar lotação e não misturar regras de votação da Arena no CTF.

## Fase 4 — Controles, segurança e compatibilidade

- Conservar os comandos existentes de CTF, especialmente Xbox/PlayStation: LS para corrida, RS para câmera, Y para trocar arma, LB para Shift Lock, X para recarga/interação, RB para trocar ombro, RT/LT para ataque/mira e D-pad direito para ajustes; usar o código real como referência em caso de discrepância.
- A UI principal deve ter foco consistente, sem exigir cursor nativo de gamepad quando ele estiver suprimido no CTF; validar o fluxo de abertura/fechamento de UI ao trocar de modo ou Place.
- Não sobrescrever silenciosamente bindings entre ações globais (menus, confirmar/voltar) e ações exclusivas do CTF. Evitar conflitos com o remapeamento já existente.
- Toda confirmação de dano, pontuação, recompensa, voto, entrada/saída e eventos sensíveis deve ser validada no **servidor**. Checar tipos, estado, permissão, distâncias, limites e frequência em RemoteEvents/RemoteFunctions. Não duplicar gratuitamente o protocolo existente; auditar e corrigir apenas problemas relevantes ao novo fluxo.
- Não quebrar `SettingsService`, nomes/estrutura de dados persistidos nem o suporte a sessão temporária durante testes do Studio.
- Não alterar `TextChatService` sem motivo.

## Fase 5 — Testes e critérios de conclusão

Execute os testes que as ferramentas locais realmente permitem, sem declarar validação que você não realizou.

**Obrigatórios para considerar o patch tecnicamente concluído:**

- [ ] Código sincroniza/compila no arranjo de projeto real; sem erros novos introduzidos.
- [ ] A UI inicial mostra Crossgrounds e diferencia claramente CTF dos modos não implementados.
- [ ] A interface navega por teclado/mouse, controles simulados e toque quando testáveis; todo botão possui estado/ação coerente.
- [ ] O caminho de retorno do CTF não provoca entradas duplicadas, vazamentos de eventos ou descarte incorreto de UI.
- [ ] CTF mantém as equipes e bots (até 6 participantes por lado), equipamentos e fluxo de partida de 5 min/3 bandeiras.
- [ ] Captura, transporte, queda, recuperação e entrega de bandeira continuam funcionando.
- [ ] Spawn seguro, HUD, câmera, munição, recarga e combate continuam funcionando sem regressão detectada.
- [ ] O mapa Travessia, seus objetos e a IA dos bots permanecem conectados corretamente.
- [ ] Preferências existentes não são perdidas nem regravadas com schema incompatível.
- [ ] Ausência de fila/ID do Place configurado produz erro honesto ou opção desabilitada — **nunca sucesso fictício**.
- [ ] Testes locais e testes que exigem publicação/console físico aparecem em grupos separados no relatório.
- [ ] Código de `Get Out`, `Duels` e `Arena` não foi inventado neste patch.

**Testes que devem ser listados como pendentes se você não tiver capacidade real de realizá-los:** teleporte entre Places no cliente Roblox, múltiplos humanos durante partida longa, controle físico Xbox/PlayStation, persistência publicada, latência, áudio/avatares completos e CPU/memória em aparelhos modestos.

## Entregáveis no workspace

1. **Código da base do Crossgrounds** e da integração/adaptador do CTF, organizado segundo o projeto real.
2. `docs/CTF-MIGRATION-AUDIT.md` — inventário do legado, módulos e instâncias do Studio, decisões de arquitetura, problemas e dependências manuais.
3. `docs/CROSSGROUNDS-IMPLEMENTATION-REPORT.md` — arquivos alterados, o que foi efetivamente implementado, testes executados e resultados, o que não foi possível validar, limitações e próximos passos necessários à integração de Places.
4. Atualização de `roblox_hub_design.md` (ou cópia em `docs/`), preservando distinção entre **definido/proposto/pendente**, sem tratar sugestões como decisões do criador.
5. Se possível, testes automatizados ou verificações mínimas de integridade dos contratos e estados da UI, com instruções reproduzíveis.

### Formato do relatório final do Codex

- **Estado real:** o que agora existe, com arquivos e alterações concretas.
- **Preservação:** o que foi mantido do CTF e por quê.
- **Testes:** cada teste executado, ambiente, resultado e falhas.
- **Integração do Studio:** instâncias ou operações manuais necessárias; Place IDs não identificados.
- **Limitações:** tudo que não foi validado ou que depende de publicação/console real.
- **Diff resumido:** módulos novos, módulos alterados, nenhum arquivo removido sem justificar.

**Não pare após a auditoria:** implemente a base e o adaptador dentro do que estiver acessível, mantendo o CTF estável. Caso uma operação dependa de uma ação manual do desenvolvedor no Studio ou Creator Dashboard, conclua as partes independentes e documente precisamente o bloqueio. Não invente que o fluxo foi testado/publicado.

---

## Referências técnicas oficiais para consulta durante a execução

- [Roblox — Places em experiências](https://create.roblox.com/docs/production/publishing/publish-games-and-places)
- [Roblox — Teleporte entre Places](https://create.roblox.com/docs/projects/teleport)
- [Roblox — MemoryStore e filas](https://create.roblox.com/docs/cloud-services/memory-stores/queue)
- [Roblox — Segurança cliente/servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Roblox — Input multiplataforma](https://create.roblox.com/docs/input)
- [Roblox — Testes no Studio](https://create.roblox.com/docs/studio/testing-modes)

**Documento principal:** `roblox_hub_design.md` (Crossgrounds, v0.2).  
**Fonte do legado:** `ESTADO-DO-DESENVOLVIMENTO.md` (22/10/2026).
