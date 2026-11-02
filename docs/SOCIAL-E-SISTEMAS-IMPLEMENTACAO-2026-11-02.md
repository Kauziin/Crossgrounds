# Social e Sistemas — implementação inicial

02/11/2026. Entrega parcial do planejamento: progressão, persistência versionada, desbloqueios, identidade e cartão de eliminação. Fontes locais aplicadas ao Studio principal 4375993208. Sem publicação.

## Implementado

- `CareerPolicy`: curva normal de 343.710 XP até 55, dez prestígios, Maestria reiniciando em 1 até 1000, Lenda reiniciando em 1 e mantendo desbloqueios. A partir de Maestria 55, custo de 12.000 XP por nível; Lenda usa 12.000. Esses valores são a primeira versão implementada da curva, sujeitos a balanceamento e migração explícita.
- XP histórico separado do XP da etapa. XP de arma e cosméticos conquistados sobrevivem aos resets. Teto não acumula XP para consumir o ciclo seguinte. Um token por modalidade nas dez transições de prestígio e nas entradas de Maestria/Lenda.
- Migração pelo XP histórico, com excedente atravessando as etapas. Em igualdade exata ao custo de uma etapa, deixa a transição disponível para confirmação voluntária. Sem atribuição retroativa de XP de armas.
- `CareerRepository`: sessão proprietária com expiração, revisão de gravação, retenção da transação incerta e recuperação sem somar novamente. Perfis incompletos/futuros e histórico indisponível não são convertidos silenciosamente em perfil vazio.
- `CareerService`: carregamento, gravação, fila de recompensas enquanto há transação pendente, operações confirmadas de prestígio/token/identidade, projeção pública sem inventário privado e limites separados para consultas e mutações.
- `ProgressionService`: integração com os contadores existentes e crédito de XP da arma no evento de recompensa. Arena e Conflict fornecem a arma creditada pelo servidor; estatísticas antigas e moedas são mantidas.
- `UnlockCatalog`/`UnlockService`: requisitos de armas/aparências e acessórios, validação de loadout no servidor e revalidação ao equipar. Preset bloqueado mantém sua intenção salva; equipamento efetivo usa M4A1/M1911 e remove acessórios ainda indisponíveis. Arena conserva atributos comuns e bloqueia apenas escolhas de aparência.
- `CareerClient`/armeiro: requisitos visíveis e seleção bloqueada no cliente, com validação independente do servidor. Prévia continua acessível.
- Catálogo inicial de seis calling cards procedurais, quatro molduras, quatro emblemas e seis títulos. Famílias padrão, eliminações, objetivos, prestígio, Maestria e Lenda; famílias se sobrepõem entre categorias. Recompensas por 100 eliminações e 10 capturas, além das fases de prestígio.
- Menu “Carreira e perfil” no lobby: identidade, personalização, próxima etapa com confirmação, catálogo paginado e uso de tokens. Usa CascadeMenu/MenuNavigation/tema existentes.
- `PlayerIdentityView`: cartão compartilhado com avatar Roblox, fundo, moldura, título, emblema e progressão. `EliminationSpectator` recebe identidade congelada no evento do servidor, mostra também a arma e permite apresentar o cartão mesmo se o modelo do eliminador não estiver mais disponível. Não implementa replay.
- Destaque de ranking existente renomeado de `Prestige_` para `Podium_`. Ranking geral de nível usa um índice separado de nível acumulado de carreira, para não ordenar o reset como perda de histórico. Perfil pessoal exibe o nível da etapa.

## Estado de persistência e corte entre versões

No Studio, o mesmo repositório opera com armazenamento de sessão em memória e não grava DataStore real. Fora do Studio, a nova carreira só ativa quando `ServerStorage.CareerCutoverApproved=true`. Esse atributo **não foi habilitado** nesta entrega.

O bloqueio é intencional: copiar o perfil v1 enquanto servidores antigos continuam gravando nele pode perder recompensas posteriores à cópia. A ativação publicada exige corte controlado, drenagem de escritores antigos, confirmação de dados e teste em experiência publicada de validação. Enquanto a ativação estiver desligada, o serviço de progressão antigo continua sendo a rota publicada; comandos novos de carreira informam indisponibilidade.

