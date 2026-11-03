# Crossgrounds — protótipo navegável da interface Nova

Abra `index.html` em um navegador. Não requer instalação, internet ou acesso ao Roblox. Os dados ficam somente na memória da página. Não usa cookies, armazenamento persistente ou serviços do jogo.

## O que avaliar

- Inicial A: marca, ação Jogar e destinos secundários; área contextual que poderá conviver com uma cena dedicada.
- Inicial B: ação e destinos em uma faixa, compartilhando os mesmos caminhos.
- Modos: acesso e disponibilidade em contexto; confirmação demonstra a jornada, sem entrar em partida.
- Armamentos: classe em foco e classe escolhida separadas; escolha e edição têm ações distintas.
- Acessórios: região única de trabalho, categorias, lista, prévia e detalhes. No mobile, selecionar item abre a etapa de prévia; alternância Lista/Arma e detalhes e ação inferior acessível.
- Configurações: destinos sem cascata de colunas. Remapeamento tem diagrama de teclado com teclas usadas e ação selecionada destacadas; representação Xbox/PlayStation manual.
- HUD futuro: vida dentro da barra, estamina separada de equipamento, equipamento inferior direito, mini-placar, killfeed compacto, estado de bandeira e sequência ilustrativa de eliminações.

Carreira/Social e categorias secundárias são destinos identificados, ainda não interfaces completas. Remapear, gerenciar classes e entrada em partida abrem explicações; não executam operações reais. Imagens de arma usam a mesma silhueta vetorial provisória e não representam o modelo de cada arma. Os acessórios são estados ilustrativos de catálogo, sem regras de compatibilidade. O fundo é abstrato e não substitui uma proposta de cena/artes finais.

## Interação

Clique/toque nos controles. Setas percorrem ações; Enter/Espaço ativam botões nativos. Escape volta ou fecha o diálogo; X abre a edição na página de classes. O footer é uma ferramenta de revisão do protótipo, não um painel proposto de dicas de gameplay. Durante diálogos, Tab permanece no diálogo e Escape retorna ao contexto.

Sons de teste podem ser habilitados em Configurações. São tons sintetizados curtos, provisórios; não houve avaliação auditiva nem seleção final de sons. A animação respeita movimento reduzido do navegador. As capturas usam `?capture=1` para desativar animações e produzir imagens determinísticas; não validam fluidez.

## Capturas e validação

Dezesseis PNGs em 1920×1080, 1280×720 e mobile paisagem 844×390. O renderizador local `tools/render_ui_nova.cjs` abre apenas este arquivo em Edge headless, captura páginas e executa 16 verificações no DOM. Resultados em `validation.json`: 16 passaram, zero falhas. Dimensões verificadas sem expansão involuntária do viewport e sem rolagem horizontal. Revisão visual manual encontrou/corrigiu recorte na inicial mobile e verificou a etapa de prévia com ação inferior visível.

Verificações incluem destinos iniciais, seleção local de classe, edição, estado bloqueado, retorno de navegação, destaque de teclado, representações Xbox/PlayStation, foco/fechamento de diálogo, vida dentro da barra e soma demonstrativa de sequência.

Não valida: fontes Roblox/Luau, gamepad físico, toque físico, desempenho de modelos 3D, detecção de plataforma, XP, persistência, recompensas ou comportamento de jogo. O botão de simular kill usa números ilustrativos e ainda não expira por janela temporal. O quadro de HUD não inclui ainda remapeamento/edição de posições, bandeira em todos os estados, medalhas reais, animação de recarga ou placar completo com plataformas.

## Próxima revisão

Escolher composição da inicial e avaliar linguagem das telas internas e regiões do HUD. Ajustar o desenho antes da implementação em Luau. A integração deverá usar catálogos/modelos reais, serviços existentes e duas apresentações isoladas. A interface Atual anterior a Geral/Completo ainda precisa ser delimitada/restaurada em etapa própria; este protótipo não altera o jogo.

Sem publicação, commit, push ou alterações de runtime Roblox nesta entrega.

## Refinamento do aviso de bandeira

