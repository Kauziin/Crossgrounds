# Riverside: teste dedicado e bots — 03/11/2026

Aplicado ao principal Crossgrounds 4375993208 em Edit, com backup `ServerStorage.Development.Revisions.RiversideBotsBaseline_20261103`. Fontes anteriores exportadas para `artifacts/riverside-bots-2026-11-03/before.json`; as três eram iguais ao HEAD local antes da alteração.

## Alterações

- `CTFBotObjectives`: travessias sem BotRoutes usam os Decks reais, ordenados pela posição Z, em vez de coordenadas antigas. Riverside tem pontes em Z −192,34 / 0 / 187,97. BotRoutes explícitas dos outros mapas continuam prioritárias. Guardiões mantêm um posto estável em vez de orbitar a bandeira continuamente.
- `BotNavigation`: água tem custo proibitivo; atalhos amostram apoio a cada três studs em todo o percurso, rejeitando vãos/água/inclinações excessivas. Chegada ao objetivo considera a diferença de altura entre root e navmesh. Removido salto redundante no waypoint que já foi alcançado; o salto necessário continua sendo emitido na aproximação ao waypoint Jump.
- `WeaponPose`: removidas a marcha senoidal e as oscilações impostas ao pescoço/cintura dos NPCs. O Animator existente mantém animações nativas/configuradas, inclusive as provenientes de avatar. Empunhadura, mira e recarga das armas permanecem no sistema de apresentação existente.

## Validação efetivamente realizada

Play local com flags inicializadas e 12 bots, sem jogador combatente: teste controlado do servidor, não uma partida iniciada pela interface. O primeiro período anterior à inicialização das flags não tinha objetivos; foi descartado das amostras de combate e o cronômetro foi reiniciado.

- Seis caminhos de acesso às pontes: Success nos dois sentidos para as três rotas.
- Doze caminhos adicionais de travessia/saída até as bandeiras: Success.
- Travessia física com seis rigs: cinco chegaram no limite de 20 s; um excedeu esse limite na ponte sul durante circulação simultânea. Reteste individual do sentido azul→vermelho na sul chegou em 5,36 s, sem evento de stuck. Atraso com circulação concorrente continua sendo uma limitação observada, sem causa isolada comprovada.
- Quatro verificações controladas da navegação passaram: rejeição de vão, aceitação de piso contínuo, bloqueio por parede e chegada com diferença de altura root/navmesh. Fixtures removidas.
- Observação por 122,10 s após inicialização das flags: 52 amostras, 22 identidades de bots ao longo de mortes/reposições, nenhuma posição amostrada abaixo de Y=15; menor Y=40,49. Bots percorreram até 564 studs acumulados. Animator manteve tracks nativas/configuradas; o cliente confirmou ausência do código antigo de marcha/pescoço.
- Snapshot acumulado do runtime (inclui preparação e fixtures): zero erros BotRuntime, 1.538 disparos aceitos, 185 registros de acerto, 219 computações de caminho, uma falha de path, 58 eventos de stuck e 53 recuperações locais emitidas; zero abandonos. Recuperação emitida não comprova resolução definitiva. Média de tick 1,90 ms e pico 53,96 ms nesta máquina, com diagnóstico ligado; não é benchmark de produção.
- Revalidação final dos 48 spawns passou. Limpeza deixou zero agentes ativos. Studio retornou a Edit; três fontes compiladas e idênticas às fontes locais.

Evidências em `artifacts/riverside-bots-2026-11-03`: paths, crossings, physical-crossings, south-retest, navigation, soak, final e sources. A atualização da música preexistente foi preservada. Console ainda contém erros externos ao escopo (playlist/interface, assets e plugins).

## Limites

Há congestionamento e recuperações durante combate; o trabalho não prova ausência de travamentos. Ainda faltam partidas humanas, testes multiplayer e visualização prolongada da animação em vários clientes, além de balanceamento e validação publicada. Não houve publicação nem salvamento na nuvem. Os dados de mapa da tarefa anterior continuam na sessão do Studio e precisam acompanhar o salvamento do place.
