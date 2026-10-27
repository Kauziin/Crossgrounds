# Get Out v0.5 — recorte de perseguição

Referência: `instructions/GET-OUT-DESIGN-v0.5.md`, recebido em 25/10/2026. O cabeçalho interno do documento ainda indica v0.3.1; esta matriz usa o nome de arquivo fornecido pelo criador e a Parte II como requisitos adicionais.

## Comparação com a implementação encontrada

Atualização de 26/10 após o relato de ações bloqueadas: o fluxo normal de interação foi corrigido e uma sessão de três clientes concluiu o ciclo com 35 verificações. Runner passou a ser a classe padrão (+150% durante 3 s, sem pular); a janela reduz a velocidade da Besta em 60%; rastejar usa pressão contínua com animação procedural e transição interrompível. Dutos/janelas do laboratório foram medidos e ajustados à referência Facility. Os números provisórios de recarga e duração da lentidão estão em GetOutPrototype. Consulte [a validação atual](../artifacts/getout-actions-runner-2026-10-26/validation.md); a matriz abaixo preserva o histórico do recorte anterior.

| Mecânica | Antes desta etapa | Estado atual | Implementação desta etapa | Limite de aceitação |
|---|---|---|---|---|
| Carregamento/spawn | Parcial | Implementado no protótipo | Pausa mantida; Get Out confirma geometria/piso por cliente e personagens posicionados antes do relógio | Spawn de três clientes passou; demais modos conservam a pausa compartilhada de 5 s |
| Portas comuns | Ausente | Parcial | Dobradiça com estados, prompts por papel, arbitragem e bloqueio de fechamento ocupado | Funciona no mapa P0; mapas importados precisam de autoramento |
| Rastejamento | Ausente | Parcial | Collider próprio, movimento planar limitado pelo servidor, entrada por teclado/controle/toque e bloqueio de levantar sob teto | Física validada no R15; Motor6D/AnimationConstraint suportados pela pose; R6, proporções e roupas exigem playtest |
| Duto | Ausente | Implementado no mapa P0 | Conector físico bidirecional; bloqueia Besta e vítimas incapacitadas | Um duto autorado; sem teleporte de travessia |
| Janela | Ausente como contrato | Implementado no mapa P0 | Janela física com peitoril e salto de ambos os papéis | Ambos atravessaram em teste; salto duplo e penalidades continuam pendentes |
| Esconderijo | Ausente | Parcial | Armário aberto com entrada a pé e ocultação por geometria | Inspeção especializada e lotação física precisam de refinamento; não há Seer |
| Hack | Hold individual | Parcial | Três slots, progresso compartilhado persistente, checks temporais no servidor e pista de erro à Besta | Cooperação e checks passaram; duração/dificuldade, animação final e UX por dispositivo pendentes |
| Martelo/derrubada | Ausente | Implementado no recorte P0 | Golpe com arco, alcance, visão e cooldown; derrubada sem morte imediata | Pose procedural inicial; animação autorada e testes de latência pendentes |
| Corda/arrasto | Teleporte para pod | Implementado no recorte P0 | Vínculo único, corda, constraints limitadas, velocidade de transporte e soltura | Curvas, obstáculos complexos e latência precisam de playtest adicional |
| Cápsula/resgate | Parcial | Parcial | Ocupação única, congelamento acumulado, pausa por proximidade e resgate com clearance | Marcadores mundiais completos pendentes; anti-camping, tempos e reuso configuráveis de teste |
| Travas | Protótipo | Implementado no recorte P0 | Quatro PCs, quatro travas, duas saídas, manivela e resultados individuais | Duas fugas físicas e resolução individual passaram |
| Cofre/Lasers/Térmica/Demolição | Contratos e estado | Parcial | Contratos preservados | Ciclos jogáveis ausentes; etapa P1 |
| Hacker | Rollback em Travas | Parcial | Rollback também reinicia progresso/estado do terminal | EMP depende de rotas ainda não jogáveis |
| Fúria/contenção | Protótipo | Parcial | 600/900 s e contenção ambiental preservados | Contratos passaram; contenção completa continua dependendo de playtest |
| Controle/UI | Parcial | Parcial | Ações remapeáveis por contexto, botões de toque, progresso de interação e estado pessoal | Controle físico, toque, escalas e câmeras exigem verificação manual |
| Áudio/animação | Parcial | Parcial | Feedback espacial com som de motor disponível, pose baixa e movimento de porta/martelo | Direção sonora, mixagem, manivela visual e animações finais pendentes |
| Balanceamento | Pendente de decisão | Pendente de decisão | Números isolados em configuração de protótipo | Nenhum valor de teste foi promovido a decisão aprovada |

