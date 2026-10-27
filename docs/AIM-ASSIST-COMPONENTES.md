# Aim assist por componentes

**23/10/2026 — implementação aplicada e testada no Studio, sem publicação.**

**Incremental visual posterior:** [cascatas sólidas e sombra por profundidade](CASCATAS-SOLIDAS.md), para aplicar sobre o pacote deste relatório. O projeto aberto já inclui a alteração.

## Pesquisa e decisão

A [documentação oficial de Modern Warfare](https://blog.activision.com/uk/en/call-of-duty/2019-10/Getting-Started-in-Modern-Warfare-Controls-and-Settings) descreve desaceleração perto do inimigo e perfis que alteram sua região/intensidade. A curva de resposta do analógico é outra configuração.

As [notas oficiais de BO6](https://www.callofduty.com/patchnotes/2024/10/bo6-preseason-patch-notes) explicam a transição gradual de força em distâncias próximas. As [notas de BO7 de novembro de 2025](https://www.callofduty.com/patchnotes/2025/11/call-of-duty-black-ops-7-preseason-patch-notes) descrevem assistência rotacional dependente do acompanhamento pelo analógico direito, com força reduzida quando essa condição não é atendida. São referências de versões específicas, sem pressupor que seus parâmetros permaneçam iguais nas versões atuais.

Um [exemplo técnico do projeto CSE 125/UCSD](https://cse125.ucsd.edu/2026/cse125g2/docs/GamepadAimAssistSystem_8hpp.html) separa desaceleração e compensação parcial do movimento de uma âncora na área escolhida pelo jogador. É uma implementação acadêmica independente, não código de Call of Duty.

O Crossgrounds recebeu parâmetros próprios, adequados a seus studs, armas e velocidade. A pesquisa não permite afirmar reprodução exata do algoritmo ou dos valores internos de CoD.

## Problema encontrado

O sistema anterior selecionava o tronco em um cone de 6°/8°, até 180 studs, e corrigia continuamente o erro entre a mira e o centro desse tronco. Movimentar o personagem já habilitava a correção. Isso podia centralizar a câmera mesmo sem acompanhamento pelo analógico direito.

A assistência foi reorganizada em:

1. **Desaceleração:** reduz parte da sensibilidade quando a mira está no corpo ou em sua margem próxima.
2. **Acompanhamento rotacional:** contribui com uma fração do deslocamento angular visível da área que o jogador já está mirando.
3. **Transições e intenção:** distância, direção do input, aquisição gradual, troca de alvo e saída rápida controlam essas duas contribuições.

O cálculo de dano, dispersão, penetração e raycast de disparo permaneceu no sistema existente. O patch não aumenta hitboxes, não escolhe a cabeça e não redireciona balas.

## Comportamento implementado

| Componente | Regra |
|---|---|
| Região de assistência | Volume aproximado do corpo, com margem angular suave: 1,15° sem ADS / 0,8° em ADS |
| Curta distância | A região acompanha o tamanho aparente do corpo, evitando depender de um cone pequeno fixo |
| Desaceleração | Até 50% × intensidade geral × pesos de corpo/distância/input |
| Desaceleração distante | Redução gradual de 50 a 150 studs; fora de 150, assistência desligada |
| Acompanhamento distante | Redução gradual de 40 a 100 studs; a partir de 100, rotação zero |
| Contato muito próximo | Força cresce suavemente entre 2 e 12 studs; evita giros abruptos junto ao personagem |
| Área acompanhada | Ponto próximo da linha de mira dentro do volume; o jogador continua escolhendo a altura e o lado |
| Movimento | Usa tradução relativa do alvo/câmera; girar o boneco ou mover a mira sobre um alvo parado não gera atração ao centro |
| Analógico direito | Acompanhamento exige input após a zona morta e alinhado ao deslocamento aparente |
| Input contrário | Contribuição rotacional zero |
| Só strafe no controle | Contribuição reduzida a até 14% do fator de intenção; não recebe força plena |
| Toque | Exige movimento recente do dedo de mira; andar com o outro dedo não ativa a rotação |
| Aquisição | Espera de 90 ms e crescimento suave por mais 100 ms; trocar de inimigo reinicia esse estado |
| Limites | Tetos de 90°/s em yaw e 30°/s em pitch, multiplicados por intensidade e distância; contribuição vertical também reduzida |
| Saída manual | Giro rápido reduz desaceleração/acompanhamento; saída da região libera a mira |
| Obstáculos e proteção | Visibilidade e elegibilidade verificadas a cada frame; perda de alvo limpa a assistência imediatamente |
| Hitches/teleportes | Sem acumular correção atrasada após frame acima de 75 ms ou deslocamento incompatível |
| Mouse | Sem assistência |

O acompanhamento é uma fração do movimento, não uma correção do erro para um ponto central. Se jogador e alvo permanecem parados, a rotação é zero, inclusive com intenção de strafe sem deslocamento físico.

No padrão de intensidade geral **45%**, a contribuição teórica máxima de movimento é 27%, antes dos demais pesos e limites. A desaceleração máxima é aproximadamente 22,5%. Esses valores são ponto inicial de calibração; não comprovam equilíbrio competitivo.

## Configurações

Em **Opções → Controles → Mira e sensibilidade**, permanecem o liga/desliga e a intensidade geral. Foram adicionados:

- **Desaceleração perto do alvo (%)**.
- **Acompanhamento do movimento (%)**.

Ambos iniciam em 100% do componente calibrado, multiplicado pela intensidade geral existente de 45%. Cada componente pode ser zerado separadamente. Os valores usam a sanitização e o serviço de configurações existentes. A curva S e as zonas mortas anteriores foram preservadas.

## Verificações

**16/16 contratos de AimAssist aprovados.** Cobrem aliados, mortos, proteção, alcance, obstáculos, janela próxima, âncora escolhida pelo jogador, alvo estático, repouso, direção de input, limites, distância, controles independentes, aquisição/troca, hitches, saída rápida e consistência entre 30/60/120 FPS.

Integração em Play, com input Gamepad simulado e raycast real:

| Caso | Resultado |
|---|---|
| Alvo móvel a aproximadamente 20 studs, input acompanhando | Seleção ativa; rotação contribuindo na direção do movimento |
| Mesmo cenário com input contrário | Rotação 0 |
| Mesmo cenário sem input ou strafe | Rotação 0 |
| Alvo a 120 studs, força geral 100% | Rotação 0; fator de sensibilidade aproximadamente 0,892 |
| Alvo além de 150 studs | Sem seleção; sensibilidade 1 |
| Parede cobrindo o alvo | Assistência zerada imediatamente |
| Proteção ativada no alvo | Seleção rejeitada |
| Assistência desligada | Sem seleção; sensibilidade 1 |
| Câmera normal, alvo parado, força geral padrão e intenção de strafe 1 | Assistência ativa, fator aproximadamente 0,775; rotação assistida 0 e alteração angular da câmera 0 |
| Troca para teclado/mouse | Assistência inativa; rotação 0 |
| Dois controles novos no menu | Ambos presentes; servidor aceitou desaceleração 0,4 |

O teste isolado de visibilidade usou uma cena temporária e suspendeu o passo da câmera apenas naquela sessão de QA. A verificação seguinte iniciou uma sessão nova e exercitou o controlador normal de câmera. Objetos de teste não foram adicionados ao projeto em Edit.

**128 fontes compiladas, sem erros e sem divergências em relação às fontes aplicadas.** O console final não apresentou novos erros destes controladores; persistem avisos da ferramenta e erro do plugin externo GUIEditor.

### Limites

- Sem controle físico Xbox/PlayStation, multitoque real ou teste prolongado com humanos.
- O caminho de input de toque foi adaptado, mas seu conforto e sua calibração em aparelho real continuam pendentes.
- Valores precisam de avaliação prática em distâncias/armas/mapas diferentes, especialmente alvos cruzando muito perto, sniper e mudanças rápidas de direção.
- Volume aproximado do corpo pode precisar de ajuste em avatares incomuns.
- Persistência publicada dos novos ajustes não foi testada.
- O teste não estabelece paridade de desempenho entre mouse, controle e toque.

## Fontes e preservação

Alteradas seis fontes: AimAssist, TargetingAssist, CombatPresentation, ExperienceSettings, ExperienceMenu e AimAssist_Test. Backup em **ServerStorage.AimAssistMotionBaseline_20261023**.

Os sistemas de armas, mapas, bots, lobby, playlist e progressão foram preservados. Permanecem combinedPrototype, TeleportEnabled=false e runner automático desativado.

[Pacote incremental cumulativo](../artifacts/crossgrounds-acessibilidade-aa-2026-10-23.rbxm): **91.029 bytes**, **27 fontes de runtime**, incluindo as duas entregas anteriores de UI/lobby. SHA-256: **373C703C5BC4D13052B5511CBBD2B411E1581D376DAF58863CF939FB8F41C028**.

Aplicar sobre Bugs23 distribuindo/substituindo por serviço, sem duplicar inicializadores. Total de runtime permanece 106 fontes. Não inclui mapas, testes ou todas as dependências anteriores. O projeto aberto já está atualizado; não reimportar nele. Instalação em outro Place não foi testada. Nenhuma publicação foi realizada.
