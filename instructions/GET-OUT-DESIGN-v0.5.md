# Crossgrounds / Get Out — especificação de fuga e contenção

**Revisão:** 2026-10-25, v0.3.1 (ampliação de v0.3). **Estado da fonte:** documentação e configuração conceitual; verificar separadamente a implementação atual do repositório. **Inclui Parte II:** referência detalhada de Flee the Facility, jogabilidade, movimento, portas, dutos, captura e critérios de implementação.

**Legenda:** **DEFINIDO** = decisão fornecida pelo criador; **PROPOSTO** = desenho ou recomendação não aprovada; **PENDENTE** = faltam requisitos ou parâmetros.

## 1. Estrutura da partida — DEFINIDO

- No começo de **cada rodada**, escolher **uma** das cinco formas de fuga **aleatoriamente** dentre as compatíveis com o mapa ativo. Não disponibilizar as cinco simultaneamente na mesma rodada.
- Os sobreviventes podem também **conter a Besta** como resultado alternativo, independentemente de qual rota de fuga tenha sido sorteada.
- **Minutos 0–10 (600 s):** fase normal; realizar a rota de fuga sorteada.
- **Minutos 10–15 (300 s adicionais):** a Besta torna-se **enfurecida e instável**. Somente nessa fase é possível ativar o **final secreto de contenção**. O jogo não apresenta a contenção como um objetivo explícito ao jogador.
- **Ao final dos 15 minutos:** se não houver resolução anterior, a Besta elimina os sobreviventes que permanecerem na instalação. Sem empates.
- As consequências para jogadores já escapados, capturados, ou contidos devem ser individualizadas na lógica de resultados (conforme documento anterior).
- **PENDENTE:** se as cinco formas de fuga e a fase de contenção se aplicam exatamente da mesma forma às variantes Mutação, Infestação e Juggernaut. O modo Juggernaut possui uma premissa diferente, com um Exorcista contra oito Bestas; não atribuir fuga humana automaticamente a ele.

### Sorteio e compatibilidade — proposta de implementação, não regra de balanceamento aprovada

1. Quando o mapa ativo for carregado, o servidor lê suas capacidades declaradas (PCs, portas, lasers, painéis, bancadas, containers etc.).
2. Cria a lista das rotas para as quais **todos os objetos indispensáveis existem**. Sorteia exatamente uma delas.
3. A distribuição entre rotas elegíveis permanece **PENDENTE** (probabilidades iguais ou pesos por mapa). Não selecionar rota ausente ou sem objetos necessários.
4. O método escolhido é fixado durante a rodada. A contenção não participa do sorteio: é condição alternativa independente.

## 2. Rotas de fuga — DEFINIDO

### 2.1 Travas (padrão do Flee the Facility)

1. Há **4 PCs**, **4 travas** de saída e **2 portas** no mapa.
2. Cada PC completamente hackeado participa da liberação das quatro travas. Ao completar os quatro, o conjunto de travas deixa de impedir a abertura das saídas.
3. O jogador deve **girar uma manivela longa** na saída para abrir a porta.
4. Cada sobrevivente **atravessa individualmente** e obtém o resultado de fuga correspondente.

**PENDENTE:** associação exata das quatro travas às duas portas (não presumir duas por porta), duração da manivela e se cada porta precisa ser aberta uma vez ou repetidamente.

### 2.2 Cofre

1. Hackear **4 PCs**, cada um revelando **1 dígito** diferente da combinação de quatro posições.
2. A combinação do cofre **não é definida/ativada até o quarto dígito ser descoberto**. Não permitir tentativa de código válida antes disso (inclusive tentativa e erro).
3. Com a combinação pronta, introduzir os dígitos mediante **disco rotativo de cofre bancário**.
4. Se uma combinação errada for digitada **após o código estar disponível**, o cofre rejeita entradas durante **30 segundos**.
5. A combinação correta abre a saída.

**Nota técnica:** para conciliar a descoberta gradual dos dígitos com a definição tardia da senha, o servidor pode registrar `digit` + `slot` para cada PC sem ativar a fechadura. Apenas depois de quatro revelações válidas concatena os dígitos na ordem dos slots, grava o segredo final no servidor e habilita a inserção. Esse é um **desenho sugerido**, não uma exigência de interface; a ordem/slot de cada dígito permanece **PENDENTE**.

### 2.3 Lasers

1. A saída tem **4 feixes letais** que causam **morte instantânea em qualquer personagem** que os tocar enquanto estiverem ativos.
2. **Painéis de segurança** estão espalhados pela instalação.
3. Em cada painel, realizar um **minijogo/puzzle inspirado no estilo de tarefas de Among Us**.
4. Cada painel resolvido desativa **1** dos quatro feixes.
5. Após remover todos os quatro feixes, a saída fica transitável.

**PENDENTE:** catálogo final de puzzles, tempo de resolução, penalidade por erro e se há reinicializações dos painéis por habilidades da Besta. Não considerar a habilidade Hacker como cancelamento de painel sem decisão específica.

### 2.4 Serra térmica ou arma de calor

1. Peças da ferramenta ficam espalhadas em **armários, baús, gavetas e outros containers**.
2. Jogadores localizam e transportam as peças; **todos os portadores necessários se reúnem numa bancada**.
3. Quando todas as peças estão reunidas, **montam a ferramenta**.
4. Um dos jogadores leva a ferramenta a **uma porta lacrada** e **corta/derrete as bordas**, derrubando a porta e abrindo o caminho de fuga.

**PENDENTE:** número/tipos de peças, tempo de montagem/corte, mecanismo de queda/recuperação de peças em caso de captura, formato definitivo (serra ou arma de calor).

### 2.5 Demolição

1. Jogadores encontram **pólvora e outros componentes fictícios de jogo** espalhados pela instalação.
2. Assim como na rota térmica, coletam os recursos, levam-nos à bancada e **fabricam cargas explosivas de jogo**.
3. Um jogador **planta a carga na porta**; inicia uma contagem regressiva de **15 segundos**.
4. Ao fim dos 15 s, a carga destrói a porta e abre a passagem.

**PENDENTE:** quantidade de cargas, locais válidos, interrupção/desarme, alcance/dano da explosão de gameplay e persistência do temporizador se quem plantou for capturado. Não interpretar como instruções reais de fabricação.

## 3. Habilidade de Besta: Hacker — DEFINIDO

A classe/habilidade **Hacker** atua de maneira distinta conforme **a rota de fuga efetivamente sorteada**, e não apenas conforme objetos existentes no mapa.

| Rota ativa | Ação | Recarga |
|---|---|---:|
| **Travas** ou **Cofre** | Reverter hackeamento de PC(s). Quais e quanto progresso são **PENDENTES**. | **150 s (2 min 30 s)** |
| **Lasers**, **Serra térmica** ou **Demolição** | Emitir **PEM/EMP** circular e expansivo que interage com **objetos/itens metálicos**, localizando-os por **5 pulsos**, cada um de **2 s**. Duração total da sequência: **10 s**. | **180 s (3 min)** |

