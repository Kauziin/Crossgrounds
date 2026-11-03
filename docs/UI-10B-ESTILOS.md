# UI #10b — estilos adicionais e direção de interface

> Registro histórico da entrega anterior. A correção do usuário exige exatamente duas interfaces, Atual e Nova. A direção vigente de planejamento está em `instructions/UI/#10b/PLANO-RECRIACAO.md`. Geral/Completo deixam de ser opções de produto no plano futuro; nenhum rollback ou migração foi executado nesta revisão.

Data: 03/11/2026. Aplicado ao editor principal, place 4375993208. Sem publicação.

## Leitura das referências

Foram inspecionadas as duas imagens de `instructions/UI/#10b` e as recomendações anexadas pelo usuário. As imagens são referências de composição; números, armas/acessórios e descrições ilustrativas não foram importados como regras do jogo.

- A referência de Progressão agrupa navegação, filtros, ranking e posição pessoal em poucas superfícies amplas. O título precede o conteúdo; a cor identifica a seleção, em vez de contornar tudo.
- A referência de Acessórios dedica quase metade da área útil à arma. Categorias horizontais, lista vertical, detalhe contextual e ações inferiores permanecem separados por função. O menu lateral continua presente.
- A recomendação distingue o caráter de entrada/navegação do caráter de edição. Isso pode ser compartilhado por componentes de apresentação, sem duplicar serviços ou telas funcionais.

## Decisão implementada

`Configurações → Interface → Estilo da interface`, também acessível em `Configurações → Temas`:

| Valor | Opção | Composição |
|---|---|---|
| 0 | Atual | Padrão dos perfis antigos; dimensões e linguagem anteriores |
| 1 | Geral | Navegação sem caixas em itens inativos, menos bordas, título destacado e mais respiro |
| 2 | Completo | Painéis ampliados, navegação mais compacta e mais espaço para listas/prévia |

A escolha é global e independente de `ThemePreset`/HSV. Usa `ExperienceSettings`, `PreferenceProfile`, `PreferenceDrafts`, `PreferenceClient` e o serviço existente de configurações. Não há um segundo armazenamento. Valores inválidos e tentativas de escopo por modalidade/dispositivo são rejeitados. A restauração ao padrão retorna a Atual. Trocar a aparência não equipa arma, salva preset de armamento ou concede XP.

O papel da tela continua relevante nos dois estilos novos: navegação geral recebe cabeçalho e espaço; edição recebe limites de largura/altura maiores. Assim o estilo Geral não comprime o Armeiro para caber em uma composição de menu inicial. Completo prioriza área útil também nas páginas gerais.

## Arquitetura e alcance desta entrega

`InterfaceStylePolicy` mantém IDs estáveis e métricas sem estado. `InterfaceStyle` fornece apresentação, cabeçalho e observação de preferências. `MenuTheme` continua responsável por paleta, superfícies, botões e acessibilidade. Não há novo laço por frame; as alterações respondem a preferência, foco e redimensionamento existentes.

| Área | Implementado |
|---|---|
| Menus Cascade | Limites de composição, cabeçalho e superfícies compartilhadas |
| Pausa e configurações | Dimensões por estilo, lateral preservada e menos bordas em estados inativos |
| Progresso | Título com marca compacta, navegação Geral sem caixas inativas, superfícies internas simplificadas e composição ampliada |
| Armeiro — armas/acessórios | Prévia com aproximadamente 48% da largura em telas largas, lista vertical e detalhes em região própria |
| Acessórios | Linhas mais altas nos estilos novos para nome/estado, itens disponíveis antes dos indisponíveis ao abrir a lista |
| Temas | Escolha de estilo, amostra de seleção/progresso ao vivo e 22 paletas existentes |
| Mobile | Cabeçalho compacto, seções de Progresso, empilhamento da prévia estreita, seletor de estilos com altura de 64 px na resolução validada |

Os sistemas de navegação, catálogos, prévias, montagem, atributos e permissões continuam os existentes. Os números de atributos no Armeiro vêm do fluxo já existente do CTF; nenhuma estatística foi introduzida na Arena. Os efeitos semânticos do HUD de combate não são alvo desta camada de estilo.

Corrigido também o apagamento dos rótulos da lateral ao mudar de modalidade com a navegação recolhida. O texto temporariamente vazio da coluna de ícones não pode substituir `ExpandedText`. Removida uma assinatura duplicada de `CTFPracticeRange` nesse fluxo.

## Direção para o editor de tema completo

A proposta de editor por tipo de elemento fica documentada, separada da entrega funcional acima. Ela ainda não está implementada integralmente.

1. Expor os papéis existentes em grupos: superfícies, destaque, bordas e texto. Estados de combate mantêm semântica protegida.
2. Usar edição temporária com Aplicar/Cancelar, sem gravar a cada movimento da roda de cor. Presets continuam como ponto de partida.
3. Prévia deve mostrar simultaneamente um menu Geral e um painel Completo com lista, botão, foco, slider e progresso.
4. Calcular contraste entre texto/superfície e foco/superfície antes de aceitar uma combinação; a correção deve ser visível na prévia.
5. Expandir o esquema e a validação do servidor para cores por papel antes de persistir tais campos. Manter o controle de acesso existente, sem liberar personalização protegida apenas no cliente.
6. Em telas estreitas, alternar Editor/Elementos/Prévia por etapas; evitar quatro colunas comprimidas.

