# Crossgrounds — acertos, escopetas e câmera do eliminador

23/10/2026 · Place 4375993208 · projeto aberto atualizado, sem publicação.

## Diagnóstico

O [diagnóstico registrado antes das alterações](ARMAS-FEELING-DIAGNOSTICO.md) identifica os caminhos originais.

A apresentação já era imediata no cliente e os tiros comuns já eram hitscan. Esses componentes foram preservados. Os principais problemas tratados foram:

- Histórico de hitboxes ignorado em conexões com ping baixo.
- Escolha temporal baseada apenas no timestamp/ping, sem pista da pose que o cliente enxergava.
- Acessórios e root invisível podendo interceptar tiros.
- Bônus de headshot de 35%; queda de dano pouco perceptível na Arena.
- Configuração global sobrescrevendo a quantidade de chumbos de cada arma.
- Ausência de uma mensagem autoritativa que identificasse o eliminador para a câmera da vítima.

Durante os testes em conjunto apareceu outro caso: um bot temporário sem CTFTeam fazia a classificação de equipe lançar erro e interromper o disparo. DamageService agora tolera esse estado, e o histórico ignora modelos já removidos do Workspace.

## Prioridade para a visão do cliente

O cliente continua prevendo som, recuo, clarão e traçantes imediatamente. Não recebe autoridade para aplicar dano.

Agora envia também, quando a mira encontra um personagem, a parte corporal observada e o centro daquela parte na sua visão. Isso é **uma pista temporal**, não uma declaração de acerto.

O servidor:

1. Valida personagem, arma equipada, sequência, timestamp, origem, direção, munição, recarga e cadência.
2. Determina uma hora de referência usando o relógio sincronizado e o RTT medido pelo servidor.
3. Procura a observação em posições de partes corporais capturadas pelo próprio servidor.
4. Aceita alinhamento apenas até ±80 ms da referência, dentro de uma janela total de 350 ms, com erro de posição máximo de 0,75 stud e interseção do raio da câmera com a caixa registrada.
5. Escolhe **uma hora para o disparo inteiro**, inclusive todos os chumbos. Não escolhe individualmente o melhor acerto para cada alvo.
6. Executa raycasts/interseções contra as hitboxes registradas e obstáculos atuais, aplicando o dano no servidor.

A captura passou de 30 para 60 Hz; interpolação também se aplica a conexões com ping baixo. Pistas inválidas ou sem correspondência usam o tempo padrão. Acessórios e HumanoidRootPart com torso real são ignorados como hitboxes. Caixas não são ampliadas.

NPCs usam a consulta no presente. Simulação matemática de projéteis, validações de origem, penetração da sniper e efeitos separados do dano permanecem no caminho compartilhado.

### Fluxo de um disparo

Input → previsão local/consumo visual → WeaponAction → ShotAuthority/ShotLedger → ShotHistory + ShotQuery → regra de dano do modo → ShotResult + ShotVisual/CombatFeedback.

ShotResult confirma munição e aceitação; ShotVisual corrige os traçantes previstos. O atirador não repete som/recuo ao receber a replicação. Chumbos compartilham um identificador e consomem **um cartucho**, com um traçante por chumbo.

## Novas classes: somente CTF

| Classe | Primária | Secundária | Andar / correr | Pulo |
|---|---|---|---|---|
| Invasor | 725 | Bastão | 19 / 26 | 7,5 |
| Demolidor | SPAS-12 Semi-Auto | Martelo | 16 / 23 | 6,5 |

Os menus existentes usam Kits.Order/LoadoutDefinitions e passam a listar cinco classes. A Arena conserva suas seis aparências de pistola. Trocas durante a partida seguem pendentes até renascer.

| Arma | Dano próximo → distante | Queda de dano | Alcance máximo | Intervalo | Carregador / reserva | Recarga |
|---|---|---|---|---|---|---|
| 725 | 8 × 29 → 8 × 4 | 18–75 studs | 110 | 0,50 s | 2 / 32 | 2,2 s |
| SPAS-12 | 8 × 22 → 8 × 3 | 24–100 studs | 135 | 0,65 s | 8 / 48 | 3 s |
| Bastão | 40 | — | 6,4 | 0,38 s | — | — |
| Martelo | 85 | — | 7 | 0,95 s | — | — |

Escopetas semiautomáticas, com cone de chumbos determinístico e distribuído em disco, igual no cliente e servidor. Melees usam o sistema existente de contato apenas durante a janela de ataque.

### Modelos e apresentação

