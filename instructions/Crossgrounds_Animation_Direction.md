# Crossgrounds — Character, Weapon & Viewmodel Animation Direction

> Instruções diretas para o Codex. Estude o controlador de movimento, rigs, armas e clipes já existentes. Reaproveite-os sempre que possível; não faça animações genéricas só para preencher uma lista.

## Objetivo

Aprimorar a leitura, o peso, a resposta ao comando e a coerência das animações **em primeira e terceira pessoa**, incluindo movimento lateral/diagonal, marcha à ré, sprint, slide, pulo, pouso, ADS, tiro, equipar/guardar e recarregar. Fazer com que o corpo, a arma, a câmera e o som contem a mesma ação — sem que a animação atrase o gameplay.

## 1. Auditoria e matriz de estados

Localizar rig R15/customizado, `Motor6D`, `Animator`, `AnimationTrack`, animações padrão substituídas, viewmodel, sistema de câmera, movimento e estados de arma. Montar uma tabela `ação | clipe FP | clipe TP | duração | prioridade | entrada | saída | interruptibilidade | markers | status`. Identificar: *foot sliding*, transições abruptas, braços que atravessam a arma, clipping de câmera, recarga fora da munição, deslizamento sem pose, direções laterais com corrida frontal reaproveitada e diferenças desnecessárias entre dispositivos.

## 2. Locomoção direcional — primeiro a base, depois as variantes

Considerar **velocidade local em relação à orientação do personagem**, com direção de olhar/mira separada da direção do movimento. Suportar Idle, Walk/Run para frente/trás/esquerda/direita/diagonais. Em geral, os clipes cardinais podem ser combinados em blend space 2D ou estratégia equivalente; as diagonais devem ser avaliadas em preview para verificar interpenetração e escorregamento. **Não apenas espelhar a corrida frontal em strafes:** pés, quadris e ombros precisam indicar deslocamento lateral. Em marcha à ré, passadas mais curtas e orientação estável. Para sprint, avaliar se é permitido lateralmente ou só para frente conforme mecânica já existente, sem inventar regra.

Critérios de movimento: velocidade dos pés condizente com deslocamento, contato planta/chão verificável, centro de massa legível, cabeça relativamente estável, quadris sem giro espasmódico, weapon sway subordinado à precisão da mira. Em câmera livre/sem arma, definir se a orientação do torso acompanha o movimento; em combate, definir se acompanha a mira.

## 3. Slide — distinguir gameplay e representação

Separar **estado físico** de **pose**. Descrever no controlador: início, deslocamento, desaceleração, saída, cancelamento/obstrução, possível colisão com teto e retorno ao estado apropriado. Não dirigir a velocidade do personagem somente pela timeline. Sinalizar estados para que FP e TP se mantenham coerentes.

**Primeira pessoa:** entrada rápida porém legível, redução da altura visual subordinada à colisão real, leve inclinação contextual, reposicionamento da arma que não obstrua o retículo, sway limitado e saída amortecida. Evitar sacudidas que produzam enjoo e não aplicar a mesma oscilação a câmera e viewmodel somando seus efeitos.

**Terceira pessoa:** antecipação breve, peso do corpo para baixo, quadris/joelhos flexionados, mãos/arma posicionadas com intenção, pernas alinhadas à direção de deslocamento e recuperação clara para corrida/agachamento/parado. Não deixar o root flutuar nem atravessar o piso.

**Eventos:** `SlideStart`, `SlideLoop`, `SlideStop`/`SlideExit` (quando usados), com áudio de roupa/fricção por material. Se slide for interrompido, parar loops sem atrasos. Testar descidas, subida, pequenas bordas, paredes e transição com pulo se o movimento permitir.

## 4. Pulo e aterrissagem

Separar `JumpStart`/impulso, `Airborne`/subida, `Fall`/descida e `Land`/recuperação. Usar estado real do Humanoid/controlador em vez de temporizações fixas para determinar início/fim do ar. Evitar 'duplo pulo visual' e repetição de pouso ao atravessar degraus. Pouso leve e pesado são possibilidades conforme velocidade de queda existente, sem inserir nova mecânica.

FP: pequeno impulso da arma e recuperação sem deslocar excessivamente a mira. TP: extensão das pernas no impulso, pose aérea coerente e absorção de choque na aterrissagem. Retomar a locomoção rapidamente se o jogador mantiver entrada direcional.

## 5. Armas: animações completas e anatomia mecânica

Para cada arma existente, revisar `Idle`, `Equip`, `Unequip`, `Fire`, `ADSIn`, `ADSIdle`, `ADSOut`, `Reload`, `EmptyReload` (se pertinente), `Sprint`, `Inspect` (se já existir ou for explicitamente aprovado). Propor variantes onde a mecânica exigir: revólver (tambor e extração/realimentação), pistola (carregador/ferrolho), shotgun (pump ou recarga por cartucho), rifle (magazine e manejo da arma). Não transformar todas em uma recarga genérica.

