# Armas, movimento e assistência de mira

Implementação de 27/10/2026, desenvolvida e testada em uma cópia local. O merge de **20 fontes de runtime** foi aplicado ao Crossgrounds principal em Edit e salvo nos caminhos correspondentes de `src/`. A aplicação verificou as fontes esperadas antes de escrever e terminou sem divergências. Nenhuma publicação foi realizada.

## Armas e animações

As novas curvas são procedurais e editáveis em `WeaponActionMotion` e `LocomotionMotion`. Não são clipes artísticos publicados e não foram inventados IDs de animação.

| Ação | Primeira pessoa | Terceira pessoa |
| --- | --- | --- |
| Equipar | Entrada amortecida da arma e apoio | Entrada do mount e mãos por IK |
| Mirar | Transição suave de posição preparada | Inclinação vertical da arma/mãos, enviada como estado limitado a cerca de 10 Hz |
| Disparar | Recuo existente e movimento do slide | Resposta breve do mount, a partir do evento visual de disparo |
| Recarregar | Curvas por mecanismo já existentes, com braços segmentados e apoio móvel | Inclinação da arma e deslocamento da mão de apoio sincronizados aos atributos de recarga |
| Melee | Preparação, contato e recuperação usam `Windup` e `ActiveTime` da arma | Golpe autoritativo existente preservado |
| Andar lateralmente/para trás | Inclinação contextual discreta | Ajustes aditivos de quadril, pés e tronco em R15 |
| Pular/cair/pousar | Resposta da arma baseada no estado físico | Poses de subida/queda e absorção de pouso em R15 |
| Slide | Reposicionamento de arma e altura visual | Pose baixa com pernas assimétricas em R15 |

O ADS é uma posição preparada: alinhamento óptico final das miras/lunetas ainda exige trabalho específico nos modelos. Não há nova sequência artística de guardar/inspecionar, dedos animados ou novos modelos importados. Os mecanismos de recarga completos em terceira pessoa continuam uma etapa de acabamento; este patch anima o mount e o apoio.

## Slide

Disponível em CTF e Arena durante corrida no chão, com velocidade física mínima de 12 studs/s. A autoridade está em `CombatMovementService`; a apresentação não decide a velocidade.

- Duração de protótipo: 0,72 s; intervalo mínimo entre inícios: 1,25 s.
- Velocidade inicial limitada à corrida do kit, sem impulso extra; desaceleração até 7 studs/s.
- Termina ao encontrar obstáculo, sair do chão, pular, trocar de arma, morrer ou mudar de contexto. O cliente solicita cancelamento ao abrir um contexto bloqueado.
- Restaura velocidade e ownership automático, removendo a restrição física criada pela ação.
- Não reduz a colisão do avatar nem permite atravessar passagens baixas. A pose não substitui um sistema físico de agachamento.

Teclado: **C**. Controle: **B/Círculo durante a corrida**; fora dela, o mesmo botão preserva a ação de voltar ao lobby. O teclado L também fica indisponível enquanto essa condição contextual de corrida está ativa. Os controles continuam remapeáveis. No toque há um botão de slide, com ícone vetorial integrado ao HUD mobile atual.

## Assistência e possível drift falso

Foram corrigidas fontes de movimento involuntário no código:

- Ruído neutro do analógico não pode selecionar o controle como dispositivo ativo, inclusive através de `PreferredInput`.
- A câmera consulta o estado atual do controle selecionado; direções digitais sintetizadas do analógico não ficam retidas como uma entrada de intensidade total.
- Uma pequena histerese na fronteira da zona morta evita alternância por ruído. Voltar ao centro zera imediatamente a saída.
- Foco, desconexão, menus, troca de dispositivo e remoção do personagem limpam o estado pertinente.
- O toque acumula deslocamentos e os consome uma vez por quadro; um segundo dedo não toma a propriedade do gesto de mira. A rotação assistida cessa no quadro sem deslocamento de mira.
- Apenas mover o personagem não ativa acompanhamento rotacional. Cada eixo requer intenção correspondente; input contrário não recebe correção.
- Mudanças de direção do alvo não herdam a velocidade suavizada no sentido anterior.

As zonas mortas e intensidades configuráveis existentes foram mantidas. Não foi diagnosticado defeito físico em nenhum controle.

Também foram corrigidos dois bloqueios de recarga na Arena: a lista de contextos de `ReloadInteract` e a restrição de escopo `interaction` no roteador.