**PENDENTE no EMP:** alcance, como selecionar objetos metálicos, se o destaque é visível só para a Besta, persistência do destaque e se existe efeito de desligamento ou somente detecção. Não converter automaticamente a detecção em desativação ou dano.

**PENDENTE nos PCs:** se o Hacker desfaz progresso parcial ou total, qual PC pode selecionar, como isso interage com dígitos já exibidos e a partir de quando não é possível reverter uma porta já aberta.

## 4. Propostas detalhadas — NÃO APROVADAS

Nenhuma destas ideias está ativa por estar descrita aqui. São opções para teste ou discussão.

### 4.1 Três puzzles de painel para Lasers

- **Fiação pareada:** quatro cabos de entrada e quatro saídas embaralhadas, cada par com a mesma combinação de **cor + símbolo** (redundância para daltonismo). O jogador seleciona a entrada e depois a saída; quando concluir os quatro pares, o feixe associado se apaga. Não exige arrastar com mouse.
- **Circuito giratório:** cinco peças de trilha (linhas/cantos) com quatro orientações de 90°. Selecionar uma peça gira-a; um fluxo visível sai da origem e, quando alcança o destino, o painel libera o feixe. Deve existir pelo menos uma solução gerada e verificada pelo servidor.
- **Sintonia de frequência:** três canais, cada qual com cinco níveis discretos. Cada canal exibe seu nível-alvo; ajustar com botões esquerda/direita, confirmando ao alinhar os três. Em controle, mover o foco entre canais pelo D-pad e alterar pelo analógico ou botões.

### 4.2 Contenção secreta na fase de fúria

- **Minuto 10:00:** a sala de contenção recebe energia, indicada **somente por uma mudança ambiental** (luz intermitente + ruído de gerador). Nenhum objetivo novo aparece no HUD.
- Sobreviventes precisam ativar **dois quadros de segurança**, em pontos separados da instalação, com **8 s de interação contínua** cada.
- Após ambos, a câmara fica operacional. Eles precisam atrair a Besta para a região demarcada pelo próprio cenário e acionar **uma alavanca externa por 4 s**.
- Se a Besta permanecer dentro até o fechamento, fica contida e a rodada termina com esse desfecho. Se sair antes, a contenção falha e os dois quadros precisam ser rearmados.
- O barulho da câmara e as luzes revelam risco tanto para a Besta quanto para os sobreviventes; o objetivo continua secreto na interface.

### 4.3 Limites de teste para o Hacker

- **Rollback de PC:** escolher um PC já totalmente hackeado, reverter **somente um** dos quatro avanços por ativação; não permitir fechar saída já aberta nem apagar objetivo de rodada já encerrado. Esse limite impede um bloqueio interminável do progresso.
- **EMP:** raio máximo de **45 studs**, cinco anéis sucessivos durante 10 s; todo item com atributo `Metallic=true` detectado é destacado para a Besta por **4 s**, inclusive atrás de paredes. O EMP **não** causa dano nem desativa equipamentos nessa proposta inicial.
- **Contrajogo:** um prenúncio audiovisual de **1 s** anuncia a ativação do Hacker aos sobreviventes próximos, permitindo que escondam ou larguem equipamento metálico antes da varredura.

### 4.4 Uma regra adicional de fúria para testes

- Durante os últimos cinco minutos, a Besta recebe **20% de velocidade adicional por 12 s** a cada **40 s**. Após cada surto, há **4 s de instabilidade** sem usar habilidade de classe. Isso evita que a fase seja apenas aumento contínuo de velocidade. **Não é uma decisão aprovada.**

## 5. Contratos mínimos antes de implementar no Roblox

- O estado oficial dos objetivos, senhas, travas, itens carregados, explosões fictícias e resultados permanece no **servidor**; o cliente só solicita interações.
- A seleção de rota ocorre quando um mapa já declarou que tem os objetos exigidos; modelos gratuitos sem painéis/containers deverão ser adaptados para cada rota, e não receber objetivos inexistentes.
- O tipo do objetivo selecionado é um dado de partida; o Hacker escolhe o comportamento a partir desse tipo para não ativar o rollback quando não existem PCs **ativos na missão**.
- Testar manivela, dial, puzzles e fabricação com **gamepad, teclado/mouse e toque**. Em especial, não exigir ação exclusiva de mouse para o cofre rotativo.
- Não incluir as propostas do item 4 em implementação automática, mesmo que o desenvolvedor importe diretamente o arquivo de configuração.

---

# PARTE II — Referência Flee the Facility e especificação de jogabilidade (ampliação v0.3.1)

**Revisão de pesquisa:** 2026-10-25. **Aplicação:** instruções para o Codex e especificação complementar; não equivale a afirmar que o sistema esteja implementado. **Fontes:** links verificáveis na seção 24 e referências adicionais na seção 26.

## 6. Critério de fidelidade e classificação

Esta parte documenta as mecânicas e a linguagem audiovisual de **Flee the Facility (FTF)** como referência para Get Out, mas **não substitui** as regras já definidas nas seções 1–5. Tratar cada item segundo sua etiqueta:

- **[FTF — VERIFICADO]**: comportamento descrito em páginas do jogo/comunidade ou changelogs; pode servir de referência para projetar a experiência.
- **[GET OUT — EXIGÊNCIA DE COMPLETUDE]**: elemento básico cuja ausência foi explicitamente apontada pelo criador (portas comuns, dutos, rastejamento), a ser implementado no Get Out em integração com o sistema existente. Não significa que os valores numéricos de FTF foram aprovados.
- **[ADAPTAÇÃO — PROPOSTA]**: solução concreta recomendada para Roblox Studio; valores e detalhes específicos exigem teste, não podem ser anunciados como decisões já aprovadas.
- **[PENDENTE]**: escolha de design não tomada. Nunca resolver silenciosamente uma pendência numérica ou de balanceamento.

**Princípio:** reproduzir a qualidade das interações e o ciclo de tensão (investigar → encontrar → interagir → ouvir perigo → fugir → esconder → salvar → retomar objetivo), não copiar modelos, trilhas, sons, interfaces, nomes cosméticos ou layouts protegidos do jogo de referência.

**Não alterar por inferência:** Get Out seleciona UMA de cinco rotas por rodada; mantém 10 min comuns + 5 min de fúria; contenção secreta alternativa; regras únicas das variantes; Hacker de Get Out funciona por rota. FTF usa normalmente hacking para desbloquear duas saídas, mas NÃO possui as outras quatro rotas de Get Out. A documentação comunitária de FTF relata quantidades de PCs dependentes dos participantes; Get Out possui **quatro PCs definidos** nas rotas Travas/Cofre, portanto não substituí-los automaticamente por fórmula de FTF.

## 7. Loop completo da rodada e agência dos jogadores

### 7.1 Fluxo de sobrevivente

