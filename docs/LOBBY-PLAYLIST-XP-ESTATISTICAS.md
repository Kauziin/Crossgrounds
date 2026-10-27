# Lobby, playlist, XP e estatísticas

**23/10/2026 — aplicado ao projeto aberto no Studio, sem publicação.**

**Atualização posterior:** [aim assist por componentes](AIM-ASSIST-COMPONENTES.md), com novo incremental cumulativo que também inclui esta entrega.

## Interface e blur

- Primeiro nível das cascatas: blur 0. Segundo nível em diante: blur 18, com transição suave ao abrir/fechar.
- A profundidade é calculada pelos painéis realmente visíveis, respeitando a ordem das interfaces. O editor do HUD mantém desfoque de edição.
- Modalidades disponíveis vêm antes das demais, em cards de 74 px, com estado verde e texto “Disponível para jogar”.
- Modos indisponíveis/planejados usam cards de 50 px e textos cinza. Continuam consultáveis, sem habilitar entrada ou fila para modos planejados.
- Permanecer no lobby e reabrir Jogar/Modalidades foram preservados.
- A cascata compartilhada e o tema acrílico da entrega anterior permanecem em entrada, kits, progresso, votação e opções. A playlist também usa essa navegação.

O blur ainda é uma aproximação com transparência dos painéis e BlurEffect do cenário; não é desfoque independente por painel. Menus nativos do Roblox continuam com seu próprio tema.

## Música e gerenciador de playlist

Acesso pela tela inicial em **Música / Playlist**, ou em **Opções → Áudio → Gerenciar playlist do lobby**.

- Pausar/retomar, faixa anterior, próxima e reprodução aleatória.
- Avanço automático ao terminar uma faixa.
- Selecionar uma faixa para ouvir, incluí-la/retirá-la da sequência e movê-la para cima/baixo.
- Proteção para manter pelo menos uma faixa habilitada.
- Transição de volume entre faixas e pausa durante combate, com retomada no lobby/preparação.
- Usa a configuração existente de volume. O controlador anterior de faixa única foi substituído, evitando reprodução duplicada.
- Faixas que não carregam em 12 s são puladas; se nenhuma estiver disponível, o gerenciador pausa para permitir nova seleção manual.

Catálogo em **src/ReplicatedStorage/Crossgrounds/LobbyMusicCatalog.luau**:

| Faixa | Origem | Asset |
|---|---|---|
| Tema original do lobby | Som já existente no projeto | 1843033302 |
| Chill Jazz | APMOfficial, Creator Store | [1845341094](https://create.roblox.com/store/asset/1845341094) |
| Pure Electronic Ambient Relax | DistrokidOfficial, Creator Store | [103039402222856](https://create.roblox.com/store/asset/103039402222856) |

As três carregaram no Studio com status Success e durações de aproximadamente 101,45 / 152,60 / 239,56 s. A validação confirmou carregamento e reprodução; não incluiu avaliação artística de volume percebido ou mixagem em aparelhos reais.

Ordem, seleção, aleatório e inclusão de faixas são preferências locais **desta sessão**, sem gravação entre sessões. O catálogo é editável pelos desenvolvedores; não há upload, busca pública ou inserção livre de IDs pela interface do jogador.

## XP e estatísticas

| Eliminação confirmada pelo servidor | XP padrão | Estatística |
|---|---:|---|
| Bot de CTF | 50 | Eliminação de partida + bot |
| Boneco de treino | 10 | Alvo de treino, sem kill de PvP |
| Jogador de CTF | 70 | Regra anterior preservada |
| Jogador de Arena | 100, +50 se headshot | Regra anterior preservada |

Bots e treino não ganham bônus de headshot. As regras continuam centralizadas em ProgressionBalance, com os valores padrão usados quando não há valor remoto configurado.

O CTF passou a conceder XP no ponto de crédito da eliminação, com informação do tipo de vítima. A observação de leaderstats não concede mais uma segunda recompensa por kill. A Arena usa a mesma política para XP global e XP da sessão.

Os alvos de treino da Arena concedem XP ao morrer. No treino do lobby de CTF, os bonecos anteriormente invulneráveis agora acumulam **200 de dano virtual**, concedem 10 XP ao completar esse total e aguardam 3 s antes de aceitar outro ciclo. Isso mantém seus modelos/rigs existentes. Os atributos PracticeHealth, PracticeMaxHealth e PracticeReadyAt expõem esse estado; não foi acrescentada uma nova animação de morte para esses bonecos.

Perfil e comparação usam tabelas com rótulos à esquerda e valores à direita. Incluem XP, nível, moedas, eliminações em partidas, bots, alvos de treino, mortes, relação E/M, capturas e tempo jogado. A relação E/M usa as eliminações de partida existentes, que incluem bots de CTF; não é uma estatística exclusiva de PvP humano. Histórico anterior não permite reclassificar retroativamente kills de bots/treino.

O placar da partida passou a usar células alinhadas, cabeçalhos separados, avatar e destaque de posição/jogador. Seu tamanho acompanha a janela sem reduzir toda a interface com UIScale. Mortes de Arena também passam a incrementar o perfil global.

## Amigos que já jogaram

- Registro ausente não é mais convertido em perfil zerado elegível.
- Amigos precisam estar presentes com perfil carregado ou ter um registro real salvo. Perfis antigos com valores zero continuam válidos quando há campos reais de progresso.
- Novas gravações registram HasPlayed, inclusive na primeira visita sem recompensas.
- Comparação mostra o próprio perfil como referência e **até oito amigos elegíveis**, ordenados por XP.
- A busca consulta até 60 contatos e reutiliza leituras por 120 s. O limite é informado quando atingido; não é uma busca completa de listas maiores.
- No Studio são usados apenas amigos presentes na sessão. A interface explica essa limitação.

Leitura/gravação real de DataStore e comparação de amigos offline em produção **não foram testadas**. O Studio mantém a proteção anterior que evita gravar progresso de teste.

## Verificações realizadas

| Teste | Resultado |
|---|---|
| Cascata inicial → modalidades → voltar | Profundidades 1/2; blur 0/18/0 |
| Ordem/estilo dos cards | CTF/Arena antes de Get Out/Duels; 74 px contra 50 px; estado verde confirmado visualmente |
| Contratos de recompensa e filtro de amigos | 7/7 aprovados, incluindo quatro contratos novos |
| Eliminação pelo DamageService com clone do template real de bot | Dano aceito, vida 200 → 0, XP +50 |
| Treino do CTF | XP +10; segundo crédito durante recuperação bloqueado |
| Morte durante Arena | ProgressDeaths +1 |
| Playlist | Troca, carregamento, pausa, retomada, aleatório, reordenação e retirada funcionaram |
| Término de faixa | Tema original avançou automaticamente para Chill Jazz |
| Combate/lobby | Música pausou no combate e retomou no lobby |
| Última faixa habilitada | Retirada bloqueada |
| Perfil | Dez linhas, valores alinhados à direita |
| Amigos no Studio | Só o próprio perfil; mensagem sobre ausência de histórico/amigos na sessão |
| Placar com estado real da Arena | Cinco cabeçalhos, linha com avatar, valores alinhados; escala 1 em janela de 749 px |
| Snapshot final | 128 fontes compiladas, sem erros e sem divergência das fontes aplicadas |

Os 84 contratos da etapa anterior são evidência histórica; nesta etapa foram executados os sete relacionados às regras alteradas. Capturas e scripts normais de cliente/servidor foram usados para a integração. Não houve teste com controle físico, multitoque, teclado virtual de console, múltiplos humanos, latência ou playlist em sessão prolongada. O caminho de erro de todos os áudios indisponíveis foi implementado, mas não foi provocado no teste.

Console: sem novos erros dos controladores nas últimas sessões; permanecem erros do plugin GUIEditor, avisos da ferramenta e avisos de valores opcionais ausentes no ConfigService. As consultas de balanceamento foram cacheadas para não repetir o aviso a cada recompensa.

## Preservação e pacote local

Backup: **ServerStorage.LobbyProgressBaseline_20261023**, com 17 fontes anteriores. Mapas, legado e dados anteriores foram preservados. Permanecem combinedPrototype, TeleportEnabled=false e runner automático desativado.

[Pacote incremental cumulativo](../artifacts/crossgrounds-lobby-playlist-progresso-2026-10-23.rbxm): **74.908 bytes**, **23 fontes de runtime**, incluindo a correção anterior da cascata. SHA-256: **0E2B382604F8BF73C4FECB38DD585147BEB560BDB06E0AE977AFBE98A5863CC2**.

Aplicável sobre Bugs23, substituindo/adicionando fontes por serviço sem duplicar controladores. Resulta em 106 fontes de runtime. Não inclui mapas, testes ou todas as dependências anteriores, não é Place completo nem instalador automático. O projeto aberto já está atualizado; não reimportar nele. A instalação em outro Place não foi testada.

Continuam pendentes da entrega anterior os testes de hardware e instalação remota. Votação de rendição, penalidades ao sair e modos planejados não foram implementados por este patch. Não houve publicação.
