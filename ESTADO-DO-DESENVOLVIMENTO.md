# Capture a Bandeira — Estado atual de desenvolvimento

**Atualização em 26/10/2026:** Travessia Ampliada montada e selecionada no Studio: 940 × 560 studs, três rotas a 180 studs de distância e bandeiras separadas por 720 studs; a versão anterior foi preservada. Textos das bandeiras restritos localmente aos participantes na região e com rodada ativa. Modo admin de câmera livre instalado para a conta 1248190494. Compilação, regras isoladas, clearance e navegação geométrica verificados; Play e equilíbrio humano desta versão ainda pendentes, pois o usuário estava editando os spawns da Arena. [Mapa, assets e limites](docs/CTF-WIDE-MAP.md) · [Comandos admin](docs/ADMIN-CAMERA.md). A votação em grid de quadrados foi registrada para uma etapa futura.

**Data:** 23/10/2026  
**Experiência:** Crossgrounds (ALPHA)  
**Place ID:** `4375993208`  
**Workspace:** `C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio`

**Controle — ajuste posterior em 23/10:** indicador lateral fora do texto, foco arredondado com contorno/brilho maiores e som curto de navegação com volume independente em Áudio. D-pad, A, deslocamento lógico pelo analógico e mute verificados com input simulado. 128 fontes compiladas. [Resultados e pacote cumulativo](docs/CONTROLE-CURSOR-FOCO-SOM.md).

**Cascatas — ajuste visual posterior em 23/10:** painéis sólidos, 8 px de separação e sombra progressiva no fundo das seções anteriores. Perfil e opções com quatro níveis verificados por captura e clique. 128 fontes compiladas. [Resultados e incremental](docs/CASCATAS-SOLIDAS.md).

**Aim assist — atualização posterior em 23/10:** assistência dividida em desaceleração e acompanhamento parcial de movimento, sem centralizar no tronco. Rotação reduzida até zerar a 100 studs; desaceleração reduzida até 150. Ajustes independentes, aquisição gradual, saída manual e checagem imediata de visibilidade. **16 contratos aprovados**, integração com input simulado e câmera normal; 128 fontes compiladas. Calibração com hardware/humanos e toque real pendente. [Pesquisa, evidências e pacote](docs/AIM-ASSIST-COMPONENTES.md).

**Lobby, playlist e progresso — atualização mais recente em 23/10:** blur por profundidade (0/18), modos jogáveis no topo em verde, gerenciador de playlist com duas músicas adicionais, bots com 50 XP e treino com 10 XP. Tabelas de perfil/placar reorganizadas; amigos sem registro anterior excluídos do comparativo. **128 fontes compiladas; 7 contratos relevantes aprovados nesta etapa.** Amigos offline, persistência publicada, aparelhos reais e instalação remota permanecem sem validação. [Resultados e pacote cumulativo](docs/LOBBY-PLAYLIST-XP-ESTATISTICAS.md).

**UI — atualização posterior em 23/10:** corrigida cascata coberta pelo próprio fundo (Global → Sibling), confirmada por captura e sobreposição. Tela inicial, kits, progresso e votação usam cascata compartilhada, tema acrílico temporário e ação explícita **Permanecer no lobby**. Estado atual: **122 fontes locais compiladas**; 84 contratos existentes aprovados durante a tarefa. Os pacotes completos da etapa anterior precisam do novo incremental de UI. [Relatório, pacote e limites](docs/UI-CASCATA-ACRILICO.md).

**Etapa anterior:** menu em listas empilhadas, loadout pendente, corrida automática opcional no toque e editor de HUD acessível. Arena com 300 s, intervalo de 1 s, recarga de 900 ms e seis visuais de pistola. Exibidor separado, braços quadrados com skin/iluminação local e classificação no topo. Recuperação de equipamento e bots menos precisos. Os oito bugs do relato de 23/10 receberam correções; Dust tem 53 pontos elegíveis para jogadores e três reservados ao treino. **119 fontes locais e 84 contratos aprovados**. Progresso e lobby recentes preservados. Hardware, PvP humano, latência, publicação e instalação remota da Arena continuam pendentes. [Resultados, pacotes e limites](docs/MENU-LOADOUT-VIEWMODEL-ARENA.md).