1. Aguardar preparação, seleção de mapa e definição da rota ativa (FTF costuma usar votação de mapa e **15 s de vantagem** dos sobreviventes — **referência**, não regra automaticamente aprovada para Get Out).
2. Reconhecer o espaço: divisões, rotas, portas abertas/fechadas, janelas, dutos baixos, armários, recursos, tarefas, pontos de captura e saídas.
3. Cumprir a rota sorteada. Ação sobre objetivo deve exigir exposição e atenção, gerando oportunidades de perseguição e resgate.
4. Detectar aproximação da Besta por som/iluminação e linha de visão; decidir continuar, interromper, ocultar-se, abrir rota secundária ou distrair.
5. Se abatido, entrar no fluxo de derrubada → possível arrasto → possível aprisionamento → resgate, recuperação ou eliminação; não cair diretamente no estado "morto" sem regra explícita do modo.
6. Abrir uma saída liberada, atravessar fisicamente a área de saída e registrar **resultado individual**. Alternativamente, seguir as condições de contenção secreta de Get Out.

### 7.2 Fluxo de Besta

1. Começar com informação parcial sobre mapa e localização dos sobreviventes. Patrulhar pontos de objetivo, corredores e atalhos; não receber posições gratuitas sem habilidade prevista.
2. Identificar pistas: falha de hack, barulho de portas, movimento, pings de habilidade, visão direta, status de cápsulas.
3. Perseguir em cenário com decisões reais de caminho; janelas e portas são acessíveis, dutos continuam exclusivos de quem rasteja.
4. Acertar vítima → aplicar estado de derrubada consistente → prender e transportar ao sistema de captura → preparar nova perseguição, escolher guardar objetivo ou investigar outro setor.
5. Defender as saídas sem bloquear de forma permanente todo o jogo; aplicar os tempos e limites específicos da fase de fúria somente quando previstos.

### 7.3 Estado da rodada

`Lobby → PreRound → HeadStart? → Active (0–600 s) → Enraged (600–900 s) → Results`.

Transições extras: `EscapeResolved`, `BeastContained`, `AllSurvivorsResolved`, `Timeout`, `Abort` (falha crítica administrada). Determinar uma única autoridade que avalia estados finais; o resultado individual do sobrevivente não implica terminar prematuramente a partida enquanto outros continuam ativos. O head start está **PENDENTE** para Get Out.

## 8. Portas comuns — MECÂNICA OBRIGATÓRIA, independente de portas de saída

**[FTF — VERIFICADO]** Portas convencionais são abertas e fechadas por interação; em material comunitário consultado, sobrevivente leva **1,5 s** para abrir, Besta **1,0 s**. Fechamento pode ser instantâneo se ninguém impedir; portas comuns servem de obstáculo temporário em perseguições. Esses números são da referência, NÃO configurações já aprovadas para Get Out.

**[GET OUT — EXIGÊNCIA DE COMPLETUDE]** Implementar portas comuns reais em todo mapa que possua molduras/acessos relevantes:

- Estados de porta: `Closed`, `Opening`, `Open`, `Closing`, opcional `Blocked`, `Locked` (somente se definido pelo mapa/rota), `Broken` (apenas recurso existente). Não confundir `Locked` de porta comum com `Locked` das saídas.
- Ação de **abrir e fechar**, com prompt contextual coerente em PC, toque e gamepad; o texto do prompt deve alternar `Abrir porta`/`Fechar porta`, sem exigir mirar numa peça minúscula.
- Duração de abertura configurável por papel; proposta de paridade inicial **1,5 s sobrevivente e 1,0 s Besta**, marcados `proposed`. Não fixar até playtest.
- Porta usa pivô/hinge definido, eixo correto, animação/som de maçaneta, dobradiça, abertura, impacto de fechamento; collider acompanha a posição (ou muda de estado com geometria estável) sem bloquear um avatar indevidamente.
- Se houver personagem/objeto na área de fechamento, cancelar/adiar fechamento, sem empurrar/explodir personagem. Testar ambos os lados e abertura concorrente. Abertura parcial bloqueada não deve permitir atravessar pela colisão.
- O fechamento rápido pode criar distância contra a Besta, mas também bloquear outro sobrevivente; não garantir invulnerabilidade ao interagir.
- Debounce e arbitragem do servidor para impedir spam, dupla animação, inversão de estado entre clientes e abertura simultânea inconsistente.
- Áudio audível em raio calibrado, permitindo decisões de perseguição. Portas quebradas por habilidades especiais só quando previstas, não como regra padrão.
- Em mapas com objetos puramente decorativos: indicar `NonInteractive` explicitamente e diferenciar visualmente, em vez de espalhar portas falsas iguais às funcionais.

**Dois objetos diferentes**: `RegularDoor` (abrir/fechar, repetível) versus `ExitDoor` (liberação por objetivo, interação prolongada final, abre persistentemente). Uma porta do corredor nunca deve requerer hacking de PCs apenas por ser uma porta.

## 9. Dutos, rastejar e passagem de baixa altura — MECÂNICA OBRIGATÓRIA

**[FTF — VERIFICADO]** Sobreviventes rastejam e atravessam dutos/aberturas estreitas; a Besta não pode entrar. Controles reportados: segurar **Shift** no PC, botão **C** no celular, **LT** no console; controles de Get Out devem ser remapeáveis/coerentes com seu sistema, não copiados rigidamente. Rastejamento também permite ocultar-se atrás de objetos baixos. O jogo original permite salto duplo de sobreviventes e há relatos de pular mesmo rastejando; isso é referência, **não** exigência de herdar comportamento contraintuitivo em Get Out.

### 9.1 Estados de movimento

`Standing`, `Moving`, `Jumping/Falling`, `Crawling`, `CrawlEntering`, `CrawlExiting`, `Downed`, `Dragged`, `Captured`, `Escaped`. Ações de ataque/hack/coleta e animações devem consultar capacidades do estado sem prender o jogador em transição.

- Acionar rastejamento ajusta **a geometria efetiva de colisão/volume** (não apenas animação ou `CameraOffset`), altura visual e câmera. É a maior falha possível de uma implementação apressada: avatar deitado visualmente mas ainda bloqueado por hitbox em pé.
- O movimento deve permanecer controlável nos eixos adequados enquanto rasteja; velocidade, aceleração e rotação ajustáveis, podendo ser inferiores às de caminhada. Rastejar não pode virar `PlatformStand` sem controle.
- Ao sair do rastejamento, fazer teste de espaço livre **sobre o jogador**; se há teto/ducto, **continuar rastejando** até a saída, em vez de forçar a postura ereta, atravessar telhado ou prender o avatar.
- Ao ser derrubado, capturado, resgatado ou sair da rodada, encerrar corretamente as animações/timers de rastejamento, restaurar controlador, câmera e colisões.
- Compatibilidade com R6/R15 e tamanhos de avatar: escolher um corpo/rig ou normalização de escala consistente por partida; acessórios sem colisão não devem bloquear túneis. Conferir `HipHeight`, colisões de partes, pivôs e qualquer controlador customizado em uso.
- Câmera não deve atravessar tetos nem apresentar zoom violento; em primeira pessoa, alinhar câmera à postura; em terceira, usar compensação suave e evitar clip.
- A entrada no duto pode acontecer por **movimento físico contínuo**, preferível a teleporte invisível. Se uma animação de entrada guiada for usada, ela precisa ter ponto de cancelamento e não capturar jogador fora de alcance.
- Dutos devem ter malha física de entrada, trecho transitável, saída e espaço de recuperação. Não deixe vent sem destino alcançável, corredor estreito demais, extremidade que prenda avatar, ou entrada que favoreça apenas um lado por erro de colisão.
- Dutos podem conectar salas, proporcionar flanco ou esconderijo; os dois lados não devem ter caminhos iguais, pois essa assimetria sustenta a perseguição. A Besta não deve atravessá-los por clipping, salto, animação ou interação alternativa.

