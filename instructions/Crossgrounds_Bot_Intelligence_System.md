# Crossgrounds — Bot Intelligence System

> **Instruções de implementação para o Codex**  
> Projeto: **Crossgrounds** (Roblox / Luau)  
> Escopo: navegação, percepção, tomada de decisão, combate, personalidades e dificuldade dos bots.  
> **Estado do código: desconhecido até a auditoria. Não presumir nomes de arquivos, módulos, eventos ou hierarquias.**

## 0. Missão e regras de execução

Investigue e melhore o sistema de bots já existente no projeto. Atualmente, os bots parecem vagar de forma incoerente, têm navegação fraca e, quando um jogador chega perto, conseguem eliminá-lo com rapidez excessiva. O objetivo é produzir adversários **coerentes, legíveis, capazes, variados e justos**: a dificuldade deve decorrer sobretudo de decisões melhores, e não de mira impossível ou conhecimento privilegiado.

**Regras obrigatórias:**

1. **Auditar antes de implementar.** Localize scripts, componentes compartilhados, comportamentos existentes e dependências do sistema de armas; registre o diagnóstico. Não comece substituindo tudo.
2. **Preservar o que funciona.** Reaproveite módulos, convenções, remotos, interfaces e lógica de modos já existentes. Faça mudanças incrementais e reversíveis; não duplique sistemas.
3. **Não presumir recursos não implementados.** Arena, Duels e Get Out têm objetivos distintos; CTF é apenas potencial. Não crie uma nova modalidade nem mecânicas que não existam apenas para exercitar a IA.
4. **Autoridade do servidor.** Dano, estado da partida, regras de armas e objetivos continuam sob validação do servidor. Um bot deve utilizar as mesmas regras de armas de um jogador, sem atalhos de dano ou informação.
5. **Desempenho mensurável.** Evite loops a cada frame por bot, recálculos incessantes de rotas, raycasts redundantes e conexões abandonadas. Defina orçamentos antes de otimizar às cegas.
6. **Sem promessas fictícias de teste.** Se não for possível executar o Roblox Studio ou uma sessão multiplayer, indique quais testes são apenas estáticos e quais permanecem manuais.

## 1. Auditoria técnica inicial

Inspecione e descreva o fluxo real desde o spawn até a eliminação ou conclusão do objetivo de um bot. Procure:

- Serviço/controle de spawning, modelos, Humanoids e ciclo de vida.
- Scripts que escolhem alvos, detectam jogadores, perseguem e patrulham.
- Uso atual de `PathfindingService`, `CreatePath`, `ComputeAsync`, `Path.Blocked`, `Humanoid:MoveTo()` e `MoveToFinished`.
- `while true`, `Heartbeat`, `task.wait`, cooldowns, loops de cada NPC e recálculos concorrentes.
- Visão, audição, linha de visão, aquisição/perda de alvo, memória e formas de comunicação entre bots.
- Dependência entre movimentação, rotação, animação, mira, disparos e dano.
- Timeouts, caminhos inválidos, waypoints inalcançáveis, travamento em portas/cantos/escadas e comportamentos de recuperação.
- Network ownership e inconsistências entre posição do NPC no servidor e em clientes.
- Configurações de dificuldade e vantagens indevidas (precisão instantânea, disparar através de paredes, visão de 360° sem justificativa, reação em zero segundos).
- Comportamentos compartilhados e específicos por modalidade.

**Entregável desta etapa:** diagnóstico conciso com **evidências do código**, causas prováveis, impacto e proposta de mudanças ordenadas por risco/benefício. Não invente falhas que não encontrou.

## 2. Arquitetura comportamental modular

Separe as responsabilidades em componentes lógicos; adapte os nomes à arquitetura encontrada:

| Responsabilidade | Função | Não deve fazer |
|---|---|---|
| **Sensor / Perception** | Visão, audição, ameaça, estado observado | Causar dano ou decidir rotas |
| **Memory / Blackboard** | Última posição conhecida, observações, confiança, timestamps | Expor posições atuais de inimigos ocultos |
| **Decision / Utility AI** | Priorizar objetivos, combate, cobertura, investigação, recuo | Mover diretamente a física do Humanoid |
| **Navigation** | Selecionar rota, waypoints, replanejamento e recuperação | Decidir se vale a pena perseguir |
| **Combat** | Selecionar disparo, mira, cadência e uso da arma via API existente | Conceder acertos ou dano arbitrários |
| **Mode Adapter** | Fornecer objetivos e regras reais do modo | Duplicar todo o controlador de bot |
| **Diagnostics** | Exibir estado, motivos e métricas | Consumir recursos em produção sem habilitação |