## 1. Resumo

O projeto está em uma fase de **protótipo funcional com apresentação e conteúdo ainda incompletos**. Existe uma partida de captura de bandeira, com kits, jogadores e bots, lobby jogável, câmera própria, HUD e menus adaptados para controle. Isso ainda não representa uma experiência visualmente finalizada ou validada em todas as plataformas.

As maiores lacunas atuais são:

1. **Empunhadura das armas:** apoio procedural de duas mãos implementado em R15 para armas de fogo e machado; faltam mira vertical do corpo/arma, animações completas e validação ampla de avatares.
2. **Animações de combate:** faltam poses e sequências próprias de equipar, mirar, disparar, recarregar e atacar com cada arma.
3. **Apresentação em primeira pessoa:** o modelo dedicado existe, mas usa peças rígidas e movimentos procedurais simples.
4. **Bots:** possuem lógica de objetivos e combate, porém ainda têm percepção, movimentação e comportamento visual pouco naturais.
5. **Áudio:** tiros, recarga, hit marker e música existem; a sonorização completa de interface, objetivos e ações ainda não existe.
6. **Mapa e votação:** CTF permanece com Travessia e navegação de bots específica desse cenário. O catálogo real da Arena inclui seis templates, com House preservado como encontrado; não possui bots próprios. Há mapas de Get Out preparados, mas ainda faltam regras e objetivos do modo.
7. **Acessibilidade:** houve avanço na navegação por controle, mas faltam opções adicionais e validação com controles físicos e teclado virtual de console.

### Como interpretar este documento

- **Implementado:** recurso encontrado no código ou nas instâncias atuais. Não significa acabamento final nem validação em produção.
- **Parcial:** existe uma base funcional, mas falta parte da implementação, do conteúdo ou da apresentação.
- **Ausência confirmada:** a implementação correspondente não foi encontrada nos sistemas examinados.
- **Validação pendente:** há implementação, mas o comportamento ainda precisa ser confirmado na condição indicada.
- **Melhoria proposta:** sugestão de evolução; não é tratada como promessa anterior ou defeito comprovado.

A avaliação inicial foi feita por leitura de fontes e instâncias. Os patches seguintes incluíram Play no Studio. A etapa atual verificou o defeito de armas, câmera obrigatória, Factory/respawn, disparo pelo fluxo mobile, editor de HUD, entrada numérica e assistência no cliente com entrada simulada. São 78 contratos aprovados. Os limites estão no relatório vinculado acima; não incluem analógicos físicos, multitoque real, PvP com múltiplos humanos ou publicação.

## 2. O que já existe