### 9.2 Layout e testes

Cada mapa deve declarar pontos `VentEntrance`, `VentExit` e conexões: `HumanOnly`, `RequiresCrawl`, `MinimumClearance`, `ExitClearance`. Testar: atravessar nos dois sentidos, iniciar rastejamento antes/depois de entrar, tentar levantar no meio, entrar com ping alto, com camadas de roupa/acessórios, Besta tentando seguir, derrubada na borda, câmera nos dois modos e reset do personagem. Indicador de interação não é necessário se o duto é naturalmente atravessável, mas a forma visual deve sugerir que ele existe.

## 10. Janelas, saltos e atravessamentos

**[FTF — VERIFICADO]** As janelas são aberturas transitáveis por sobreviventes e Besta mediante salto; a Besta costuma sofrer desaceleração de aproximadamente **0,8 s após aterrissar** no salto normal (poderes podem modificar). Esse desequilíbrio faz janelas úteis para ganhar distância, sem transformá-las em abrigo garantido.

**[ADAPTAÇÃO — PROPOSTA]** Aberturas do Get Out devem ser testadas como geometria física, com dimensões de colisão coerentes e animações opcionais de salto/vault; se houver vault assistido, deve ser previsível, interrompível e não teleportar através de barreira fechada. Sinalizar visualmente janela atravessável. A Besta não é impedida de usar janela, diferente de duto. Regras de salto duplo de FTF (incluindo recarga relatada de ~3 s) **PENDENTES** para Get Out: não ativar automaticamente sem decisão sobre mobilidade e balanceamento.

## 11. Armários, esconderijos e ocultação

**[FTF — VERIFICADO]** Os armários/cabinetes comportam um sobrevivente oculto e podem impedir que o poder Seer revele o jogador enquanto estiver escondido. No jogo de referência, existem variantes de armários de colisão simples (entrada caminhando); não pressupor que todos usem animação de abrir portas.

**[GET OUT — PROPOSTA]** `HideSpot` pode ser armário, sob mesa ou atrás de obstáculo, com propriedades próprias: `IsOccupied`, `Concealment`, `Entry/Exit`, `VisibilityToBeastAbility`, `ExitBlocked`. Jogador escondido não fica invisível nem imune a golpe se a Besta o vir e alcançar. Esconder deve interromper rastreamento automático quando aplicável, sem apagar informação legítima de som ou última posição. Não criar teleporte para dentro de armário que garanta proteção inviolável. Para armários interativos: animação curta, som de porta, ponto de câmera e botão de sair; para armários abertos: colisão e visibilidade natural. Impedir dois jogadores na mesma vaga caso o esconderijo só comporte um.

## 12. Computadores — ação cooperativa, erro e revelação

**[FTF — VERIFICADO]** Jogador interage junto ao teclado, começa animação de digitar e barra de progresso; testes periódicos de tempo/reflexo devem ser acertados. Erro interrompe temporariamente o hack, deixa tela vermelha, toca som de falha e transmite indício visual que ajuda a Besta a localizar o terminal. Conclusão muda tela para verde. Há suporte de até **três sobreviventes no mesmo PC**; tempos relatados em fonte comunitária: **64 s sozinho, 32 s com dois, 20 s com três** (aproximações de referência, não obrigação de Get Out).

### 12.1 Implementação proposta

- Cada terminal possui estados `Idle`, `InUse`, `ErrorCooldown`, `Completed`, opcional `DisabledByRoute`.
- Possuir **slots reais de interação** em lados válidos da máquina: 1 a 3 posições com `Attachment`, evitando três avatares sobrepostos. Se só há um teclado fisicamente acessível, criar versões de terminal apropriadas.
- Progresso **compartilhado por terminal**, com contribuição por participante e um único valor oficial. Ao soltar ou ser perseguido, o restante permanece ou decai conforme regra de Get Out a definir; não reiniciar involuntariamente toda vez que alguém sai.
- Cada participante pode receber teste individual que exige foco e entrada compatível com teclado, gamepad e toque. Gerar janelas de interação legíveis; erro deve indicar **quem falhou** sem culpar os demais visualmente.
- Resultados não podem depender apenas do resultado declarado pelo cliente: servidor agenda janela, valida IDs/ordem/intervalos, participantes ativos e condições do terminal.
- SFX: digitação leve, início e parada, erro alto localizável, progresso, sucesso, desbloqueio de saída. Se error beacon global existir, distinguir som local do aviso intencional à Besta.
- A dificuldade não deve variar com FPS: usar relógio/tempo de servidor e tolerância mensurada para input. Evitar travas de teclado após capturas.
- Quando terminar, sinal verde + som + decremento de tarefa ativa, sem dupla conclusão por múltiplos jogadores. Na rota Cofre cada PC concluído revela seu dígito/posição conforme regra v0.3. Não expor a combinação antecipadamente.

**[DIFERENÇA]** FTF pode exigir número de PCs variando com o grupo e manter PC extra; Get Out já fixa 4 PCs nas rotas Travas/Cofre. Não inventar quinta máquina exigida, nem alterar a mecânica de rollback Hacker sem a decisão correspondente.

## 13. Besta: câmera, golpe, desmaio, corda e transporte

**[FTF — VERIFICADO]** A Besta atua em primeira pessoa, usa martelo para derrubar sobreviventes, conecta uma corda ao abatido e o arrasta até cápsula. A referência registra atraso de movimento de cerca de **3 s** após acerto padrão e penalidade de salto (salvo modificadores). Não presumir que a vítima morre ao ser acertada; o ciclo de captura e resgate é fundamental.

### 13.1 Máquina de estados de vítima

`Active → Downed → (Recovered | Leashed → Dragged → PodCaptured → (Rescued | Frozen))`.