O perfil novo usa `CrossgroundsCareer_v2`; a origem é `CrossgroundsProgression_v1`. Recompensas seguem `ProgressionBalance`, que já usa ConfigService. Curvas persistidas não mudam por configuração remota durante a migração.

## Catálogo e limites do primeiro bloco

No primeiro bloco, parte dos requisitos era derivada do ID. A continuação substituiu essa distribuição pela trilha explícita descrita ao final deste relatório. Acessórios usam marcos por slot; XP de armas tem teto de nível 55 nesta versão.

O token só compra itens de progressão realmente catalogados para Arena/Conflict; não libera IDs inexistentes ou implementações de prévia. Tokens de Get Out/Duels ficam preservados para os catálogos futuros. Os cosméticos pessoais de feitos não entram no catálogo de equipamento comprado por token.

Não há ainda molduras em todas as listas/placares, vitrine de insígnias/contadores, edição de perfil offline ou um catálogo extenso de arte. Os cartões iniciais são composição de interface, sem novas imagens externas.

## Validações realizadas

- **16/16 contratos isolados no Studio**, em módulos temporários removidos após a execução: fronteiras de todos os níveis normais, dez prestígios, Maestria/Lenda, migração exata/excedente, preservação de armas/cosméticos, token por modo, projeção pública, versão inválida, corrupção de perfil, leitura indisponível, sessão concorrente/expirada e recuperação de resposta perdida na abertura/gravação.
- Resultado persistido em `artifacts/social-systems-2026-11-02/foundation-result.json`; suíte reproduzível em `tests/Unit/Cases/CareerFoundation_Test.luau`.
- **8/8 verificações no servidor em Play**: perfil pronto; iniciais liberadas/AX-50 bloqueada; fallback sem alterar preset; catálogo; XP de arma/teto; prestígio preservando arma/cosmético; token/duplicata; projeção pública sem dados privados.
- Consultas pelo remoto normal no cliente confirmaram rejeição de cosmético não conquistado, transição expirada e item inexistente.
- Em outro Play, chamada real de recompensa de Conflict creditou conta e arma. O helper normal de equipamento construiu `Sword`, `m4a1` com Ammo 30 e `m1911` com Ammo 7, sem AX-50 bloqueada. Isso valida a integração de recompensa/equipamento, não uma eliminação PvP humana completa.
- Personalização por remoto confirmou os quatro campos no servidor e o título “Linha de frente” no cartão renderizado.
- Menu aberto pelo roteador real dos LocalScripts e cartão inicial inspecionado visualmente. Corrigida disputa entre atualização automática e comando de personalização, separando limites de leitura/escrita; cartão começa com identidade padrão válida, sem textos “Label”.
- Eliminação simulada por fixture de servidor exibiu cartão do adversário e arma M4A1. Após respawn, jogador vivo, cartão oculto e `SpectatingEliminator=false`. A fixture não representa uma kill PvP real ou teste multiplayer.
- Compilação e igualdade local/Studio confirmadas para **26 fontes**. `git diff --check` dos arquivos alterados passou, com aviso de conversão de finais de linha do Git em ProgressionSchema.

Permanecem sem validação: DataStore real, corte de produção, teleporte, hardware físico, partidas humanas multiplayer, curva de horas, todas as armas/acessórios e revisão visual em todos os dispositivos. O console manteve avisos anteriores de assets sem permissão/arquivados, plugin GUIEditor e pasta histórica de StarterPlayerScripts em TestService; não foram atribuídos à nova carreira.

## Pendências registradas no primeiro bloco (histórico)

1. Amigos/presença e jogadores recentes além do comparativo existente.
2. Formação, liderança, convites, bônus e admissão coletiva local foram implementados na continuação abaixo; resta a camada entre servidores.
3. Matchmaking e transporte entre servidores com reserva/recuperação do grupo.
4. Clãs persistentes, contribuições, progressão e os dois rankings com igual destaque.
5. Ampliação do perfil público, aplicação de molduras nas listas/placares e catálogo editorial de cosméticos/desbloqueios.
6. Balanceamento e validação publicada da migração/persistência.

Competições permanecem reservadas ao jogo público e polido; desafios cooperativos dependem de Get Out jogável e futuras funções Médico/Engenheiro em Conflict.

## Recuperação e franquia

