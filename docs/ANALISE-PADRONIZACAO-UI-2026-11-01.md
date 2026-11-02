# Padronização da interface do Crossgrounds

Análise de 01/11/2026, no Place principal 4375993208. Pedido: percorrer os menus únicos, incluindo início, pausa, votação, armas, placar, configurações e HUD, e julgar sua padronização. Esta etapa produz diagnóstico e evidências; não implementa um redesenho.

## Julgamento

**Padronização geral: aproximadamente 6/10.** Nota editorial baseada no percurso e no código atual, não uma métrica automática nem uma nota de beleza. O jogo possui uma identidade reconhecível: fundos escuros, Gotham, textos claros, acentos ciano e navegação por painéis. Essa identidade ainda se divide em famílias com componentes, densidades e comportamentos diferentes.

Os menus recentes têm boa consistência interna. A quebra aparece principalmente nas transições entre famílias. Tela inicial, Progressão e Armeiro já sugerem uma direção comum forte; a pausa, a playlist, o placar e alguns HUDs mantêm outro acabamento. Configurações têm seus próprios controles e paleta, com melhor acabamento no desktop do que adaptação à tela estreita.

| Dimensão | Avaliação editorial | Evidência principal |
| --- | --- | --- |
| Identidade e paleta | 7/10 | Escuro/ciano recorrente; cinza neutro, azul-petróleo e transparências competem entre famílias. |
| Tipografia e hierarquia | 7/10 | Família Gotham consistente; escalas de título, metadados e instruções sem uma hierarquia única. |
| Navegação | 7/10 | MenuNavigation e cascatas compartilhados; nomes, retornos e instruções ainda variam. |
| Componentes e estados | 5/10 | Botões, cards, seleção, foco e confirmações possuem implementações próprias. |
| Responsividade entre famílias | 4/10 | Estratégias distintas; remapeamento no telefone ficou com apenas 34 px de altura para a lista. |

## Percurso e cobertura

Foram preservadas **45 capturas** em `artifacts/ui-standardization-2026-11-01/`, com dimensões verificadas e índice em `capturas.csv`. São capturas de famílias e de seus estados representativos, não 45 menus independentes. `comparativo-familias.jpg` coloca seis famílias lado a lado.

O percurso principal usou o preset oficial Xbox One, com captura de 1920×1080. A comparação estreita usou iPhone 17 Pro em landscape, com captura de 874×402 e viewport informado pelo Studio de 750×382. O jogo usa `LandscapeSensor`; não foi feito teste em portrait. Os menus são construídos em runtime; StarterGui não tinha ScreenGuis próprios no início da revisão. Não é validação em hardware físico.

| Família | Percurso / estado observado | Avaliação de padronização |
| --- | --- | --- |
| Inicial | Início em uma sessão limpa; Jogar, Permanecer no lobby, Progresso, Ajustes e Música | Identidade forte, ícones lineares, losango e contorno turquesa. Composição própria apropriada para a entrada. O padrão visual se perde nos submenus neutros. |
| Modalidades | Grade com as quatro modalidades, detalhes do CTF e disponibilidade de Duels/Get Out | Grade e imagens ajudam. A cascata retoma os botões cinza, com outro ritmo e escala em relação à inicial. |
| Pausa | Hub e painéis de navegação de CTF/Arena; Continuar, Armeiro/Loadout, Progressão, Opções, Render-se e Sair | Clara, mas com aparência de menu genérico. Ações do mesmo nível não têm a iconografia e a hierarquia da inicial. |
| Configurações | Categorias; Geral, Controles, Analógicos, Remapeamento, Toque/HUD, Câmera, Mira, Retículo, Interface, Gráficos, Acessibilidade e Áudio | Família com boa consistência interna: rótulo, ajuda, controle e reset. Muitas camadas persistem simultaneamente, deixando pouco espaço em landscape estreito. |
| Utilidades de configurações | Desenvolvimento, Admin/mapas, confirmação de restauração | Reutilizam a estrutura da configuração, mas ações comuns e ferramentas administrativas parecem igualmente importantes. Admin/mapas retornou estado de catálogo indisponível nesta sessão. Não foram acionados seus mapas. |
| Música | Controles, lista de faixas e detalhe da faixa | Coerente com a cascata antiga. Botões neutros, informações em texto e grandes áreas vazias se distanciam do acabamento dos menus recentes. A playlist não foi editada. |
| Progressão | Perfil, Líderes e Comparação com Amigos | Uma das famílias mais coesas: cards, ícones, valores, abas, avatar e cor de seleção. Líderes mostrou a indisponibilidade de ranking global no Studio; comparação mostrou carregamento/ausência de seleção. Não houve validação de dados de produção. |
| Classe CTF | Criar Classe no Practice Range, slots, lista de armas, acessórios e opções da classe | Estrutura própria adequada à tarefa. Ciano, títulos e cards se aproximam da Progressão. Existem diferenças entre a seleção com ícone genérico, artes de acessórios e miniaturas 3D. Parte dos textos ainda usa termos em inglês. |
| Arena Loadout | Lista dos seis presets, arma ampliada, melee e descrição | Compartilha boa parte da linguagem do Armeiro, com composição mais simples. A diferença de complexidade é justificada pelo modo; título, rodapé e estados ainda podem ser comuns. Não foi confirmado outro equipamento. |
| Votação | CTF e Arena, com estado interativo e contagem; transição de resultados da Arena | Mesmo MapVoteGrid é um ponto positivo. CTF usa fallback textual para seus dois mapas; Arena usa miniaturas. O painel ainda pertence à família cinza, com outra seleção/ênfase em relação aos menus ciano. |
| Placar | Componente HeldStandings renderizado com os dados da sessão Arena | Tabela clara, mas seleção cinza, título e superfície translúcida se distanciam de Líderes/Progressão. Não necessita copiar o layout do ranking; pode compartilhar cabeçalho, linhas, identidade e semântica de destaque. |
| HUD CTF | Preparação, votação e Practice Range: arma, munição, vida, estamina, slots, timer e placar por equipes | Compartilha algumas âncoras com Arena, mas distribui e ordena informações de outra forma. Vida/munição, tamanho do texto e contornos precisam de uma regra comum. |
| HUD Arena | Preparação, partida, ranking no topo, vida, munição, estamina e resultados | Mesmas cores funcionais básicas, mas com disposição e densidade diferentes. Resultados mantêm essencialmente o HUD de partida com mudança de estado, sem apresentação de encerramento equivalente à qualidade dos menus recentes. |
| HUD Get Out | Prévia isolada do componente existente, com estado sintético de sobrevivente | Card no topo central com estilo próprio. Get Out está indisponível no catálogo; não foi ativada uma partida do protótipo. Não inferir navegação ou comportamento do modo a partir desta prévia. |
| Editor do HUD | Editor sem seleção e com inspetor do botão de disparo; cancelado | Círculos e ícones são adequados ao toque, mas toolbar/inspetor usam outro acabamento. No Hub, o catálogo reapareceu atrás do editor, aumentando o ruído e confundindo o contexto de edição. |
| Carregamento / recuperação | Entrada de modo e erro real de carregamento do CTF | Tela de função distinta e legitimamente própria. Cor azul, botões e tipografia ainda podem consumir a mesma base visual. O erro informa um ponto de nascimento sem chão; a rodada ficou em LoadFailed. Isso limitou a visita de uma partida CTF normal e não foi corrigido nesta análise. |