- `Downed`: bloquear objetivos, exibir ragdoll controlado (ou pose physics-safe), manter identidade, áudio e visão coerentes; recuperação temporizada se não for carregado — duração é **PENDENTE** em Get Out.
- `Leashed`: Besta precisa estar próxima do alvo derrubado e livre para iniciar; apenas uma vítima por Besta por padrão (sujeito a variantes). Estado de vínculo reproduzido para todos.
- `Dragged`: restrição física/kinemática estável; corda visível com comprimento e tensão definidos, impedir explosões de física, sling exagerado, atravessar parede, arrasto instantâneo pelo mapa. Besta pode soltar; regras de soltar e recuperação após soltar **PENDENTES**.
- `PodCaptured`: vítima fica posicionada na cápsula correta, movimentos e objetivos suspensos; interface de estado de congelamento/progresso; resgate disponível a aliados elegíveis.
- `Rescued`: limpar restrições/corda/ragdoll/efeitos, restaurar controlador, liberar cápsula, garantir spawn/extrair fora do collider e breve proteção contra erro técnico, se necessário para evitar reentrada física imediata (invulnerabilidade de gameplay **não** aprovada).
- `Frozen`/eliminado: impedir reinserção em cápsula já consumida quando esta for regra de Get Out; resolver resultado individual.

### 13.2 Golpes e equilíbrio

Validação do alcance e arco do golpe, hitbox temporal sincronizada à animação, cooldown, áudio de swing/hit/miss, evitar hits múltiplos na mesma janela. Animação de martelo em 1ª e 3ª pessoa, alinhamento de hitbox e hitstop/feedback moderado. FTF usa primeira pessoa para Besta e penalidades específicas; Get Out pode adaptar, mas não misturar com armas/combate de Juggernaut sem separação de variante.

## 14. Cápsulas de congelamento e resgate — sistema completo

**[FTF — VERIFICADO]** A Besta coloca capturado em Freeze Pod e a vítima congela progressivamente ao longo de cerca de **50 s** quando a drenagem está ativa. Se Besta estiver suficientemente próxima, a perda de vida pode **pausar** (mecanismo anticamping). Jogadores podem resgatar o capturado por interação. Ao libertar, o progresso de congelamento já acumulado **não se regenera**; recaptura continua daquele nível. A última pessoa ativa capturada pode congelar imediatamente. Alguns detalhes dependem de versão e mapa.

**[GET OUT — ADAPTAÇÃO PROPOSTA]** Implementar `FreezePod` com estados `Available → Occupied → (Available after rescue | Consumed after freeze)`:

- Apenas Besta com vítima vinculada válida pode colocar alguém em uma cápsula livre, dentro do raio e com posicionamento livre.
- Ícone mundial e UI: capturado identificado para aliados, status visível, barra de congelamento, alerta de resgate, aviso de congelamento definitivo; não obrigar que o jogador conheça o mapa de cor.
- Resgate de outro sobrevivente exige interação deliberada e validação do estado; cancelar se o salvador sair do alcance, for derrubado ou perder elegibilidade.
- Anti-camping: distância mínima da Besta à cápsula para o relógio de congelamento avançar, conforme parâmetro testado. Deve pausar drenagem de forma clara e não punir inadvertidamente perseguições normais ao redor da cápsula.
- Recuperação da cápsula, múltiplas interações de resgate, desconexão do capturado ou da Besta, troca de variante e fim de rodada precisam produzir estado consistente.
- Limite de sobreposição: um ocupante por cápsula; não armazenar ocupante em uma cápsula eliminada se ela for de uso único após congelamento.
- **PENDENTE Get Out:** tempo, distância anticamping, se há congelamento cumulativo sem cura, reuso de cápsula, tempo de resgate e resultado da última captura. O objetivo é manter o ciclo de "derrubar → arrastar → aprisionar → salvar", não fixar automaticamente números de FTF.

## 15. Portas finais, cronômetro de abertura e fuga individual

**[FTF — VERIFICADO]** Duas portas de saída: vermelho=travada, amarelo=destravada após PCs, verde=aberta; áudio global de liberação e marcadores de saída. Abertura manual leva **12 s** e, se interrompida, progresso de abertura não é preservado no original. Depois de abertas, não voltam a fechar. Atravessar o limite de saída registra fuga individual; atravessar como Besta não atribui fuga.

**[GET OUT — DEFINIDO]** Rota Travas: quatro PCs/quatro travas, duas saídas, manivela longa, resultado individual. Abertura de saída deve refletir a rota ativa:

- `ExitDoorState`: `InactiveForRoute`, `Locked`, `ReadyToOpen`, `Opening`, `Opened`, `Destroyed/Removed` (para térmica/demolição), e `Unavailable` (mapa sem aquela saída).
- `ReadyToOpen` depende do **objetivo sorteado**: travas PC; cofre código; lasers feixes; térmica corte; demolição carga virtual. Não tornar a porta clicável simplesmente por existir no mapa.
- A manivela da rota Travas é uma **interação distinta** de porta comum, com progress bar e animação de rotação em primeira/terceira pessoa. Duração, persistência do progresso e exigência por porta estão **PENDENTES** em Get Out. Os 12 s são número de FTF, não decisão aprovada.
- Ao abrir, a geometria/colisão realmente passa a permitir saída; hitbox de resultado colocada **além do limiar**, evitando fuga acidental por encostar na porta. Validação de equipe, vivo/ativo e estados resolvidos; cada jogador obtém fuga uma vez.
- Efeitos de liberação, marcadores e estados devem ser aplicados nos clientes para comunicar claramente o progresso coletivo.
- Em Lasers, contato letal permanece específico da rota; não aplicar feixes letais sobre as outras quatro rotas.

## 16. Habilidades e diferenças de classe da Besta

**[FTF — VERIFICADO, 2026]** A comunidade documenta três poderes selecionáveis: **Runner** (burst de velocidade, restrições de salto e alteração da penalidade após golpe), **Stalker** (redução temporária de assinatura audiovisual, mobilidade e portas) e **Seer** (localização de sobreviventes não escondidos, contra-jogo por armário). O poder **Hacker ainda é listado como não lançado** em FTF. Um changelog oficial de setembro/2026 alterou Runner (remoção de hit-slowdown ativo) e reduziu em 5 studs o raio passivo do batimento do Stalker. Logo, não usar guides antigos que dizem que só Runner existe.

**[GET OUT — DEFINIDO]** Hacker tem duas operações, conforme rota; não substituí-las por FTF. As demais classes propostas anteriormente só se tornam regras quando aprovadas. Se Get Out já possui sistema de classes, registrar cada habilidade com `Role`, `Activation`, `Cooldown`, `Tell`, `Counterplay`, `MovementOverrides`, `InformationRevealed`, `Limitations`, `VariantCompatibility`. As habilidades não podem ignorar arbitrariamente as vantagens de dutos/portas sem previsão.

## 17. Interface/UX: informação útil sem transformar terror em radar

