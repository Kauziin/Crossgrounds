# AX-50 — Referência visual e instruções para o Codex (Crossgrounds)

**Referência analisada:** vídeo fornecido no ChatGPT, `78144.mkv` (1920 × 1080, 30 FPS, 4,13 s).  
**Material visual complementar:** `AX50_storyboard_recuo_ferrolho.jpg`.  
**Objetivo:** recriar visualmente, o mais fiel possível à referência, o comportamento em PRIMEIRA PESSOA ao atirar e ciclar o ferrolho da AX-50 no Roblox. Não usar animação de troca de carregador como se fosse ciclagem do ferrolho.

> **Grau de certeza:** as marcações em segundos são observações aproximadas dos quadros disponíveis, com resolução temporal de ~33,3 ms. Valores em studs, graus e curvas de animação abaixo são **pontos de partida para calibração**, não transformações 3D extraídas matematicamente do jogo original. Para cópia visual rigorosa, comparar lado a lado o vídeo e a implementação; apenas um vídeo 2D não revela as posições de ossos, pivôs ou parâmetros internos da câmera do jogo de origem.

## 1. Análise visual do vídeo

| Tempo absoluto no vídeo | O que aparece | Conduta na implementação |
|---|---|---|
| 0,000–0,133 s | Arma em posição de repouso / preparação | Guardar pose inicial, câmera base e posição da luneta. |
| ~0,133–0,200 s | Disparo e impulso muito rápido; arma sai bruscamente da pose; câmera também sofre impacto/rotação | Iniciar imediatamente evento de tiro; impulso independente para viewmodel e para câmera. Evitar tween lento e linear. |
| ~0,200–0,367 s | Fase mais evidente de recuo: arma vai para direita da tela, aparenta se aproximar e girar; oscilações fortes | Combinar recuo translacional local, rotação e oscilação curta; não aplicar só `Camera.CFrame *= CFrame.Angles(...)`. |
| ~0,367–0,667 s | Retorno amortecido da arma e da orientação da câmera | Recuperar pose progressivamente com curva de amortecimento e pequeno overshoot, sem retorno instantâneo. |
| ~0,700–0,900 s | A mão direita começa a alcançar o mecanismo | Iniciar ação de ferrolho, somente depois da pancada principal do tiro. |
| ~0,900–1,167 s | Mão cobre região lateral/ferrolho; manipulação de abertura | Animar braço/mão e componente móvel com pivôs coerentes. |
| ~1,167–1,400 s | Extração; estojo metálico visível saindo do mecanismo por volta de 1,23–1,35 s | Sincronizar ejeção visual com marco de extração no AnimationTrack, sem ejetar no instante do tiro. |
| ~1,367–1,567 s | Mão retorna e mecanismo é concluído | Empurrar/travar ferrolho e devolver mão à empunhadura. |
| ~1,567–1,767 s | Arma estabiliza | Recuperar estado pronto para novo tiro conforme regras da arma. |
| 1,767–4,128 s | Sem outra ação grande visível | Não inferir animações adicionais daqui. |

**Importante:** este clipe NÃO demonstra uma recarga completa com retirada/inserção de carregador. Demonstra tiro + ciclagem do ferrolho e ejeção de estojo.

## 2. Orientações de implementação

1. Antes de alterar scripts, **inspecionar a implementação atual de armas, viewmodel, câmera, animações e sons** no repositório local. Aproveitar a arquitetura existente e evitar duplicar controladores ou criar efeitos que briguem pelo `Camera.CFrame`. Não alterar armas não relacionadas.
2. Separar o comportamento em canais sobrepostos:
   - `WeaponRecoil`: transformações ADITIVAS do viewmodel (translação em X/Y/Z local e rotação nos três eixos). Esse canal cria o giro/deslocamento lateral visível da AX-50.
   - `CameraRecoil`: pequeno impulso na orientação da câmera, com retorno amortecido e sem deslocar permanentemente a direção de tiro.
   - `BoltCycle`: animação da mão e do mecanismo da AX-50 (Animator/Motor6D ou solução já usada no projeto), com eventos/markers nomeados para áudio, estojo e fechamento.
   - `WeaponSFX`: disparo e camadas mecânicas disparadas de eventos explícitos da timeline, não de `wait()` espalhado em múltiplos scripts.
3. Em tiro, **calcular a direção/projétil no mesmo estado de mira do momento do clique**. O recuo visual deve ocorrer depois de capturar essa direção para evitar problema conhecido de o disparo não coincidir com a mira exibida. Não alterar hit detection sem necessidade.
4. Para a animação vista em câmera solta/hipfire, dar mais peso ao viewmodel; em ADS aplicar perfil próprio, mantendo a luneta e o retículo coerentes. O vídeo só mostra a apresentação SEM mirar pela luneta.
5. Não ajustar recuo multiplicando diretamente frames; usar `dt` ou curvas de tempo absoluto, sem depender de FPS. A referência tem 30 FPS, mas o movimento deve interpolar bem a 60+ FPS.
6. Aplicar deslocamento/rotação a partir de **pivôs consistentes**. O mecanismo de ferrolho deve mover-se em relação à arma, não apenas em relação à câmera. Se a arma for rigada, animar o mecanismo no próprio rig com `Motor6D` / ossos adequados.
7. Tratar interrupções: trocar arma, morrer, equipar/desquipar, entrar/sair de ADS. Evitar estados presos no meio da ciclagem. Permitir próximo disparo apenas quando o estado da arma permitir; não deixar clique iniciar duas operações de ferrolho simultaneamente.

## 3. Curva de recuo sugerida — relativa ao disparo