Duels e Get Out estavam explicitamente indisponíveis no catálogo. Os módulos JoinMenu e a cascata antiga de votação da Arena também foram lidos: os fluxos atuais redirecionam escolhas para o Loadout e votação flutuante. Não foram apresentados como novos menus acessíveis ao jogador. Feedback de dano, kill feed, avisos de bandeira, mira óptica e espectador foram incluídos na leitura dos componentes de HUD; não foram provocadas todas as combinações de combate, mortes ou notificações. A análise desses estados é de estrutura/código quando não há captura correspondente.

## Achados que explicam a sensação de divisão

### 1. A base visual já existe, mas os componentes não a consomem de forma uniforme

`MenuTheme.luau:12` define a paleta neutra; `:13` define outra paleta para Settings. `ProgressionView.luau:6`, `LoadoutMenuView.luau` e `CTFClassOverview.luau` têm suas próprias cores e superfícies. Há tons próximos suficientes para parecerem relacionados, com diferenças suficientes para parecerem de etapas diferentes do projeto.

`MenuTheme` usa arredondamentos de 18 px em superfícies comuns, 16 px em Settings e 14 px em botões. Progressão e componentes específicos usam ainda outros valores. Variação de raio pode ser intencional; falta uma escala declarada que associe cada valor a um papel visual.

### 2. O mesmo tipo de decisão muda de apresentação

Opções de classe usam modal central com fundo escurecido e botões azuis. Restauração de preferências substitui o conteúdo do painel de configuração por Confirmar/Cancelar. Sair abre um painel lateral grande com um botão de confirmação. A mesma semântica de decisão ganha três estruturas e sinais visuais diferentes.

Um componente comum de confirmação poderia oferecer variantes para ação normal e ação destrutiva, mantendo posição das ações, retorno, título, destaque e foco previsíveis.

### 3. A nomenclatura não é uniforme

- Inicial: **Ajustes**; pausa: **Opções**; título: **Configurações**.
- Inicial: **Progresso**; pausa: **Progressão**.
- CTF: **Armeiro**; Arena/títulos: **Loadout**; classe: **Criar Classe**.
- Há **Capture a Bandeira**, **Capture The Flag**, rótulos como **ASSAULT RIFLES**, nomes de teclas como **EQUALS** e unidades como **studs** no conteúdo observado.

Nomes reais de armas/acessórios podem permanecer próprios. Categorias, ações, títulos e instruções precisam de um glossário do produto.

### 4. A responsividade usa estratégias diferentes e não preserva sempre a área útil

No iPhone 17 Pro em landscape, a lista de remapeamento foi medida em **446×34 px**, dentro de um painel Detail de **462×198 px**. Acima dela ficam título, descrição, abas de categorias e abas de dispositivo. A lista não consegue mostrar uma linha completa confortavelmente. Essa é a prioridade mais objetiva desta revisão.