Backups das fontes anteriores em `artifacts/social-systems-2026-11-02/before` e `ServerStorage.SocialSystemsBaseline_20261102`. O snapshot inicial do Studio está em `studio-before.json`. `tools/serve_social_systems.py` é uma ponte de loopback para fontes/validação; não é componente do jogo. `tools/integrate_career_20261102.py` foi usado como transformação única, com âncoras que impedem repetição silenciosa.

Franquia de 5 horas consultada ao longo da execução: disponível caiu de 29% para **5% na consulta final**. Ao se aproximar desse limite, o trabalho se concentrou em estabilizar este bloco, sem iniciar implementação parcial de grupos ou clãs. Fechamento confirmou 26 fontes compiladas/iguais às locais, migração publicada desativada e principal em Edit. Ponte temporária de validação encerrada. Não foi usado o crédito de reset da conta.

## Continuação: grupos e entrada coletiva local

A janela de 5 horas foi renovada antes da continuação (99% disponíveis na primeira consulta). O Studio estava sem place aberto; a cópia local `CrossGroundsWorkingOne.rbxl` foi aberta para validação e suas fontes alinhadas ao repositório, com snapshot anterior em `artifacts/social-phase2-2026-11-02/edit-before.json`. O principal 4375993208 conectou depois; suas fontes coincidiram com a base do repositório e recebeu os 20 arquivos deste bloco, com backup em `ServerStorage.SocialGroupsBaseline_20261102` e `main-before.json`. Sem publicação.

Implementados `PartyRoster`, `PartyService`, `PartyAdmission`, política de reserva de equipes e cálculo de XP com frações conservadas. Grupos de até 12 no lobby, liderança/transferência, convite com expiração e aceitação, remoção/saída, opção de equipe e bloqueio de alteração durante entrada. Convites reais verificam amizade Roblox no servidor. Menu Social e grupo usa a navegação e as cascatas existentes, com notificação de convite.

Admissão coletiva local cria tickets para todos e reserva vagas antes de entrar. Conflict preserva grupos de mesma equipe também na troca de rodada; empacotamento por blocos faz busca limitada para não separar grupos quando uma distribuição gananciosa falha. Arena declara capacidade de 12 e inclui reservas no controle de vagas. Falha de qualquer integrante aciona saída dos que já entraram, incluindo o integrante cuja entrada parcial falhou. Treino continua individual; modalidades planejadas permanecem indisponíveis.

Bônus de +5% por outro integrante elegível no mesmo round aplicado a XP de conta e da arma, sem alterar moedas ou placar. Conta participantes mortos da partida, mas exclui lobby, treino, transição e AFK. Frações menores que 1 XP são acumuladas na sessão. A integração expõe evento de recompensa com os valores base, antes do bônus, para futuras contribuições de clã.

Validação deste bloco: **16/16 contratos isolados** e **29 verificações em teste com dois clientes reais do Studio** passaram. O teste cobriu criação/aceitação por remoto, menus, treino sem arraste, liderança, cancelamento e nova busca, entrada conjunta no Conflict, equipe comum, bônus em conta/arma (70→73 XP), treino sem bônus, morte sem perda de elegibilidade, saída do grupo sem expulsão da partida e retorno individual do líder ao hub. A amizade de plataforma não foi validada: clientes de teste não são amigos reais; somente a criação da proposta de convite foi preparada pela fixture de servidor. O teste utiliza as remotes normais para a aceitação e demais ações.

Fontes reproduzíveis: `tests/Unit/Cases/PartySystems_Test.luau` e `tests/Integration/PartySystems.server.luau`/`.client.luau`. Resultados: `artifacts/social-phase2-2026-11-02/tests-result.json` e `runtime-result.json`. A execução multiplayer foi na cópia local, não no principal. Camada entre servidores, amigos/recente completos e clãs seguem em trabalho; não interpretar esta subseção como conclusão do pedido integral.

## Continuação: amigos, perfil público e clãs

Diretório nativo de amigos com paginação/cache, favoritos privados (até 50), presença oferecida pelo Roblox e participantes recentes de partidas da sessão. Preferências permitem desativar convites e ocultar estatísticas do perfil; o servidor verifica essas preferências. Perfil de conhecidos usa projeção pública, avatar, calling card e moldura; não envia inventário ou preferências privadas. Amigos ausentes podem ser consultados com o perfil v2 quando disponível em produção. O botão de convite para a experiência abre o prompt nativo do Roblox somente após ação do jogador.

