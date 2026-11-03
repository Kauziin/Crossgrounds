# Nova UI — primeiro bloco no Roblox

03/11/2026. Editor principal: Crossgrounds ALPHA, place 4375993208. Sem publicação.

## Etapas revisadas

Direção vigente: duas experiências, Atual anterior ao experimento Geral/Completo e Nova, com identidade Crossgrounds, navegação aberta, menus primeiro e HUD depois. Referência operacional: instructions/UI/#10b/PLANO-RECRIACAO.md, decisões mais recentes e protótipo local. A UI #11b (diagramas/remapeamento) está explicitamente fora desta implementação.

Sequência de implementação: fundação e inicial/modalidades; pausa e categorias de configurações; Armamentos/Armeiro; demais páginas de Carreira/Social; consolidação/responsividade; HUD em etapa posterior. Os destinos atuais continuam acessíveis enquanto sua apresentação não foi migrada.

## Implementado agora

- NovaHubView: apresentação Luau separada da inicial e modalidades, com ações reais de Jogar, explorar lobby, Música, Configurações, Carreira e Social. Navegação interna tem uma região principal, sem empilhamento de colunas. Carreira oferece perfil, progressão/estatísticas e progressão da guilda; Social oferece grupo/amigos e guilda, encaminhando aos fluxos existentes.
- Catálogo de modalidades real via HubBridge. Disponibilidade, motivo de indisponibilidade, descrição, estado de entrada/cancelamento e treino vêm dos dados atuais. Modos em desenvolvimento continuam consultáveis sem permitir entrada.
- Entrada no Practice Range e modalidade respeita o fluxo existente de join/ticket/enter; nenhum serviço de fila, XP ou loadout refeito. Armamentos no hub explica a necessidade de entrar na modalidade e conduz ao catálogo, preservando a regra existente; não oferece edição fictícia de equipamento fora do contexto autorizado.
- Duas escolhas no sistema existente de preferências: Atual (0) e Nova (1), padrão Atual. Valor experimental 2 migra para 1 no carregamento; novas edições aceitam somente 0/1. Temas/paleta permanecem independentes.
- A camada de estilos experimentais deixou de remodelar as Views antigas: elas usam composição clássica enquanto a Nova tem sua apresentação própria. Não foram copiadas as antigas opções Geral/Completo para dentro de outra variação estética.
- MenuNavigation reconhece NovaHub e ignora o fundo antigo quando a GUI antiga está desativada. Apenas a apresentação ativa fica acessível ao foco/entrada no lobby. Sons usam o sistema de navegação existente; transição curta de página respeita movimento reduzido.
- Mobile paisagem: disposição compacta, rolagem de modalidades e ações de entrada/treino próprias, sem encolher o menu inteiro pelo fator mobile legado. Preferências salvas existentes não foram reescritas. A Nova usa dimensionamento próprio; as Views antigas mantêm suas opções de escala.

## Validação efetiva

46/46 casos passaram em InterfaceStyle, PreferenceProfile, PreferenceDrafts, ThemeAndInterface e MobileMenusAndSafeZone. Incluem migração de valores experimentais, isolamento da paleta e restrição de escopos.

Play novo após alteração das fontes. Fluxo testado por chamadas ao sistema normal de navegação/preferências em LocalScript temporário: selecionar Nova ativa NovaHub e desativa apresentação antiga; abrir Configurações fecha a Nova; Jogar abre catálogo; Practice Range entra em CTF com CTFPracticeRange=true e fecha NovaHub. Retorno ao hub + Atual reativa a apresentação antiga e desativa NovaHub. Sem testes com gamepad físico ou entrada de toque física.

Capturas reais do Studio em artifacts/nova-runtime-2026-11-03: inicial e modalidades em Xbox 1920x1080; modalidades em iPhone paisagem 874x402 (viewport 750x382). No mobile, lista mediu 662x63 px, com uma linha acessível e demais opções por rolagem; este estado compacto ainda precisa de avaliação de uso. Ações principais permanecem visíveis.

8/8 fontes finais compiladas e iguais ao editor, resultados em source-match.json. git diff --check passou. Sem erro novo de runtime das fontes modificadas observado; console mantém avisos anteriores de áudio, GUIEditor e organização de TestService. Play encerrado, testes temporários removidos e simulador restaurado ao padrão.

## Pendências e limites — situação atualizada em 03/11/2026

Inicial compartilhada Clássica/Neo, catálogo de modalidades Neo, pausa/saída/rendição Neo e páginas comuns de Configurações Neo já implementados. Cabeçalhos de Carreira/Social no hub encaminham a destinos existentes; isso não significa que os conteúdos desses destinos estejam migrados.

Ainda falta apresentação Neo dedicada para: seleção/edição de classes e armamentos Arena/CTF, Armeiro (armas, acessórios, prévias, presets e opções da classe); Progresso (estatísticas, líderes, amigos, trilhas de conta/armas/guilda); Carreira/perfil e cosméticos; Social/grupos/amigos/guilda; Música/Playlist; votação de mapas, painéis de entrada/fila e resultados/pós-jogo; componentes especializados de configurações (remapeamento, personalização de temas e editor de HUD). Estes sistemas continuam funcionais em suas apresentações existentes. Aplicar tokens de tema não equivale à migração da composição/experiência.

HUD e família de avisos ficam para a etapa posterior: vida/estamina/equipamento, placares, killfeed, XP, bandeiras/objetivos, eliminações/medalhas e controles mobile. A UI #11b permanece fora do escopo atual. A cena dedicada de inicial é opcional; a inicial vigente continua a Clássica compartilhada. Comparação integral com a Clássica anterior ao experimento e validação física por plataforma permanecem pendentes.