Um *blackboard* por bot pode conter `State`, `CurrentGoal`, `CurrentTarget`, `LastSeenPosition`, `LastSeenTime`, `LastHeardPosition`, `CurrentPath`, `ThreatScore`, `AssignedRole`, `LastDecisionReason` e flags de recuperação. Escolha um subconjunto necessário: **não introduza uma estrutura gigante sem uso**.

Estados conceituais: `Idle`, `Patrol`, `Investigate`, `Search`, `Engage`, `Retreat`, `Objective`, `Recover`. Faça transições explícitas e observáveis. Considere interruptibilidade: morte, início/fim de partida, objetivo inválido, alvo perdido e descarte do bot devem cancelar imediatamente tarefas anteriores.

## 3. Navegação robusta (primeira prioridade)

Utilize o pathfinding nativo como base geométrica, mas controle planejamento, execução e recuperação:

1. Ajuste `AgentRadius`, `AgentHeight`, `AgentCanJump`, `AgentCanClimb`, `WaypointSpacing` segundo as dimensões e movimentos reais dos personagens.
2. `ComputeAsync` pode falhar ou não achar caminho: capture erros, cheque `Path.Status` e mantenha alternativa segura.
3. Percorra waypoints respeitando ações como pular quando o agente de fato suportar a ação.
4. Reaja a `Path.Blocked` somente quando o bloqueio afetar o trecho ainda não percorrido; também detecte bloqueios **dinâmicos** que o caminho não resolve sozinho.
5. Replaneje por evento relevante (mudança significativa de destino, obstáculo, rota inválida, tempo de obsolescência), **não** a cada deslocamento mínimo do alvo.
6. Acompanhe progresso pela distância efetivamente percorrida e pelo tempo desde o último avanço; controle *stuck detection* independentemente de `MoveToFinished`.
7. Lembre que `Humanoid:MoveTo()` pode encerrar por timeout de aproximadamente **8 segundos**. Renove o movimento quando fizer sentido, mas nunca transforme falha de progresso em repetição infinita do mesmo comando.
8. Ao travar, tente, nesta ordem adaptável: pequeno ajuste local, esperar brevemente por passagem, replanejar, selecionar outro ponto alcançável e abandonar o objetivo inviável.
9. Evite teletransportar bots visivelmente durante partidas para disfarçar erros. Caso exista resgate excepcional, documente regras e só considere em situações não competitivas e fora da visão de jogadores.
10. Garanta que cancelamentos desconectem `Path.Blocked`/`MoveToFinished` e invalidem callbacks de uma rota antiga. Use tokens de geração se necessário.

### 3.1. Navegação tática

Além do menor caminho, considere **pontos táticos** que realmente existam no mapa: locais de cobertura, corredores, entradas, flancos, regiões perigosas e objetivos. `PathfindingModifier`/`Costs` podem favorecer ou evitar regiões; a avaliação de risco do combate deve acontecer **acima** do pathfinding, e não ser confundida com ele.

Atribua pontos ou regiões a partir dos mapas existentes, com validação de alcance e custo de manutenção. Não infira automaticamente que toda parede é cobertura segura ou que toda área vazia é um ótimo flanco. Evite depender de edição manual extensa de cada mapa caso um método mais simples seja suficiente.

### 3.2. Quando usar movimento direto

Permita movimento/ajuste local sem recálculo global apenas quando houver caminho direto comprovadamente livre e a ação for adequada (reposicionamento curto, strafing, saída de uma porta). Não atravesse obstáculos nem ignore a colisão real.

## 4. Percepção, memória e conhecimento justo

Implemente sensores separados de decisões:

- **Visão:** campo angular de visão, alcance, distância, alvos válidos e `Raycast` de linha de visão; considere geometria estática e dinâmica. Percepção não deve significar localização perfeita permanente.
- **Audição:** disparos e eventos ruidosos publicados pelos sistemas reais; cada evento tem posição, instante e alcance audível plausível. Não use o áudio tocado localmente como prova autoritativa de posição.
- **Memória:** último local observado, tempo decorrido, confiança e eventual estado de busca; degrade a informação com o tempo.
- **Ameaça:** proximidade, dano recente, visibilidade, importância do objetivo e risco; evite trocar de alvo freneticamente.

