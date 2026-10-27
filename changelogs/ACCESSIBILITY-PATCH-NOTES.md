# Acessibilidade, controles e recuo

22/10/2026 · Place 4375993208 · aplicado no Studio.

## Entregue

- Recuo visual mais forte no Kastov 545 e, principalmente, no Lachmann LMS. Retorna ao repouso sem alterar a câmera nem a direção do tiro.
- Cursor nativo do gamepad desativado durante o jogo. Mira livre continua disponível pela própria mira; menus usam um cursor em forma de losango, independente do cursor nativo.
- Navegação por D-pad e cursor pelo analógico esquerdo; analógico direito rola os menus. Movimento do personagem é suspenso enquanto um menu próprio está aberto.
- Ajustes com sliders, botões de incremento/decremento e valores editáveis. Enter ou perda de foco confirma a edição; valores finitos fora do intervalo são corrigidos para o limite. Valores inválidos mantêm a configuração anterior.
- Ícones de D-pad aparecem somente no campo selecionado pelo cursor do menu. Esquerda diminui, direita aumenta; segurar repete o ajuste.
- FOV configurável entre 60 e 110 graus, padrão 70. Corrida em movimento adiciona 6 graus com transição suave; ao mirar, usa o FOV de mira da arma.
- Ícones e instruções de Xbox e PlayStation obtidos do Roblox para o controle conectado. Também há instruções de ações no HUD que acompanham o remapeamento.
- Remapeamento separado para controle e teclado/mouse, com 5 segundos para receber a nova entrada. Sem entrada válida, mantém o valor anterior. Botões em conflito trocam as duas ações.
- Botão para restaurar os controles padrão. Preferências continuam salvas por jogador no servidor publicado; Studio usa valores apenas da sessão.
- Botão Ajustes dentro da seleção inicial de kit. Kits, votação, configurações, remapeamento e confirmação de retorno ao lobby são acessíveis por controle.
- Interface com rolagem e altura adaptada a telas menores, mantendo o tamanho do texto.
- X prioriza recarga quando há munição de reserva e espaço no carregador; com arma pronta, aciona a interação próxima. Prompts e botões de toque usam o mesmo comando de interação.

## Padrões de controle

| Ação | Xbox | PlayStation | PC |
|---|---|---|---|
| Alternar corrida | LS | L3 | Ctrl |
| Trocar perspectiva | RS | R3 | V |
| Trocar arma | Y | Triângulo | G |
| Shift Lock | LB | L1 | Shift |
| Recarregar / interagir | X | Quadrado | R |
| Trocar ombro | RB | R1 | Q |
| Atacar | RT | R2 | Mouse 1 |
| Mirar | LT | L2 | Mouse 2 |
| Pular | A | Cruz | Espaço |
| Ajustes | D-pad direito | D-pad direito | F2 |
| Kits | D-pad cima | D-pad cima | K |
| Votação | D-pad baixo | D-pad baixo | M |
| Retornar ao lobby | B | Círculo | L |

Nos menus, confirmar, voltar e navegação permanecem fixos para preservar o acesso às configurações. Enquanto um campo de texto estiver em edição, B/Círculo sai da edição; pressionar novamente volta no menu. Os analógicos e WASD mantêm o movimento padrão. Start/Options e comandos do sistema Roblox não são remapeados.

## Verificação

- Sintaxe dos scripts sem erros.
- Comandos padrão e ausência do cursor nativo durante o combate verificados em Play.
- FOV base 60 alcançou aproximadamente 66 ao correr em movimento.
- Edição do FOV: 999 corrigido para 110 e -999 corrigido para 60.
- Recuo medido: pico aproximado de 0,069 no fuzil e 0,333 na sniper; ambos retornaram ao repouso, com variação zero na direção da câmera no teste.
- Remapeamento de corrida para RB trocou o ombro para LS, com confirmação no servidor. Tempo esgotado preservou o valor anterior.
- Todas as linhas de remapeamento percorridas por D-pad, com rolagem; restauração retornou LS/RS/Y/LB/X aos padrões.
- Recarga no X observada após gastar munição, sem abrir seleção de kit. Com carregador cheio, X abriu a interação de kit.
- PS5 simulado detectado como PlayStation, usando ButtonCross e os ícones de D-pad da plataforma.
- Menu de ajustes acessado a partir da seleção de kit somente com gamepad.
- Layout inspecionado em console e iPhone 17 Pro, em paisagem. Simulador restaurado; Play encerrado.
- Nenhum erro dos sistemas alterados observado no último teste. O plugin externo GUIEditor continua registrando seus próprios erros.

O comportamento com controles físicos, teclado virtual do console e persistência entre sessões publicadas ainda precisa ser confirmado nesses dispositivos.

## Arquivos e recuperação

- Fontes em `src/`, organizadas por serviço.
- Backup anterior às mudanças: `ServerStorage.AccessibilityBackup_1792642663`.
- Pacote de recuperação: `artifacts/accessibility-patch.rbxm`, organizado por serviço; não é um instalador nem um place completo.
- Pacote verificado: 211572 bytes; SHA-256 `B31FD70457FF8C7D14CCE4579D1EE2AFBACAE096B308EDEB7CAF63ED5CA18ECA`.
- Preserve `DisplayScript.Enabled=false`, `StarterPlayer.EnableMouseLockOption=false` e `StarterPlayer.CameraMaxZoomDistance=16` ao recuperar apenas as fontes.
- A propriedade ChatVersion foi conferida ao concluir o patch e já está em TextChatService.
- A publicação continua manual: Arquivo → Publicar na Roblox.