- HUD de sobrevivente: cronômetro, rota objetiva, tarefas restantes, interação contextual, barra de progresso, teste de reflexo e estado pessoal; indicadores de aliados capturados, fuga e resultado.
- HUD de Besta: temporizador, alvo derrubado/vinculado, cápsulas disponíveis/ocupadas, estado da habilidade e feedback de detecção legítima. **Não revelar automaticamente PCs ocupados** quando não houve barulho/erro/poder.
- Estados claros: tela de PC azul/neutro antes da conclusão, vermelho por falha, verde após completar; saída com marcador de bloqueio/liberação/abertura, cápsula com status.
- Dutos e janelas reconhecíveis por forma e animação; apresentar dica de rastejar no início da experiência ou no tutorial, não como UI intrusiva a cada metro.
- Retícula/ProximityPrompt em objeto prioritário: quando PC e porta têm alcance sobreposto, o foco deve selecionar objeto de forma determinística, sem ações acidentais.
- Evitar fazer jogador preso em resgate perder feedback ou ficar sem saber quem pode salvá-lo. Mostrar que "esperar resgate" e "eliminado" são estados diferentes.
- **Acessibilidade:** botões legíveis em controle e toque, prompts remapeáveis, cores acompanhadas de símbolo/texto, escalas de HUD, indicadores de áudio quando apropriado, legendas de avisos importantes.
- No FTF, atualização oficial em 07/09/2026 adicionou **indicadores percentuais** para PCs, saídas e capturas. A informação é útil para diminuir ambiguidade, mas a forma exata de UI de Get Out deve seguir o estilo próprio do Crossgrounds.

## 18. Estilo ambiental, ritmo e sound design

**Direção de referência, não cópia de assets:** instalações labirínticas mas navegáveis, salas interligadas por portas e janelas, dutos como rotas de fuga exclusivas, armários como ocultação, cápsulas como pontos de resgate, PCs como fontes de exposição e duas saídas que dividem a atenção da Besta. FTF utiliza sons e brilho de gema/cor junto de batimento e música de perseguição para comunicar proximidade; Get Out deve criar identidade sonora própria.

### 18.1 Camadas recomendadas

- `Ambient`: ventilação, transformadores, zumbido de lâmpadas, goteiras, portas distantes, salas com reverberação diferente; ambiência por setor com transições suaves.
- `Tension`: batimento e/ou drone de perigo cuja intensidade responde à ameaça percebida; áudio não deve denunciar parede por telemetria injusta, mas também não pode falhar sob o mesmo teto.
- `Chase`: transição musical gradual após aproximação/visualização/ameaça sustentada e saída progressiva quando perder perseguição; evitar alternância espasmódica em cada frame.
- `Interact`: teclas, bip de PC, erro, progresso, válvula, rotação de manivela, corte e solda ficcionais, feixe desligando, contêiner, resgate.
- `Movement`: passos por material, corrida, rastejamento raspando no piso, salto/pouso, janela, portas abrindo/fechando, corpo sendo arrastado.
- `Beast`: golpe, acerto, arrasto/corda, gemido de vítima, cápsula, ativação de poder; sinal auditivo justo de aproximação, modificado apenas quando habilidade autorizada.
- `Endings`: liberação de saída, fuga individual, congelamento, fase de fúria, contenção secreta, expiração do tempo.

Mixagem: priorizar sons de perigo e objetivos sobre textura ambiental; usar posicionamento 3D/oclusão de maneira consistente, sem ruído contínuo que mascara passos. Efeitos originais/lícitos (não extrair a música ou sons proprietários de FTF).

### 18.2 Câmera e animação

- Sobreviventes: corrida, início/parada, vira rápida, salto/janela, deitar/rastejar, digitar terminal, abrir porta, abrir saída/manivela, pickup, derrubada, arrasto, cápsula, resgate.
- Besta: percepção em 1ª pessoa, martelo preparado/ataque/recuperação, atravessar janela, abrir portas, prender vítima, carregar/arrastar, colocar na cápsula, ativação de habilidades.
- Os efeitos de câmera devem comunicar estados sem prejudicar leitura do ambiente ou causar enjoo; oferecer redução de tremor e movimentos de câmera.
- Sincronizar eventos com animation markers (abrir maçaneta, batida, tecla, amarração, fechar cápsula). Não confiar em `task.wait()` arbitrário para efeitos decisivos.

## 19. Design de mapas: grafo de perseguição e cooperação

Construir mapa como **grafo de salas e conexões**, não somente decoração. Para cada sala registrar:

- Entradas por porta comum, janela e duto; quais papéis podem usá-las.
- Rotas circulares de fuga (loops), rotas de risco curto, corredores cegos intencionais, visão das salas, esconderijos, cobertura e barulho.
- Proximidade de PC, cápsula, recurso e saída; nenhuma cápsula pode estar sempre impossível de resgatar nem sempre à vista de todas as tarefas.
- Ao menos algumas perseguições devem permitir ao sobrevivente escolher entre porta lenta, janela rápida, duto exclusivo ou armário com risco de ser inspecionado. Sem escolhas, o encontro vira corrida linear ou captura inevitável.
- Duas saídas efetivas precisam ser separadas espacialmente o bastante para a Besta não bloquear ambas sem custo. Evitar rota obrigatória única que transforme a instalação num funil.
- Toda rota sorteável (Travas, Cofre, Lasers, Térmica, Demolição) possui todos os objetos, ancoragens, UX e espaços de interação; objetivos inativos da rodada não devem distrair com prompts.
- Para mapas de terceiros: validar modelo, portas, vent connectors, colisões, espaços de cápsula, spawn e escape zones antes de ativá-los.

**Ferramenta de validação de mapa** sugerida: listar caminhos navegáveis para papéis diferentes, vent sem saída, portas sem pivô, cápsula sem clearance, PC sem slots, saídas alcançáveis antes da liberação, área de resultado atravessável pelo lado de fora, objetivos que podem ficar impossíveis por capturas/desconexão e distância entre saídas.

## 20. Contrato técnico para o Codex — sem nomes rígidos de pastas

O Codex deve examinar o repositório atual para identificar o que já foi implementado e preencher só as lacunas. A especificação v0.3 é histórica e afirma *design_only*; **não deve ser usada como prova de que o jogo atual está sem código**.

### 20.1 Componentes lógicos recomendados (nomes ilustrativos)

- `GetOutRoundController`: fases, relógio, variante, sorteio da rota e resultados individuais.
- `GetOutInteractionService`: interações por alcance, estado, equipe e exclusividade; entradas teclado/controle/toque.
- `GetOutDoorController`: portas regulares, pivôs, animação, colisões e feedback.
- `GetOutTraversalController`: rastejar, alturas, janelas e dutos; um único controlador de estados de avatar por papel.
- `GetOutHackController`: slots/cooperação, progress, skill checks, erro, sucesso, revelação da Besta.
- `GetOutBeastController`: câmera, ataque, hitboxes, corda/arrasto, estado da vítima e habilidades.
- `GetOutCaptureController`: cápsulas, resgate, congelamento e anti-camping.
- `GetOutEscapeController`: portas de saída por rota, conclusão individual.
- `GetOutSoundDirector` / `GetOutHUDController`: camadas de percepção e UI.
- `GetOutMapValidator`: verifica contrato estrutural antes de aceitar mapa/rota.

Não criar dez sistemas duplicados se os sistemas equivalentes já existirem no Crossgrounds. Reutilizar módulos gerais de input, áudio, UI, interação, animação e controle de personagem.

### 20.2 Tags e atributos sugeridos