**Rig e pivôs:** manter arma e mãos em coordenadas coerentes, `Muzzle`, `EjectionPort`, mão de apoio, grip, mag, slide, bolt/cylinder quando existem. Objetos móveis devem poder ser animados independentemente. Separar viewmodel FP da representação visível por outros jogadores; compartilhar semântica e timing de eventos, não obrigatoriamente todos os keyframes ou ângulos.

**Ritmo da recarga:** intenção e leitura da arma > exagero. Etapas como `MagOut`, `MagIn`, `Chamber`, `ReloadReady` devem ocorrer no contato visual correspondente; uma arma recarregada por cartucho exige markers por cartucho. Não alterar munição só porque um marker cosmético disparou: o sistema de arma controla o momento autorizado. Lidar com cancelar/reiniciar, última bala, troca de arma, morte, sprint e interrupções permitidas.

**Disparo/recuperação:** ataque curto com retorno suave; recuo visual não deve movimentar o ponto autoritativo do raycast em momento incorreto. Distinguem-se pose de ação, camera recoil e weapon sway. ADS deve alinhar sights/retículo de forma verificável em diferentes FOVs. Testar clipping com câmera próxima de paredes.

## 6. Animation Graph Editor ou Animator existente?

A Roblox oferece Animation Graph Editor com blending e máquinas de estados. Primeiro verificar se é estável e integrável no projeto atual. Prototipar uma cadeia locomotora pequena (`Idle ↔ Move ↔ Jump/Fall ↔ Land`, com Slide como estado separado) antes de converter todo o `Animate`. Se o controlador atual for mais simples/robusto, manter `Animator`/`AnimationTracks`, usando fades, prioridades e pesos corretamente. Não criar dois controladores competindo pelos mesmos joints.

Mapear prioridades: movimentos em `Movement`, ações que substituem juntas relevantes em `Action` e variantes superiores apenas quando necessário; documentar sobreposições. Considerar layers/máscaras de juntas quando suportadas pela abordagem escolhida. Não usar prioridade alta indiscriminadamente, pois ela suprime a locomoção.

## 7. Sincronização com gameplay e áudio

Utilizar eventos de animação como `FootLeft`, `FootRight`, `MagOut`, `MagIn`, `Bolt`, `FireVFX`, `Land`, `SlideStart`, `SlideEnd`. Associar o nome a eventos semânticos do áudio. Durante blending, evitar double-trigger dos dois clipes de passos; escolher estado dominante ou regra de limiar, sem perder passos em transições reais. A máquina de estados da jogabilidade permanece fonte de verdade para consumo de munição, movimento e possibilidade de disparo.

Replicação: o jogador local precisa receber feedback imediato, enquanto terceiros veem o corpo no estado certo. Evitar transmitir `CFrame` de cada joint por frame; usar replicação de estados/clipes compatível com a arquitetura de animação do projeto. NPCs devem usar representações TP apropriadas, sem viewmodel FP invisível.

## 8. Qualidade e testes

Fornecer clipes/editáveis, rigs de referência, IDs publicados **somente se realmente existirem**, registros de pivôs, tabela de markers e vídeo/frames de testes quando disponíveis. Testar:

- Oito direções de movimento com mira parada, mira girando e mudança brusca de direção.
- Sprint→slide→saída, sprint→pulo→queda→pouso, slide→parede, slide→mudança de arma e outros caminhos permitidos pelo jogo.
- Reload completo/interrompido, vazio/parcial, com e sem ADS, tiro durante/ao final da recarga conforme regras atuais.
- FP e TP em 30/60/120 FPS, latência simulada, PC/controle/mobile quando houver acesso.
- Animações de bot observadas por vários clientes; ausência de dupla reprodução de som/evento.
- Clipping de mão/arma/câmera, contato com chão e alinhamento da boca da arma.

Relatório final curto: arquivos alterados, clips criados/reutilizados, estados cobertos, comparativo dos maiores problemas e lista explícita do que depende de publicação/importação manual. **Não alegar que animações foram produzidas ou testadas no Studio se o ambiente não deu acesso ao editor.**

## Referências

- [Animation Editor](https://create.roblox.com/docs/animation/editor) · [Animation Graph Editor](https://create.roblox.com/docs/animation/graph-editor) · [State Machines](https://create.roblox.com/docs/animation/graph-editor-state-machine).
- [Animation Events](https://create.roblox.com/docs/animation/events) · [AnimationTrack](https://create.roblox.com/docs/reference/engine/classes/AnimationTrack) · [AnimationPriority](https://create.roblox.com/docs/reference/engine/enums/AnimationPriority).
- [Rigging and Skinning](https://create.roblox.com/docs/art/modeling/rigging).
