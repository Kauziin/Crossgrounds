# Plano — integração do Aim Assist do Projectile Test

**Implementação posterior em 27/10/2026:** assistência e perfis gráficos incorporados ao principal. Este documento mantém o planejamento histórico; resultados e limitações estão em [PORTE-PROJECTILE-TEST-2026-10-27.md](PORTE-PROJECTILE-TEST-2026-10-27.md).

**27/10/2026 — somente planejamento.** Nenhuma fonte, configuração ou comportamento de jogo foi alterado nesta etapa.

## Objetivo

Usar Projectile Test como referência de arquitetura e sensação de mira assistida para controles e toque, integrando aspectos aproveitáveis sem substituir o sistema atual já testado. A intenção é ajudar a manter a mira sobre um alvo que o jogador já escolheu, reduzir a velocidade perto do corpo e evitar atração sem olhar ativo.

## Evidência da referência

Projectile Test resolve tiros como hitscan volumétrico (Spherecast); o laser visível é cosmético. A assistência afeta a câmera/entrada antes do disparo, sem determinar dano nem redirecionar a bala.

O controlador organiza três etapas: **Friction**, que reduz a velocidade da mira perto de alvo elegível; **Tracking**, que acompanha parte do deslocamento aparente de um alvo já selecionado; e **Centering**, que corrige o erro em direção ao centro do alvo.

A leitura estática encontrou defeitos que não devem ser reproduzidos:

- A força de Centering é lida do atributo de Tracking, apesar de existir atributo próprio; o valor configurado para desligar Centering é ignorado.
- O tempo de inatividade do toque é calculado subtraindo o relógio atual do instante anterior. Depois do primeiro gesto, o resultado continua negativo e o toque pode permanecer elegível indefinidamente.
- Qualquer stick acima do limiar torna o gamepad elegível, inclusive movimento apenas pelo analógico esquerdo. O Crossgrounds já tem uma regra mais restritiva.

## Estado atual do Crossgrounds

O projeto separa cálculo geométrico e aquisição de alvo (ReplicatedStorage.Crossgrounds.AimAssist), seleção/visibilidade e elegibilidade (StarterPlayerScripts.TargetingAssist), entrada/câmera (CombatPresentation) e filtragem do analógico (AnalogFilter).

Já existem desaceleração, acompanhamento parcial do movimento real do alvo, alinhamento à intenção do analógico direito ou gesto de mira, saída quando o jogador olha contra o movimento, aquisição gradual, limites de rotação, fades por distância, verificações de obstáculos/proteção/equipe, configurações independentes e limpeza ao trocar modo/dispositivo. Mouse fica sem assistência. Testes de contrato e integração estão registrados em [AIM-ASSIST-COMPONENTES.md](AIM-ASSIST-COMPONENTES.md).

A integração prevista é uma **revisão comparativa e refinamento**, não uma substituição do sistema existente pelo sample.

## Plano de implementação

### 1. Preservar os contratos de mira e disparo

- Manter assistência somente na transformação local da câmera/entrada.
- Preservar origem e direção de tiro, dispersão, raycast autoritativo, dano e validações. Assistência não declara acerto, amplia hitboxes ou escolhe headshots.
- Preservar ViewportFrame, seleção pelo ponto de mira e separação entre CTF, Arena, treino, bots, aliados, mortos e proteção.
- Manter mouse/teclado sem assistência, salvo decisão futura explícita.

### 2. Mapear os componentes à arquitetura atual

- **Friction:** manter desaceleração independente já exposta em configurações. Comparar curvas e fades do sample com os atuais; só ajustar após medições lado a lado.
- **Tracking:** manter acompanhamento do deslocamento real do alvo, condicionado a input de olhar alinhado. Preservar rotação zero em repouso, com alvo parado ou input contrário.
- **Centering:** não importar a centralização do Projectile Test. Ela atrai para o centro e a referência contém o erro de atributo descrito acima. Se houver necessidade futura, fazer experimento opcional, desligado por padrão, independente de Tracking e sem preferência por cabeça; antes definir limites, telemetria e critérios de conforto.
- Reaproveitar a ordem conceitual (desaceleração, acompanhamento, eventual centralização) sem acoplar cálculos ou copiar alcance, raio, força ou cadência da referência.

### 3. Fechar intenção de mira e falso stick drift