`RegularDoor`, `ExitDoor`, `Vent`, `WindowTraversal`, `HideSpot`, `HackTerminal`, `FreezePod`, `EscapeZone`, `Workbench`, `Container`, `SecurityPanel`, `ContainmentPanel`. Atributos de exemplo: `ObjectId`, `InteractionType`, `OpenSecondsSurvivor`, `OpenSecondsBeast`, `CurrentState`, `AllowedRoles`, `ConnectedRoomIds`, `RequiredRoute`, `OccupantUserId`. Prefira `CollectionService`/`Attributes` e descritores de mapa; não procurar objetos por nomes mágicos. Tags são sugestões de schema, não identificadores obrigatórios para código atual.

### 20.3 Padrões de input

`ProximityPrompt`/`ProximityPromptService` são úteis para interações; `HoldDuration` para abrir portas e acionar alavancas, mas duração mais complexa e exclusividade devem continuar com controle de estado no servidor. Rastejamento deve ser uma ação de controle contextual contínua (segurar/alternar conforme acessibilidade), não um prompt no duto. Use APIs de mapeamento de ações coerentes com projeto; suporte simultâneo a gamepad, toque e teclado. Validar distância/estado no servidor para ações relevantes.

### 20.4 Eventos, reconexões e resiliência

- Estado oficial de porta, terminal, captura e saída mantém-se no servidor. Cliente só anima localmente conforme estado replicado e pode prever feedback visual seguro.
- O mesmo evento não pode ativar duas vezes uma porta, captura, resgate ou fuga.
- Conexões e constraints do ragdoll/corda precisam ser removidas quando a vítima desconecta ou a rodada termina.
- Jogador nunca fica permanentemente `Anchored`, `PlatformStand`, sem câmera ou preso em animação por interrupção.
- Se uma rota se torna irrealizável por erro de asset, relatar falha de validação do mapa antes da partida; não encobrir movendo manualmente PCs durante o round.

## 21. Matriz de comportamento por papel e estado

| Comportamento | Sobrevivente ativo | Sobrevivente rastejando | Derrubado/arrastado/capturado | Besta |
|---|---|---|---|---|
| Abrir/fechar porta comum | Sim | Conforme postura/alcance (teste) | Não | Sim |
| Passar no duto baixo | Sim, ao rastejar | Sim | Não | Não |
| Passar janela | Sim, salto | Depende geometria/teste | Não | Sim, salto |
| Entrar armário | Sim | Conforme modelo | Não | Inspecionar, não se esconder por padrão |
| Hackear PC | Sim | Posição em pé/compatível | Não | Não |
| Resgatar na cápsula | Sim | Sair da postura se exigido | Não | Não |
| Derrubar e prender | Não | Não | Vítima da ação | Sim |
| Abrir saída liberada | Sim | Conforme ponto/ação | Não | Não |
| Atravessar saída aberta | Sim | Sim, se fisicamente atravessável | Não | Sem resultado de fuga |

As células com *conforme/teste* são detalhes propostos a confirmar; não inventar impossibilidades sem avaliar UX e animação.

## 22. Checklist de aceitação jogável (prioridade alta)

**Portas**
- [ ] Sobrevivente abre e fecha porta comum por ambos os lados; Besta também.
- [ ] Porta não atravessa jogadores e não prende avatar ao fechar.
- [ ] Sonorização, animação e colisão convergem para o mesmo estado.
- [ ] Porta comum não é confundida com saída final.

**Rastejamento e dutos**
- [ ] Sobrevivente deita e se move com hitbox real reduzida; não somente animação.
- [ ] Entra e sai de dutos transitáveis sem teleporte invisível ou clipping.
- [ ] Não consegue levantar sob teto baixo; consegue ao sair.
- [ ] Besta não passa por duto, mas passa por portas e janelas.
- [ ] Testes com três entradas: teclado, controle e celular; duas câmeras e diferentes FPS/ping.

**Hack**
- [ ] PCs têm slots não sobrepostos e até três participantes **se aprovado**.
- [ ] Barra partilhada e teste individual; sucesso e erro sincronizados.
- [ ] Falha denuncia posição somente como previsto; conclusão única, cor/áudio/HUD.
- [ ] PCs do Cofre revelam dígitos corretamente sem habilitar chute antecipado.

**Captura**
- [ ] Martelo derruba; não elimina diretamente por acidente.
- [ ] Corda e transporte persistem e limpam constraints ao terminar.
- [ ] Cápsula aceita vítima, mostra estado, congela, permite resgate e aplica anticamping conforme decisão.
- [ ] Resgate restaura avatar e câmera; recaptura/última vítima/desconexão testadas.

**Saída/partida**
- [ ] Só rota sorteada possui prompts de objetivo ativos.
- [ ] Saídas desbloqueiam conforme aquela rota, abrem fisicamente e registram fuga individual.
- [ ] Fúria começa aos 600 s, expiração ocorre aos 900 s, contenção não aparece como objetivo explícito.
- [ ] Besta e sobreviventes recebem o estado correto de resultado, sem empates inventados.

**Polimento**
- [ ] Música de perseguição e batimento são progressivos, sem vazamento de posicionamento fora das regras.
- [ ] Passos, porta, dutos, janelas, PC, golpe, arrasto e resgate têm áudio/anim funcional.
- [ ] O mapa oferece pelo menos duas decisões de fuga viáveis durante perseguições comuns.
- [ ] UI não colide com prompt de outras mecânicas; funciona em PC/Xbox/PlayStation/toque.

## 23. Plano de implementação ordenado para o Codex

**P0 — vertical slice fiel ao núcleo:** porta comum, rastejar com collider correto, 1 duto, 1 janela, esconderijo, terminal compartilhado, golpe/queda/arrasto, cápsula/resgate, saída com abertura e resultado. Primeiro em mapa de teste isolado; depois migrar para mapas ativos. Esse recorte é obrigatório antes de adicionar sistemas cosméticos ou múltiplas novas habilidades.

**P1 — completar todas as instâncias:** adaptar todos os mapas, inserir `MapValidator`, estados de feedback, áudio, animação e controles por dispositivo; integração das cinco rotas sem afetar as regras específicas da v0.3.

**P2 — balancear:** duração de interações, velocidade de rastejo, espaço de dutos, poder da Besta, congelamento, anti-camping, resgate, lugares de saída, progressão de PCs e dinâmica da fúria. Medir resultados reais de partidas; não copiar valores indiscriminadamente.

**P3 — polimento:** sonar/chase mix, câmera, pós-processamento leve, variação de anim, pistas ambientais, tutorial contextual, UX de espectadores/resultados e acessibilidade.

## 24. Fontes consultadas e cautelas

