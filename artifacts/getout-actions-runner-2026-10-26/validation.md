# Get Out: interações, Runner e travessias

Entrega iniciada em 26/10/2026 e conferida em 27/10/2026 no Place Crossgrounds (ALPHA), 4375993208. Fontes anteriores dos dez scripts alterados em before/. Scripts de diagnóstico e integração ficam em tests/Integration; as cinco fixtures temporárias foram retiradas do Place após a execução. Não há ponto de entrada de QA no bootstrap normal.

## Falha reproduzida

Foi executado um teste com dois clientes reais do Studio e os controles normais carregados. O sobrevivente estava ativo, com ClientLoading=false, sem menu/transition e junto de PC1.HackSlot2. Router:Dispatch de ReloadInteract chamou a interação normalmente.

O servidor recebeu PromptButtonHoldBegan, depois PromptButtonHoldEnded e só então Triggered (cerca de 0,7 ms depois do evento de término). O handler antigo apagava holds[player] no término; Triggered rejeitava a ação mesmo depois de cumprir o tempo. O teste confirmou hackActive=false. Esse mesmo construtor de prompts atendia corda, cápsulas, resgate e manivelas.

## Correção

- Interações Get Out usam protocolo explícito begin/complete/cancel e registros do servidor para os prompts daquela rodada. O servidor confere papel, estado, participação, distância, prompt habilitado e tempo realmente decorrido. Pedidos de conclusão não antecipam o tempo de segurar.
- O caminho nativo de compatibilidade conserva brevemente o registro após HoldEnded para tolerar a ordem real dos eventos.
- O cliente mantém a mesma ação remapeável de interação e o botão de toque. O CTF continua usando seu caminho anterior.
- O teste de dois clientes foi repetido: hackActive=true usando a ação normal do cliente, sem chamar StartHack diretamente.
- Menus ocultos do CTF não bloqueiam controles de Get Out por estado residual.

## Movimento e classe

- Runner é a classe padrão da Besta: multiplicador 2,5 (+150%), duração de 3 s, salto bloqueado no servidor e no cliente durante o efeito. Base de 18 resulta em 45 studs/s. A recarga de 20 s é provisória.
- Cruzar uma janela aplica multiplicador 0,4 (-60%) à velocidade da Besta e reduz a velocidade horizontal carregada. Duração de 1,5 s é provisória. Os modificadores compartilham um cálculo de movimento para não se anularem por atribuições concorrentes.
- O salto de Get Out foi limitado a 2,4 studs, com limite adicional conforme a altura da cabeça do avatar e a abertura da janela. Arena, CTF e lobby não recebem esse ajuste.
- Rastejamento usa Begin/End/Cancel, incluindo soltura rápida, perda de foco e término de toque/mouse fora do botão. Ao soltar dentro do duto, o personagem permanece baixo até haver espaço e levanta automaticamente ao sair.
- Nova animação procedural dedicada, com quatro poses interpoladas, braços e pernas alternados, flexão de cotovelos/joelhos, cabeça levantada e movimento de tronco. A frequência acompanha o deslocamento. A entrada/saída mistura a pose atual e pode ser interrompida, sem enfileirar animações. Suporta Motor6D e AnimationConstraint, com nomes normalizados de R6/R15.

## Referência de Facility

Foram medidos os modelos originais de Development.MapSources.GetOut.Facility. AirVent tem aproximadamente 2 x 3 x 6 studs; Window, 2 x 6 x 8. As dimensões se repetem em vários exemplares do modelo.

O laboratório passou de duto de 14 studs de profundidade para 2, conservando 3 de altura e 6 de largura. A abertura interna é de 2,2 studs. A janela foi ajustada a 2 x 6 x 8, com borda superior livre em Y=108,6 no laboratório. A moldura inferior do duto é decorativa, sem colisão, como a referência: sua colisão bloqueava o deslocamento planar do corpo baixo na primeira execução. A geometria anterior foi preservada em Development.Revisions.Maps.

## Rodada multicliente concluída

ExecuteMultiplayerTestAsync com três clientes reais. As interações foram acionadas pelo ControlRouter/InteractionController e pelas remotes normais; as posições iniciais dos cenários foram preparadas pelo teste. Resultados de hack, corda, resgate e fuga não foram forçados por chamadas diretas às funções do servidor.

35 verificações passaram:

1. Três clientes prontos no hub, rodada iniciada e carregamento encerrado para todos.
2. Interação curta cancelada e recusa de prompt de computador para a Besta.
3. Hack iniciado pela ação normal do cliente.
4. Toque curto no rastejamento interrompe a entrada; segurar entra; soltar levanta em espaço livre.
5. Ombros/joelhos animados durante movimento físico.
6. Travessia do duto compacto sem teleporte; tentativa de levantar sob o teto bloqueada; levantamento automático após sair.
7. Ambos os papéis atravessam a janela com salto limitado.
8. Runner: velocidade 45, salto zero/desabilitado, duração de três segundos e restauração.
9. Janela: velocidade da Besta reduzida a 7,2 e restaurada após o efeito.
10. Golpe do cliente derruba; interação prende a corda; interação aprisiona na cápsula; outro cliente resgata.
11. Quatro computadores concluídos em cooperação, incluindo checks enviados pelos clientes.
12. Quatro travas liberadas e manivela abre a saída física.
13. Ambos os sobreviventes atravessam a saída, recebem resultado escaped e a rodada chega a results, com ending=all_survivors_resolved.

## Conferência complementar final

Mais 11 verificações passaram em dois clientes, com o salto final de 2,4 e a versão 3 da geometria. Ambos atravessaram a janela a partir de uma aproximação curta; topo máximo da cabeça: sobrevivente Y=108,452 e Besta Y=108,448, abaixo da borda inferior do topo em Y=108,6. A lentidão da janela continuou funcionando.

O alinhamento vertical da animação foi corrigido para compensar o deslocamento do joint raiz de R15 e a queda física do root ao deitar. O menor ponto do tronco ficou em Y=100,389, acima do piso Y=100. A transição compensa essa diferença gradualmente; o movimento planar inicia após a entrada de 0,32 s. Segurar e soltar foram novamente aprovados.

As molduras inferiores de duto e janela são decorativas, sem colisão. O peitoril físico da janela termina em 3 studs, mantendo a moldura de 0,4 separada, conforme a referência Facility.

Conferência de encerramento: 11 fontes locais iguais às fontes do Studio; 130 scripts compilados sem erro; manifesto do mapa válido; nenhuma das cinco fixtures de teste permaneceu em ServerScriptService/StarterPlayerScripts.

A sessão completa demonstrou o ciclo de partida e as interações; as posições foram controladas para repetir os cenários, portanto não representam uma partida humana de balanceamento. Toque em aparelho e controle físico ainda precisam de conferência manual.