O Loadout estreito aceita rolagem e uma composição reduzida. A cascata geral oculta níveis anteriores em largura estreita; Settings preserva colunas/rails e também suas abas. A solução precisa considerar largura **e altura**, com um orçamento mínimo para o conteúdo ativo.

Os rodapés também continuam anunciando **Analógico/D-pad/X/Y** nas capturas estreitas, enquanto o jogador está num contexto de telefone simulado. `ExperienceMenu.luau:353` fixa esse texto; `:126` fornece outra versão fixa para Loadout. Não foi feito teste físico de toque ou controle nesta etapa.

### 5. As regras globais têm cobertura parcial

`InterfaceThemeController.local.luau:32` aplica tema/tipografia a uma lista explícita de ScreenGuis. `GetOutHUD`, `FloatingMapVote`, `ClassOptionsOverlay` e `CrossgroundsLoading` ficam fora dessa lista. Isso não prova que cada preferência falha em todos eles; prova que não recebem automaticamente a mesma política global. Alguns componentes têm regras próprias e outros não têm equivalentes.

A aplicação por nomes, nomes de filhos e atributos como `CascadeDecoration`/`SettingsStyled` exige muitas exceções. Componentes com contrato explícito de tema, escala e foco tornariam o resultado mais previsível.

### 6. Os HUDs compartilham assunto e cores, mas não uma gramática

CTF e Arena usam vida verde e estamina azul, perto do canto inferior esquerdo. No CTF, arma/munição vêm antes das barras; na Arena, vida vem antes de arma/munição. Timer, objetivo, status da modalidade e ranking ocupam áreas e níveis de destaque diferentes. Get Out usa outro card no topo central.

As informações próprias de cada modo devem continuar próprias. Vida, estamina, arma, munição, objetivo, estado de rodada, notificações e atalhos podem compartilhar escala tipográfica, espaçamento, contraste e posições reservadas.

## Direção recomendada

A melhor referência visual é a combinação da identidade da inicial, da hierarquia da Progressão e dos controles de Settings. O Armeiro já se aproxima dessa direção. Preservar as composições específicas: inicial ampla, configurações com controles, seleção com inspeção, placar em tabela e HUD compacto.

1. **Prioridade alta — área útil em telas baixas:** compactar a navegação e cabeçalhos de Settings, alternar níveis quando necessário e garantir uma lista com linhas completas. Corrigir instruções para o dispositivo/contexto ativo.
2. **Prioridade alta — base compartilhada:** uma paleta semântica e escalas de fonte, espaço, raio, opacidade e foco. Separar seleção, hover, foco, equipado, pendente, indisponível e ação destrutiva.
3. **Prioridade média — componentes comuns:** cabeçalho/voltar, navegação, botão, card, aba, rodapé, tabela e confirmação. Unificar pausa e playlist primeiro, onde a diferença em relação à inicial é maior e a estrutura é mais simples.
4. **Prioridade média — HUD compartilhado:** padronizar os blocos comuns e reservar zonas para particularidades de cada modo; alinhar também placar e feedback.
5. **Prioridade média — acabamento de conteúdo:** glossário, ícones, miniaturas de mapa CTF e tratamento de estados vazios/futuros. Evitar dar a uma funcionalidade indisponível a mesma presença de uma ação pronta.
6. **Antes de considerar concluído:** conferir as famílias em desktop/console e telefone landscape, com fonte ampliada e alto contraste, por mouse, teclado, controle e toque. Usar o mesmo conjunto de capturas como referência de aceitação.

## Método e limites da inspeção

A navegação começou com mouse/teclado da ferramenta. O Studio perdeu foco para entradas de teclado; depois foram usados ganchos de navegação temporários, em Play, que chamaram `MenuNavigation` e os callbacks existentes. Eles não alteraram o estilo das telas. Entrada de modos usou o protocolo existente; os comandos de desenvolvimento do Studio encurtaram o tempo da Arena e abriram sua votação para inspecionar os estados.

O placar foi renderizado a partir da fonte real em uma cópia temporária do LocalScript, ignorando apenas o bloqueio de `ControlRouter:IsBlocked()` causado pelo foco inativo. A captura serve para julgar seu visual; não valida Tab/controle em uso normal. O HUD Get Out foi renderizado em cópia temporária com dados sintéticos e visibilidade local, sem habilitar o modo ou seu catálogo.

Nenhuma confirmação de restauração/exclusão foi concluída, nenhum preset foi salvo e o editor de toque foi cancelado. Scripts e GUIs temporários existiram somente no Client durante Play e desapareceram no encerramento. Uma sessão limpa final recapturou a inicial. Editor confirmado sem instâncias `UIReview`; simulador devolvido ao viewport padrão; Place deixado em Edit. Não houve publicação, push, teste unitário novo, benchmark ou validação em hardware físico nesta etapa.

Mudanças de áudio/ADS já presentes no checkout foram preservadas. As únicas entregas persistentes desta análise são este documento, as evidências e o registro no Estado de desenvolvimento.