Requisitos comportamentais:

1. Um alvo escondido não pode ser rastreado como se continuasse visível.
2. Perder a visão deve permitir investigação da última posição, busca limitada e desistência.
3. Bots não devem girar instantaneamente ou detectar atrás das costas sem pista plausível.
4. Armas e explosões podem alertar bots, mas sem telepatia coletiva; se houver comunicação de equipe, defina alcance, atraso e quais informações podem ser transmitidas.
5. Use consultas espaciais, cadências e cache conforme a distância/importância do bot. Não faça raycast por bot contra todo jogador a cada frame.
6. A visão de um bot não deve conhecer dados privados do cliente ou entidades que o servidor não conseguiu validar.

## 5. Decisão por utilidade e estabilidade

Projete uma **Utility AI enxuta** para avaliar ações aplicáveis ao modo: `Engage`, `Retreat`, `FindCover`, `Flank`, `Search`, `Patrol`, `HelpAlly`, `CompleteObjective`, etc.

Atribua *scores* normalizados conforme distância, risco, HP, munição, capacidade da arma, visibilidade, objetivo e personalidade. Comece com poucas ações úteis; documente pesos e condições de exclusão. Não copie cegamente uma fórmula numérica sem testar.

**Antioscilação obrigatória:** introduza uma margem mínima para mudar de ação (*histerese*) ou compromisso temporal apropriado, com interrupções imediatas para perigos críticos. Um bot não deve alternar entre perseguir, recuar e patrulhar a cada atualização.

A frequência de decisões táticas pode ser menor que a frequência da execução do movimento. Eventos críticos (dano, perda de alvo, mudança do objetivo) podem antecipar a revisão.

## 6. Combate convincente e integração com disparos

Os bots devem usar a API existente do sistema de armas do Crossgrounds, inclusive a melhoria de disparos/hitscan/projéteis que estiver presente no repositório:

- Mesmas regras de arma, cadência, munição, recarga, alcance, dispersão, obstruções, estados e aplicação de dano.
- Sem dano mágico por proximidade nem porcentagem artificial de acerto sem uma trajetória/disparo real.
- Aquisição de alvo com atraso variável; rotação progressiva da mira, limites de velocidade angular, erro de acompanhamento e correções graduais.
- Nenhuma garantia de headshot/acerto; desvios devem resultar da mira, do movimento, do contexto e da arma.
- Disparar apenas quando o estado permitir, dentro de condições válidas de percepção e obstrução.
- Reposicionar, interromper uma rajada, buscar cobertura, recarregar ou recuar quando fizer sentido.
- Considerar armas com diferentes alcances, spread, velocidade e métodos de projéteis sem especializar a IA em uma única arma.
- Separar a animação/efeito do tiro do resultado autoritativo de dano; evitar efeitos duplicados em clientes.

**Atenção:** as mesmas regras de combate não significam os mesmos mecanismos de input. O bot pode chamar internamente uma API de disparo validada; ele não precisa falsificar um `RemoteEvent` como se fosse um jogador.

## 7. Dificuldade sem vantagens desleais

**Separe dificuldade de personalidade.** Projete perfis configuráveis — por exemplo `Recruta`, `Regular`, `Veterano`, `Elite` — como ponto de partida; adapte-os aos nomes já existentes se o projeto possuir outros.

Parâmetros possíveis por perfil:

| Parâmetro | Perfil menor | Perfil maior |
|---|---|---|
| Tempo de reação | Maior e mais variável | Menor, mas não zero |
| Velocidade de aquisição | Mais gradual | Melhor estabilização |
| Erro de mira | Maior | Menor, mas existente |
| Antecipação de movimento | Limitada | Melhor, porém imperfeita |
| Percepção | Mais distraído | Mais atento, sem atravessar paredes |
| Uso de cobertura | Ocasional | Mais consistente |
| Gestão de risco | Básica | Mais apropriada ao contexto |
| Cooperação | Simples | Melhor coordenação, sem telepatia |

Como referência **apenas experimental**, reações iniciais poderiam começar em faixas como 0,65–1,00 s (Recruta), 0,35–0,65 s (Regular), 0,22–0,40 s (Veterano) e 0,16–0,30 s (Elite). Não fixe esses números no projeto sem *playtesting*; eles não são medidas científicas, e a dificuldade também depende das armas, distâncias e animações.