Nesta entrega, o HSV e sua permissão permanecem no fluxo existente. Não foram criados um seletor circular, cores arbitrárias independentes por componente, novos passes, novas regras de balanceamento ou acessórios para preencher referências.

## Validação efetiva

- 45/45 testes passaram: `InterfaceStyle_Test` (sete novos contratos), `PreferenceProfile_Test`, `PreferenceDrafts_Test`, `ThemeAndInterface_Test` e `MobileMenusAndSafeZone_Test`.
- Nova sessão de Play após mudanças visuais; 12/12 fontes finais compiladas e iguais ao editor. Registro em `artifacts/ui-10b-2026-11-03/final-source-match.json`.
- Troca de estilo por callbacks reais de `PreferenceClient`, com confirmação no estado efetivo. Não foram acionadas compras nem alteradas permissões.
- Com Studio ativo: D-pad esquerdo moveu Completo → Geral, A aplicou Geral e B voltou para o item Temas no menu pai. Entradas simuladas pelo Studio; não representa controle físico.
- Transição de configurações recolhidas para CTF Practice Range: seis rótulos laterais não vazios após a correção, incluindo Configurações, Progressão, Render-se e Sair.
- Capturas no simulador Xbox 1920×1080 e 1280×720. Em 720p o conteúdo que excede a altura usa a rolagem existente; a tipografia não é reduzida para simular uma tela lógica de 1760 px.
- iPhone 17 Pro landscape 874×402, viewport 750×382. Botões de estilo mediram aproximadamente 131×64 px. Linhas HSV mediram 412 px de largura e os três controles de restauração ficaram dentro de suas linhas após compensar a escala do conteúdo.
- `git diff --check` passou. Existiam avisos de assets de áudio sem acesso/arquivados, plugin GUIEditor e organização antiga de TestService. Uma tentativa de laboratório durante a transição CTF falhou por acessar o Armeiro antes de sua criação; repetida após a transição, passou. Não foi observado erro novo de runtime dos módulos de estilo.
- Play encerrado, pasta temporária `UI10bTests` removida e simulador restaurado ao padrão. Alterações paralelas preexistentes preservadas.

### Evidência visual

Pasta `artifacts/ui-10b-2026-11-03`:

- `01-general-progress-1080.jpg`: Geral, Progresso com navegação simplificada.
- `02-complete-weapons-1080.jpg`: primeira verificação do layout ampliado de armas, anterior ao ajuste final de transparência.
- `03-style-and-theme-1080.jpg`: seletor de estilos e paletas na mesma página.
- `04-complete-progress-720.jpg`: composição final de Progresso em 720p.
- `05-progress-mobile.jpg`: Progresso estreito com seletor de seções e rolagem.
- `06-styles-mobile.jpg`: botões de estilo com leitura e toque ampliados.
- `07-complete-accessories-1080.jpg`: Acessórios final, prévia ampliada e rótulos laterais restaurados.

As capturas mostram dados da sessão Studio, não estatísticas ou persistência de produção. O personagem e os modelos são os reais da experiência.

## Limites

Não é uma reconstrução de todas as telas específicas. Telas que não usam os componentes compartilhados precisam de uma migração própria para aproveitar toda a composição. Também permanecem pendentes editor de cores por papel/roda cromática, comparação visual de todos os estados, hardware físico, retrato, todas as proporções, gestos completos, DataStore de produção, multiplayer humano e medição de desempenho/FPS. Não houve publicação, commit ou push nesta tarefa.

## Arquivos desta entrega

- `src/ReplicatedStorage/ExperienceSettings.luau`
- `src/StarterPlayer/StarterPlayerScripts/MenuTheme.luau`
- `src/StarterPlayer/StarterPlayerScripts/InterfaceThemeController.local.luau`
- `src/StarterPlayer/StarterPlayerScripts/CascadeMenu.luau`
- `src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.local.luau`
- `src/StarterPlayer/StarterPlayerScripts/ProgressionView.luau`
- `src/StarterPlayer/StarterPlayerScripts/ArsenalSelectionView.luau`
- `src/StarterPlayer/StarterPlayerScripts/ThemeSelectionView.luau`
- `src/StarterPlayer/StarterPlayerScripts/SettingsVisual.luau`
- `src/StarterPlayer/StarterPlayerScripts/SettingsCard.luau`
- `src/ReplicatedStorage/Crossgrounds/InterfaceStylePolicy.luau`
- `src/StarterPlayer/StarterPlayerScripts/InterfaceStyle.luau`
- `tests/Unit/Cases/InterfaceStyle_Test.luau`
- `tools/ui_10b.py` (ponte local de validação, fora do runtime)
- `ESTADO-DO-DESENVOLVIMENTO.md`
- Este relatório e evidências em `artifacts/ui-10b-2026-11-03`.