| Sistema | Estado | Entrega atual |
|---|---|---|
| Captura de bandeira | Implementado | Captura, transporte, queda, recuperação, entrega e atualização de placar. |
| Equipes | Implementado | Azul e vermelho; bots completam a falta de jogadores até 6 participantes por lado. |
| Partida | Implementado | Rodadas de 5 minutos, 3 capturas para vencer e preparação de 8 segundos. |
| Spawns | Implementado | 24 pontos por equipe, escolha por segurança/ocupação e proteção temporária. |
| Lobby | Implementado, com acabamento parcial | Área jogável, alvos de treino, percurso de saltos, escolha de kit e retorno da partida. |
| Kits | Implementado | Leve, regular e pesado, com velocidades e saltos diferentes. |
| Combate | Implementado, com apresentação parcial | CTF com 200 HP; Arena com 20 HP. Munição, recarga, cadência, queda de dano e melee durante janela de ataque. |
| Equipamentos próprios | Parcial | HUD e seleção próprios; os equipamentos ainda são instâncias `Tool` do Roblox. |
| Câmera | Implementado, com refinamentos pendentes | Arena exclusivamente em primeira pessoa. Armas de fogo sempre travadas; CTF preserva câmera por ombro e preferências nos contextos permitidos. |
| Recuo | Implementado em primeira pessoa | Movimento visual da arma, mais intenso no fuzil e na sniper, sem desviar a câmera. |
| Corrida | Implementado | Alternada, cerca de 10,5 s por carga cheia, com FOV suave e balanço procedural mais lento/amplo. |
| HUD | Implementado, com acabamento parcial | Vida, estamina, munição, slots, objetivo, placar, hit marker, eliminações e killfeed. |
| XP da Arena | Implementado apenas na sessão | 100 por eliminação PvP, +50 por headshot; treino sem recompensa. Sem níveis ou persistência permanente. |
| Menus | Implementado, com acabamento parcial | Catálogo com entrada local direta, ajustes por categoria, editor de HUD mobile, kits, votação e remapeamento. |
| Controle | Implementado; validação física pendente | Cursor próprio nos menus, D-pad, ícones por plataforma e remapeamento. |
| Analógicos e mira assistida | Implementados; hardware/toque pendentes | Zonas mortas 5%/10%, curva S ajustável, assistência com desaceleração/correção e bloqueio por paredes. Sensibilidade até 4×. |
| Votação de mapas | Implementado para testes; conteúdo parcial | Travessia no CTF; Shipment, Dust, Factory, Pátio, Posto e House no catálogo atual da Arena. House não foi explorado neste patch. |
| Preferências | Implementado; produção pendente | Persistência por DataStore fora do Studio; sessão temporária nos testes locais. |
| Chat | Configurado | `TextChatService.ChatVersion` está em `TextChatService`. |

## 3. Armas, empunhadura e animações

### 3.1 Empunhadura com duas mãos — base implementada, acabamento parcial

**Implementado e testado em R15:** WeaponRig, ArmPose e WeaponPose posicionam as mãos nas pegadas de SMG, fuzil, sniper e machado. A pose é calculada após o Animator, com suporte a Motor6D e AnimationConstraint, inclusive em bots cuja aparência troca as juntas. Faca e espada mantêm a montagem da mão direita.

Limitações restantes:

- A mão acompanha as pegadas; a mira vertical do tronco/arma continua pendente.
- Poses procedurais não substituem animações completas de combate.
- R6 possui uma aproximação ainda não validada neste patch.
- Avatares e acessórios extremos precisam de avaliação de alcance, encaixe e interseções.

Em primeira pessoa há braços quadrados com cores da skin e camisa clássica, renderizados em ViewportFrame independente. Recarga move apoio, carregador e mecanismo; roupas em camadas e animações completas de equipar continuam pendentes. Terceira pessoa usa a pose separada existente.

**Próxima entrega sugerida:** camada de mira vertical e animações sincronizadas de combate, compatíveis com os diferentes avatares.

### 3.2 Animações de combate — ausentes como conjunto próprio

O combate ainda não possui um conjunto dedicado e completo de animações para:

- Equipar e guardar cada equipamento.
- Permanecer parado, andar e correr segurando a arma corretamente.
- Entrar/sair da mira e acompanhar a inclinação vertical da pontaria.
- Disparar em terceira pessoa com resposta visível do corpo e da arma.
- Recarregar: retirar/inserir carregador, operar mecanismo e mover as mãos.
- Executar golpes distintos de faca, Executor e Treme-Terra.

O melee altera `Tool.Grip` por código. Em primeira pessoa há arco de ataque e recargas procedurais com peças móveis; o Magnum abre o tambor. Esses movimentos ainda não equivalem a um conjunto completo de animações artísticas, sobretudo em terceira pessoa.

**Limitação concreta de sincronização:** o golpe visual em primeira pessoa usa duração fixa de aproximadamente `0,42 s`, enquanto preparação e janela de dano variam entre as armas. É necessário sincronizar gesto, contato e som com os parâmetros reais de cada equipamento.

### 3.3 Modelos e primeira pessoa — parciais

