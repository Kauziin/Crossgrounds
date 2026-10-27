# Crossgrounds — implementação de Bots e UI unificada

23/10/2026 · Place inspecionado e alterado: **4375993208, Crossgrounds (ALPHA)**.
Correção posterior: o foco nativo concorria com o cursor próprio no controle. Veja [correção de navegação e cursor](CONTROLE-CURSOR-CORRECAO.md), aplicada após esta entrega.
Correção posterior de configurações: [sliders e sincronização](SLIDERS-SINCRONIZACAO.md) separa rascunhos locais das confirmações do servidor, eliminando incrementos perdidos em ajustes rápidos.
Os dois documentos da raiz foram lidos integralmente. Bots receberam prioridade.
**Sem publicação.** Mapas, projeto legado, regras dos modos e pacotes anteriores preservados.
Aplicação feita no projeto aberto e nas fontes locais; outros Places não foram abertos/alterados automaticamente.

## 1. Diagnóstico e abordagem

O [diagnóstico anterior às alterações](BOTS-UI-DIAGNOSTICO.md) registra as evidências do controlador e das telas originais.
O spawn, skins, roles, animações do template, bandeiras, damage service, menus de loadout, votação, playlist e editor touch existentes foram reutilizados.

Problemas corrigidos dos bots: monólito com loop por NPC; rota sem orçamento global/Blocked; fallback MoveTo sem comprovação de caminho; resgate por teleporte; cone ignorado de perto; leitura contínua de posição escondida; munição particular infinita; desvio da API comum de armas.
Problemas corrigidos da UI: FOV/oscilação em Gráficos, perspectiva em Jogabilidade, AA duplicado; configurações planas sem herança; escalas inexistentes; colunas comprimidas no celular; retículo fixo sem prévia.

## 2. Bots: implementação

Fluxo: BotManager → BotBrain compatível → BotRuntime → sensor/memória → utilidade → adapter CTF → navegação e combate → ShotAuthority → Ballistics/ShotHistory conforme o disparo → DamageService.

### Navegação

- Pathfinding nativo: raio 2,1, altura 5,5, salto/escalada, waypoints de 4 studs; custo de água 25.
- Fila com **duas computações concorrentes** e reposição de **quatro tokens/s**, permitindo rajada inicial de quatro solicitações. Computação assíncrona não bloqueia o sensor/combate.
- Replaneja por mudança de destino >10 studs, bloqueio adiante, rota obsoleta após 6 s ou falta de progresso. Token de geração invalida retornos antigos.
- Movimento direto somente em deslocamentos curtos (até 18 studs), com Blockcast e verificação de chão. Respeita waypoint de pulo e renova MoveTo a cada 2 s quando necessário.
- A chegada ao waypoint usa tolerância horizontal e limite vertical separado: pontos da navmesh ficam no chão, enquanto HumanoidRootPart fica acima. Isso evita esperar num waypoint já alcançado sem aceitar outro andar distante.
- Após 2,5 s sem progresso: ajuste lateral se livre, espera curta, nova rota e abandono. Falhas de rota têm backoff crescente; três falhas abandonam o objetivo e evitam repeti-lo por 7 s. O adapter pode sugerir outra lane.
- Rotas, callbacks e fila são liberados no Stop/death/removal. Não há teleporte para disfarçar travamento; queda abaixo do limite existente encerra a vida e usa respawn normal.
- Cobertura consulta nós táticos já existentes e sua obstrução em relação à ameaça observada. Não trata toda parede como cobertura segura.

### Percepção e decisão

- Cone de 140° e alcance visual de 190 studs, incluindo alvos próximos. Até três candidatos por scan, com LOS e filtro de aliados/cadáveres.
- Scans distribuídos (Regular: 0,28 s + jitter); orçamento conjunto de até 120 consultas/s com reserva máxima de 24 tokens. A audição também consome esse orçamento.
- Memória guarda a última observação, velocidade estimada limitada, instante e confiança. Após perder LOS não atualiza a posição escondida; confiança expira conforme o perfil.
- Disparos autoritativos geram pistas auditivas limitadas; área aproximada em grade de 8 studs, TTL curto e atenuação por obstáculo. Sem comunicação telepática entre bots.
- Ações efetivas: Objective, Engage, Retreat, Search e Patrol; recuperação fica na navegação. Utilidade normalizada, margem de 0,12 e compromisso de 0,85 s evitam alternância frenética. Saúde crítica e transporte de bandeira podem interromper.
- Adapter CTF preserva captura, defesa, devolução, recuperação, escolta e lanes. Interceptação inimiga usa observação, não posição privada do portador.
- Atualização compartilhada a 20 Hz, decisões a 0,4 s + jitter e execução de navegação a 0,1 s.