- 725: canos sobrepostos, coronha e guarda-mão de madeira, báscula, ponte de mira, detalhes laterais, duas mãos e abertura da báscula/cartuchos na recarga em primeira pessoa.
- SPAS-12: escudo ventilado, tubo inferior, guarda-mão com nervuras, janela de ejeção, ferrolho, coronha com hastes, duas mãos e movimento de alimentação/ferrolho na recarga em primeira pessoa.
- Bastão com empunhadura, anéis e ponteira; martelo com cabo, cabeça, faces de impacto e hitbox própria.
- Recuo próprio por escopeta e sons existentes reutilizados com volume/pitch diferentes. **Não foram adquiridos sons novos.**
- Shell de recarga da SPAS aparece apenas durante a animação no exibidor.
- Sons de hit de múltiplos chumbos são agrupados em intervalos de 60 ms para evitar oito reinícios do mesmo som.

A inspeção visual no cliente confirmou os dois modelos em primeira pessoa, via ViewportFrame; a 725 mostrou ambos os canos e os dois braços/grips. As animações são procedurais; não foram produzidas animações novas de corpo inteiro em terceira pessoa.

## Headshots e alcance

Headshot de arma de fogo = **1,5 × dano após distância × multiplicador de penetração**. Dano fracionário é preservado: um chumbo próximo da 725 dá 29 no corpo e 43,5 na cabeça.

| Arma existente | Dano próximo → distante | Queda | Alcance |
|---|---|---|---|
| Vasnev 9mm | 22 → 8 | 30–110 | 180 |
| Kastov 545 | 34 → 17 | 75–220 | 360 |
| Lachmann LMS | 150 → 100 | 220–600 | 800 |
| Pistolas da Arena | 45 → 14 | 35–140 | 210 |

Na Arena, com 20 HP, um acerto distante no corpo deixa de eliminar sozinho; um headshot distante dá 21. Na sniper, penetração continua reduzindo 20% por alvo atravessado.

Ao mirar em um personagem visível com ADS, há um texto discreto: ALCANCE EFETIVO, DANO REDUZIDO ou FORA DE ALCANCE. Não há indicação de inimigos ocultos nem novo exibidor numérico de dano.

Esses valores são uma base de balanceamento; não são resultado de sessões extensas de PvP.

## Câmera após eliminação

DamageService e ArenaCombat enviam à vítima a identidade do eliminador selecionada pelo servidor. EliminationSpectator segue esse personagem até o respawn, oculta a mira/equipamento local e restaura a câmera do novo personagem.

Se o eliminador morrer ou sair, a câmera mantém a última visão em vez de selecionar outro inimigo. Mudança de modo e troca/remoção do personagem encerram a observação. O cronômetro de respawn não foi alterado. Não é replay/killcam histórica.

## Arquivos e responsabilidades

Caminhos relativos a src/:

| Arquivo | Responsabilidade |
|---|---|
| ReplicatedStorage/KitDefinitions.luau | Classes, armas, mobilidade, dano/falloff, headshots, faixas de alcance |
| ReplicatedStorage/Crossgrounds/ShotMath.luau | Cone determinístico com múltiplos chumbos |
| ReplicatedStorage/Crossgrounds/ShotQuery.luau | Raycast compartilhado ignorando cosméticos/root |
| ReplicatedStorage/Crossgrounds/WeaponReloadMotion.luau | Movimentos de recarga das escopetas |
| ServerScriptService/Crossgrounds/ShotHistory.luau | Histórico, alinhamento temporal e interseções autoritativas |
| ServerScriptService/Crossgrounds/ShotAuthority.luau | Integração do histórico e quantidade de chumbos |
| ServerScriptService/MainGameScript/GameManager/WeaponFactory.luau | Modelos, grips, hitboxes e grupos de recarga |
| ServerScriptService/MainGameScript/GameManager/DamageService.luau | Eliminação no CTF e classificação robusta de equipes |
| ServerScriptService/Crossgrounds/ArenaCombat.luau | Evento de eliminador na Arena |
| StarterPlayer/StarterPlayerScripts/CombatPresentation.luau | Observação da mira e previsão dos chumbos |
| StarterPlayer/StarterPlayerScripts/WeaponController.luau | Pedido com pista de pose, texto de alcance, bloqueio durante espectador |
| StarterPlayer/StarterPlayerScripts/FirstPersonRenderer.luau | Grupos visuais de recarga e cartuchos temporários |
| StarterPlayer/StarterPlayerScripts/CombatHUD.luau | Agrupamento sonoro dos hits |
| StarterPlayer/StarterPlayerScripts/EliminationSpectator.luau | Nova câmera da vítima |
| ServerStorage/UnitTest/Cases/ShotHistory_Test.luau | Limites temporais, pistas inválidas, alvo em movimento, cobertura |
| ServerStorage/UnitTest/Cases/ShotPipeline_Test.luau | Compatibilidade de contagem de chumbos |
| ServerStorage/UnitTest/Cases/Ballistics_Test.luau | Composição de headshot/falloff/penetração |
| ServerStorage/UnitTest/Cases/ArenaRewards_Test.luau | Tiros necessários à distância na Arena |
| ServerStorage/UnitTest/Cases/ArenaRefinement_Test.luau | Inventário dinâmico de classes |
| ServerStorage/UnitTest/Cases/CombatFeeling_Test.luau | Novas classes, modelos, cones, dano e hitboxes |