Os modelos foram retrabalhados por código com corpo, carregador, trilhos, cano, coronha e luneta da sniper. A versão 3 acrescenta chanfros, miras, mecanismos, parafusos e detalhes nas pistolas e melees; luvas recebem peças arredondadas. Os nomes Kastov 545, Vasnev 9mm e Lachmann LMS estão aplicados. O visual permanece geométrico e provisório, sem meshes/texturas próprios ou acabamento final.

Faltam ou precisam de retrabalho:

- Modelos finais, proporções, materiais e detalhes consistentes entre as seis armas.
- Braços articulados de primeira pessoa e animações independentes por ação.
- Alinhamento de miras: mirar atualmente ajusta o FOV; não há um sistema completo de alinhamento com alça/massa de mira ou visão dedicada da luneta.
- Acabamento e sincronização completa do disparo local. Clarões já foram implementados e verificados no viewmodel; permanecem pendentes animações completas e validação dos efeitos sob latência/aparelhos variados.
- Efeitos finais de impacto por material e outros detalhes de disparo. Hoje há traçadores simples e luz de disparo no equipamento real.

**Validação pendente:** enquadramento perto de paredes, transições de perspectiva, interseção dos braços/arma e percepção do recuo em telas e FOVs diferentes.

### 3.4 Sistema de equipamentos — migração parcial

A mochila padrão está oculta e há seleção/HUD próprios, porém `WeaponFactory` ainda cria `Tool`, `KitService` coloca os itens na `Backpack` e o equipamento usa `Humanoid:EquipTool`.

Portanto, **não foi concluída uma substituição integral do sistema de itens do Roblox**. A interface e parte da apresentação são próprias, mas a estrutura de equipamentos ainda usa os mecanismos nativos.

Antes de uma migração completa, é necessário definir o modelo de estado de equipamento, representação no servidor, apresentação local, troca de armas e integração com as animações. A migração não deve ser considerada concluída apenas por esconder a mochila padrão.

## 4. Bots e inteligência artificial

### 4.1 Implementado

- Preenchimento das duas equipes e substituição após morte, com intervalo de 7–9 segundos.
- Papéis de corredor, soldado e guardião, com armas diferentes.
- Captura, retorno, recuperação de bandeira, interceptação, escolta e defesa.
- Reação com atraso, rajadas, dispersão, carregadores e tempo de recarga.
- Busca de cobertura quando a vida está baixa e deslocamento lateral em combate.
- Pathfinding, saltos e tentativas de sair de situações de travamento.
- Aparências de amigos dos jogadores quando disponíveis, com alternativa aleatória.

### 4.2 Animação básica presente; combate visual incompleto

O template atual contém **um `Animator`, 27 instâncias `Animation` e um Script `Animate` habilitado**. Há animações básicas e emotes do Roblox. A reprodução correta com todas as aparências não foi verificada novamente nesta exportação.

Assim, a pendência não deve ser descrita simplesmente como “nenhum recurso de animação existe”. O que falta é principalmente:

- Refinamento das poses e do apoio procedural de duas mãos já implementado.
- Animação de mira, disparo e recarga sincronizada com o cérebro do bot.
- Transições naturais entre patrulhar, correr, buscar cobertura e enfrentar o alvo.
- Orientação visual de cabeça, tronco e braços coerente com a pontaria.

Hoje a orientação de combate gira a raiz do personagem diretamente no plano horizontal. O disparo e o traçador dos bots usam a boca real da arma, com verificação de cobertura. A orientação vertical do corpo/arma ainda precisa acompanhar a pontaria.

### 4.3 Limitações da tomada de decisão

**Confirmadas pela implementação atual:**

- Percepção restringe alvos muito atrás, com exceção para proximidade/alerta após dano. A visão periférica ainda é ampla e exige ajuste com humanos.
- Memória curta e investigação existem, mas não há percepção completa por som ou busca coordenada.
- Papéis definidos pelo número do slot. Quando jogadores entram e bots são removidos, não há recomposição tática dos papéis restantes.
- Rotas, escolta e cobertura são regras simples; não há coordenação de esquadrão ou distribuição dinâmica de ameaças.
- A recarga repõe o carregador sem consumir uma reserva finita equivalente à dos jogadores.
- Não há integração própria de som/animação de recarga no cérebro dos bots.
- A recuperação de travamentos pode mudar a rota, saltar e, em determinadas condições, reposicionar o bot. Isso pode produzir movimentação artificial.