## Evidências

- **41 contratos aprovados:** 15 de movimento/drift/recarga, 16 de AimAssist, 4 de analógicos e 6 de combate/modelos.
- **6 verificações com eventos simulados sobre o código real de InputMode:** ruído neutro, ruído de PreferredInput, entrada deliberada, início de toque, direção sintetizada e soltura de tecla.
- Play isolado na Arena/Pátio: renderizador FP ativo e sem erros novos dos controladores; câmera em repouso com alteração angular de 0° em um segundo.
- Slide pelo teclado: início aceito, término em aproximadamente 0,72 s e WalkSpeed restaurado a 25. Pulo cancelou; troca de arma encerrou com motivo `weapon`.
- Fixture física de parede: início aceito, saída `obstructed`, sem `LinearVelocity` remanescente.
- Entrada direcional sintetizada seguida de soltura: analógico filtrado e rotação assistida zerados; alteração angular posterior de 0°.
- Integração de TargetingAssist com dependências de modo/dispositivo simuladas e raycasts reais: alvo selecionado, rotação horizontal parcial com input alinhado; rotação zero em repouso e com input contrário.
- Harness de recarga usando registro de ação com escopo `interaction` e o Remote normal: ação disponível na Arena, recarga iniciada, munição 11 → 12 e reserva 120 → 119. O teste não substitui a validação da tecla R com foco físico na janela.
- **20 fontes finais compiladas no Studio principal**, sem divergência da versão integrada.

Os testes em Play se concentraram na Arena. CTF usa os mesmos módulos e tem elegibilidade coberta por contratos, mas uma rodada completa de CTF não foi repetida nesta tarefa. Controle físico Xbox/PlayStation, multitoque real, latência, 30/60/120 FPS de renderização, R6 e avatares extremos continuam sem validação. Os avisos de carregamento tardio e o erro do plugin GUIEditor preexistente não foram tratados como defeitos deste patch.

## Preservação e arquivos

O merge preservou as mudanças concorrentes de CTF e do HUD mobile, incluindo o novo clamp de posição e a arte vetorial. As fontes locais de MobileHUD, ExperienceSettings e AdminCameraController não foram substituídas por esta tarefa. Mapas e recursos históricos foram preservados.

Backup das fontes anteriores no Studio principal: `ServerStorage.Development.Revisions.WeaponsMotionBaseline_20261027`. Backups locais: `artifacts/weapons-motion-2026-10-27/local-before-merge/`; base e comparação de três versões permanecem na mesma pasta.

Cópia completa de teste: `artifacts/weapons-motion-2026-10-27/Crossgrounds-Weapons-Movement-v2.rbxl`. Ela usa o snapshot local CTF como base, mais as fontes integradas e a suíte manual, e não substitui um salvamento completo do estado atual do Place principal. A estrutura binária com os novos módulos foi aberta e lida pelo Studio durante a validação; a cópia foi atualizada após os últimos ajustes de escopo, ícone e formatação.

O Play da cópia terminou em Edit. O principal recebeu as fontes em Edit; não foi iniciado Play nele. O método empregado foi cópia independente e merge de fontes com verificação de concorrência, sem trocar a branch do checkout compartilhado ou pressupor sincronização automática entre janelas.

## Ajuste posterior de primeira pessoa

A pedido do criador, os braços segmentados desta entrega foram substituídos pela forma anterior: uma peça retangular por braço, com cores e camisa clássica da skin do jogador. A arma foi baixada no ViewportFrame: pistolas de Y −0,65 para −0,98 e demais armas de fogo de −0,85 para −1,18. A apresentação em primeira pessoa também compensa 0,24 stud da elevação compartilhada de ADS, ficando aproximadamente 0,57 stud abaixo da pose anterior ao mirar. Melee usa Y −1,30.

O ajuste altera somente FirstPersonRenderer e o parâmetro ADS enviado por CombatPresentation. As curvas compartilhadas de terceira pessoa permanecem com seus valores anteriores. Duas fontes compiladas no Studio, posicionamento de repouso/ADS conferido por composição de CFrames e igualdade das fontes locais/principal confirmada. Esta revisão visual ainda não teve uma nova captura em Play.

Backup desta revisão: `ServerStorage.Development.Revisions.FirstPersonFramingBaseline_20261027`; fontes locais anteriores em `artifacts/fp-framing-2026-10-27/before/`.