### Combate e perfis

- API interna FireNPC/ReloadNPC, sem RemoteEvent falsificado. Mesmo resolver de arma dos jogadores: munição/reserva finitas, recarga, cadência, alcance, dispersão, obstruções, headshot, falloff e penetração.
- Reação variável, giro/mira com velocidade angular limitada, erro contínuo e antecipação imperfeita da velocidade observada. Rajadas pequenas com pausa; não existe indicador de “acerto pretendido” nem dano por proximidade.
- A correção de paralaxe usa a profundidade observada do alvo para que o cano não convirja apenas no alcance máximo.
- Dificuldades Recruit/Regular/Veteran/Elite alteram reação, frequência/qualidade de percepção, mira e memória; **não alteram HP/dano**.
- Personalidades Aggressive/Defensive/Flanker/Objective/Support/Cautious alteram pesos e preferências, separadamente da dificuldade. São valores iniciais que exigem playtest de balanceamento.
- Mantidos 200 HP, até seis por equipe, roles, skins, network ownership do servidor e respawn existente.
- As animações originais do template foram preservadas. Este patch não cria animações novas de reload/cobertura nem um sistema de troca de armas dos bots.
- Ao esgotar também a reserva, o bot deixa de escolher combate direto; não recebe munição infinita ou ressuprimento inventado.

### Diagnóstico de desenvolvimento

Opções → Desenvolvimento · Studio: diagnóstico, dificuldade dos **próximos spawns** e snapshot.
Atributos por bot incluem decisão/idade/motivo, scores, objetivo, alvo, última visão/som, confiança, LOS/FOV, rota/waypoint/motivo, viagem/imobilidade/travamentos, arma/recarga, disparos/acertos e motivo de tiro negado.
Rotas de debug são limitadas a 24 segmentos por bot e removidas ao desligar. Renderização/atributos detalhados são condicionados a Studio e ativação explícita.
Snapshot agrega CPU do coletor, atraso de agendamento, NPCs ativos, rotas/min, concorrência/falhas, eventos de recuperação, trocas de alvo, faixas de disparo/acerto e atraso até o primeiro tiro. Contadores leves permanecem no runtime; não há profiler nativo de pathfinding embutido.
“Recuperações” conta tentativas de ajuste, não prova sucesso; “imóvel” é tempo estimado sem deslocamento durante objetivo ativo. Acertos por faixa podem incluir penetração e não são uma taxa científica de precisão.

## 3. UI: mapa de navegação

| Antes | Agora |
|---|---|
| Jogabilidade com câmera/perspectiva | Geral: corrida automática touch; câmera em Mira e Câmera |
| Gráficos com FOV e oscilação | Mira e Câmera → Câmera e perspectiva |
| AA em Controles e Acessibilidade | Mira e Câmera → Mira e sensibilidade |
| Retículo fixo | Mira e Câmera → Retículo, com prévia interativa |
| Sem escalas independentes | Interface: menu/HUD; Acessibilidade: texto |
| HUD touch em área pouco clara | Controles → Toque · editar HUD, usando o editor real existente |
| Colunas estreitas em celular | Apenas nível ativo e Voltar; cascata lateral preservada em tela larga |

Menu principal mantém Continuar, Loadout, Opções, Render-se e Sair. Mantidos catálogo/hub, playlist, progresso, votação e ferramentas existentes.
Categorias: Geral, Controles, Mira e Câmera, Interface, Acessibilidade e Áudio, além dos painéis reais de progresso/mapa/desenvolvimento.
Não há nova categoria gráfica vazia: não foram criadas preferências sem aplicador.

