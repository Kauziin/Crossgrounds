# Blaster, AutoBlaster e correção de assistência

**Conferência após reabertura em 28/10/2026:** após o usuário fechar o Studio e abrir novamente o cartão Crossgrounds (ALPHA), a conexão retornou Place ID 4375993208, universo 1404405130 e PlaceVersion 343. As 19 fontes foram comparadas integralmente com work/src e todas coincidiram. O namespace ProjectileTest contém os dois viewmodels, as duas Tools e 153 descendentes (152 nós exportados mais a pasta Tools criada na importação); ambas as prévias e os IDs originais de malha/animação estão presentes. Não foi necessário recuperar ou reaplicar alterações. A operação de salvamento não havia sido executada ou observada pelo agente durante o merge anterior; esta reabertura agora confirma a persistência do conteúdo carregado pelo Studio. Isso não é uma verificação da versão em execução nos servidores públicos. Evidência: artifacts/blasters-2026-10-28/reopened-verification.json.

Implementação em 28/10/2026, testada em cópia e incorporada ao Crossgrounds principal em Edit. Foram importados 152 nós de modelos/rigs/efeitos do Projectile Test, duas prévias de loadout e 19 fontes de runtime. Backup das fontes anteriores: ServerStorage.Development.Revisions.BlastersPortBaseline_20261028. Nenhuma publicação realizada.

## Armas disponíveis

Blaster e AutoBlaster são opções adicionais de loadout em CTF e Arena. As escolhas da Arena seguem o mecanismo existente de equipamento no próximo nascimento. A troca entre espada e arma foi adaptada para reconhecer os dois novos IDs. As armas anteriores permanecem no catálogo.

| Arma | Disparo | Carregador | Reserva inicial | Recarga | Cadência máxima | Dano base |
| --- | --- | --- | --- | --- | --- | --- |
| Blaster | Semiautomático | 10 | 100 | 1 s | 600 RPM | 35 |
| AutoBlaster | Automático | 30 | 180 | 1,5 s | 600 RPM | 10 |

Os dois usam hitscan com raio de 0,4 stud e alcance de 1.000 studs, conforme a referência. Isso foi aplicado tanto na previsão como na consulta autoritativa. O histórico calcula a interseção com caixas arredondadas, evitando a tolerância extra que uma simples expansão das caixas produziria nos cantos. Obstáculos atuais continuam bloqueando o tiro. Munição, validação de estado, dano e rejeição de pedidos permanecem no servidor. Reservas finitas e o multiplicador de headshot do Crossgrounds são adaptações à experiência; o sample não mantinha reserva.

Foram portados os modelos, materiais, rigs FP e worldmodels, peças móveis, clipes Idle/Equip/Shoot/Reload de primeira pessoa e Idle/Shoot/Reload de terceira pessoa, variações de tiro e sons mecânicos por marcadores. O viewmodel permanece em ViewportFrame, baixo e lateral; a pele e a camisa clássica do jogador são exibidas por braços quadrados que seguem o rig animado. O recuo da câmera acumula velocidade angular e a dissipa com resposta 10; o pulso de FOV de 1 grau retorna com resposta 20. Não se impõe o FOV fixo de 70 do sample.

O laser conserva o template original e velocidade visual de 200 studs/s. O dano ocorre imediatamente. Impactos usam os templates da referência e a confirmação do servidor. Como ViewportFrame não renderiza partículas, o flash em FP usa uma peça curta visível; o worldmodel conserva as partículas. Áudio usa vozes independentes, integrado ao volume de SFX da partida; os marcadores de Shoot não duplicam o som de tiro predito/replicado.

O controlador original de rede/input do sample não foi copiado para as Tools, evitando um segundo sistema de consumo de munição e dano. Haptics do sample não foram transferidos nesta etapa.

## Aim Assist

