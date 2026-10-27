# Arena: ritmo e feedback — 22/10/2026

## Alterações implementadas

- **20 HP na Arena**, incluindo preparação, respawn e alvos de treino. Hub e CTF continuam com 200 HP. As pistolas atuais eliminam com um tiro no corpo mesmo no fim de sua queda de dano. Cadência, recarga e respawn de 3 s foram preservados.
- Removidos os números de dano da Arena. Acertos mantêm marcador e som; eliminações recebem notificações próprias. Barras nativas sobre os personagens ficam ocultas na Arena e são restauradas ao sair. O HUD ainda mostra a vida do próprio jogador.
- Notificações animadas mostram vítima, arma efetivamente equipada, headshot e XP. Killfeed da Arena mostra autor, vítima, arma e headshot.
- **XP apenas da sessão:** 100 por eliminação PvP, mais 50 por headshot. Os 150 exibidos já incluem esse bônus. Alvos de treino não concedem XP nem eliminações PvP. O servidor calcula e registra ArenaSessionXP; o cliente não envia recompensas. O total atravessa rodadas, mas é reiniciado ao entrar em uma nova sessão da Arena. Não há níveis, DataStore de XP ou progressão permanente nesta entrega.
- Corrida recebe inclinação lateral mais perceptível, leve movimento angular vertical e resposta a curvas. O viewmodel assume uma pose de corrida com balanço da arma e movimento dos cotovelos/mangas. Em R15, a montagem da arma e o apoio de duas mãos acompanham a pose em terceira pessoa.
- A pose volta ao repouso ao mirar, disparar, recarregar, atacar ou parar. O ajuste **Oscilação da câmera = 0** desliga esses movimentos adicionais. Recuo permanece visual, separado da direção autoritativa de pontaria. FOV de corrida mantido.
- HUD da Arena acompanha discretamente a inclinação; notificações têm entrada/saída animadas e a abertura da votação tem transição curta. Navegação e catálogo dos cinco mapas preservados.

As animações novas são procedurais. Não substituem um conjunto final de animações de equipar, recarga, disparo e combate para todos os avatares.

## Revólver

WeaponFactory passou a ModelVersion 4. A geometria de Magnum foi reajustada mantendo marcadores de pegada e alinhando a boca ao novo comprimento:

| Peça | Antes | Agora |
|---|---|---|
| Tambor: comprimento × diâmetro | 0,58 × 0,62 | 0,74 × 0,46 studs |
| Cano: comprimento × diâmetro | 1,05 × 0,22 | 1,52 × 0,17 studs |
| Posição local do Muzzle no eixo Z | -1,92 | -2,39 studs |

Aros, câmaras, sulcos, trava, haste e reforço inferior acompanham as novas proporções. Modelo e braços foram inspecionados em captura de primeira pessoa. Materiais e geometria continuam provisórios.

## Sons

Assets gratuitos encontrados no Creator Store e inseridos como fontes em ServerStorage.CrossgroundsAudioSources:

