# Crossgrounds — armas, pegada, pulo e movimento de câmera

**22/10/2026. Aplicado no Studio integrado e em `src/`. Não publicado.**

## Implementação

- Modelos procedurais novos para Vasnev 9mm, Kastov 545, Lachmann LMS, Faca, Executor e Treme-Terra. Armas de fogo possuem corpo, carregador segmentado, gatilho/proteção, trilhos, cano, boca e coronha; a sniper possui luneta. SMG/fuzil: 41 partes cada; sniper: 48; faca: 12; espada: 15; machado: 16. São modelos geométricos provisórios, sem meshes/texturas próprias.
- Apoio das duas mãos nas armas de fogo e no machado em R15. `WeaponRig` monta a arma no tronco; `ArmPose` resolve ombro, cotovelo e punho; `WeaponPose` aplica a pose em PreSimulation, após o Animator, para jogadores e bots. Faca/espada mantêm a mão direita livre para o golpe.
- Compatibilidade com Motor6D e AnimationConstraint. Quando existem juntas antigas e novas com o mesmo nome, a nova tem prioridade. Cadeias de braços são reavaliadas a cada 0,5 s, pois a aparência de amigos aplicada aos bots pode substituir membros/juntas depois de equipar.
- O machado mantém a transformação do ataque por Tool.Grip, aplicada sobre sua montagem própria. Os volumes de contato anteriores foram preservados: faca 0,28 × 1,9 × 0,18; espada 0,55 × 3,5 × 0,18; machado 4,5 × 2,3 × 0,45. Dano, cadência, alcance e janelas continuam em KitDefinitions, sem rebalanceamento neste patch.
- Primeira pessoa usa o novo modelo e luvas, dedos e mangas geométricos nas posições das pegadas. Recuo visual existente preservado. Ainda não é um conjunto de braços com animações completas.
- Pulo pelo ControlRouter ganhou buffer de 0,18 s e aplicação em PreSimulation. O PlayerModule sobrescrevia a solicitação única de pulo depois de consumir o botão A.
- ButtonSelect deixou a lista de remapeamento: no teste do Studio ele não acionou o salto e disputa a seleção da interface do Roblox. Atalhos padrão permanecem A pulo, LS corrida, RS câmera, Y arma, LB trava e X recarga/interação.
- Oscilação leve ao andar/correr e inclinação ao deslocar lateralmente, com amortecimento no repouso, redução ao mirar e interrupção em menus. Novo ajuste **Oscilação da câmera**, 0–100, padrão 35; zero desliga o efeito. Usa a navegação, ícones e entrada numérica existentes.
- O efeito é cosmético: o cálculo de mira usa a câmera base, descontando a oscilação. Não modifica a simulação do personagem. O aumento existente de FOV durante corrida foi preservado.
- Saída para o hub limpa montagem, pose ativa, viewmodel, câmera de combate e oscilação.

## Testes executados no Studio

Controle **simulado** pelo conector; não substitui Xbox/PlayStation físico.

| Verificação | Resultado observado |
|---|---|
| Reprodução do defeito original, Arena, botão A | Elevação de 0 stud, mesmo com JumpHeight habilitado e personagem no chão. |
| Botão A após correção, Arena, kit Regular | Elevação máxima de aproximadamente 7,31 studs. |
| Remapeamento do salto para RB no treino CTF | Aproximadamente 7,31 studs; conflito trocou o atalho de ombro para A. Padrões restaurados após QA. |
| A durante menu de ajustes aberto | Menu continuou aberto; elevação de 0 stud. |
| Fuzil durante corrida, lateral e salto | Distância mão/pegada inferior a 0,001 stud na amostra de 9 s, para ambas as mãos. |
| SMG e sniper no avatar R15 do jogador | Ambas as mãos a menos de 0,001 stud das respectivas pegadas na conferência em repouso. |
| Machado, repouso e golpe | Contato das mãos em repouso; erro máximo da mão de apoio de aproximadamente 0,029 stud durante o golpe medido. |
| Machado contra alvo de treino | Um feedback de contato aproximadamente 0,30 s após início do ataque, com Attacking=true. Nenhum contato registrado durante a espera anterior. Não comprova dano PvP nem todas as colisões. |
| Bots vivos com SMG, fuzil e sniper | Pegadas conferidas após atualização das aparências, com erro inferior a 0,001 stud nas amostras finais. Corpos mortos foram excluídos da medição. |
| Primeira pessoa | Inspeção visual de fuzil e sniper; troca Y e alternância RS funcionaram. |
| Tiro e recarga na Arena | Três disparos; carregador retornou a 26 e reserva caiu de 130 para 127. |
| Corrida/lateral, oscilação padrão | Deslocamento máximo observado de 0,0272 stud e inclinação de aproximadamente 0,35°. FOV chegou a 76 a partir de 70; oscilação decaiu ao parar. |
| Oscilação zero | Deslocamento medido de 0 durante deslocamento lateral. |
| Entrada numérica do novo ajuste | 999 corrigido para 100; −20 para 0; 35 restaurou intensidade interna 0,35. |
| Retorno Arena → hub | Sem viewmodel/montagem residual; CombatCameraActive=false e oscilação zero. |
| Contratos existentes | 32 executados, 32 aprovados, zero falhas: catálogo, protocolo, provedor local, transporte simulado e votação. |
| Integridade das fontes | 69 fontes iguais entre Studio e disco; pacotes com 62 fontes de runtime cada, iguais às reais, exceto configuração de papel. |
| Preservação do cenário | 56 transformações/tamanhos de referência das bases iguais; terreno e legado preservados. |