**Validação pendente:** dificuldade contra humanos, previsibilidade, uso real das três rotas, travamentos prolongados e custo de processamento com a partida completa.

### 4.4 Novos mapas ainda exigem adaptação dos bots

O catálogo de mapas existe, mas a IA não está completamente independente do cenário atual. `BotBrain` usa coordenadas fixas como `X = ±32/±42`, altura `Y = 41` e rotas em `Z = -70/0/70`, além de posições de defesa baseadas na orientação atual das equipes.

**Impacto:** cadastrar um novo mapa na votação não garante que os bots consigam jogá-lo corretamente. As rotas precisam virar dados do próprio mapa ou ser substituídas por uma navegação de objetivos que não dependa dessas coordenadas.

## 5. Sons e música

### 5.1 O que existe

- Sons de disparo associados às três armas de fogo.
- Sons de ataque melee; faca e espada compartilham um dos assets.
- Um som de recarga compartilhado entre as armas de fogo.
- Som de hit marker confirmado no cliente.
- Música de lobby/menu com ajuste de volume e transição para a arena.

### 5.2 O que falta

**Ausências nos sistemas examinados:**

- Sons próprios para foco, navegação, confirmação, voltar e erro nos menus.
- Sonorização dedicada de equipar/guardar, carregador vazio e etapas de recarga.
- Sons próprios de impacto e contato diferenciados por arma/material.
- Alertas sonoros próprios de bandeira roubada, recuperada, entregue e de início/fim de rodada.
- Sistema próprio de passos por superfície e ambientação do mapa. Sons padrão do personagem, quando presentes, não constituem esse sistema.
- Integração de recarga sonora dos bots e mixagem final das várias fontes de combate.

**Validação pendente:** carregamento/permissões de todos os assets na experiência publicada, volumes relativos, distância audível e comportamento com vários jogadores e bots atirando.

**Melhoria proposta:** canais separados de volume para música, efeitos, interface e ambiente. Atualmente o menu oferece volume da música, sem um painel completo de mixagem.

## 6. Menu, HUD, lobby e acessibilidade

### 6.1 Base funcional entregue

O menu não está ausente: há escolha simplificada de kit, entrada na partida, Ajustes acessível a partir da seleção inicial, votação, remapeamento e retorno ao lobby. O lobby também já é jogável; a preparação não se resume a prender o jogador em uma tela por 30 segundos.

Há cursor próprio nos menus, navegação por D-pad, rolagem, campos numéricos, sliders, prazo de 5 segundos para remapear e restauração de padrões. Os ícones usam a plataforma do controle conectado.

### 6.2 Acabamento e recursos ainda parciais

- A interface é construída por código com painéis e componentes básicos; identidade visual e acabamento final ainda precisam de revisão.
- Faltam os sons de navegação e confirmação mencionados na seção de áudio.
- A seleção de mapa mostra essencialmente nome e votos; faltam apresentação visual dos mapas e refinamento do feedback de escolha/resultado.
- Falhas de carregamento/salvamento de preferências não possuem uma comunicação completa de erro e recuperação para o jogador.
- O fluxo de resultados ainda é básico; uma apresentação detalhada de desempenho de fim de partida não faz parte da entrega atual.
- Em celular, a área útil reduzida faz o menu exibir poucos ajustes por vez. A rolagem funciona, mas conforto de toque e legibilidade ainda exigem avaliação em aparelho real.

A seleção de kit com texto e nomes das armas foi uma escolha solicitada. A ausência de uma prévia 3D nessa seleção, por si só, não é registrada como falha.

### 6.3 Acessibilidade ainda incompleta

**Opções ainda ausentes:**