Clãs possuem catálogo de brasões/cores, nome e tag filtrados por TextService, capacidade inicial 30 configurável, líder/oficiais/integrantes e convites de amigos no lobby. Filiação em duas etapas: intenção confirmada no perfil individual antes de criar/entrar no registro compartilhado; operações incertas podem ser repetidas ou canceladas com um registro que impede execução tardia. Cada filiação tem identidade própria para não confundir quem saiu e voltou. Saída voluntária confirma a contribuição antes de remover o integrante; o líder precisa transferir o cargo, e o último integrante arquiva o clã.

Duas medidas com igual destaque no menu e rankings: histórico somado do elenco atual e conquistas acumuladas enquanto os integrantes pertenciam ao clã. Entrar não importa histórico para as conquistas; sair retira o histórico do elenco, mantendo as conquistas já confirmadas. Contribuições usam valores base de recompensas elegíveis da partida, antes do bônus de grupo; treino não contribui. Snapshots cumulativos são confirmados no perfil e agrupados por clã a cada 30 s; repetição e entrega fora de ordem não duplicam valores. O perfil confirmado pode reenviar contribuições na sessão seguinte. Cosméticos permanentes de clã são concedidos no nível 3, após contribuição individual de 1.000 XP. Curva inicial: 5.000 × (nível − 1)² XP; precisa de balanceamento humano.

Fontes de persistência: `CrossgroundsClans_v1`, `CG_ClanRosterXP_v1` e `CG_ClanEarnedXP_v1`; no Studio operam em memória. Índices são atualizados periodicamente e não representam resultados instantâneos de todas as sessões. Rankings mostram o top consultado de até 20 clãs, sem recompensas competitivas. Competições não foram criadas.

Validações: 15/15 contratos em `ClanSystems_Test.luau`, cobrindo autoridade, lotação, expiração, importação de histórico, soma de contribuições, saída, troca de filiação, resposta perdida e cancelamento antes de execução tardia. No principal em Play, criação com filtragem nativa passou por serviço e pelo menu; os dois rankings e projeção pública passaram. Seis verificações do cliente confirmaram menu/modal/bloqueio de gameplay, abertura Social→Clãs, criação e igual destaque dos totais. Seis verificações de servidor confirmaram exclusão do treino, contribuição de 70 XP, confirmação do perfil e aplicação única pelo worker. Essas fixtures isolam a recompensa de combate e não representam kill PvP humana.

Corrigido reconhecimento de Carreira/Social/Clãs em MenuNavigation e ControlRouter, além de fechamento mútuo dos menus. Sem publicação ou persistência real. Concorrência distribuída, teleporte, hardware e evolução longa do clã permanecem sem validação publicada.

## Fechamento da continuação: camuflagens, Maestria e viagem coletiva

Armas receberam acabamentos procedurais Original, Bosque (nível 10), Deserto (25), Oceano (40) e Ouro (55). São variações de cor por peça que preservam geometria, texturas e propriedades funcionais, com exclusão de lentes, miras, partes invisíveis, projéteis decorativos e vidro/neon. Seleção validada no servidor, persistida por arma e aplicada no próximo nascimento, incluindo recuperação de equipamento e Arena. O catálogo de tokens oferece um acabamento específico de uma arma e modalidade; não libera o mesmo acabamento em todas as armas. Prestígio/Maestria/Lenda preservam progresso e seleção visual. Corrigido repasse do ID da arma nas recompensas de alvo de treino do Conflict.

A trilha de armas de Conflict tem requisitos explícitos em todos os níveis 1–55, com M4A1/1911 iniciais e AX-50 em 55. Alternativas da pistola da Arena usam marcos explícitos (M1911 inicial, Sykov em 55). Novos IDs sem requisito explícito ficam em 55 até curadoria, sem deslocar os itens existentes. Esses parâmetros são uma primeira distribuição de balanceamento, não uma curva de horas validada com jogadores.

Maestria libera os estilos Clássico, Astral e Solar para a insígnia de progressão, separados do emblema pessoal. O servidor preserva fase e nível verdadeiros; trocar o estilo não simula progressão. Estilo permanece na Lenda. Avatar/moldura também aparecem nos integrantes do grupo, além de amigos e recentes.

