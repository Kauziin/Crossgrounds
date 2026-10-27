# Estudo da experiência Projectile Test

Inspeção de 27/10/2026 na experiência aberta no Roblox Studio, Place ID **106713083062312**. Foram lidos os controladores e examinados modelos, atributos, animações e áudio. Também foi realizado Play com as duas armas, disparo, troca e recarga. O Play foi encerrado, retornando ao modo Edit. Nenhuma fonte ou configuração persistente da experiência foi alterada; nenhuma mudança deste estudo foi aplicada ao Crossgrounds.

## Tipo de disparo

**É hitscan com volume, usando Spherecast.** O nome da experiência não corresponde a um sistema de projéteis físicos com tempo de viagem para causar dano.

- `ReplicatedStorage.Blaster.Scripts.BlasterController:86–130`: calcula as direções e o resultado do disparo imediatamente no cliente, apresenta animação/recuo/hitmarker e envia origem, timestamp e alvos relatados ao servidor.
- `ReplicatedStorage.Blaster.Utility.castRays:53–69`: consulta `Workspace:Spherecast` no alcance completo; raio das duas armas = **0,4 stud**. O comentário da implementação declara tolerância a tiros que passam perto do alvo.
- `ServerScriptService.Blaster.Scripts.Blaster:23–105`: recalcula as direções, consulta o cenário, valida os alvos e aplica o dano durante o processamento do disparo.
- `ReplicatedStorage.Blaster.Effects.laserBeamEffect:9–23`: o laser é cosmético, com tween do attachment e velocidade visual de **200 studs/s**. O efeito não decide quando o dano ocorre.

Assim, a experiência permite estudar comportamento e apresentação de hitscan. O raio de Spherecast é uma regra de precisão/tolerância própria, e não deve ser confundido com assistência que apenas altera a entrada da câmera.

## Armas configuradas

| Atributo | AutoBlaster | Blaster |
| --- | --- | --- |
| Modo | Automático | Semiautomático |
| Carregador | 30 | 10 |
| Dano por disparo | 10 | 35 |
| Cadência configurada | 600 RPM | Limite de 600 RPM, um tiro por acionamento |
| Recarga | 1,5 s | 1 s |
| Alcance | 1.000 studs | 1.000 studs |
| Dispersão | 2° | 2° |
| Raio do Spherecast | 0,4 stud | 0,4 stud |
| Intervalo de recuo configurado (X/Y) | (−2, 5) a (2, 7) | (0, 15) a (5, 20) |

Os valores de recuo são sorteados por tiro e convertidos para radianos pelo controlador. A Blaster possui impulso configurado maior que a AutoBlaster; a impressão subjetiva de peso também depende dos clipes e do áudio.

Em Play, uma rajada da AutoBlaster reduziu a munição de **30 para 23**, e R a restaurou a **30**. Segurar o disparo da Blaster por aproximadamente 0,6 s consumiu apenas **uma bala, 10 → 9**; R restaurou **10**.

## Enquadramento, braços e animações

O `ViewModelController` usa um rig próprio, separado da arma visível pelos outros jogadores. O modelo é colocado no Workspace, seguindo a câmera; não é renderizado em ViewportFrame.

O offset comum é `CFrame.new(0.9, -1.3, -1.3)`. A medição em Play confirmou esses valores relativos à câmera. Nas capturas de repouso, as duas armas ficaram abaixo do retículo e deslocadas à direita, mantendo o centro da visão livre. A geometria e o pivô de cada arma também contribuem para o enquadramento, portanto o offset isolado não determina a mesma ocupação de tela em outro modelo.

Os braços são Parts retangulares de aproximadamente **0,6 × 0,6 × 4 studs**. Cada viewmodel tem os clipes **Idle, Equip, Shoot e Reload**. O corpo do personagem tem clipes próprios de Idle, Shoot e Reload. Carregador e, na AutoBlaster, ChargingHandle são partes separadas no rig.

Referências principais:

- `ReplicatedStorage.Blaster.Constants:48–59`: offset, bobbing e resposta de recuo.
- `ReplicatedStorage.Blaster.Scripts.ViewModelController:64–84`: bobbing por velocidade horizontal, com amplitude máxima configurada de 0,05 stud e transição suave.
- `ViewModelController:133–163`: tiro sem fade de entrada, emissão imediata de flash, recarga com velocidade ajustada à duração de gameplay e equipar junto da pose Idle.
- `CharacterAnimationController:17–46`: representação do personagem e recarga ajustada à mesma duração.

Na recarga observada, a arma sobe/inclina para executar o gesto e retorna ao enquadramento de repouso. Não foi encontrado ADS próprio, clipe de mira ou mudança de enquadramento por botão direito. Em Play, segurar o botão direito manteve **FOV 70** e o mesmo offset do viewmodel.