Não escale a dificuldade apenas com multiplicadores de dano, vida ou precisão. Se algum modo realmente exigir modificadores de atributos, mantenha-os explícitos e independentes da inteligência.

## 8. Personalidades ortogonais à dificuldade

Forneça uma estrutura opcional de tendências comportamentais, sem obrigar a implementação de todas antes da base funcionar:

- **Agressivo:** pressiona e aceita exposição maior.
- **Defensivo:** preserva vida e sustenta posição.
- **Flanqueador:** busca ângulos alternativos quando alcançáveis.
- **Oportunista:** prioriza alvos vulneráveis e janelas curtas.
- **Objetivo:** coloca a condição de vitória acima de duelos desnecessários.
- **Suporte:** protege aliados e posições importantes.
- **Impulsivo:** muda prioridades mais facilmente e assume riscos.
- **Cauteloso:** investiga, espera e só avança com melhores informações.

A personalidade modifica **pesos e preferências**, nunca garante um estado ou substitui regras da modalidade. Teste combinações (`Recruta + Agressivo`, `Elite + Cauteloso` etc.). Varie timing e escolhas dentro de limites plausíveis para que bots idênticos não ajam em perfeita sincronia.

## 9. Adaptação por modalidade

Crie interfaces/adaptadores pequenos que forneçam ao planejador ações, objetivos e permissões reais da modalidade.

| Modalidade | Prioridades específicas a estudar |
|---|---|
| **Arena** | Combate rápido, cobertura, flanco, respawn, gestão de distância, objetivo real da partida |
| **Duels** | Leitura do adversário, espaçamento, pistola/faca, duas habilidades (se implementadas), ritmo e regras de rounds |
| **Get Out — sobrevivente** | Evasão, progresso dos objetivos, suporte, fuga, riscos de interagir com puzzles e dispositivos |
| **Get Out — caçador** | Patrulha, pistas, investigação, perseguição, interceptação e regras próprias do papel |
| **CTF (somente se existir)** | Capturar, defender, escoltar, interceptar e recuperar bandeira |

Em **Get Out**, os bots não devem fingir resolver puzzles por meio de uma animação e marcar objetivo como concluído sem utilizar a lógica real de interação. Se o modo ainda não expõe APIs adequadas para NPCs, documente a dependência e não fabrique funcionalidade.

Não use um único modelo de combate FPS para todos os papéis. Verifique a existência efetiva dos modos no projeto e mantenha o sistema integrável aos que vierem depois.

## 10. Controle de carga e ciclo de vida

- Centralize ou coordene atualizações por orçamento e prioridade; evite um `Heartbeat` pesado por bot para percepção + decisão + pathfinding simultâneos.
- Distribua sensores e replanejamento no tempo para evitar picos em massa.
- Preserve atualizações críticas de combate/movimento quando necessário, sem reduzir indiscriminadamente a frequência de tudo.
- Limite computações de rota concorrentes e faça *backoff* em caminhos inalcançáveis.
- Limpe conexões, tarefas, referências a jogadores mortos, caminhos antigos, sons/indicadores e objetos de debug ao remover NPCs ou encerrar partidas.
- Verifique autoridade e network ownership dos corpos de NPCs de acordo com a estratégia existente, evitando que um cliente controle estado de combate crítico.
- Não otimize com paralelismo/Actors ou bibliotecas externas antes de medir se realmente são necessários.

## 11. Ferramentas de depuração obrigatórias

Sob ativação de desenvolvimento (jamais por padrão em produção), permita inspecionar por bot:

- Estado atual e há quanto tempo está nele.
- Objetivo, alvo, última posição vista/ouvida e grau de confiança.
- Waypoints, rota escolhida e motivo de replanejamento.
- Distância percorrida e contador de travamentos/recuperações.
- Ação selecionada e principais pontuações de utilidade.
- Linha de visão, campo de percepção e razão de um disparo negado.
- Dificuldade, personalidade, arma e condição de recarga.

Instrumente métricas agregadas: latência de decisão, computações de rota por minuto, falhas de rota, tempo imóvel, alterações de alvo por minuto, disparos/acertos por distância, tempo até primeiro tiro, carga de CPU do sistema quando mensurável e quantidade de NPCs ativos.

## 12. Plano de execução por etapas

