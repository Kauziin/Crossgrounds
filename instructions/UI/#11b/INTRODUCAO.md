# UI #11b — introdução: diagramas de entrada e simplificação mobile

Material fornecido pelo usuário: `Crossgrounds_Diagramas.zip`. ZIP original preservado nesta pasta, com nove arquivos extraídos em `referencias/`. `manifesto.json` registra tamanhos e SHA-256 para conferência de integridade. Nenhum arquivo do pacote foi modificado.

## Finalidade das referências

- Teclados TKL de referência ABNT2 e ANSI em PNG/SVG, com SVG editável por tecla.
- Conceitos de diagramas de teclado/Xbox/PlayStation.
- Exemplos de keycaps e botões de controle nos estados normal, hover, selecionado e indisponível.
- Conceito de interface de remapeamento.

As imagens são referências fornecidas, não código funcional nem fonte de verdade para bindings. As legendas do conceito podem misturar convenções (por exemplo, A em prévia rotulada PlayStation); conferir rótulos e posições ao implementar. Diagrama físico deve refletir os comandos efetivos do jogador e comportar múltiplas ações por botão. Layout de teclado e representação de controle não provam plataforma do jogador.

Não adotar automaticamente a cascata/colunas ou a navegação do mockup: a direção vigente continua sendo interface Nova aberta, com mobile paisagem e identidade consistente. Teclas, ícones e estados podem orientar o novo remapeamento sem impor a composição inteira do exemplo.

Três imagens conceituais foram inspecionadas visualmente nesta organização: mapeador, diagramas de entrada e botões de controles. Demais itens foram inventariados e preservados; isso não constitui revisão completa de todas as teclas/legendas ou validação de importação Roblox.

## Proposta de simplificação mobile — para avaliação

Objetivo: reduzir controles e informação simultâneos, preservando ações essenciais e os perfis pessoais. Sem reduzir botões até ficarem difíceis de tocar.

1. **Base de dois polegares:** joystick à esquerda; disparo, mira e pulo como ações prioritárias à direita. Recarga/interação e troca de arma permanecem diretamente acessíveis, com hierarquia visual secundária. Esses cinco botões mais movimento são a base proposta, não remoção de funcionalidades.
2. **Ações opcionais recuperáveis:** câmera, ombro e trava podem ir a um painel rápido ou opção de layout; nunca depender de gesto oculto. Deslize/agachamento continua acessível no perfil que o utiliza. Sprint automático é uma preferência opcional, não ativação compulsória para eliminar seu botão.
3. **Perfis, não imposição:** oferecer proposta limpa para dois polegares e uma opção expandida/customizável. Não sobrescrever posições, visibilidade e tamanho salvos. Controles essenciais devem continuar ao alcance; preservar Salvar/Cancelar e forma de recuperar controles opcionais.
4. **HUD separado das zonas dos dedos:** vida/estamina em faixa compacta inferior esquerda; equipamento compacto inferior direito; reservar área dos controles antes de posicionar informação. XP deve respeitar lente, joystick, botões e equipamento em ambas as opções de posição.
5. **Menos repetição de mensagens:** aviso de bandeira próximo do placar; depois da comunicação inicial, ícone de portador/cantos continuam informando o estado sem repetir continuamente o texto longo. Killfeed compacto com poucas linhas; detalhes adicionais só em contexto apropriado. Nada de esconder estado crítico apenas por reduzir ruído.
6. **Menus por tarefa:** tela de lista ou prévia no Armeiro, com ação principal fixa e retorno claro. Em remapeamento/configurações, uma região principal e passos reconhecíveis; diagramas ampliáveis, sem comprimir teclado e lista lado a lado.
7. **Validação:** mobile em paisagem com botões de toque reais na simulação; testar dois polegares, simultaneidade mover/mirar/disparar, áreas seguras, alvos de pelo menos 44 px e separação de avisos. Hardware físico e multitoque ainda são pendentes.

A proposta não foi aplicada ao protótipo ou ao jogo nesta etapa. A única ação executada foi guardar e documentar as referências. O plano de recriação e as decisões anteriores permanecem em `../#10b/PLANO-RECRIACAO.md`.


## Exemplo visual entregue

Protótipo local em artifacts/ui-nova-prototype/index.html agora alterna Perfil Limpo/Expandido no HUD. Capturas 17-mobile-simple.png, 18-mobile-quick-panel.png e 19-mobile-simple-scope.png mostram a proposta em paisagem. É simulação separada do Roblox, sem substituir layouts salvos. Reduz de nove para sete alvos permanentes ao manter cinco ações essenciais, joystick e Mais; corrida/deslize/câmera continuam disponíveis no painel temporário.

## Correção prevalente: significado de mobile limpo

O usuário esclareceu que limpo significa área oval central livre de UI, não menos botões. A proposta anterior de esconder ações em Mais foi substituída. Preservar controles diretos e distribuí-los pela periferia. O protótipo usa provisoriamente um oval centrado com 60% da largura e 46% da altura da tela, dimensões a ajustar com uso real. Botões, mensagens e XP ficam fora dele. XP à esquerda se afasta também dessa área, além da lente. Guias ilustrativos centrais são ocultados nessa apresentação; a mira/óptica real da arma requer tratamento próprio na integração, sem remover mecanismos de pontaria do jogo.
