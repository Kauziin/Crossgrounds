# Reservas por classe e Arena infinita — 02/11/2026

Implementado no principal Crossgrounds (ALPHA), em Edit, sem iniciar Play ou publicar. Backup das fontes existentes em `ServerStorage.Development.Revisions.AmmoReserveBaseline_20261102`.

Valores são munição **de reserva**, além do carregador. Capacidade dos carregadores, inclusive acessórios de 7/9 e 10/40/60, e tempo de recarga não foram modificados.

| Classe | Reserva |
|---|---:|
| Fuzis de Assalto | 300 |
| Submetralhadoras | 240 |
| Escopetas | 64 |
| Fuzis de Atirador | 80 |
| Fuzis de Precisão | 40 |
| Pistolas | 150 |
| Metralhadoras leves | 400 |
| Especiais explosivos | 4 |
| Especiais de projétil | Mínimo 12, mantendo valores maiores próprios |
| Especiais sem categoria | 10 |

`AmmoReservePolicy` aplica os valores depois de todas as definições de KitDefinitions. Não depende de WeaponCatalog para evitar dependência circular; classes por ID são explícitas e validadas contra o catálogo. Sniper legado (Lachmann LMS) e Kar98k são de Atirador, com 80; Dragunov segue Precisão, com 40, conforme o catálogo existente. Glock18/Luger/Beretta e demais armas antigas também recebem a reserva de classe. Blaster/AutoBlaster são especiais de projétil e mantêm 100/300, acima do mínimo. Regras dos explosivos e de armas especiais futuras ficam registradas sem tornar armas de prévia jogáveis.

ArenaPistol tem `InfiniteReserve=true` e `Reserve=0`. Zero representa ausência de estoque finito, não falta de munição: o input permite solicitar recarga e o servidor da Arena preenche o carregador sem debitar reserva. HUD da Arena e HUD de combate mostram `∞`. Mantidos os gates de modo, vida, arma válida, operação em curso e duração da recarga. Equipamento inicial/recuperação já usam as definições compartilhadas, assim como bots e resolução de acessórios. Conflict continua com reserva finita.

Validações realizadas em Edit:

- Seis fontes compiladas e aplicadas ao principal.
- Contrato de política verificou todas as classes, preservação do carregador, mínimo de projétil, manutenção de valor maior, fallback especial e reserva infinita separada da Arena.
- Nova instância de KitDefinitions conferida contra as categorias das 48 armas importadas jogáveis; verificações explícitas dos legados e Arena.
- Método real `Combat:Reload` extraído sem alterações e exercitado com interfaces isoladas de personagem/Tool: cinco recargas vazias com reserva zero, uma parcial, reserva sempre zero e cancelamento por mudança de modo. Duração abreviada apenas nos dados da fixture. Isso valida a rotina de conclusão, não remotos ou a admissão real em uma partida.
- `git diff --check` passou, com avisos de CRLF em fontes já alteradas.

Limites: sem teste novo em Play, sem avaliação visual do símbolo no HUD e sem teste multiplayer/publicado. Fontes aplicadas em Edit passam a valer nas próximas instâncias de jogo; não foi iniciada uma sessão para atualizar ferramentas em execução. Nenhuma arma de prévia foi habilitada.