### Opções efetivamente implementadas

- Menu 80–130%; HUD 80–130%; fonte adicional 90–135%, com limites no viewport e reflow/scroll.
- Alto contraste, redução de movimento de menus e tratamento das preferências nativas documentadas.
- Retículo: seis cores, comprimento, espessura, abertura, ponto, contorno, opacidade e variação dinâmica. Prévia e arma usam **o mesmo módulo**.
- Visibilidade de killfeed por modo; intensidade de movimento da câmera/dano na tela com override onde permitido.
- Mantidos FOV, sensibilidade, AA, zonas mortas, curva dinâmica, remapeamento e edição touch.
- Valores numéricos aceitam texto e são corrigidos ao limite/passo; D-pad aparece no campo focado. Os defaults antigos de sensibilidade/volumes/flash foram preservados na grade de passos.
- Seleção nativa GuiService.SelectedObject acompanha o foco acessível existente; CAS, cursor afastado do texto, sons e ícones continuam usados.
- Insets seguros e níveis únicos em tela estreita. Tipografia respeita a escala nativa sem multiplicá-la manualmente de novo; FontScale é um ajuste adicional. TextScaled é desativado nas telas acompanhadas.
- Alto contraste preserva cores semânticas saturadas de equipe/estado. Preferência nativa de transparência afeta superfícies acrílicas; cascatas continuam sólidas.
- Redução de movimento nativa serve de default se não houver override explícito de ReducedMenuMotion. Não muda a câmera competitiva por conta própria.

### Schema, persistência e precedência

Mesmo ExperienceSettings/SettingsService, mesmo remoto UpdateExperienceSetting e **mesmo DataStore CTF_ExperienceSettings_v1**.
Formato Version 2: Global, Modes.ctf/arena e Devices.Keyboard/Gamepad/Touch.
Cada regra informa ID, categoria, tipo, padrão/limites/passo/opções, escopo, modos permitidos, persistência e atributo aplicador.

Precedência: default → Global → Mode, quando permitido. Chaves explicitamente de dispositivo usam seu bucket; **nenhuma chave implementa a matriz Mode×Device**.
Ausência de chave significa herdar. False é um valor válido explícito.

Exemplo: Global.ReticleColor=verde; Arena= ciano; CTF sem override → verde.
Restaurar padrão em Arena grava branco só em Arena. “Herdar Global” remove a chave e volta ao verde imediatamente.
Escopo aparece nas folhas relevantes e cada linha indica Global/herdado/personalizado/dispositivo. Há reset por opção, categoria, Global e todos os escopos.

Perfil plano antigo migra conservando bindings e layout touch nos buckets adequados. Campos desconhecidos/inválidos não controlam o jogo.
Estado efetivo continua em Setting* para consumidores existentes; overrides ficam no PreferenceState privado do PlayerGui. Mudanças são imediatas, coalescidas por 80 ms e persistidas em lote, com UpdateAsync/30 s/saída/fechamento.
Merge de campos alterados preserva alterações de outras chaves e edições durante load; versão mais nova salva não é sobrescrita. Não oferece lock de sessão completo; concorrência de edição da **mesma chave** continua last-writer.
Studio continua **session only**, como antes. Persistência entre sessões publicadas **não foi testada**.

### Catálogo solicitado: disponível e pendente

| Grupo | Estado real |
|---|---|
| Escalas, retículo, contraste, herança | Implementados |
| Bindings/deadzone/curva/sensibilidade/AA/layout touch | Existentes, preservados e organizados |
| Música, playlist e sons de navegação | Existentes, preservados |
| Idioma, legendas e indicadores direcionais de som | Não implementados; faltam localização/conteúdo e política de pistas |
| Crouch/vibração/canais de ambiente/partículas/reflexos | Não expostos: sistemas/aplicadores correspondentes não identificados neste escopo |
| Modos Duels/Get Out | Sem painéis/overrides fictícios; dependem de gameplay/APIs reais |
| Duração/quantidade do killfeed e escala individual de objetivos | Pendentes; este patch implementa visibilidade e escala agrupada |
| Cor personalizada arbitrária | Seis presets validados nesta entrega; sem seletor RGB livre |
| HUD móvel | Editor existente reutilizado; testes físicos de toque/teclado virtual continuam pendentes |

