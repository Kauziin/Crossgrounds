# Get Out v0.5 P0 — evidências de validação

**Data:** 26/10/2026. **Place:** Crossgrounds (ALPHA), 4375993208. **Adaptador:** 0.5-p0.

## Resultado

| Verificação | Resultado |
|---|---|
| Suíte `GetOutP0`, com três clientes reais de simulação do Studio | 44 checks passaram |
| Contratos existentes de Get Out | 6 de 6 passaram |
| Compilação de módulos/clientes relacionados | 18 arquivos passaram; os scripts alterados depois também foram compilados/carregados nos testes direcionados |
| Catálogo e carregamento de mapa | `pursuit_lab` elegível e carregável; `facility` legada rejeitada até adaptação |
| Sincronização de fontes | 22 scripts locais coincidem com o Studio após normalizar finais de linha e whitespace final |
| Reset durante espera | Novo personagem, 100 de vida, modo `get_out`, pronto e apoiado em `Workspace.GetOutStaging` |
| Volta ao hub após reset | Modo `hub`, 200 de vida, pronto, fila `idle` |

O ensaio multicliente atravessou fisicamente o duto nos dois sentidos e a janela com os dois papéis, abriu/fechou a porta comum, recusou fechamento ocupado, derrubou sem matar, prendeu corda, moveu a vítima com a Besta, aprisionou, pausou/avançou congelamento, resgatou, cooperou no hack e validou erro temporal. Também verificou rollback, soltura, duas fugas físicas e preservação do resultado de cada sobrevivente.

Depois da suíte, foram testadas as correções direcionadas de respawn durante espera e isolamento dos handlers do CTF, com entrada normal pelo catálogo e retorno ao hub. O Studio foi devolvido ao modo Edit.

## Medição isolada do rastejamento

O controlador de caminhada do Humanoid apresentou instabilidade com o collider baixo. O rastejamento passou a usar movimento planar com velocidade limitada pelo servidor e orientação física própria, mantendo gravidade e colisões do cenário.

- Destino leste: aproximadamente `(2609.93, 100.80, 0)`.
- Destino oeste: aproximadamente `(2589.82, 100.80, 0)`.
- Maior velocidade planar medida: `7.00054 studs/s`, para configuração de `7`.
- Não há teleporte para atravessar o duto.

A pose é aplicada pelo cliente após a avaliação do Animator, usando `Transform` em Motor6D e AnimationConstraint. A implementação segue o contrato de [AnimationConstraint na documentação Roblox](https://create.roblox.com/docs/reference/engine/classes/AnimationConstraint).

## Checks da suíte multicliente

1. three hub characters ready
2. round started after client map acknowledgements
3. spawn remained on map: Player1
4. spawn remained on map: Player2
5. spawn remained on map: Player3
6. crawl uses a physical low collider
7. physical vent crossing west to east
8. physical vent crossing east to west
9. cannot stand under vent ceiling
10. stands after clearing ceiling
11. survivor physically crosses jump window
12. beast physically crosses jump window
13. vent blocks beast only
14. regular door opens
15. door refuses to close on character
16. regular door closes after clearance
17. hammer downs without lethal damage
18. downed victim stays alive
19. beast leashes downed victim
20. victim physically follows the walking beast
21. dragged victim enters a nearby capsule
22. anti-camping pauses freeze
23. freeze progresses away from beast
24. rescue restores movement and removes restraints
25. two users occupy separate hack slots
26. server rejects early timing check
27. cooperative progress completes exactly one PC
28. Hacker rolls back the completed PC
29. rollback resets shared terminal state
30. victim can be leashed again after rescue
31. release cleans rope and constraints
32. final objective completes: pc1
33. final objective completes: pc4
34. final objective completes: pc3
35. final objective completes: pc2
36. first exit crank unlocks after all PCs
37. first survivor physically crosses escape zone
38. first escape preserves the other survivor's round
39. second exit crank remains independent
40. last physical escape resolves the round
41. results preserve both individual escapes
42. results restore character: Player1
43. results restore character: Player2
44. results restore character: Player3

## Limites da evidência

A suíte usa assertions programáticas e deslocamento controlado no Studio. Ela não substitui playtest humano com teclado, gamepad e toque. Ainda precisam de revisão: R6, escalas e roupas variadas, câmeras, UI em telas pequenas, arrasto em curvas/obstáculos importados e comportamento sob latência/perda de pacotes.

Os contratos de 600/900 segundos foram verificados por testes de estado; esta sessão não aguardou uma rodada humana inteira de 15 minutos. Cofre, Lasers, Térmica e Demolição continuam sem ciclo jogável completo. Indicadores mundiais completos de resgate e a apresentação audiovisual final permanecem parciais.

O log geral de teste também registrou mensagens de plugin GUIEditor, Marketplace e permissão para o som `5207633818`. Nenhuma delas corresponde a um stack dos módulos novos de Get Out, e as 44 assertions passaram. Isso não equivale a afirmar que toda a experiência está livre de erros externos ao recorte.

O checkout contém arquivos não rastreados. `git diff --check` terminou sem erro, mas não valida esses arquivos; a evidência principal de código é a compilação e a execução no Studio.