- No gamepad, ler o estado físico atual do **analógico direito**, aplicar zona morta radial configurada e histerese, e exigir magnitude útil para Tracking. Analógico esquerdo, ruído de PreferredInput e direções digitais sintetizadas não contam como intenção de mira.
- No toque, associar o gesto ao dedo controlador da mira, consumir seu delta uma vez por frame e expirar a intenção usando tempo decorrido (agora menos instante anterior). Dedo de disparo ou analógico virtual de movimento não ativa Tracking.
- Reusar o limiar já aplicado pelo AnalogFilter; evitar uma segunda zona morta divergente dentro de AimAssist.
- Limpar alvo, velocidade suavizada e contribuição ao abrir menu, perder foco, trocar dispositivo/modo, sair do combate, morrer/respawnar ou desconectar controle. Ruído sem movimento deliberado resulta em rotação zero.
- Encerrar contribuição imediatamente quando o jogador soltar ou olhar na direção contrária.

### 4. Preservar aquisição justa e previsível

- Revalidar equipe, vida, modo, proteção, alcance, janela angular e visibilidade até o alvo e a âncora escolhida pelo jogador.
- Manter aquisição suave, troca de alvo sem salto, descarte de hitches/teleportes e limites de rotação por eixo.
- Não copiar o Spherecast de raio 0,4 do disparo: ele é tolerância balística, não Aim Assist.
- Exigir mira inicial dentro da região assistida; Tracking acompanha movimento do alvo, sem perseguir o centro do corpo.

### 5. Validar antes de calibrar

- Executar contratos existentes de AimAssist e AnalogFilter, ampliando-os para os contratos novos que forem implementados.
- Em Play, repetir repouso, pequeno drift, input só no stick esquerdo, intenção curta no direito, soltura, direção contrária, perda de visibilidade, troca de alvo/dispositivo, menus, respawn e hitch.
- Comparar câmera sem assistência, com Friction apenas e com Tracking apenas usando o mesmo ponto inicial, alvo e input.
- Avaliar manualmente em controle físico e aparelho touch: conforto, latência percebida, tracking cruzado, distâncias curta/longa e hip-fire/ADS.
- Não declarar pronto para publicação com simulador, mocks ou contratos apenas. Registrar dispositivos, build, mapa, distâncias e limites observados.

### 6. Calibrar com evidência

- Preservar inicialmente configurações atuais: intensidade geral e intensidades independentes de desaceleração/acompanhamento.
- Usar valores do Projectile Test como referência comparativa, sem transportar atributos de arma.
- Ajustar em passos pequenos e registrar medidas antes/depois para gamepad e touch.
- Reavaliar padrão de 45% e curvas por distância em hardware; não inferir equilíbrio competitivo com mouse a partir de simulação.

## Critérios de aceite

- Drift, ruído de troca de dispositivo e movimento apenas no stick esquerdo não causam rotação assistida.
- Tracking só age com intenção ativa, alinhada e dentro dos limites; zera em input contrário, soltura, obstáculo ou inelegibilidade.
- Friction não altera direção autoritativa do tiro nem afeta mouse/teclado.
- Toque usa somente o dedo de mira, expira no tempo correto e não confunde movimento/disparo.
- Sem snap, preferência por headshot, hitbox ampliada ou mudança no cálculo autoritativo.
- Confortável em controle físico e touch real, além de passar os contratos automatizados.

## Pendências

O estudo da referência não incluiu controle físico ou multitoque real. Os defeitos do sample foram encontrados por leitura estática. O Crossgrounds tem testes de integração e configuração registrados, mas esta etapa não os executou novamente e não alterou comportamento. Equilíbrio e conforto requerem sessões em hardware real.

## Direção gráfica: modos de qualidade

A captura em Edit mostrou uma identidade de arena sci-fi clara: arquitetura branca com acentos amarelos, formas grandes e legíveis, vegetação e rochas nas bordas, céu azul e contraste de luz/sombra. O Lighting aberto apresenta Atmosphere, sombras globais e efeitos ativos de Bloom, SunRays, Depth of Field e ColorCorrection. A tecnologia de renderização não pôde ser lida pela ferramenta, então não a registro como confirmada.

Esses elementos servem como referência visual, não como pacote de efeitos a copiar por inteiro. A implementação futura deve oferecer perfis **Desempenho**, **Equilibrado (padrão)**, **Alto** e **Visual (opt-in)**: o mais bonito é escolha do jogador, enquanto Equilibrado preserva legibilidade com custo moderado. Perfis devem afetar apenas recursos visuais do Crossgrounds e não sobrescrever globalmente a qualidade escolhida no Roblox.

Bloom, SunRays, Depth of Field e ColorCorrection serão avaliados individualmente. Profundidade de campo não pode desfocar o combate; todos os perfis devem preservar leitura de inimigos, mira, objetivos e efeitos de acerto. Medir frame time e memória na mesma cena e validar em desktop, console e celular antes de aprovar o perfil padrão. Não foi feita comparação A/B, medição de FPS/memória ou avaliação em hardware; nenhum modo ou parâmetro foi implementado ou aprovado nesta etapa.