## 4. Fontes alteradas

30 fontes no pacote incremental: 27 de runtime e três módulos de teste. As responsabilidades estão abaixo.

| Fonte | Responsabilidade |
|---|---|
| `src/ServerScriptService/Crossgrounds/BotProfiles.luau` | Dificuldade, personalidade e orçamentos independentes de HP/dano. |
| `src/ServerScriptService/Crossgrounds/CombatNoise.luau` | Observações sonoras publicadas pelo servidor, com TTL e limite. |
| `src/ServerScriptService/Crossgrounds/BotDecision.luau` | Utilidade, exclusões, compromisso e histerese. |
| `src/ServerScriptService/Crossgrounds/BotPerception.luau` | Cone, LOS, orçamento, audição e memória degradável. |
| `src/ServerScriptService/Crossgrounds/BotNavigation.luau` | Fila compartilhada, path cancelável, bloqueio, progresso e recuperação. |
| `src/ServerScriptService/Crossgrounds/CTFBotObjectives.luau` | Objetivos reais de bandeiras, lanes e cobertura existente. |
| `src/ServerScriptService/Crossgrounds/BotCombat.luau` | Mira gradual, reação, rajadas e chamadas à autoridade comum. |
| `src/ServerScriptService/Crossgrounds/BotRuntime.luau` | Coletor compartilhado, ciclo de vida e métricas/diagnóstico. |
| `src/ServerScriptService/Crossgrounds/ShotAuthority.luau` | Resolver comum de disparos e API interna validada FireNPC/ReloadNPC. |
| `src/ServerScriptService/Crossgrounds/DevelopmentService.luau` | Comandos Studio para diagnóstico e dificuldade dos próximos spawns. |
| `src/ServerScriptService/MainGameScript/GameManager/BotBrain.luau` | Fachada compatível para o novo Runtime. |
| `src/ServerScriptService/MainGameScript/GameManager/BotManager.luau` | Spawn existente preservado; encerramento explícito do controlador/observação de dano. |
| `src/ServerStorage/UnitTest/Cases/BotIntelligence_Test.luau` | Nove testes novos de percepção, decisão, mira, waypoints, disparos, reload e scheduler. |
| `src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau` | Categorias, escopo, herança, resets, prévia e layout responsivo. |
| `src/StarterPlayer/StarterPlayerScripts/PreferenceClient.luau` | Estado local efetivo, notificações e coalescência de edições. |
| `src/ReplicatedStorage/ExperienceSettings.luau` | Registro central ampliado e validação de campos/escopos. |
| `src/StarterPlayer/StarterPlayerScripts/CascadeMenu.luau` | Escala e navegação por níveis em tela estreita para menus compartilhados. |
| `src/StarterPlayer/StarterPlayerScripts/InterfaceThemeController.luau` | Texto, HUD, contraste e preferências nativas sem multiplicação repetida. |
| `src/ServerScriptService/MainGameScript/GameManager/SettingsService.luau` | Migração Version 2 e persistência no serviço/store existentes. |
| `src/ServerStorage/UnitTest/Cases/PreferenceProfile_Test.luau` | Oito testes novos de migração, herança, validação e isolamento. |
| `src/ServerScriptService/Crossgrounds/PreferenceAdapter.luau` | Metadados de versão/schema para o hub. |
| `src/ReplicatedStorage/Crossgrounds/PreferenceProfile.luau` | Containers, resolução, migração e edições validadas. |
| `src/ReplicatedStorage/Crossgrounds/Reticle.luau` | Renderizador compartilhado entre jogo e prévia. |
| `src/StarterPlayer/StarterPlayerScripts/ArenaHUD.luau` | Preferência de visibilidade do killfeed. |
| `src/StarterPlayer/StarterPlayerScripts/CombatHUD.luau` | Preferência de visibilidade do killfeed. |
| `src/StarterPlayer/StarterPlayerScripts/WeaponController.luau` | Renderiza a mira configurável sem mudar trajetória/input. |
| `src/StarterPlayer/StarterPlayerScripts/MenuTheme.luau` | Transparência nativa, contraste e redução de movimento. |
| `src/ServerStorage/UnitTest/Cases/ShotHistory_Test.luau` | Fixture usa instantes realmente capturados, evitando dependência de frame adivinhado. |
| `src/ServerScriptService/Crossgrounds/ShotHistory.luau` | Consulta somente leitura ObservedAt para diagnóstico/testes. |
| `src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau` | GuiService.SelectedObject sincronizado com foco customizado; preserva cursor, sons e bindings. |

