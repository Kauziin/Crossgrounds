# Tela Jogar e nome Conflito — 03/11/2026

Cards compartilhados de ModeSelectGrid preservam as quatro imagens de ModePresentation. NovaHubView substitui lista de modalidades e grandes ações externas pela grade, com cabeçalho compacto e fundo integral. HubController deixa de exibir a coluna lateral antiga na tela de modalidades Clássica; detalhes usam diálogo flutuante nas duas apresentações.

Cada card contém tipo do modo, disponibilidade, ícone de pessoa, contagem/capacidade e atalhos internos de 44 px. A/card Jogar mantém o fluxo de entrada existente; X abre detalhes; Y abre Practice Range somente no Conflito. Mouse/toque usam os próprios botões. Mobile remove prefixos de teclas dos botões e não mostra dicas de navegação. Links de direção da grade atualizam com a quantidade de colunas.

Contagem usa jogadores humanos com CrossgroundsMode correspondente no servidor local; Practice Range é excluído. Modos remotos/indisponíveis mostram capacidade em vez de uma população inventada. Get Out usa o intervalo 2–5 já descrito pelo catálogo; Duels fica sem número definido. Rótulos Neste servidor/Capacidade explicitam o escopo. Atualização por eventos de entrada/saída e atributos, sem consultas periódicas novas ou serviço global.

Nome visível padronizado para Conflito. Corrigido ProgressionSchema.Names.ctf que ainda mostrava Capture The Flag, além de Conflict em catálogo, trilhas, entrada, carreira/social, HUD, placar, tooltip e mensagem de indisponibilidade. Identificadores ctf, saves, remotes e aliases técnicos como ConflictPistolVisuals preservados. Descrição do objetivo de capturar bandeira e backups históricos não renomeados.

Validação efetiva em Play:
- Cards na Neo, ações externas ocultas, nome Conflito e schema de progressão confirmados.
- Clássica mantém os cards atualizados e a troca de estilo desativa o fundo Neo.
- X abre detalhes e Voltar fecha; Y do card Conflito entrou realmente no CTF Practice Range pelo fluxo atual.
- A do card Arena entrou realmente na modalidade, contagem mudou para 1/12 e returnHub devolveu ao lobby.
- Desktop 1459×748 e iPhone 17 Pro paisagem 874×402 inspecionados. Mobile final: card 325×186, botão Practice Range 143×44, ações da primeira linha integralmente dentro da área visível, dicas ocultas e rótulos sem teclado.
- Capturas finais 01-desktop.jpg e 02-mobile.jpg. A primeira versão mobile cortava o rodapé dos cards; corrigida altura e conferida novamente em sessão nova.
- 33 fontes do conjunto compiladas e correspondentes ao editor; git diff --check passou. Nenhum nome antigo exato encontrado nos TextLabels/TextButtons de StarterGui. Console final sem novo erro observado das fontes alteradas; avisos anteriores de áudio, GUIEditor e TestService permanecem.

Limites: sem controle/toque físico, contagem global entre servidores, multiplayer humano, conectividade remota de produção ou sessão completa de partida. Testes por chamadas aos callbacks reais de navegação, sem alegar teste físico de D-pad. Play encerrado, simulador padrão e fixtures descartadas. Sem publicação.