1. **Diagnóstico e baseline:** identificar módulos e coletar exemplos reproduzíveis das falhas.
2. **Navegação:** estabilidade de waypoints, timeout, bloqueio, stuck detection, cancelamento e recuperação.
3. **Percepção e memória:** visão, pistas auditivas, última posição conhecida, perda de alvo.
4. **Decisão:** estados claros, utilidade, prioridades, histerese e objetivos reais.
5. **Combate:** integração à API de armas, mira progressiva, precisão justa, cobertura.
6. **Dificuldade/personalidade:** configuração de tendências, testes comparativos e ajuste.
7. **Modo a modo:** integrar primeiro a modalidade que já possui bots; expandir depois de estabilizar.
8. **Performance e regressão:** instrumentar, medir, ajustar e documentar.

Para cada etapa, mantenha o jogo funcional e relate arquivos modificados e alterações de comportamento. Não faça refatoração massiva de módulos não relacionados.

## 13. Matriz de testes e critérios de aceitação

| Cenário | Resultado esperado |
|---|---|
| Corredor estreito, porta e canto | Bot navega sem oscilar indefinidamente |
| Alvo atravessa cobertura | Bot perde linha de visão e investiga posição anterior |
| Alvo se afasta vários metros | Replanejamento controlado, sem recomputar por frame |
| Obstáculo dinâmico bloqueia rota | Recuperação ou rota alternativa dentro de limite razoável |
| Destino inalcançável | Bot desiste/reprioriza em vez de travar para sempre |
| Alvo atrás do bot | Percepção respeita sensores; sem giro mágico instantâneo |
| Alvo próximo | Reação visível e disparo regulado por arma, sem morte automática por proximidade |
| Múltiplos inimigos | Escolha de alvo estável e sensível à ameaça |
| Baixa vida/munição | Decisões compatíveis com personalidade e recursos |
| Dificuldades distintas | Diferenças observáveis de reação e estratégia, não apenas dano |
| Bots idênticos | Variação plausível, sem sincronia perfeita |
| Múltiplos bots/jogadores | Sem explosão de consultas ou degradação severa |
| Fim da partida, morte e respawn | Tasks/conexões canceladas e estados reiniciados corretamente |
| Arena, Duels, Get Out | Apenas regras e objetivos realmente suportados por cada modo |

Execute testes com número crescente de bots (por exemplo 1, 4, 8 e 16 **somente se o projeto suportar**), em cenários controlados e reais. Compare **antes/depois**; não invente porcentagens de melhoria nem metas numéricas sem um baseline.

**Aceitar somente quando:**
- Navegação previsível, travamentos tratados e replanejamento com controle.
- Percepção e memória não concedem informações impossíveis.
- Bots apresentam estados e decisões explicáveis.
- Combate utiliza regras existentes e tem reação/mira plausíveis.
- Dificuldades e personalidades são independentes e configuráveis.
- Ciclo de vida não deixa loops/eventos órfãos.
- Impacto de desempenho foi medido ou explicitamente registrado como pendente.

## 14. Relatório final obrigatório

Entregue ao terminar:

1. **Diagnóstico**: falhas reais, evidências e causas raiz.
2. **Arquitetura resultante**: componentes, eventos e dados compartilhados.
3. **Mudanças por arquivo**: o que foi alterado e por quê.
4. **Comportamentos obtidos**: navegação, percepção, combate, dificuldade e modos.
5. **Testes executados**: ambiente, cenário, resultados e números reais, se medidos.
6. **Limitações/pendências**: riscos, integrações inexistentes e testes manuais.
7. **Reversibilidade**: como retornar ao comportamento anterior ou desligar funcionalidades experimentais, se aplicável.

**Princípio central:** um bot convincente não precisa enxergar tudo nem acertar todos os tiros; ele precisa perceber, decidir, agir, errar e se recuperar de maneiras compreensíveis.

## Referências técnicas (Roblox Creator Hub)

- [Pathfinding — guia oficial](https://create.roblox.com/docs/characters/pathfinding)
- [PathfindingService — API](https://create.roblox.com/docs/reference/engine/classes/PathfindingService)
- [Humanoid / MoveTo e MoveToFinished](https://create.roblox.com/docs/reference/engine/classes/Humanoid)
- [Segurança na fronteira cliente-servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary)

> A documentação é referência técnica, não autorização para substituir contratos do projeto sem auditoria. Antes de usar uma API, confira sua disponibilidade e comportamento na versão atual do Roblox Studio.
