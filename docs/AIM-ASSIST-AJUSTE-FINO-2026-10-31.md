# Aim Assist: ajuste fino e distância

Implementação em 31/10/2026 no Crossgrounds (ALPHA), Place ID 4375993208, carregado como versão 347. Desenvolvimento e calibração em cópias dos módulos no cliente de Play; depois, merge de cinco fontes em Edit e sincronização local. Um novo Play verificou o código de produção, sem os módulos temporários de teste. Não houve publicação nem operação de salvamento na nuvem pelo agente.

## Comportamento

- Desaceleração e acompanhamento continuam independentes. O teste com controle físico confirmou que a desaceleração já atuava; o usuário esclareceu que faltava atração para o ajuste fino.
- Acompanhamento: força integral de distância até 80 studs, redução até 250; seleção e desaceleração terminam em 300. O movimento alinhado do analógico deixa de sofrer a penalização de 90% usada para escapar da desaceleração. Correções pequenas, já filtradas pela zona morta física, não reiniciam a aquisição por uma segunda zona morta de 2,5%.
- Nova preferência `AimAssistCentering`, **Atração suave ao alvo (%)**, em Opções → Mira e câmera → Mira. Padrão 65% do componente, multiplicado pela intensidade geral existente; zero desliga apenas a atração. A calibração inicial de 50% foi considerada fraca; o usuário aprovou a força reforçada e pediu explicitamente que ela preservasse quem já está acertando.
- A atração atua ao segurar ADS ou fornecer entrada deliberada de olhar, com aquisição gradual. Fora de ADS, soltar a entrada zera a atração. Cada eixo cede quando o jogador olha para o lado contrário; movimentos amplos também removem a atração. Controle/toque continuam sendo os dispositivos assistidos.
- **Preservação da região escolhida:** a atração corrige apenas o erro até a borda mais próxima da região do alvo. Dentro dessa região, não centraliza. Um raycast adicional até a direção atual confirma acertos reais no alvo e bloqueia a atração também na cabeça ou em partes fora da região aproximada. O acompanhamento do movimento mantém sua âncora própria; não foi convertido em centralização no peito.
- Atração tem curva própria de distância: começa a reduzir em 150 e termina em 300 studs, respeitando também o alcance da arma e a seleção. Resposta proporcional 18, tetos de 18°/s horizontal e 10°/s vertical, multiplicados por intensidade, preferência, distância, janela e aquisição. A contribuição por frame é limitada e não ultrapassa o erro restante até a borda.
- O medidor existente abaixo do retículo agora mostra a distância numérica em studs, inclusive fora de ADS e ao mirar em superfícies. Ao mirar com ADS sobre um personagem, mantém também a faixa de dano existente. A distância corresponde à superfície atingida pelo raio atual; não mede um inimigo através de uma parede.

## Validação realizada

- **39 contratos aprovados** na cópia e novamente num novo Play após o merge: 31 de assistência, quatro de analógicos e quatro de intenção/toque/perfis existentes. Incluem atração em alvo parado, repouso em hip fire, saída manual, componente desligado, gesto expirado, hitches, distância própria, ausência de overshoot e preservação de mira já sobre o alvo.
- Três contratos novos reproduziram limitações do cálculo anterior: movimento forte alinhado, microcorreção após a filtragem física e acompanhamento nas distâncias médias. A versão anterior falhou nesses três casos; a correção passou.
- Com controle físico, foram observados entrada Gamepad, alvos elegíveis, desaceleração e contribuição do acompanhamento na câmera real. A rodada de calibração do acompanhamento registrou correções entre aproximadamente 80 e 138 studs, sem correções em 297 frames de analógico direito neutro e sem contribuição contrária à entrada. Os números de antes/depois não são um benchmark controlado, pois as cenas e as entradas variaram.
- A força da atração reforçada foi aprovada pelo usuário com controle. Depois dessa aprovação, a regra final mudou de atração ao centro para entrada na borda, conforme a correção do usuário. A preservação final foi verificada com geometria real e contratos; a avaliação prolongada de conforto dessa última trajetória permanece aberta.
- **Três cenários com peças e raycasts reais usando a fonte final de TargetingAssist:** cabeça fora da região aproximada: acerto confirmado e atração zero; tronco: atração zero; mira ao lado: correção na direção da borda. A cena e os módulos eram temporários e foram removidos.
- Novo Play: atributo `SettingAimAssistCentering=0.65`, categoria Aim registrada, HUD numérica visível durante combate e nenhuma fonte temporária QA no PlayerScripts. O servidor aceitou mudar a preferência para 0,8; ela foi restaurada a 0,65. Isso confirma o caminho de configuração em Studio, não persistência publicada.
- Merge guardado por comparação das cinco fontes anteriores, backup em `ServerStorage.Development.Revisions.AimAssistCenteringBaseline_20261031`, leitura de igualdade após a escrita e sincronização local sem substituir alterações concorrentes. `git diff --check` das seis fontes/testes desta etapa sem erros.

## Evidências e limites

Fontes anteriores, variantes, fontes incorporadas e resultados estão em `artifacts/aim-assist-2026-10-30/`. A pasta mantém a data de início da investigação. `evidence.json` contém medições e resultados do merge; `merged/` contém as cinco fontes finais e o caso de testes.

Sem validação física de toque, partida com múltiplos jogadores humanos, persistência de preferências fora do Studio ou publicação. A navegação visual até o novo controle de configuração não foi percorrida; sua regra, categoria, atributo e aplicação pelo servidor foram verificados.

Durante o diagnóstico já existiam erros de CombatHUD (iteração de `entries` nil), ArenaHUD (acesso a `KillFeed.Text` num Frame), ativo sem permissão 5207633818 e plugin externo GUIEditor. Permaneceram fora desta correção. Os controladores de câmera e assistência carregaram no novo Play apesar desses erros independentes.
