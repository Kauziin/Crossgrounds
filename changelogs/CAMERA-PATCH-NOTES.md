# Câmera, apresentação e menus — Capture a Bandeira

Data: 22/10/2026. Place: 4375993208.

Atualização posterior: [acessibilidade e novos controles](ACCESSIBILITY-PATCH-NOTES.md). Os controles e o comportamento do cursor descritos abaixo registram a versão anterior.

## Alterações aplicadas no Studio

- Câmera de combate em terceira pessoa com deslocamento de ombro, troca de lado e Shift Lock alternável, ligado por padrão.
- Mira livre usa o cursor do mouse ou do Xbox. GamepadService controla o cursor nativo; há uma mira móvel pelo analógico quando esse cursor não está disponível.
- Primeira pessoa usa uma cópia local da arma e braços próprios. O personagem real fica oculto somente no cliente. A câmera não acompanha a animação da cabeça.
- Recuo visual por arma, confirmado pelo servidor, sem modificar a direção do tiro. A arma recua e retorna ao repouso.
- Sensibilidade da câmera e ao mirar, volume de música, ombro, perspectiva inicial, Shift Lock e intensidade do flash de dano configuráveis.
- Preferências salvas por jogador em DataStore no jogo publicado. No Studio, permanecem somente durante a sessão de teste.
- Música de lobby com transição de volume ao entrar e sair da arena: Tactical Pulse (Underscore Version), APMOfficial, asset 1843033302. Volume inicial de 22%.
- Flash vermelho suave quando a vida diminui.
- Votação durante os 8 segundos de preparação, com até três mapas cadastrados. Um voto por jogador, troca de voto permitida e sorteio nos empates.
- Nomes: Faca, Vasnev 9mm, Executor, Kastov 545, Treme-Terra e Lachmann LMS.
- Corrigida a proteção de lobby que podia permanecer após entrar na arena. A proteção normal de spawn continua por 2 segundos ou até atacar.
- Detecção de entrada compartilhada para alternar entre teclado, toque e controle, incluindo comandos de controle simulados pelo Studio.

## Controles

| Ação | PC | Controle | Celular |
|---|---|---|---|
| Alternar Shift Lock | Shift | Clique LS | TRAVA |
| Trocar ombro | Q | D-pad esquerdo | OMBRO |
| Primeira/terceira pessoa | V | Clique RS | 1ª / 3ª |
| Atacar | Clique esquerdo | RT | ATACAR |
| Mirar | Botão direito | LT | MIRAR |
| Recarregar | R | X | RECARREGAR |
| Trocar equipamento | 1–2 | LB–RB | Slots do HUD |
| Alternar corrida | Ctrl | Y, na arena | CORRER |
| Voltar ao lobby | L | B | Botão do HUD |
| Configurações | F2 | D-pad direito, fora da seleção de kit | CONFIGURAÇÕES |
| Votação | M | D-pad baixo, fora da seleção de kit | MAPAS |

Nos menus: LB/RB troca abas, D-pad seleciona/ajusta, A confirma e B fecha. No lobby, Y permanece disponível para as interações de kit.

## Cadastrar mapas

O mapa atual está em `ServerStorage.CTFMaps.riverside`, com o nome visível **Travessia**. Não foram adicionadas opções fictícias à votação.

Cada novo mapa deve ser um Model ou Folder dentro de `CTFMaps`, com nome interno único e esta estrutura:

```
meu_mapa
├── CTFInfrastructure
│   ├── BlueBase: FlagStand, FlagPole, FlagBanner, Spawns
│   ├── RedBase: FlagStand, FlagPole, FlagBanner, Spawns
│   └── TacticalCover
├── Geometry
└── TerrainData (opcional, TerrainRegion)
```

Preserve a estrutura das bases e os pontos de spawn do modelo atual ao duplicá-lo. Os objetos devem estar nas posições finais do mapa. `Geometry` guarda o cenário estático; o lobby é compartilhado e fica fora dela.

Atributos do mapa: `DisplayName` e `Description` são textos; `Enabled=false` exclui a opção. `TerrainOrigin` é um Vector3 com a origem em células de terreno. Sem `TerrainData`, usa-se o terreno de Travessia. Ao trocar de mapa, bandeiras, coberturas e spawns passam a usar a nova infraestrutura.

## Verificação realizada

- Sintaxe de todos os scripts dos serviços de combate, cliente e definições sem erros.
- Navegação das configurações por controle, foco visível e sensibilidade alterada de 0,55 para 0,65.
- LS alternou a trava; analógico simulado deslocou a mira para fora do centro.
- Primeira pessoa inspecionada visualmente com modelo reduzido e corpo real oculto.
- Recuo medido retornou ao repouso; variação de direção da câmera durante o disparo foi zero.
- Troca real entre duas opções de mapa em Play, depois retorno ao mapa original; 24 spawns por equipe e 11 bots com um jogador. A cópia de teste não foi mantida no projeto.
- Após entrar na arena: 200 HP, nenhum LobbyShield restante e dano de 40 reduziu a vida para 160, disparando o flash.
- Música carregada e reproduzida no lobby; pausada após a transição para a arena.
- Tela de configurações inspecionada em simulação de iPhone em paisagem. Simulador restaurado e Play encerrado.
- Nenhum erro dos novos sistemas observado no último teste. O plugin externo GUIEditor ainda registra erros próprios.

O cursor nativo Xbox e a sensação final da câmera ainda precisam de uma sessão com controle físico. Persistência de preferências precisa ser confirmada em servidor publicado.

## Recuperação e pendências

- Fontes atualizadas em `src/`, organizadas por serviço.
- Pacote `artifacts/camera-experience-patch.rbxm`: 197947 bytes, organizado por serviço para recuperação manual. Não é um instalador nem um place completo.
- Backup anterior às alterações em `ServerStorage.CameraExperienceBackup_1792639814`.
- Preserve `DisplayScript.Enabled=false`, `StarterPlayer.EnableMouseLockOption=false` e `StarterPlayer.CameraMaxZoomDistance=16` ao recuperar a partir das fontes.
- **Chat:** a API recusou alterar `TextChatService.ChatVersion` por exigir a capacidade RobloxScript. O usuário decidiu alterar essa propriedade depois para `TextChatService`.
- **Publicação pendente:** alterações aplicadas na edição atual do Studio. O controle da janela falhou com CryptUnprotectData e a API disponível não publica a edição atual. Use Arquivo → Publicar na Roblox.