- Inverter eixo vertical e ajustar sensibilidade por eixo/dispositivo.
- Ajustar sensibilidade por eixo e ampliar a validação dos filtros existentes; zonas mortas e curva S já são configuráveis.
- Ajustar tamanho do cursor dos menus, texto e contraste por preferência do jogador.
- Modos alternativos de cores/identificação de equipes.
- Desativar completamente o flash de dano: o ajuste atual tem mínimo maior que zero.
- Reduzir/desativar o recuo visual e a expansão de FOV da corrida para conforto de movimento.

**Melhoria proposta:** feedback háptico configurável. Assistência de mira opcional já está implementada; equilíbrio e hardware físico continuam pendentes.

**Limites intencionais do remapeamento atual:** confirmar/voltar e navegação nos menus permanecem fixos para preservar o acesso às configurações. Analógicos, WASD e comandos do sistema Roblox não fazem parte do remapeamento de ações.

### 6.4 Controles padrão atuais

| Ação | Xbox | PlayStation | PC |
|---|---|---|---|
| Alternar corrida | LS | L3 | Ctrl |
| Trocar câmera | RS | R3 | V |
| Trocar arma | Y | Triângulo | G |
| Shift Lock | LB | L1 | Shift |
| Recarga / interação | X | Quadrado | R |
| Trocar ombro | RB | R1 | Q |
| Atacar | RT | R2 | Mouse 1 |
| Mirar | LT | L2 | Mouse 2 |
| Ajustes | D-pad direito | D-pad direito | F2 |

X/Quadrado prioriza recarga quando ela é possível; com o equipamento pronto, pode interagir com um prompt próximo. O cursor nativo do gamepad é suprimido no jogo; a mira própria permanece, e os menus usam o cursor dedicado.

## 7. Mapa, spawns e votação

### Entregue

- Travessia, com três rotas, conexões e coberturas adicionadas ao cenário existente.
- Base azul no lado de Blue Building e base vermelha no lado do Noob.
- Bandeiras, pontos de spawn amplos e lobby separado.
- Catálogo em `ServerStorage.CTFMaps` e votação durante a preparação.

### Incompleto ou pendente

- **Somente um mapa está cadastrado:** `riverside`, com o nome Travessia. A votação está preparada tecnicamente, mas ainda não oferece variedade real de conteúdo.
- A existência das três rotas não comprova equilíbrio de fluxo, linhas de tiro, vantagem de altura ou resistência a pressão sobre o spawn.
- Acabamento visual, continuidade entre estruturas antigas e novas, ambientação e leitura dos acessos ainda precisam de uma revisão de cenário.
- Spawns precisam de testes com equipes humanas completas, ocupação simultânea e inimigos pressionando as bases.
- Novos mapas exigem a adaptação da navegação dos bots descrita na seção 4.4.

Os testes anteriores de pathfinding e captura validaram caminhos e interações pontuais; não substituem sessões de equilíbrio do mapa com jogadores.

## 8. Balanceamento atual

Combatentes do CTF têm 200 HP; Arena tem 20 HP. Na Arena, pistolas usam intervalo de 1 s, 12/120 de munição e recarga de 0,9 s. A tabela abaixo descreve os kits CTF, **não uma confirmação de equilíbrio competitivo**.

| Kit | Melee: dano / intervalo | Arma de fogo: dano próximo → distante | Intervalo do tiro | Carregador | Andar / correr / salto |
|---|---|---|---|---|---|
| Leve | Faca: 26 / 0,32 s | Vasnev 9mm: 19 → 11 | 0,13 s, automática | 32 | 22 / 29 / 9 |
| Regular | Executor: 65 / 0,70 s | Kastov 545: 29 → 20 | 0,20 s, automático | 26 | 18 / 25 / 7,2 |
| Pesado | Treme-Terra: 110 / 1,50 s, área | Lachmann LMS: 150 → 125 | 2,00 s | 5 | 14 / 20 / 5,5 |

Andar/correr e salto são os valores configurados de movimento dos jogadores. Bots usam velocidades e salto definidos separadamente por papel.

Ainda é necessário avaliar:

- Tempo para eliminar e vantagem de cada kit nas distâncias reais do mapa.
- Impacto do headshot de jogadores, que multiplica o dano de arma de fogo por 1,35.
- Capacidade de eliminação do pesado em relação à sua mobilidade e cadência.
- Alcance percebido do melee e concordância entre lâmina visível e contato válido.
- Dificuldade dos bots, precisão e diferença de recursos em relação aos humanos.
- Sensação do disparo sob latência. O recuo visual atualmente começa após a confirmação do servidor; atraso perceptível é um risco a testar, não uma falha de rede reproduzida nesta exportação.

## 9. Validação: o que já foi registrado e o que falta

### Registrado nos patches anteriores

- Sintaxe dos scripts alterados sem erros.
- Captura/entrega de bandeira, placar, respawns e preenchimento por bots.
- Disparos automáticos, consumo de munição, recarga e dano melee por janela de ataque.
- Navegação dos menus por controle, remapeamento com conflito, tempo esgotado e restauração dos padrões.
- Correção de valores digitados de FOV para os limites de 60–110 graus.
- FOV de corrida e recuo visual com retorno ao repouso sem mudar a direção da câmera.
- Prioridade de recarga/interação e entrada nos Ajustes a partir da seleção de kit.
- Ícones PlayStation confirmados no simulador de PS5 e layouts inspecionados em console e iPhone em paisagem.
- Troca entre mapas em Play usando uma cópia temporária de teste; essa cópia não foi mantida no catálogo.

### Ainda não atestado

- Partida longa com vários clientes humanos, entradas/saídas e duas equipes completas.
- Controle físico Xbox e PlayStation, incluindo troca entre mouse/controle e teclado virtual do console.
- Persistência de configurações após sair e entrar em servidores publicados.
- Reprodução e encaixe das animações em diferentes avatares e aparências de amigos.
- Carregamento de todos os sons no jogo publicado.
- Desempenho de CPU, rede e renderização em aparelhos modestos, com combate simultâneo.
- Comportamento sob latência, perda de conexão e falhas dos serviços externos.

O último patch registrou ausência de erros dos sistemas alterados no seu teste final, mas há erros anteriores de um plugin externo GUIEditor. Isso não equivale a uma garantia de ausência de bugs na experiência.

## 10. Ordem sugerida para os próximos patches

As prioridades abaixo são uma avaliação de desenvolvimento, sem estimativa de prazo.

| Prioridade | Entrega | Critério de conclusão |
|---|---|---|
| P1 | Completar poses de armas | Apoio de duas mãos já implementado; faltam mira vertical e validação ampla de avatares/jogadores/bots. |
| P1 | Animações de combate | Equipar, mirar, atirar, recarregar e melee com mãos/arma sincronizadas aos eventos reais. |
| P1 | Validação de controle físico | Percorrer todos os fluxos de menu e combate em Xbox/PlayStation, incluindo edição e remapeamento. |
| P1 | Refinar Aim Assist com base no Projectile Test | Revisar Friction/Tracking contra o pipeline atual; preservar intenção real, anti-drift e validação touch/gamepad; sem importar Centering ou regras balísticas. Plano registrado em `docs/PLANO-AIM-ASSIST-PROJECTILE-TEST-2026-10-27.md`; nenhuma implementação nesta etapa. |
| P2 | Modos gráficos por perfil | Direção visual do Projectile Test registrada; Equilibrado será o padrão proposto e Visual será opt-in. Perfis e desempenho ainda não implementados ou medidos. Plano em `docs/PLANO-AIM-ASSIST-PROJECTILE-TEST-2026-10-27.md`. |
| P1, antes do segundo mapa | Navegação de bots por dados do mapa | Novo cenário jogável sem depender das coordenadas fixas de Travessia. |
| P2 | Refinar percepção e movimento dos bots | Menos giros/travamentos artificiais, busca após perder alvo e melhor distribuição de papéis. |
| P2 | Completar áudio e efeitos | Interface, objetivos, recarga, impactos e efeitos locais de primeira pessoa consistentes. |
| P2 | Ampliar acessibilidade | Opções de conforto visual, analógicos, leitura da UI e volumes separados. |
| P2 | Acabamento de cenário e UI | Direção visual consistente, acessos legíveis, votação apresentada e fluxos revisados em telas menores. |
| P2 | Sessões de equilíbrio e desempenho | Resultados registrados de partidas humanas e aparelhos/condições de rede diferentes. |