Viagem coletiva implementada como integração com TeleportAsync em lote e um registro temporário MemoryStore (`CrossgroundsPartyHandoffs_v1`): IDs reais de integrantes, líder, política de equipe, modalidade e destino são gerados no servidor. TeleportData contém apenas a chave opaca; o destino valida jogador/Place, expiração e o primeiro servidor que assumiu a chegada. O destino espera todos os integrantes e perfis prontos, encerra a confirmação, restaura a formação e reserva vagas antes da admissão coletiva. Chegada incompleta não inicia a partida coletiva; os presentes podem reorganizar o grupo e voltar ao hub. Falhas da plataforma e prazo na origem liberam quem permaneceu; não é possível desfazer um teleporte já concluído. Perfil em uso na origem pode aguardar até 30 s pela liberação normal de sessão. Essa camada utiliza o encaminhamento de servidores do Roblox; não cria uma fila global própria com habilidade/região/temporada.

`GroupTransferEnabled=false` e `TeleportEnabled=false` continuam no principal, e `CareerCutoverApproved` não foi ativado. Não foram inferidos novos IDs de Place/Universe. A viagem real precisa de destinos na mesma experiência, configuração dos papéis e teste privado publicado autorizado. A documentação oficial confirma que TeleportService não funciona em Play do Studio: [viagem entre Places](https://create.roblox.com/docs/projects/teleport), [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService), [MemoryStoreHashMap](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreHashMap).

Validações adicionais já realizadas: 61 contratos isolados passaram antes da trilha explícita final; suíte atualizada inclui também cobertura de todos os níveis da trilha. Multiplayer repetido com dois clientes: 36 verificações passaram, incluindo restauração preparada pelo servidor, admissão conjunta na Arena e retorno ao hub. Esse trecho valida o destino local com clientes reais, sem afirmar execução de MemoryStore/teleporte publicado. Smoke final no principal: seis verificações de servidor (boot, gates, Maestria, projeção, criação nativa e arquivamento do último integrante) e quatro de cliente (três modais e insígnia da Maestria renderizada) passaram. Criação de clã usa a filtragem real do Roblox; persistência continua em memória do Studio. No equipamento real, M4A1 dourada com Ammo 30/Handle/65 descendentes; remoto recusou Ouro na M1911 sem nível e aceitou na M4A1 de nível 55. Uma primeira asserção de munição aplicada ao retorno cru da factory falhou porque quem inicializa munição é KitService; o teste foi corrigido para verificar o equipamento real, que passou.

Limites operacionais atuais: contribuições administrativas entre servidores refletem snapshots já confirmados no registro do clã; remover alguém em outra sessão pode excluir ganhos ainda não sincronizados. Remoção local confirma o snapshot antes de remover. Presença depende do dado retornado pelo Roblox; recentes abrangem somente esta sessão. Não há busca global por nome de clã, apenas rankings, convite e ID completo compartilhável. Cosméticos iniciais usam composição/cores do jogo, sem pacote externo novo de arte. Continuam abertos testes publicados de concorrência/persistência/migração/teleporte, hardware físico e balanceamento. Competições e desafios cooperativos permanecem adiados conforme decisão do usuário.

### Evidência consolidada

- **65/65 contratos**: carreira (17), clãs (15), trilha/camuflagens (7), grupos/admissão (19) e transferência (7). Resultado: `artifacts/social-phase2-2026-11-02/combined-contracts-result.json`.
- **36 verificações multiplayer** com dois clientes reais, em `runtime-result.json`. As fixtures usam as remotes normais; apenas convite sem amizade e restauração da confirmação são preparados no servidor. Não executam teleporte ou MemoryStore reais.
- Resultados nativos adicionais: `clan-native-result.json` e `final-native-result.json`. Os testes de progressão preparados em memória do Studio não alteram contas publicadas.
- Remoção local de integrante de clã agora confirma seu snapshot antes da remoção; contrato de autoridade testado isoladamente, novo flush não validado com dois membros reais de clã em servidores publicados. Falha de leitura do registro de clã ativo retorna indisponibilidade, sem apresentar silenciosamente a conta como sem clã.
- Histórico de franquia durante a continuação: 99%, 65%, 51%, 46%, 40%, 37%, 33% e 31% disponíveis nas consultas até esta consolidação. O crédito de reset não foi usado. Monitoramento prossegue até o fechamento.

Fechamento do menu: corrigida disputa entre atualização automática e leitura logo após criar o clã. ClanBridge centraliza os intervalos e cancela refresh substituído por consulta mais recente. Cinco verificações finais passaram pelo cliente: criação/visão própria, ausência de aviso indevido de limite, leituras sequenciais, métricas iguais e avatar/moldura do grupo. Resultado em `clan-menu-final-result.json`. Última consulta de franquia: 25% disponíveis; sem uso do crédito de reset e sem atingir o limiar de 5%.

Conferência final: 49/49 fontes funcionais alteradas compiladas e idênticas ao repositório no principal. Principal em Edit, sem fixture multiplayer no principal. Fixtures da cópia de validação removidas após o teste. Migração não aprovada e as duas flags de viagem desativadas. `git diff --check` passou, com avisos de normalização LF/CRLF do Git. Console não mostrou erro novo desses sistemas no último Play; manteve avisos anteriores de assets, GUIEditor e pasta histórica de TestService, além de chaves novas de ConfigService ausentes usando os defaults locais. Ponte de loopback encerrada após a verificação; fontes/evidências ficaram locais, sem commit ou publicação feitos nesta tarefa.

## Ícones de biblioteca e molduras em camadas

Pacote gratuito Lucide Icons (WORKING), Creator Store 119136002207552, importado no principal e preservado em `ServerStorage.LibraryImports.Lucide Icons Library`. Inspeção da fonte antes de execução confirmou registro de dados/função de busca, sem carregamento remoto de código. 1.668 ícones; adaptador `InterfaceIcons` centraliza funções de interface, com símbolos distintos por função. Substituídos desenhos repetidos do início do hub (Carreira/Social antes caíam no mesmo desenho de música), indicadores de progressão, ícones de categorias/configurações e botões de identidade/social que passam pela cascata. Mesma ação em telas diferentes pode manter o mesmo símbolo; miniaturas de mapas e glifos nativos de entrada mantêm suas funções próprias. Catálogos antigos de atlas ficaram preservados, sem uso em SettingsVisual. Créditos do módulo/sheets e avisos Lucide/Feather registrados em `assets/vendor/lucide`.

Molduras agora compõem até quatro camadas, da interna para a externa, com reordenação, adição/remoção, modelos conquistados e cor RGB livre por camada. Editor em Carreira → Personalizar perfil → Moldura por camadas e cores. HEX #RRGGBB e ajuste dos canais; prévia local, salvamento explícito, restauração da composição salva. Cores não dependem da liberação de tema HSV do lobby. Modelos de Prestígio/Maestria/Lenda/clã continuam exigindo conquista. Formatos de borda e ornamentos distinguem as famílias. Escolher uma moldura simples substitui a composição; perfis antigos continuam válidos. Composição é validada/copiada no servidor, preservada nos resets, publicada nos cartões/perfis/miniaturas sociais e atualizada no grupo quando a aparência muda.

Validações: sete contratos de ícones/camadas passaram (funções com arte distinta, cores arbitrárias, modelos bloqueados, RGB inválido, estrutura/limite, cópia, migração e preservação). No cliente real: duas camadas salvas com RGB arbitrário e reordenadas, cartão com camadas, rejeição de Lenda bloqueada e atlas carregado. Outro fluxo usou a navegação normal de volta/salvar para três camadas, com prévia e ordem confirmadas. Último Play confirmou propagação da aparência no estado do grupo, duas camadas no avatar e abertura de configurações, sem erro novo desses sistemas no console. Evidências em `profile-frames-icons-result.json`; sete contratos em `tests/Unit/Cases/ProfileFrames_Test.luau`. Persistência publicada e hardware físico continuam sem validação. Última consulta de franquia: 14% disponíveis, sem crédito de reset usado.

Fechamento deste ajuste: os 65 contratos anteriores foram repetidos com a nova política e passaram, além dos sete novos. 57/57 fontes funcionais alteradas compiladas e iguais às locais; pacote original preservado no Studio, principal em Edit. Helper de loopback encerrado após a conferência. Alterações continuam locais, sem commit/publicação nesta tarefa.
