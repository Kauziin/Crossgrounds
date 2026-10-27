# Get Out — protótipo Clássico/Travas

> Registro histórico da primeira implementação. A etapa atual, baseada no design v0.5 e no mapa `pursuit_lab`, está em [GET-OUT-V05-IMPLEMENTATION.md](GET-OUT-V05-IMPLEMENTATION.md).

**Data:** 25/10/2026. **Referência:** `GET-OUT-DESIGN-v0.4.md` e `Crossgrounds-ModeConfigs/Crossgrounds-ModeConfigs/GetOutConfig.luau` (schema 2). O `GetOutConfig.luau` da raiz (schema 1) foi preservado como documento anterior.

## Implementado no projeto local e no Studio

- `Facility` recebeu manifesto `GetOut` autorado, com quatro PCs, quatro travas, duas portas, manivelas, quatro pods e sala de contenção de teste. A rota `locks` é a única elegível. O autoramento reproduzível está em `src/ServerStorage/GetOutFacilityAuthoring.luau`; ele não sobrescreve marcadores existentes.
- `GameCatalog`, `HubBootstrap`, `PlayerContext` e `TravelService` permitem a entrada local no Get Out Clássico do protótipo combinado. A admissão é de 2 a 5 participantes; quem entra durante a rodada aguarda a próxima.
- `GetOutAdapter` controla atribuição de Besta, rodada de 900 s, fase enfurecida aos 600 s, hack dos quatro PCs, liberação das travas, manivela de cada saída, travessia individual, captura em pod com resgate e resultado por sobrevivente. A Besta Hacker reverte um PC com recarga de 150 s, sem fechar porta aberta. Na fase final, dois quadros e uma alavanca operam a contenção secreta; a interface não a apresenta como objetivo.
- `GetOutHUD`, `InteractionController` e `ControlRouter` oferecem interação por tecla, controle e botão de toque. O HUD informa papel, tempo, rota, PCs, pod e resultado; a habilidade Hacker usa Q, botão Y do controle ou botão na tela.
- `GetOutManifest`, `GetOutMaps` e `GetOutRound` mantêm a validação de objetos e o estado da partida no servidor. As outras quatro rotas têm contratos de mapa e de estado, mas não estão habilitadas nem possuem interfaces jogáveis.

## Valores provisórios de teste

Em `GetOutRules.Prototype`: 2 a 5 jogadores; preparação 8 s; resultados 12 s; hack 8 s por PC; manivela 10 s; captura 2 s; resgate 4 s; pod 45 s; proteção após resgate 5 s; Besta com velocidade 18, passando a 21 na fúria. A contenção usa dois quadros de 8 s e alavanca de 4 s. Esses números e o transporte automático para o pod são **provisórios**, autorizados para o primeiro protótipo; não atualizam as decisões definitivas da v0.4.

## Validação feita

- Compilação Luau dos oito arquivos novos: passou.
- Seis testes de contrato executados no Studio: seis passaram.
- Manifesto de `Facility`: uma rota válida (`locks`); cópia do mapa carregou 3.822 descendentes e os spawns passaram na validação.
- Após marcar os componentes físicos das portas, os dois corredores de saída ficaram livres em um teste de raycast quando as portas foram abertas.
- O adaptador criou os 13 prompts de objetivo previstos em uma cópia do mapa; o método real de abertura das duas portas liberou os corredores em teste isolado.
- Em Play com um cliente, o catálogo ofereceu Get Out como entrada local, a transição ao modo concluiu e o HUD mostrou a espera por outro jogador. Não apareceram erros de Get Out no console desse teste.
- Em um segundo Play com um cliente, a sequência hub → Get Out → hub concluiu com a fila novamente em `idle` e sem erro de Get Out no console.

## Limites atuais

O teste Play disponível nesta sessão abriu um cliente. **Ainda falta validar a rodada inteira com dois ou mais clientes humanos**, incluindo captura/resgate, fuga, Hacker, contenção, retorno ao hub e controles em gamepad/toque. Os pontos autorados de `Facility` foram verificados contra piso e geometria principal, mas ainda precisam de revisão de navegação completa durante uma partida. O protótipo não inclui Mutação, Infestação ou Juggernaut; nem Cofre, Lasers, ferramenta térmica e Demolição como rotas jogáveis.
