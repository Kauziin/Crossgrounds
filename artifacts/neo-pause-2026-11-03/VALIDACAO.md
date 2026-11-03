# Neo — margens, fundo e pausa

Alterações: margens Neo calculadas em 3% da largura, limitadas a 16–48 px por lado; removido teto de 1180 px que criava grandes espaços laterais. Exemplo desktop 1459 px: margem 44 px e painel 1371 px. Conteúdo continua na área segura; fundo independente cobre a tela física.

Fundo: preto puro com transparência base .03; gradiente adicional 0→.08→.22, mais intenso que o anterior .16 com gradiente até .55. Aplicado a Configurações, Pausa e páginas de saída/rendição da Neo; Clássica preservada.

Novo NeoPauseLayout organiza pausa como lista vertical de texto/ícones/divisórias, sem painel encaixotado. Mesma apresentação aplicada às páginas Exit/Surrender, preservando callbacks e confirmação existentes. Botão Voltar visível nessas páginas para toque; nenhuma confirmação de saída/rendição executada nos testes.

Validação em Play: Configurações com margem medida; pausa sem sobreposição de título/lista após cancelamento do tween legado; Continuar fecha menu/fundo; entrada real no Practice Range CTF para visitar saída/rendição; confirmação existente encontrada na saída; alternância Clássica/Neo esconde/restaura título/fundo; botão de voltar por toque retorna à pausa. iPhone paisagem: lista 440x178 px, com rolagem das ações restantes. Capturas desktop 1459x748 e mobile 874x402. As capturas de pausa antecedem somente o ajuste de Back nas páginas de confirmação, sem mudança visual da pausa capturada.

Um erro de sintaxe no preparo da fonte foi identificado pelo compilador e corrigido antes da execução da nova versão. O primeiro Play ainda usou a fonte anterior por esse bloqueio; verificações posteriores foram feitas em sessão nova com as fontes aplicadas. Encontrada também animação antiga deslocando pane da pausa sobre o título, cancelada no ramo Neo. Sem novo erro de runtime das fontes observadas após correção; console mantém avisos antigos de áudio, plugin e TestService.

Arquivos funcionais: ExperienceMenu.local.luau e NeoPauseLayout.luau (novo). Sem alterações #11b, HUD, regras de equipamento, recompensas ou dados. Sem controle/toque físico, partida humana completa, desempenho ou publicação.
