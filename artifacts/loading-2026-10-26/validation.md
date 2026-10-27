# Inicialização, armazenamento do editor e carregamento

Aplicado no Studio Crossgrounds (ALPHA), Place 4375993208, em 26/10/2026. Fontes locais em src; fontes anteriores dos 12 scripts iniciais em before/.

## Editor guardado

- Sessão integral: ServerStorage.Development.Editors.ArenaSpawnEditor.
- 15 mapas, 323 marcadores na sessão e 323 nos templates de ServerStorage.CrossgroundsMaps.Arena. Geometrias, orientações, regiões e atributos preservados.
- 318 pontos aceitos pela checagem geométrica. Cinco preservados para revisão: Courtyard (2), Neighborhood (2), Nuketown (1). O carregador já descarta pontos inválidos em vez de usá-los para reaparecimento.
- Assault 27, Beach 26, Factory 15 e Glacier 24 mantidos na versão guardada.
- Store salva e guarda a sessão; Restore devolve a mesma sessão ao Workspace. Apply continua exigindo validação completa. Revisões anteriores de spawns/regiões ficam em Development.Revisions.Maps.
- O bootstrap não destrói mais a prévia objeto por objeto com uma espera para cada remoção. Uma prévia eventualmente aberta é movida em lotes para ServerStorage somente na simulação.

## Comportamento implementado

- Desativa CharacterAutoLoads antes de inicializar modalidades. Publica o papel do Place e atribui contexto hub antes do trabalho de montagem do lobby; não assume CTF enquanto o contexto está ausente.
- Publica remotes antes da montagem. Falhas do bootstrap produzem estado legível na tela de carregamento.
- CombatHUD começa oculto e registra observadores antes das esperas por remotes. Exige contexto CTF, personagem pronto e ausência de carregamento local.
- ReplicatedFirst.CrossgroundsLoading exibe a tela antes dos clientes de gameplay. Aguarda jogo, bootstrap, lobby, personagem posicionado e piso no cliente; bloqueia movimento e cobre a interface durante preparação e troca de modalidade/mapa.
- Arena e CTF aguardam pelo menos cinco segundos depois da montagem e exigem confirmação do cliente: revisão do cenário, quantidade esperada de partes, pré-carregamento limitado de recursos visuais e piso nos pontos de spawn. A confirmação não é substituída por uma porcentagem baseada em tempo.
- Entrada em rodadas de Arena/CTF já em andamento também pede confirmação do cenário para esse jogador. Revisões estáveis dos objetos permitem confirmações simultâneas.
- Get Out mantém sua confirmação existente de mapa/piso e a fase de posicionamento; a tela acompanha loading/deploying.
- O tempo limite não revela um cenário incompleto. Há mensagem e retorno ao lobby; no carregamento inicial, pode recarregar o personagem após o bootstrap estar pronto.
- Saída durante carregamento remove a espera daquele participante e não deixa erro/tela presa no lobby.
- O indicador de seleção da votação usa SelectionMarker: o nome anterior Selected colidia com a propriedade booleana do botão no cliente.

## Verificação em Play

Sessão local do Studio com um cliente real, sem substituir a confirmação por mocks:

1. Inicialização repetida: CrossgroundsBootReady=true, CrossgroundsMode=hub, ModeCharacterReady=true. Personagem em aproximadamente (888.36,137.50,294.95), junto do spawn do lobby (888.19,136,294.95). CombatHUD.Enabled=false e ClientLoading=false após terminar.
2. Entrada na Arena e votação em Assault: partida iniciada, carregamento encerrado, personagem em piso do mapa e HUD do CTF oculto.
3. Entrada no CTF: HUD ativo somente no contexto CTF. Tela de carregamento conferida visualmente durante RoundState=Loading. Após Playing, personagem sobre Workspace.Terrain, pronto e sem tela presa. Retorno ao lobby voltou a ocultar o HUD.
4. Entrada no Get Out: estado waiting com um jogador, personagem pronto no staging, HUD do CTF oculto e tela encerrada.
5. Saída durante SceneLoading=true na Arena: retornou ao hub com SceneLoading=false, ClientLoading=false, personagem pronto e sem SceneLoadingError.
6. Nova votação/rodada Beach: carregamento observado e concluído, SceneLoading=false, ClientLoading=false, personagem sobre CrossgroundsArenaRound.Batch004.Part, iluminação às 10h e cronômetro com 299,29 segundos restantes de 300.
7. Correção da votação: seleção de Factory exibiu somente o marcador de Factory entre os 15 cartões. Console da sessão posterior sem erro de MapVoteGrid, tela de carregamento ou bootstrap e sem Infinite yield.
8. Compilação dos 121 scripts de servidor, clientes, ReplicatedFirst e ferramentas: sem erros. Depois da última correção, MapVoteGrid também recompilado e exercitado no cliente.
9. Após parar Play: Studio em Edit, editor ausente do Workspace e sessão guardada com 323 marcadores; templates também com 323.

## Limites da verificação

- Não houve sessão com dois clientes nesta entrega. A rodada completa de Get Out e as entradas simultâneas/tardias em rodada ativa ainda precisam dessa conferência.
- O tempo limite sob rede lenta/perda de conexão não foi reproduzido por degradação de rede.
- A quantidade/checagem geométrica dos spawns não comprova equilíbrio, conectividade ou se um ponto faz sentido no desenho do mapa.
- O console ainda registra avisos anteriores de permissão do áudio 5207633818 e erros do plugin GUIEditor/TestService fora do fluxo alterado.

Guia de recuperação e edição: docs/ARENA-SPAWN-EDITOR.md.