- [revolver_fire — Hersel_5](https://create.roblox.com/store/asset/115486270266848): disparo das pistolas da Arena.
- [mm2 sheriff hit — afiefhakimi1](https://create.roblox.com/store/asset/135358622908846): confirmação de eliminação.

Disparo com volume 0,68, playback 0,96, alcance de áudio 160 studs, equalização e compressão. A confirmação de eliminação usa volume 0,7 e pequena variação em headshot. Vozes são independentes; outro tiro ou confirmação não reinicia a anterior. Os dois assets são pré-carregados no cliente da Arena. Aumento de intensidade não representa uma avaliação auditiva concluída da mixagem.

## Verificações realizadas

| Verificação | Resultado |
|---|---|
| Contratos | **62 aprovados, zero falhas**; nove novos casos de recompensa, limite de vida, locomoção e câmera. |
| Integridade | 85 fontes conferidas entre disco e Studio, sem diferenças após normalizar espaços finais; 71 fontes de cada pacote comparadas com as atuais, exceto configuração de papel intencional. |
| Vida e isolamento | Arena 20/20 HP e barras nativas ocultas; retorno ao hub e entrada no CTF com 200/200 HP e HealthDisplayType anterior restaurado. |
| Disparo real | Magnum eliminou alvo de treino com 20 HP por headshot; munição 12 → 11, XP e eliminações PvP permaneceram em zero. |
| Notificação real | Mensagem HEADSHOT, Alvo de treino, Magnum e TREINO inspecionada em captura. Toast numérico removido. |
| XP e feed | Recompensas 100/150 e acúmulo 250 testados com objetos simulados. Prévia de UI enviada pelo servidor mostrou arma, +150 XP, bônus incluído e feed; essa prévia não concedeu XP. Eliminação PvP entre humanos ainda não testada. |
| Corrida | W+D e LS simulados em plataforma aberta de QA: velocidade 25, peso de pose 0,582, montagem deslocada até 0,230 stud, variação de manga por quadro até 0,017 stud, roll de câmera até 1,50° e rotação do HUD em torno de 0,59°. |
| Mira e limpeza | Pose voltou praticamente a zero ao mirar. Retorno ao hub zerou pose/pitch, removeu notificações e limpou feed. Objetos de QA removidos. |
| Áudio | Ambos carregaram no cliente: disparo 1,168 s; confirmação 1,409 s. Efeitos de equalização/compressão encontrados no equipamento. |

A primeira tentativa de medir corrida ocorreu contra obstáculo; a verificação válida usou uma plataforma temporária aberta. Ela foi removida, sem alterar os templates dos mapas.

## Fontes e recuperação

Novos módulos: WeaponLocomotion e ArenaRewards. Novos testes: ArenaRewards_Test e Locomotion_Test. Atualizados ArenaDefinitions, ArenaAdapter, ArenaCombat, KitDefinitions, CameraMotion, ArmPose, WeaponPose, CombatPresentation, ArenaHUD e WeaponFactory. Total de **85 fontes**, sendo 71 de runtime/autoramento e 14 de testes. Runner automático desativado.

Backup anterior: **ServerStorage.ArenaFastGameplayBaseline_1792710573**. Pacotes anteriores e originais dos mapas preservados.

| Pacote local | Bytes | SHA-256 |
|---|---:|---|
| [Hub atualizado](../artifacts/crossgrounds-hub-arena-rapida-2026-10-22.rbxm) | 153048 | 5F4665558A23CF9A5C678CB5CDDE46B7B8C0067F4AEFEB8E8249F6F4721D55EE |
| [Arena atualizada](../artifacts/crossgrounds-arena-arena-rapida-2026-10-22.rbxm) | 993963 | E19123E5F2ACAB7D21230BB8FA719430481633E72A8659CC7B2DD9B4639662C8 |

Pacotes por serviço, com 71 fontes cada; Arena inclui os cinco mapas. Fontes de áudio são IDs no código, sem dependência das instâncias de referência guardadas. Instâncias de recuperação: Crossgrounds_hub_FastArenaBundle e Crossgrounds_arena_FastArenaBundle. Instalação no Place remoto da Arena continua pendente. [Guia de Places](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md).

## Limites e problemas observados

- Sem teste PvP com múltiplos humanos, controle/celular físico, R6, avatares extremos, latência ou desempenho comparativo. Poses R15 e primeira pessoa foram verificadas localmente.
- Não houve avaliação auditiva humana ou ajuste por equipamento de áudio. Disponibilidade dos sons em produção ainda precisa ser confirmada após instalação/publicação autorizada.
- Shipment apresentou texturas indisponíveis: 10628328397 não conforme e NormalMap 10628322885 sem aprovação para o solicitante. As texturas não foram removidas dos originais nem substituídas nesta etapa.
- Persistem erros externos conhecidos de GUIEditor e avisos da ferramenta sobre StarterPlayerScripts/câmera. Não apareceram erros dos módulos novos durante o percurso testado.
- Get Out continua indisponível; seus mapas preparados não representam implementação do modo.

Estado entregue: Studio em edição, combinedPrototype, teleporte desativado. Nenhuma publicação, mudança de start place ou remoção do legado.