- Treino CTF: PracticeDummy dentro de CTFLobby passa a ser elegível quando o personagem está AtLobby. Nesse estado, inimigos da rodada não são aceitos como alvos de treino. Vida e proteção continuam verificadas.
- Registro de alvos: referências fortes com remoção em DescendantRemoving substituem a tabela de chaves fracas; não depende mais da sobrevivência de wrappers Lua na coleta de lixo. A perda por coleta não foi reproduzida de forma forçada; a mudança elimina essa fragilidade e explicita o ciclo de vida.
- Toque: a intenção pode sobreviver a um frame sem evento enquanto o mesmo dedo continua ativo por até 100 ms. O delta de câmera é consumido uma única vez; soltura/inatividade zeram o acompanhamento.
- Frames lentos: intervalos até 150 ms não reiniciam continuamente a aquisição; a correção por frame é limitada a 50 ms. Travadas maiores continuam descartadas. O caso de 100 ms e o reset em 200 ms têm contrato específico.
- Retículo livre: o ramo de acompanhamento agora pode deslocar o ponto de mira. A política atual força lock com armas de fogo, portanto esse ramo não foi apresentado como uma nova opção de câmera ou como correção perceptível no modo atual.
- Diagnóstico: AimAssistInput e AimAssistEligibleTargets ajudam a distinguir ausência de input, elegibilidade e seleção. Mouse fica sem assistência; andar apenas com o stick esquerdo não gera rotação.

## Validação realizada

- 50 contratos aprovados: assistência, analógicos, intenção/toque, definições/fábrica das duas armas, geometria histórica e pipeline de disparo. Incluem cantos do Spherecast, estados de treino, eventos esparsos de toque, proteção, paredes, cadência/replay, hitboxes históricas e hitches.
- Controlador real de câmera em Play, com injeção apenas de entrada e cena de treino na cópia: acompanhamento alinhado somou aproximadamente −0,03191 rad; entrada contrária, repouso e alvo parado produziram zero. A seleção e os raycasts foram os reais.
- Toque simulado com amostras a cada dois frames: 42 frames observados, 25 com assistência, nove frames sem nova amostra mas com acompanhamento; contribuição máxima aproximada de 0,001135 rad e rotação zero após a expiração. Isso não equivale a aparelho touch físico.
- Mouse nativo: Blaster segurada consumiu uma bala por acionamento; disparos aceitos reduziram PracticeHealth em 35 cada, de 200 para 130 em dois tiros.
- Mouse nativo: AutoBlaster fez rajada de 30 para 23. R recarregou para 30 e reserva de 180 para 173. A recarga da Blaster também foi confirmada, de 9 para 10, reserva 100 para 99.
- Capturas mostraram os dois modelos e a recarga da AutoBlaster com carregador e mãos animados. Tracks FP/TP foram observadas em execução; a recarga TP da AutoBlaster de 1,6667 s foi ajustada aos 1,5 s de gameplay.
- Um erro de inicialização parcial de tracks TP foi encontrado e corrigido: o registro só fica ativo depois de carregar Idle, Shoot e Reload. A repetição de recarga das duas armas não apresentou erros dos novos controladores; persistiu erro do plugin externo GUIEditor.
- As injeções de QA, a cena artificial e a alteração de mínimo de jogadores usada para impedir respawns da rodada ficaram restritas à cópia. As fontes incorporadas ao principal não contêm esses hooks.

## Recuperação e limites

Artefatos em artifacts/blasters-2026-10-28: assets.json com os 152 nós e referências, import.luau, work/src, baseline, local-before-merge e changes.diff. O arquivo Crossgrounds-Blasters-Work.rbxl foi o ponto de partida da cópia; ele foi atualizado em memória com assets e fontes e não deve ser usado sozinho como instalador final. Os dados serializados e as fontes permitem reconstrução. O principal recebeu os assets reais no DataModel.

WeaponController no Studio já tinha uma prioridade de interação/recarga mais recente que o arquivo local ainda idêntico ao HEAD. Essa versão do Studio foi preservada no teste/merge e alinhada ao disco, além das alterações deste porte. As edições concorrentes de UI não foram sobrescritas.

Sem validação com gamepad físico, multitoque real, dois clientes humanos, R6, reconexão publicada ou benchmark de FPS. O áudio foi integrado por assets e marcadores; não houve audição direta para julgar timbre/mixagem. Os valores originais mudam o equilíbrio de CTF/Arena e ainda precisam de partidas humanas. Source assets permanecem referenciados por seus IDs originais; nenhuma nova animação ou malha foi publicada.