Não valida produção/DataStore real, todas as modalidades, todos os estados de erro/cancelamento, gamepad/toque físico, multiplayer ou FPS. A migração de preferências foi testada como contrato; não é evidência de gravação em produção. Não houve publicação, commit ou push.

## Arquivos

- `src/ReplicatedStorage/ExperienceSettings.luau`
- `src/ReplicatedStorage/Crossgrounds/InterfaceStylePolicy.luau`
- `src/ReplicatedStorage/Crossgrounds/PreferenceProfile.luau`
- `src/StarterPlayer/StarterPlayerScripts/InterfaceStyle.luau`
- `src/StarterPlayer/StarterPlayerScripts/ThemeSelectionView.luau`
- `src/StarterPlayer/StarterPlayerScripts/HubController.local.luau`
- `src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau`
- `src/StarterPlayer/StarterPlayerScripts/NovaHubView.luau`
- `tests/Unit/Cases/InterfaceStyle_Test.luau`
- `tools/serve_nova_runtime.py` (ponte local de validação)
- `ESTADO-DO-DESENVOLVIMENTO.md`

## Correção de direção — Clássica e Neo

Nomes públicos confirmados pelo usuário: Clássica (0) e Neo (1). A inicial não terá variante Neo: ambos os temas usam exatamente a apresentação inicial Clássica do HubController. NeoHub é ativado apenas nas páginas internas; Voltar retorna ao root clássico. A linguagem dessa inicial orienta as telas internas Neo: listas verticais, texto/ícones sem caixas permanentes e foco/seleção delimitados. O seletor, a prévia e a ajuda foram renomeados; IDs/valores de preferência não mudaram. Nome interno NovaHub/NovaHubView continua técnico, sem criar terceira opção.

Validado em Play com InterfaceStyle=1: CrossgroundsHub ativo e NovaHub desativado na inicial; Jogar troca para a lista vertical Neo; Voltar reativa a inicial compartilhada. Labels de runtime confirmados CLÁSSICA/NEO. Captura 04-inicial-compartilhada-neo.jpg registra a inicial real. A expansão integral desse estilo para telas ainda não migradas continua pendente; base de botões compartilhados já aplica estados Neo sem alterar o tema Clássica. Sem publicação ou #11b.


## Etapa seguinte concluída — Configurações Neo

NeoSettingsLayout apresenta uma página por vez, retirando a cascata de colunas de categorias/subcategorias/opções na Neo. Preferências, escopos e callbacks preservados; Clássica mantém layout e fator mobile próprios. Linhas menos encaixotadas e controles mobile com escala efetiva do painel. Verificados caminhos Câmera, Interface e Analógicos, mudança/restauração do killfeed e alternância de estilos. Três capturas e limites em artifacts/neo-settings-2026-11-03/VALIDACAO.md. Diagramas #11b, HUD e telas especializadas não recriados.


## Neo — pausa, saída/rendição e acabamento do fundo

Reduzidas margens laterais para 3% (16–48 px) e intensificado gradiente preto de tela inteira. Pausa recebeu lista vertical sem painel, seguindo inicial Clássica; saída/rendição recebem a mesma apresentação com Voltar acessível por toque. Preservadas ações e confirmações existentes, não executadas nos testes. Validação/capturas em artifacts/neo-pause-2026-11-03/VALIDACAO.md.

## Ajuste seguinte — fundo suavizado e dicas por plataforma

Conforme nova correção, gradiente de ExperienceMenu suavizado: transparência base .07 e extremo .28. NeoNavigationHints apresenta ações por símbolos e teclas/glifos nativos de InputIcons, com ações contextuais da opção selecionada. Usado em ExperienceMenu e NovaHubView; evita duplicar rodapé legado. Mobile não mostra dicas de navegação, inclusive rodapé global de controle; controles de toque permanecem disponíveis. Captura de remapeamento mantém mensagens funcionais e oculta dicas enquanto aguarda entrada.

Play verificou teclado, apresentação Xbox simulada, iPhone paisagem, ocultação mobile na Clássica/Neo e hub, e início/expiração de captura sem alteração do vínculo. Sem controle físico ou PlayStation validado. Evidências e limites em artifacts/neo-hints-2026-11-03/VALIDACAO.md. Não houve migração das demais interfaces nem implementação #11b/publicação.

## Dicas dinâmicas por controle em foco

MenuNavigation.GetHintContext descreve ações realmente registradas no alvo em foco, ajuste, callback de voltar e categorias do menu ativo. NeoNavigationHints deixa de presumir X em toda a página de Loadout ou Y em todo controle ajustável; usa custom/reset/options/group do dispatcher existente. SetActions notifica alterações de ações no mesmo card. Troca de raiz/foco, caixa de texto e abertura/fechamento do menu Roblox atualizam as dicas; menu pai não mantém dicas atrás de uma confirmação flutuante. Dispositivos móveis continuam sem dicas. Não adiciona atalhos ou muda os callbacks de seleção/equipamento.

Play novo verificou slider, booleano, botão comum, alterações de ações no mesmo alvo, edição de texto, confirmação flutuante e troca para pausa. Apresentações especializadas ainda não migradas devem consumir a mesma fonte de contexto ao receber a composição Neo.
Sessão adicional confirmou LS e grupos LT/RT na apresentação Gamepad simulada somente enquanto seus callbacks estão registrados. 15/15 fontes compiladas e correspondentes ao editor; sem teste físico de controle ou nova simulação mobile nesta etapa. Play encerrado, sem publicação.