**Oficiais do jogo e changelogs:**
- [Experiência Flee the Facility (Roblox)](https://www.roblox.com/games/893973440/Flee-the-Facility)
- [Changelog oficial 07/09/2026 (Roblox DevForum)](https://devforum.roblox.com/t/flee-the-facility-change-log-090726/4858054) — confirma alterações de Runner/Stalker e percentuais de PC/saída/captura.

**Wiki comunitária (descrições de mecânicas, sujeitas a atualização):**
- [Survivors](https://flee-the-facility.fandom.com/wiki/Survivors)
- [Beast](https://flee-the-facility.fandom.com/wiki/Beast)
- [Beast Powers](https://flee-the-facility.fandom.com/wiki/Beast_Powers)
- [Computers](https://flee-the-facility.fandom.com/wiki/Computers)
- [Doors](https://flee-the-facility.fandom.com/wiki/Doors)
- [Exit Doors](https://flee-the-facility.fandom.com/wiki/Exit_Doors)
- [Vents](https://flee-the-facility.fandom.com/wiki/Vents)
- [Crawling](https://flee-the-facility.fandom.com/wiki/Crawling)
- [Windows](https://flee-the-facility.fandom.com/wiki/Windows)
- [Cabinets](https://flee-the-facility.fandom.com/wiki/Cabinets)
- [Freeze Pods](https://flee-the-facility.fandom.com/wiki/Freeze_Pods)
- [Maps](https://flee-the-facility.fandom.com/wiki/Maps)

**Documentação de implementação (Roblox):**
- [ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt)
- [Proximity prompts](https://create.roblox.com/docs/ui/proximity-prompts)
- [ProximityPromptService](https://create.roblox.com/docs/reference/engine/classes/ProximityPromptService)
- [Segurança das interações de cliente e servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary)

**Cautela:** os valores 1,5 s / 1 s para portas, 12 s para saída, 50 s para congelamento, 64/32/20 s para PCs, 0,8 s para salto e 15 s de head start são números publicados por fontes externas para FTF, com diferenças possíveis por versão, classe e atualização. São **referências de comparação**, não regras validadas para Get Out. A wiki pode conter dados antigos (por exemplo, guias que mencionam apenas Runner antes da disponibilização de Stalker/Seer); preferir changelogs recentes para recursos alterados.

## 25. Solicitação operacional ao Codex

> Estude a implementação **atual** de Get Out no repositório antes de alterar scripts. Compare-a com este documento e produza uma matriz `Implementado / Parcial / Ausente / Bloqueado / Pendente de decisão` por mecânica. Priorize os elementos que estavam ignorados: portas comuns operáveis, dutos físicos, rastejamento com colisão adequada, janelas, esconderijos, máquina de estados de captura, corda/arrasto, cápsulas e resgate. Integre essas mecânicas aos sistemas atuais sem destruir as cinco rotas de fuga, o Hacker por rota, a fúria de 10–15 minutos ou a contenção secreta. Preserve regras definidas, não promova propostas a regras sem aprovação. Faça um vertical slice funcional, execute os testes possíveis e registre os que dependem de playtest manual no Roblox Studio. Use componentes compartilhados, evite placeholders que não funcionam in-game e mantenha animações, colisões, sons e UI sincronizados.

## 26. Metajogo, lobby e identidade externa da partida — referência, não escopo obrigatório

**[FTF — VERIFICADO]** O jogo de referência também tem estrutura de lobby (Camp Lapis), intervalos de votação de mapas (material comunitário menciona **30 s** com quatro opções), indicador de chance de receber papel de Besta, menu com nível/XP/moeda, menu de espectador e personalização cosmética. Jogadores recebem XP/créditos por hackear, resgatar, fugir ou congelar; podem usar moedas para obter martelos/gemas cosméticas. Existe posto de trocas de cosméticos entre jogadores, com acesso por nível. A atualização de setembro/2026 acrescentou guia de coleção e seleção de mapas históricos em servidores privados. Essas mecânicas compõem o **metajogo** do FTF, não o seu loop de perseguição.

**[GET OUT — DIREÇÃO]** Crossgrounds já é um hub multimodalidade. Não clonar Camp Lapis, mapa de votação, loja de martelos, economia, caixas de itens, chance de Besta comprável, sistema de trocas ou monetização só para alegar fidelidade. O que vale integrar ao conceito de Get Out é:

- Pré-rodada com identificação clara do papel e tutorial contextual mínimo; preparação antes da Besta ingressar no mapa se o design aprovar vantagem inicial dos sobreviventes.
- Seleção de mapa compatível com rota, variante e população de jogadores; preservar matchmaking/votação global do Crossgrounds.
- Resultado individual, registros de objetivos realizados, resgates, capturas e fugas; progressão/recompensa apenas se compatível com o sistema universal do projeto.
- Espectador dos jogadores que escaparam/foram eliminados, com limites para evitar transmitir informações injustas ao time vivo (decisão de produto pendente).
- Cosméticos próprios do Crossgrounds que não alterem silenciosamente alcance, visibilidade, hitbox ou eficiência dos papéis.
- Perfil visual claro e legível: tensão durante a partida, simplicidade na leitura de interações e interface com feedback imediato. Menus de coleção/loja são opcionais e **não bloqueiam as mecânicas P0**.

**Fontes adicionais:** [Levels](https://flee-the-facility.fandom.com/wiki/Levels), [Credits](https://flee-the-facility.fandom.com/wiki/Credits), [Main Menu](https://flee-the-facility.fandom.com/wiki/Main_Menu), [Trading Post](https://flee-the-facility.fandom.com/wiki/Trading_Post), [Crates](https://flee-the-facility.fandom.com/wiki/Crates). A wiki de crates indica mudanças históricas e pode estar desatualizada; não adotar dados de monetização sem verificação específica.

## 27. Priorização concreta das pendências de decisão

Os seguintes parâmetros pertencem ao design do Get Out e precisam continuar distintos dos valores observados em FTF:

| Tema | Escolha pendente | Referência externa ou decisão existente |
|---|---|---|
| Preparação inicial | Há vantagem de tempo dos sobreviventes? | FTF 15 s; Get Out não definiu |
| Porta comum | Tempo de abrir/fechar por papel, colisão | FTF 1,5/1,0 s |
| Rastejamento | Velocidade, hold/toggle, permissão de salto | Não fixado Get Out |
| Dutos | Dimensões, número por mapa, acesso lateral | Sobreviventes apenas — núcleo solicitado |
| Janelas | Penalidade de salto da Besta | FTF ~0,8 s |
| Salto duplo | Permitir ou não; recarga | FTF tem salto duplo; Get Out não definiu |
| Hack | Slots, duração, frequência de checks, persistência | FTF até 3; Get Out 4 PCs em duas rotas |
| Derrubada | Tempo para recuperação, arrasto, soltura | Não fixado Get Out |
| Cápsula | Congelamento, anti-camping, resgate, cura | FTF ~50 s e pausa perto da Besta |
| Saída Travas | Tempo da manivela, reset ao interromper | Get Out manivela; FTF abre em ~12 s |
| Armários | Entrada física ou prompt; inspeção | Esconder do Seer na referência |
| Metajogo | Espectador, XP, personalizações | Herdar do hub Crossgrounds quando existir |

A execução **não** deve travar por causa dessas decisões se houver um vertical slice com parâmetros de protótipo claramente marcados, isolados em configuração e não publicados como balanceamento aprovado. Valores de protótipo podem ser usados para testar o funcionamento, sem substituir a documentação de design.