## Testes efetivamente executados

**149/149 testes da suíte passaram**, incluindo testes anteriores preservados e oito novos. O teste de alinhamento de alvo em movimento usa poses capturadas no servidor e um relógio de teste fixo para não depender de travadas de inicialização do Studio. As simulações 30/60/120 FPS são matemáticas; não representam três sessões gráficas nesses limites de FPS.

**5/5 cenários de integração passaram em Play, com um cliente real:**

1. 725: oito pacotes de traçantes, oito chumbos, dano acumulado 232 no alvo amplo, munição 2 → 1, alinhamento da observação com ping baixo. A chamada de previsão local levou aproximadamente 3,18 ms nesta amostra; isso não é uma medição física de latência input-to-photon.
2. Cadência e vetor inválido rejeitados sem consumir munição extra.
3. Parede próxima bloqueou todos os chumbos. Recarga finita: carregador 2, reserva 32 → 30.
4. SPAS-12: acúmulo de dano por chumbos, munição 8 → 7 → 8, reserva 48 → 47 e estado de recarga válido.
5. Troca de classe permaneceu pendente até o respawn; vítima observou o eliminador, sem retículo, e voltou equipada com a nova classe.

[Resultados completos](../artifacts/weapon-feeling-evidencias-2026-10-23.json).
[Fixture de servidor](../artifacts/weapon-feeling-integration-server-2026-10-23.luau) e [fixture de cliente](../artifacts/weapon-feeling-integration-client-2026-10-23.luau) são material de QA, não componentes a instalar no jogo.

Validação final: **155 fontes compilaram sem erro**, 20 fontes do patch correspondem às locais normalizando finais de linha, e 20 fontes foram recuperadas sem divergência na serialização/desserialização do pacote. Scripts/remotos/objetos temporários de QA foram removidos da edição.

## Desempenho e limitações

- Nenhum projétil físico, Touched ou replicação por frame foi adicionado.
- Histórico mantém uma conexão Heartbeat compartilhada; nenhum loop por bala. Janela menor compensa parte do aumento de frequência, mas não elimina o custo adicional de captura e das oito consultas por escopeta.
- Câmera de espectador usa um callback compartilhado de renderização; efeitos e previsões usam o gerenciamento existente.
- Ainda não foi feito benchmark comparativo sob carga de um servidor cheio.
- A pista temporal continua limitada; não é garantia de validar todo acerto visto em conexões ruins. A margem de ±80 ms é um compromisso de justiça que precisa de telemetria/PvP real.
- Portas/obstáculos e origem do atirador não são rebobinados. Proteção de spawn e saúde são verificadas no presente; alvos já mortos não voltam a receber dano.
- **Pendentes:** WAN com latência/jitter/perda, servidor com vários jogadores reais, alvo PvP em movimento, cliente FPS real 30/60/120 e dispositivos físicos de controle/touch.
- O fluxo da câmera de morte foi testado no CTF contra um eliminador de fixture. A emissão da Arena está implementada, mas a observação entre dois jogadores reais de Arena permanece pendente.
- O estilo, os grips e as animações precisam de avaliação artística em movimento e em skins R6/R15 variadas. Nenhuma afirmação de animação completa foi feita.
- Avisos preexistentes de plugins e fallback de ConfigService apareceram no console; não foram tratados como falhas desse patch.

## Instalação e recuperação

O projeto aberto já recebeu as alterações; não foi publicado. Pacote incremental: [crossgrounds-weapon-feeling-2026-10-23.rbxm](../artifacts/crossgrounds-weapon-feeling-2026-10-23.rbxm).

20 fontes, 73.915 bytes. SHA-256: FF8F5103B4A53BD00C213E0FBF2DA1F04D619C9E628970E91C822DD94BFEC35A.

Os diretórios no pacote são Folders de transporte. Para outro Place, copie apenas as fontes para os caminhos correspondentes; EliminationSpectator é LocalScript e CombatFeeling_Test é ModuleScript. Preserve os patches anteriores, mapas e serviços inteiros.

Backup das 18 fontes existentes: ServerStorage.WeaponFeelingBaseline_20261023. Novos componentes: EliminationSpectator e CombatFeeling_Test. Para reverter, restaure essas fontes e remova apenas esses dois novos componentes. Não remova o legado ou pastas de mapas.

Referências técnicas: [cliente/servidor Roblox](https://create.roblox.com/docs/projects/client-server), [Player:GetNetworkPing](https://create.roblox.com/docs/reference/engine/classes/Player) e [simulador de rede do Studio](https://create.roblox.com/docs/studio/network-simulator).