Abaixo, a **intensidade normalizada** é uma sugestão para prototipagem, não medida absoluta. Use os momentos do storyboard para calibrar a composição. Mantenha os dois sinais independentes.

| t a partir do disparo | Peso de deslocamento do viewmodel | Peso do impulso na câmera | Descrição |
|---|---:|---:|---|
| 0 ms | 0,00 | 0,00 | Disparo; inicialização dos efeitos. |
| +35 ms | 0,70 | 1,00 | Pancada rápida; início do deslocamento/giro. |
| +100 ms | 1,00 | 0,85 | Arma perto da excursão máxima na direita. |
| +180 ms | 0,85 | 0,45 | Instabilidade/giro perceptíveis. |
| +300 ms | 0,45 | 0,20 | Retorno e pequeno balanço. |
| +450 ms | 0,15 | 0,06 | Estabilização gradual. |
| +550–600 ms | 0,00 | 0,00 | Preparada para a ação de ferrolho. |

Para o viewmodel, **não** usar apenas um `CFrame.new(0, 0, z)`. Misturar movimento à direita + aproximação da arma ao observador + rotação/roll + componente vertical oscilante. Como valores iniciais para EXPERIMENTAR (não afirmar que são 1:1): desvio lateral máximo de ~0,12–0,25 studs; movimento em profundidade de ~0,10–0,20 studs; roll ~3–7°, pitch e yaw menores, ajustando ao rig, distância focal e escala do modelo. Exposição dos valores no config permite comparar rapidamente o resultado com a referência. O deslocamento aparente na imagem é influenciado por câmera, perspectiva e rig, não pode ser convertido linearmente em studs.

## 4. Animação de ferrolho e marcadores

Implementar um ciclo de duração visual aproximada ~0,9–1,0 s iniciado por volta de `shotTime + 0,55 s`:

- `BoltReach` (`shot + 0,55–0,80 s`): mão dominante se solta da empunhadura e alcança a alavanca.
- `BoltUnlock` (`shot + 0,75–0,95 s`): destrava/levanta o ferrolho.
- `BoltPull` (`shot + 0,93–1,15 s`): puxa o mecanismo; incluir microbalanço da arma com reação mecânica.
- `CasingEject` (`shot + 1,08–1,20 s`, alinhado com **1,23–1,35 s absolutos no vídeo**): instanciar estojo visual com velocidade e rotação, ou utilizar sistema existente. **O evento deve corresponder à extração**, não ao disparo.
- `BoltPushLock` (`shot + 1,22–1,40 s`): empurra e trava.
- `BoltReturn` (`shot + 1,30–1,55 s`): mão volta à empunhadura; estado retorna ao pronto.

**Atenção:** `shotTime` é por volta de 0,13–0,17 s **do vídeo**. As expressões entre parênteses são uma proposta de temporização relativa; afinar cada marker quadro a quadro. Evitar chamar uma "recarga completa" nesse contexto.

## 5. Áudio — pontos de referência

O arquivo possui uma trilha de áudio Opus misturada ao vídeo; os picos de amplitude detectados são **indicadores de eventos**, não provas da identidade de cada som. Não se trata de arquivos separados de tiro/ferrolho.

- ~0,14–0,50 s: grande transiente do disparo, com ataque forte e cauda prolongada. O sinal segue reverberando/decrescendo depois desse intervalo.
- ~0,95–1,05 s: acento mecânico compatível temporalmente com contato e manipulação do ferrolho.
- ~1,20–1,30 s: segundo grupo de acentos, compatível com extração/ejeção.
- ~1,50–1,56 s: acento metálico próximo à conclusão da manipulação.
- ~1,70–1,75 s: último transiente audível; confirmar no vídeo se pertence ao acabamento da animação ou ao ambiente.

No Crossgrounds, usar **áudios próprios ou devidamente licenciados**, distribuídos em camadas, com eventos vinculados aos markers. O vídeo do Call of Duty é referência audiovisual, não licença para republicar seus arquivos de som.

## 6. Critérios de aceite

- [ ] No frame do tiro, a direção da bala coincide com o retículo no instante da entrada, antes do kick visual.
- [ ] Há pancada rápida com deslocamento para a direita, componente de giro e recuperação amortecida da arma.
- [ ] Câmera e arma não são exatamente o mesmo movimento; ficam sincronizadas sem "brigar" pelo CFrame.
- [ ] Ciclo de ferrolho começa após o recuo forte, com mão, mecanismo e estojo sincronizados.
- [ ] Estojo aparece próximo ao movimento de extração (não no início do disparo).
- [ ] Ao final, braços, ferrolho e câmera retornam completamente à pose inicial.
- [ ] Funciona em FPS variável e não quebra ADS, troca de armas, hit registration nem outras armas.
- [ ] Valores de timing e amplitude estão configuráveis por arma para ajustes lado a lado.

## 7. Entrega esperada do Codex

1. Localizar os módulos atuais relevantes antes de editar e listar o que pretende reutilizar.
2. Implementar os canais de recuo/ferrolho na AX-50, mantendo os padrões atuais do repositório.
3. Documentar as constantes de movimento e timestamps no config da arma.
4. Informar quais keyframes/poses exigem edição manual no Roblox Animation Editor, caso não seja possível criá-los de forma confiável só por script.
5. Relatar arquivos alterados e oferecer um checklist de teste no Studio; não declarar resultado 1:1 sem comparação visual real com o arquivo de origem.

**Observação operacional:** o Codex só verá o vídeo original e o storyboard se você disponibilizar esses arquivos no filesystem do PC/workspace que ele tem permissão para ler. Se receber apenas este Markdown, ainda poderá implementar a aproximação descrita, mas não validar visualmente cada frame do vídeo original.
