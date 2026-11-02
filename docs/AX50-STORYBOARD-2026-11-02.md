# AX-50 — implementação de Arsenal #2a

## Referências examinadas

Lidos `instructions/Arsenal/#2a/AX50_instrucoes_Codex.md` e storyboard JPG. Localizado também o vídeo `Polar - AX-50 SNIPER SOUND EFFECT (CALL OF DUTY MODERN WARFARE).mkv`, 1920×1080, 30 FPS, duração 4,13 s. Extraídos e examinados quadros em 0,233 s e 1,30 s; metadados e SHA256 preservados em `artifacts/ax50-storyboard-2026-11-02/reference`. Áudio do vídeo não foi importado para o jogo. Não houve comparação contínua lado a lado nem extração matemática de rig; não declarar equivalência 1:1.

## Arquitetura reutilizada

- `WeaponRecoil` e o deslocamento recuperável de câmera já existente continuam responsáveis pelo impulso/amortecimento, separados da orientação manual.
- `AX50Motion` agora define o movimento aditivo da arma em três eixos e a timeline de mão/ferrolho. `FirstPersonRenderer` compõe os canais em seu viewport; não há segundo escritor da câmera.
- `WeaponPose` já usa AX50Motion.Bolt e recebe a nova temporização sem alterar outras armas.
- Novo helper `AX50CycleEffects` pertence ao renderizador, não cria conexões globais de input/render. Consome marcadores da mesma timeline, reproduz mecânica local e anima um estojo cosmético no WorldModel FP.
- `WeaponAudioLibrary.Banks.awp` fornece Seat/BoltBack/BoltForward, banco compartilhado provisório já existente, não gravações exclusivas da AX-50.

## Configuração

`AX50Motion.Config`, também exposta em `KitDefinitions.Weapons.ax_50.PresentationTimeline`, contém os tempos e amplitudes. Movimento lateral 0,20 stud, profundidade 0,16, vertical 0,035; pitch 2,2°, yaw −2,8°, roll −5,5°, reduzidos a 32% no ADS. Curva configurada: 0→0; 35ms→0,70; 100ms→1; 180ms→0,85; 300ms→0,45; 450ms→0,15; 580ms→0; pequeno overshoot em 640ms e neutro em 720ms. São parâmetros de partida, adicionais ao recuo amortecido existente e à intensidade efetiva dos acessórios.

| Marcador | Tempo relativo ao tiro | Efeito |
|---|---:|---|
| BoltReach | 0,55 s | mão começa a alcançar |
| BoltUnlock | 0,80 s | mecanismo levanta; som Seat |
| BoltPull | 0,98 s | extração mecânica; som BoltBack |
| CasingEject | 1,13 s | um estojo .50 BMG sai |
| BoltPushLock | 1,28 s | fechamento; som BoltForward |
| BoltReturn | 1,48 s | conclusão visual |

Pose completamente neutra em 1,50 s, compatível com o cooldown atual de 1,50 s, que foi preservado. Caso o cooldown efetivo seja menor, os tempos do ferrolho são comprimidos proporcionalmente; não são aumentados acima do tempo de referência. O próximo tiro inicia uma nova instância lógica da timeline, sem duas ações sobrepostas. Não há troca de carregador nessa ação.

O mecanismo se move no referencial local existente do Bolt; braço direito deixa a empunhadura, alcança e retorna. Os braços quadrados com skin do jogador foram preservados. Para equivalência fina de pulso, dedos e contato com a alavanca, pode ser necessário um rig/poses manuais no Animation Editor; a implementação procedural atual não afirma reproduzir esses detalhes orgânicos.

## Estojo e interrupções

Reutilizado o MeshPart real `.50 BMG Casing` em `ServerStorage.ImportedArsenalOriginals["Modern Warfare Reloaded - Casings & Bullets"]["Spent Casings"]`. Cópia saneada em `ReplicatedStorage.Crossgrounds.CasingTemplates.AX50`, com origem e publicationBlocked preservados. Instância FP não colide nem participa de consultas de tiro e é removida em 1,1 s.

Sons e estojo disparam pelo cruzamento de markers, não por waits dispersos. Recarga cancela o ciclo de efeitos; tiro rejeitado pelo servidor cancela sons/ejeção e movimento do ferrolho. Troca/destruição do viewmodel limpa vozes e casings; morte passa pelo mesmo descarte. Eventos antigos não são reproduzidos em lote após um hiato de render maior que 200 ms. Entrar/sair de ADS reduz o deslocamento sem reiniciar os marcadores.

## Direção do tiro e testes

WeaponController captura alvo, origem e direção da câmera e origem do cano antes de PredictShot/Kick. O servidor, dano, munição, velocidade de projétil e cooldown não foram alterados.

- Três contratos aprovados: ferrolho neutro durante a pancada inicial e após o ciclo, ejeção única em 30/60/120 FPS e deslocamento hipfire maior que ADS com retorno completo.
- Em cliente Play, efeitos produziram um estojo na extração; repetir a amostra não duplicou a ejeção; cancelar por recarga limpou vozes/estojo e não retomou a timeline.
- Prévia em Play amostrada em 0/0,10/0,40/1,08 s: conferidos deslocamento lateral e alcance da mão ao mecanismo. Prévia não reproduz toda a mola dinâmica ou o feedback da câmera.
- Primeiro smoke com câmera ainda distante após respawn foi corretamente rejeitado por `camera`, sem consumir munição. Repetição com câmera alinhada foi aceita pelo servidor: Ammo 5→4.
- Não foram testados controle físico, multiplayer humano, escuta comparativa, toda combinação de acessórios, nem todos os cenários de interrupção em movimento contínuo. Ajuste visual fino da mão/pivô ainda pendente.

Principal em Edit. Backup `ServerStorage.Development.Revisions.AX50StoryboardBaseline_20261102` e arquivos em `artifacts/ax50-storyboard-2026-11-02/before`. Sem publicação. Bibliotecas locais de som/estojo mantêm suas limitações de autorização de publicação.