O recuo tem duas fontes: o clipe da arma e o controlador de câmera. `CameraRecoiler` acumula impulso angular, dissipa-o com fator de resposta 10 e acrescenta um pulso de **+1° de FOV**, retornando ao FOV base 70 com fator 20. Portanto, o sample altera a câmera, enquanto o Crossgrounds anteriormente mantinha seu recuo principalmente visual na arma.

## Sons e sincronização

Os efeitos usam **AudioPlayer e Wire**, com barramentos separados de mundo e UI e processamento de compressor/equalizador/fader. Cada reprodução clona um AudioPlayer, conecta-o ao destino, toca e descarta a instância ao terminar. Isso permite sobreposição de tiros sem reiniciar uma única instância.

Cada arma contém **três amostras de disparo**, escolhidas aleatoriamente. Volume configurado dos disparos e dos sons mecânicos = **0,5**; equipar = **0,25**. Na Blaster, as três amostras de tiro estavam carregadas (`IsReady=true`) e tinham durações de aproximadamente **1,07–1,20 s**.

O ponto mais útil da implementação é a sincronização com marcadores dos clipes:

| Arma / clipe | Marcador | Tempo no clipe original |
| --- | --- | --- |
| Ambas / Shoot | `RandomSound: Shoot` | 0 s |
| Ambas / Equip | `Sound: Equip` | 0 s |
| Blaster / Reload | `Sound: MagOut` | 0,167 s |
| Blaster / Reload | `Sound: MagIn` | 0,833 s |
| AutoBlaster / Reload | `Sound: MagOut` | 0,100 s |
| AutoBlaster / Reload | `Sound: MagIn` | 0,733 s |
| AutoBlaster / Reload | `Sound: Charger` | 1,100 s |

Os marcadores foram confirmados por leitura dos KeyframeSequences publicados, não inferidos apenas dos nomes. Os tempos acima são do clipe original; a reprodução é escalada pela duração configurada da recarga.

O áudio local da arma é ligado ao barramento World. Para disparos de outros jogadores, `ShotReplication` usa o AudioEmitter no Handle e também reproduz o flash e o laser. As animações do corpo não acionam novamente os sons, evitando a duplicação local do áudio do viewmodel.

Os impactos têm templates diferentes para personagem e cenário, com partículas de faísca/círculo. Não foi encontrado, nesses efeitos, um catálogo de impacto por material.

**Limite de áudio:** foram analisados arquivos referenciados, disponibilidade, durações, volumes, roteamento e eventos. Não houve audição direta para avaliar timbre, conforto ou mixagem subjetiva. `IsReady` não equivale a uma avaliação auditiva.

## Cuidados com o Aim Assist da referência

Como o sistema é hitscan, também foi inspecionado o comportamento de assistência. Há três componentes: Friction, Tracking e Centering, aplicados nessa ordem, com seleção por alcance/FOV e checagem de visibilidade.

Foram encontrados dois problemas concretos de código:

1. **Atributo de centralização incorreto.** `BlasterController:235` atribui `self.centering` lendo `AIM_ASSIST_TRACKING_STRENGTH_ATTRIBUTE`, embora exista `AIM_ASSIST_CENTERING_STRENGTH_ATTRIBUTE`. Nas armas examinadas, tracking é 0,5 e centering é 0. O código passa 0,5 ao método Centering, ignorando o zero configurado.
2. **Janela de inatividade do toque invertida.** `AimAssistController:64` verifica `lastActiveTouch - os.clock() < 0.1`. Depois de um gesto, esse valor fica negativo e continua satisfazendo a condição, mesmo após a inatividade pretendida. O teste de tempo decorrido deveria subtrair o instante anterior do atual.

Além disso, o controle é considerado elegível quando **qualquer um dos dois analógicos** ultrapassa 0,1. Isso pode habilitar tracking/centering durante movimento apenas pelo analógico esquerdo, comportamento diferente da regra atual do Crossgrounds. São observações estáticas verificadas nas fontes; não foram reproduzidas com controle físico ou multitoque real.

## Referência para o Crossgrounds

Os elementos mais aproveitáveis são a composição baixa e lateral, o carregador/ferrolho como partes animáveis, clipes FP e TP distintos com duração compartilhada e os sons nos contatos reais da animação. A identidade do avatar deve seguir a preferência já definida pelo criador: skin do jogador com braços quadrados.

O pipeline atual de ViewportFrame do Crossgrounds pode receber esse tipo de enquadramento/animação sem exigir a troca para um viewmodel no Workspace. O raio tolerante do Spherecast, os valores de dano/cadência, a centralização automática e o recuo de câmera são decisões de gameplay separadas; este estudo não os transferiu para o projeto.
