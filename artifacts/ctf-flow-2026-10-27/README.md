# CTF: entrada, carregamento e bandeiras

Arquivo de trabalho: `CrossgroundsAlphaCopy-CTF.rbxl`. As fontes desta alteração ficam em `artifacts/ctf-flow-2026-10-27/src/`; não houve sincronização dessas fontes sobre os arquivos compartilhados de outras tarefas.

## Causas encontradas

1. A geometria ativa da Travessia Ampliada foi elevada: o piso passou de Y=80 para Y=104, mas spawns, bandeiras e navegação continuaram no referencial anterior. Os 48 raios de confirmação de chão falhavam. O servidor aguardava o cliente, falhava e repetia a preparação.
2. SettingsService e ProgressionService abriam DataStores ao serem requeridos, mesmo no modo Studio. A cópia local não publicada interrompia a inicialização antes de criar os personagens.
3. ProgressionBalance aguardava GetConfigAsync durante o require. Uma consulta remota pendente bloqueava a inicialização de todo o CTF.
4. A tela de carregamento podia manter um pedido já encerrado e não era reaberta se uma falha imediata ocorresse entre dois frames.

## Alterações

- MapManager alinha a infraestrutura à fundação real, de modo idempotente, atualizando as posições das bandeiras, dos spawns e das rotas, mais NavigationFloorY/PlayRegionCenter. A geometria editada e o terreno são preservados. Isso também ocorre ao trocar de mapa.
- Os pontos de nascimento são conferidos antes da solicitação de carregamento. Uma falha coloca a rodada em LoadFailed e aguarda uma nova tentativa ou saída, sem repetir rodadas indefinidamente.
- SceneLoadFinished encerra o pedido correspondente no cliente em sucesso, falha ou cancelamento; tokens encerrados são ignorados temporariamente.
- A tela de erro permite tentar novamente ou voltar ao lobby. O fim do carregamento usa fade e respeita SettingReducedMenuMotion.
- Ao escolher Jogar CTF no hub, o adaptador inscreve o jogador na equipe com o kit selecionado. O menu de kits continua acessível, mas não interrompe automaticamente a entrada. Rodadas seguintes mantêm a inscrição existente.
- Os DataStores mantêm os nomes existentes e só são abertos fora do Studio. Em testes, os serviços usam o estado temporário já previsto no código.
- Configurações de recompensa são carregadas em segundo plano em experiências com Universe ID. Os valores padrão existentes permitem iniciar imediatamente. A conclusão/atualização da consulta invalida o cache de valores.
- A bandeira replica referência e nome do portador. Participantes CTF veem contorno através de obstáculos e identificação acima do portador. A interface apresenta aviso de roubo, queda, retorno e captura, além de instruções persistentes para interceptar/escoltar/levar à base. Marcadores são limpos na queda, captura, morte e saída.

## Verificação em Play

- Inicialização concluída: CrossgroundsBootReady=true e personagem pronto no hub.
- Entrada real pelo menu com navegação de teclado: hub -> CTF -> Countdown -> Loading -> Playing, sem confirmação adicional de kit/entrada.
- Travessia Ampliada: 48 spawns com chão; 11 bots com um jogador; InArena=true; SceneLoading=false; tela de carregamento desativada.
- Jogador pegou a bandeira vermelha por contato: estado carried, referência/nome replicados, Highlight e BillboardGui presentes; aviso de posse exibido.
- Bot vermelho pegou a bandeira azul: aviso “Red_AI_1 está com a sua bandeira!” visível e destaque presente. Posse simultânea de ambas as bandeiras mostrada na interface.
- Morte do portador inimigo removeu sua referência; a bandeira retornou à base.
- Entrega da bandeira vermelha somou uma captura e removeu contorno, marcador e aviso persistente.
- Retorno ao hub limpou InMatch/InArena, desativou alertas e liberou a tela.
- Falha imediata de chão simulada apenas no DataModel de Play: servidor permaneceu em LoadFailed; após restaurar o ponto e solicitar RetryLoading, a rodada voltou a Playing. A simulação não foi gravada no Place.
- Após corrigir o tratamento da falha imediata, uma nova simulação abriu a tela de atenção com os dois botões. O clique real em Tentar carregar mapa retomou a rodada e a tela desapareceu.
- Cliente com piso não confirmado, enquanto o mapa do servidor continuava válido: a espera expirou em LoadFailed, SceneLoading foi limpo e a interface apresentou nova tentativa e saída. Esse teste exercitou o encerramento de um pedido ativo por timeout. Após restaurar o piso no cliente e clicar em tentar novamente, a rodada voltou a Playing com 11 bots, sem SceneLoading nem tela de carregamento.

O teste usa um cliente humano e bots. Multiplayer com vários clientes humanos, controle físico e teleporte/publicação não foram validados. O console contém avisos preexistentes de áudio sem permissão, plugin GUIEditor e cópias de StarterPlayerScripts guardadas em TestService; não foram tratados como confirmação de falhas do patch.

## Artefatos

- `before.rbxl`: backup completo anterior à tarefa.
- `baseline/` e `src/`: fontes anteriores e finais do escopo.
- `changes.diff`: diferenças completas das fontes.
- `source-manifest.json`: fontes alteradas e hash do backup.
- `tools/patch_ctf_flow_place.cjs`: recompõe o Place preservando todos os chunks que não são propriedades Source. `--manifest` verifica igualdade com o resultado salvo.

Nenhuma experiência foi publicada.