## Mapa e configuração

`pursuit_lab` é um mapa original e isolado para P0, reproduzível por `ServerStorage.Development.Tools.GetOutSliceAuthoring.Build()`. Contém divisória com porta, duto e janela, armário, quatro terminais com três slots cada, duas cápsulas, duas saídas e contenção. O manifesto de travessia é validado antes da cópia. A Facility foi preservada como mapa legado e não recebeu mecânicas falsas por associação de nomes.

Mapas sem o contrato de perseguição v0.5 são rejeitados pelo catálogo e pelo carregador. A Facility legada permanece armazenada, mas precisa de portas/dutos, vagas de hack e pontos seguros de resgate antes de voltar a ser elegível nesse adaptador.

`GetOutPrototype` reúne os novos valores **proposed_test_only**. `GetOutRules` conserva os contratos de 600/300/900 s, cofre e demolição. Não foi acrescentado head start, salto duplo, nova classe de Besta ou regra de Juggernaut. Os testes não equivalem a aprovação de balanceamento.

## Teste reproduzível

A suíte multicliente usada nesta etapa foi movida para `tests/Integration` em 26/10/2026. Seus objetos e pontos de entrada exclusivos foram retirados do Place atual; o argumento `GetOutP0` não inicia mais a suíte. Para preparar uma reprodução em um Place isolado, consulte [testes locais e dependências históricas](../tests/README.md). Os 44 checks abaixo registram a validação anterior à organização.

O protocolo de prontidão é usado pelo cliente normal: ele conta a geometria recebida e verifica piso sob todos os spawns antes de responder. Timeout de cliente/personagem aborta a partida com mensagem, mantendo a opção de voltar ao hub.

## Validação

- Compilação no Studio dos módulos e clientes de Get Out: passou.
- Manifesto e contrato P0 de `pursuit_lab`: passaram; 120 descendentes no template.
- Carregamento real da cópia e clearance de todos os spawns: passou após afastar um spawn da mesa do terminal.
- Suíte multicliente de perseguição com três clientes: **44 checks passaram**, incluindo duto bidirecional, janela para ambos os papéis, porta segura, arrasto em movimento, cápsula/resgate, cooperação no PC e duas fugas físicas com resultados individuais.
- Seis testes existentes de contrato: **6/6 passaram**, preservando quatro PCs, manivelas independentes, 600/900 s, contenção, rollback e cofre.
- Rastejamento isolado: travessia física nos dois sentidos, sem teleporte; maior velocidade planar medida `7.00054 studs/s` para limite `7`.
- Reset durante espera: personagem recriado no Get Out, vivo e com piso confirmado pelo cliente. Retorno ao hub concluiu com personagem pronto e fila `idle`.
- Catálogo rejeitou a Facility legada sem contrato P0 e carregou `pursuit_lab` normalmente.
- Comparação final de conteúdo: **22 scripts locais sincronizados com o Studio**. A experiência ficou em Edit após os testes.

Evidências completas, checks e limites: [relatório de validação](../artifacts/get-out-v05-validation-2026-10-26.md).