## Place de Arena e pacotes

Consulta real de AssetService confirmou os dois Places no Universe **1404405130**:

- **4375993208** — Crossgrounds (BETA), projeto integrado atual.
- **84561729907420** — KAuZiiN_4k's Place: 10222026_1, criado pelo usuário e confirmado por ele como **Arena**.

ArenaPlaceId foi preenchido no projeto e nos novos pacotes. TeleportEnabled=false; HubPlaceId, CTFPlaceId e ApprovedUniverseId continuam vazios na configuração entregue. Não houve mudança de start place.

| Pacote atualizado | Bytes | SHA-256 |
|---|---:|---|
| [Hub](../artifacts/crossgrounds-hub-armas-camera-2026-10-22.rbxm) | 132209 | 0FE946500AB401213608BFB12D13C3D12575479E703ECBE78C53663333B7ED21 |
| [Arena, com os dois mapas](../artifacts/crossgrounds-arena-armas-camera-2026-10-22.rbxm) | 181861 | E622CA8369617877905B636DC652FCF5F281AF1044C527661AFF0C4C0E03B51B |

Pastas de origem no Studio: ServerStorage.Crossgrounds_hub_WeaponMotionBundle e Crossgrounds_arena_WeaponMotionBundle. Fontes anteriores ao patch preservadas em ServerStorage.WeaponGripMotionBaseline_1792690402; pacotes antigos mantidos.

Os pacotes são organizados por serviço para instalação manual. **Não foram instalados nem testados no novo Place remoto**: ele não estava aberto na conexão de Studio disponível. Abra esse Place para instalar o pacote Arena conforme [o guia de Places](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md). Um pacote não é um Place completo nem um instalador automático.

## Pendências e limites

- Conjunto de animações de equipar, mirar, atirar, recarregar e melee ainda incompleto. A pegada procedural não adiciona animações autorais nem resolve a mira vertical do corpo/arma em terceira pessoa.
- R6 possui aproximação de apoio no servidor, mas **não foi validado neste patch**. Avatares extremos podem exceder o alcance dos braços; o solver limita o alcance sem alongar os membros. Ainda falta uma matriz de avatares e acessórios.
- Modelos e braços de primeira pessoa continuam geométricos. Faltam acabamento artístico, animações de dedos, carregador móvel e sincronização completa de gesto/contato/som.
- Caminhamento e decisões dos bots não foram reescritos. Sua naturalidade, navegação específica de Travessia e transições de animação continuam pendentes.
- Sem novos sons neste patch; falta validar todas as permissões/volumes em versão publicada.
- Sem teste com múltiplos humanos, controle/celular físico, teclado virtual de console, persistência publicada, teleporte real ou avaliação de desempenho em aparelhos modestos.
- Pacotes dedicados atualizados, mas o ciclo publicado Hub → Arena → Hub depende de instalação, configuração de destinos/permissões e publicação manual autorizada.
- Persistem erros anteriores de GUIEditor e dos teleporters legados. A ferramenta também emitiu avisos de câmera e de StarterPlayerScripts durante testes; não foram atribuídos aos fontes novos. Não apareceram erros de WeaponRig, ArmPose ou WeaponPose nas verificações finais.
- ChatVersion foi apenas lido nesta etapa e já estava em TextChatService; não foi alterado pelo agente.

Referências de API consultadas: [AnimationConstraint e migração de juntas](https://create.roblox.com/docs/reference/engine/classes/AnimationConstraint), [IKControl](https://create.roblox.com/docs/reference/engine/classes/IKControl) e [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D). O protótipo com IKControl foi substituído pela solução procedural após não manter as mãos alinhadas durante a animação do avatar real.

**Estado final:** Studio em edição, combinedPrototype, entradas locais CTF/Arena mantidas. Nenhuma publicação ou remoção do legado.