BotAccuracy foi preservado por compatibilidade, mas o novo controlador não usa seus acertos pretendidos. O teste legado desse módulo continua passando e não comprova o comportamento da nova IA.

## 5. Testes reais e limites

Método: Roblox Studio Play com Script/LocalScript normal instalado temporariamente; remotos e módulos usam o contexto real da sessão. O require isolado da ponte MCP não foi usado como prova de integração.
Fixtures de teste foram removidos ao encerrar Play. [Evidências estruturadas](../artifacts/bots-ui-test-evidence-2026-10-23.md).

| Cenário executado | Resultado |
|---|---|
| Suíte completa, incluindo nove testes de bots e oito de perfil | **133/133 passaram**, inclusive com o teste de chegada ao waypoint |
| Cone atrás de perto, alvo coberto/memória, limite angular | Passaram com fixtures reais de partes/raycast |
| Disparo NPC, munição, cadência, parede, reload finito/cancelado | Passaram usando ShotAuthority real |
| Scheduler e Stop | Executou decisão e desconectou após parar |
| Parede dinâmica durante rota | Chegou a <2 studs em 6,14 s, 52,68 studs percorridos; motivo blocked; duas computações adicionais ao baseline do fixture |
| Destino fechado por paredes/teto | Abandonou em 4,32 s, após três falhas adicionais; sem teleporte |
| 12 bots CTF por ~35 s, com reconciliação de respawn | Todos os 12 se deslocaram >5 studs nos snapshots; houve combate; zero erros do controlador; máximo duas rotas concorrentes |
| Encerramento da rodada de 12 | active=0, connected=false, queued=0, concurrent=0 |
| Perfil antigo/corrompido, limites, false explícito, isolamento | Testes passaram |
| Hub → CTF → Hub → Arena → respawn → Hub | Retículo global=2/CTF=2/Arena=3; HUD Arena=1,2; overrides mantidos no respawn e Global restaurado no hub |
| Layout real limitado a 360×640 e 640×360 | Apenas Detail visível; Voltar e scroll disponíveis; largura útil 335/615 px |
| Layout limitado a 1024×768 | Quatro níveis laterais visíveis; detalhe com scroll |
| Texto 135% + menu 130% | Título 27 px a partir de 20; sem multiplicação crescente; painel com reflow |
| Default vs herdar e contraste/redução | Confirmados em LocalScript e atributos efetivos |
| ButtonA sintetizado no Studio, botão registrado | Uma ativação; foco customizado e SelectedObject no mesmo controle |
| Inspeção visual desktop do retículo/configurações | Cascatas sólidas separadas, prévia e valores renderizados |

Os layouts limitados são **GUIs reais com área constrangida no desktop**, não emulação completa de smartphone, notch, teclado virtual ou toque físico.
O teste de ButtonA não equivale a uma sessão inteiramente navegada com controle físico.

Na rodada de ~35 s: média do coletor 1,87 ms, pico 5,26 ms, atraso médio de agendamento 51,67 ms, 86 computações de rota totais (uma anterior do teste), 416 disparos e 22 impactos. Contadores são observações de uma execução curta, sem comparação controlada antes/depois.
O tempo medido inclui o coletor Luau; **exclui trabalho nativo assíncrono de PathfindingService** e não é custo total do servidor. A medição não estabelece capacidade de produção ou balanceamento.
Faixas históricas dessa primeira rodada tinham uma referência compartilhada no snapshot; corrigido com cópia profunda e explicitado nas evidências.