## 11. Fontes, recuperação e publicação

### Fontes principais desta avaliação

| Tema | Fonte |
|---|---|
| Modelos, empunhadura e `Tool` | [WeaponFactory.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ServerScriptService/MainGameScript/GameManager/WeaponFactory.luau) |
| Disparo, melee e recarga | [KitService.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ServerScriptService/MainGameScript/GameManager/KitService.luau) |
| Primeira pessoa, mira e recuo | [CombatPresentation.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/StarterPlayer/StarterPlayerScripts/CombatPresentation.luau) |
| Decisões e rotas dos bots | [BotBrain.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ServerScriptService/MainGameScript/GameManager/BotBrain.luau) |
| Equipes de bots e aparências | `BotManager.luau`, `AvatarService.luau` e template `ServerStorage.CTFBotTemplate` inspecionado no Studio. |
| Ajustes e limites | [ExperienceSettings.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ReplicatedStorage/ExperienceSettings.luau) |
| UI, controles e persistência | `ExperienceMenu.luau`, `MenuNavigation.luau`, `ControlRouter.luau`, `InputIcons.luau` e `SettingsService.luau`. |
| Balanceamento e sons de armas | [KitDefinitions.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ReplicatedStorage/KitDefinitions.luau) |
| Testes já registrados | [ACCESSIBILITY-PATCH-NOTES.md](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/ACCESSIBILITY-PATCH-NOTES.md), [CAMERA-PATCH-NOTES.md](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/CAMERA-PATCH-NOTES.md) e [PATCH-NOTES.md](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/PATCH-NOTES.md). |

As notas antigas descrevem estados intermediários. Para controles e cursor, prevalecem o patch de acessibilidade e as fontes atuais.

### Pacotes locais

| Arquivo | Tamanho | Estado representado |
|---|---|---|
| `artifacts/crossgrounds-hub-arena-mobile-2026-10-23.rbxm` | 169236 bytes | Hub dedicado atualizado; instalação e publicação remotas pendentes. |
| `artifacts/crossgrounds-arena-mobile-2026-10-23.rbxm` | 1038080 bytes | Arena com correções, HUD mobile e seis templates; instalação remota pendente. |
| `artifacts/accessibility-patch.rbxm` | 211572 bytes | Recuperação histórica anterior à base Crossgrounds e ao patch de pegada. |
| `artifacts/camera-experience-patch.rbxm` | 197947 bytes | Estado anterior, de câmera e menus. |
| `artifacts/three-lanes-patch.rbxm` | 129466 bytes | Estado anterior, de mapa, bots e combate. |

Os pacotes são organizados por serviço para recuperação manual. **Não são um place completo nem um instalador automático.** Há 98 fontes locais em `src/`. Cada pacote dedicado atualizado contém 80 fontes de runtime/autoramento; 17 fontes de testes e o Blood legado ficam fora deles. A correção do Blood está aplicada ao projeto integrado e exportada como fonte local. Originais, templates de Get Out e cenário CTF continuam nas instâncias preservadas no Studio; o pacote de Arena inclui os seis templates encontrados no catálogo. Pacotes anteriores permanecem disponíveis.

O último patch foi aplicado e testado no Studio. A publicação ficou manual no encerramento daquela etapa. **Esta exportação não consultou nem confirmou a versão atualmente publicada na Roblox**, portanto o estado de edição não deve ser apresentado como publicação confirmada.

---

**Conclusão:** a base de jogo existe e permite continuar a produção. O maior débito atual está em empunhadura/animações, apresentação de combate, naturalidade dos bots, sonorização completa e validação real de acessibilidade e multiplayer.