Aviso colocado 13 px abaixo do placar nas três resoluções verificadas, com texto mais forte, acento âmbar, chevrons e passagem luminosa para a direita limitada a dois ciclos. Ícone de bandeira ampliado de 48 para 80 px no desktop e de 30 para 60 px no mobile. Aviso contido horizontalmente em 1920x1080, 1280x720 e 390x844; mobile reposiciona o estado de portador e killfeed para evitar disputa com a faixa. Movimento reduzido mantém sinais estáticos. Capturas desativam animações; a sequência animada ainda depende de avaliação visual no protótipo aberto.

## XP e orientação mobile corrigidos

Mobile validado em paisagem (844x390), conforme correção do usuário. As capturas mobile anteriores em retrato foram substituídas. O HUD do protótipo oferece o botão XP, alternando Embaixo e Esquerda do retículo, e botão Scope para testar afastamento. A posição inferior fica próxima à borda inferior e preserva espaço da ferramenta de revisão. À esquerda, a borda direita do aviso mantém distância do centro; com scope a distância considera o raio ilustrativo da lente mais margem, evitando sobreposição. A circunferência é somente guia de layout, não implementação de óptica. Preferências vivem só na memória da página.

Capturas 12/13/14 mostram inferior, esquerda normal e esquerda com scope em mobile paisagem; 15 mostra scope em desktop. Renderizador valida contenção horizontal e separação da lente/retículo. 15 capturas e 13 verificações anteriores passaram; não valida diferentes modelos de scope nem câmera real do Roblox.

## PC/console e simulação de toque

PC/console compartilham composição e as duas opções de XP. Capturas 05/16/15 mostram inferior, esquerda e esquerda com scope, respectivamente. Sem botões de toque no desktop.

Mobile paisagem agora inclui nove alvos de toque (joystick e oito botões), somente ícones e nomes acessíveis. Ações essenciais baseadas no inventário MobileLayout do projeto; posições aqui são propostas novas para acomodar informação e toque, não uma alteração dos layouts salvos. Mirar alterna guia de scope, recarga/troca mostram mudança ilustrativa; demais ações dão retorno visual. Joystick não move personagem e não há simulação de combate real.

A barra de ferramenta do estudo permite alternar Método entre Toque e PC/Console. No mobile, vida/equipamento/killfeed foram reposicionados. Capturas 12/13/14 incluem botões nas duas posições de XP e com scope. Mínimo acionável medido de 44 px, sem sobreposição entre aviso de XP e os nove controles nas capturas. A captura agora aguarda a inicialização da página específica, evitando registrar o estado da página anterior durante uma troca.

## Exemplo do perfil mobile limpo

Na ferramenta de revisão do HUD, Perfil alterna Limpo/Expandido. Limpo mantém joystick, disparo, mira, recarga/interação, pulo e troca de arma. Corrida, deslize e câmera ficam acessíveis pelo botão de reticências, sem ativar corrida automática. O estado de portador mantém o ícone/cantos, com menos repetição de texto; killfeed mostra só a linha mais recente no exemplo.

Capturas 17/18/19 mostram o perfil limpo, o painel de atalhos aberto e XP ao lado de scope. Painel rápido é temporário, não um substituto adequado para ações usadas continuamente: nesses casos, perfil expandido/customização deve manter o botão direto. Implementação de gesto/segurar e comportamento real de correr/deslizar continuam pendentes. O exemplo reduz de nove para sete alvos permanentes (incluindo joystick e Mais), não apenas diminui o tamanho dos botões.

## Correção do conceito de limpeza mobile

O controle Centro alterna Livre/Comparação anterior. A apresentação Livre preserva todos os nove alvos diretos e distribui UI fora de uma área oval central (60% da largura, 46% da altura, medidas provisórias). Retirado painel Mais como solução de limpeza; captura 18 é agora comparação sem painel, apesar do nome histórico. Capturas 17 e 19 mostram centro livre e XP deslocado para fora da região com scope. Renderizador verifica interseção de retângulos de HUD/controles com o oval nos estados Livre; 18 testes e 19 capturas passaram. Não prova adequação ergonômica ou multitoque físico.