[Rodada posterior à correção de waypoint](../artifacts/bots-ui-final-waypoint-2026-10-23.md): 30 s, estados Objective/Engage/Retreat/Search/Patrol observados, 331 disparos/36 impactos, zero erros de controlador e zero falhas de rota novas. Média do coletor 1,96 ms e pico 6,79 ms; 66 novas computações de rota, máximo duas concorrentes. O snapshot final tinha 11 agentes vivos, devido ao respawn. Encerramento zerou agentes/fila/concorrência/conexão. Ainda houve 23 eventos de stuck e 20 tentativas de ajuste; o mapa exige playtest prolongado e esta amostra não prova ausência de travamentos. A última correção também invalida o comando MoveTo em cache quando ele é cancelado, para reenviá-lo imediatamente ao receber a próxima rota.

[Validação final da versão empacotada](../artifacts/bots-ui-release-validation-2026-10-23.md): suíte **133/133**; rodada curta de 15 s com 12 ativos, 106 disparos, três impactos, nenhuma falha de rota/erro de controlador e sete eventos de stuck. Média 1,41 ms/pico 4,18 ms do coletor; encerramento sem fila/rota concorrente/agente/conexão. Na UI, botões de ajuste/padrão têm 44 px lógicos (57,2 px com escala 130%); área 360×640 mostrou apenas Detail, Voltar, texto a 135% e scroll. São sessões distintas, não uma comparação controlada antes/depois.

### Verificações ainda necessárias

- Multiplayer real, latência, combate humano contra cada combinação de dificuldade/personalidade, TTK de perto/longe e impressão de justiça.
- Corredores/portas/escadas de todos os mapas, multidões em passagens, rotas de bandeira completas e teste prolongado de stuck/falhas. Houve eventos de recuperação na sessão curta; não se afirma navegação perfeita.
- Comparações controladas com diferentes quantidades suportadas de NPCs, CPU/memória nativa e taxa de decisões sob carga prolongada. O limite atual CTF é 12; não foi inventado teste com 16.
- Persistência publicada com reentrada, falha de rede de DataStore e concorrência de servidores. Foi testada persistência **na sessão e no respawn**, não gravação real no Studio.
- Navegação de todos os painéis com controle físico Xbox/PlayStation, troca contínua entre inputs e rolagem por analógico.
- Celular/tablet reais: retrato/paisagem, notch, teclado virtual, toque, popups e editor HUD.
- Preferências nativas de fonte/transparência/redução alteradas pela conta/dispositivo, além do ajuste interno.
- Textos ingleses/localização: a UI existente está em português; não se declarou suporte multilíngue.
- Novas animações/contexto de cobertura e expansão da IA para modos sem controlador NPC permanecem fora desta base.

## 6. Instalação e reversão

O projeto aberto já recebeu as fontes. Pacote incremental: artifacts/crossgrounds-bots-ui-2026-10-23.rbxm.
Validação final: 151 fontes do projeto compilaram sem erro; as 30 fontes do patch correspondem às locais. Serialização e desserialização do pacote recuperaram as mesmas 30 fontes sem divergência. [Manifesto e SHA-256](../artifacts/crossgrounds-bots-ui-2026-10-23.md).
Os diretórios do pacote são **Folders de transporte**; para outro Place, copie cada SourceContainer para o caminho de serviço correspondente, substituindo a fonte existente e adicionando apenas os módulos novos. Não deixe scripts de gameplay executando dentro do pacote de transporte. Não substitua mapas/serviços inteiros.

Backup das 18 fontes originais inspecionadas: ServerStorage.BotUIBaseline_20261023 (inclui ShotEffects, inspecionado e não alterado).
Para reversão, restaure as fontes correspondentes do backup, remova apenas os novos módulos listados neste patch e mantenha os objetos/mapas legados. Perfil Version 2 exige restauração/migração de dados se houver adoção em produção; **nenhum perfil persistente foi migrado publicamente nesta sessão**.

Referências técnicas consultadas: [pathfinding nativo](https://create.roblox.com/docs/characters/pathfinding), [GuiService/acessibilidade](https://create.roblox.com/docs/reference/engine/classes/GuiService) e [size modifiers](https://create.roblox.com/docs/ui/size-modifiers).
