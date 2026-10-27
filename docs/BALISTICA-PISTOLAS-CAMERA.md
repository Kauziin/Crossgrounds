# Crossgrounds — balística, clarões, pistolas e câmera do editor

**22/10/2026. Aplicado no projeto integrado do Studio e em `src/`. Não publicado.**

## Entrega

- Tiros do CTF ignoram personagens aliados inteiros, incluindo acessórios, para jogadores e bots. Corpos mortos também são ignorados. A seleção de pontaria do cliente recebeu o mesmo filtro de aliados; paredes continuam bloqueando.
- A sniper atinge **até dois inimigos no total por disparo**: primeiro com 100% do dano, segundo com 80%. Aliados não consomem essa passagem. A redução combina com distância e headshot, com arredondamento inteiro ao final. Sem penetração de paredes; o terceiro inimigo fica intacto.
- `Ballistics` centraliza o hitscan usado por KitService, BotBrain e ArenaCombat. Personagens já atingidos são excluídos por inteiro para não receber dano repetido em vários membros. Alvos cuja aplicação de dano foi recusada bloqueiam a continuação do tiro.
- Colisão dos tiros parte da cabeça, evitando originar a colisão do outro lado de uma cobertura quando o cano está atravessando geometria. O traçante do CTF parte visualmente da boca da arma.
- Clarão na boca de todas as armas de fogo: partículas com textura interna do Roblox, chama por Beam e luz curta posicionada no Muzzle. Sniper possui clarão maior. O efeito dura aproximadamente 45 ms e também é disparado no modelo dedicado de primeira pessoa. Não depende de asset novo enviado à plataforma.
- Arena substituiu o fuzil por uma pistola com três modelos: **M1911**, **Magnum** e **Glock 18**. O Executor permanece como segunda arma, acessível por Y. Movimento e 200 HP do protótipo permanecem.
- Os três visuais usam o mesmo WeaponId e uma única definição de combate: 45 de dano próximo, mínimo 30 com distância; intervalo de 0,22 s; alcance 220; carregador 12; reserva 72; recarga de 1,6 s; mesmo recuo e disparo contínuo ao manter o botão pressionado. Magnum não recebe vantagem de dano nem Glock recebe cadência diferente. São modelos inspirados nas referências, sem simulação fiel das armas reais.
- Seleção de visual no painel da Arena, com navegação por D-pad/A e cursor próprio. A escolha inicial é aleatória; a escolha manual vale no **próximo respawn**, para não repor munição ao trocar o visual. Escolha mantida na sessão, sem novo DataStore.
- CombatPresentation retorna sem adquirir câmera quando inspecionado fora de Play. A câmera do editor foi restaurada separadamente; o usuário confirmou que voltou a mover a visão.

## Testes realizados

| Verificação | Resultado |
|---|---|
| Contratos automatizados | 40 executados, 40 aprovados, zero falhas. Incluem oito novos contratos de balística. |
| Sniper pelo WeaponAction real do CTF, contra NPCs de QA no Workspace | Com 400 HP iniciais: aliado 400, primeiro inimigo 250, segundo 280, terceiro 400. Danos 150/120/0 confirmados no servidor. |
| Parede entre primeiro e segundo inimigo | Primeiro ficou com 250; segundo, terceiro e aliado permaneceram com 400. |
| Fuzil na mesma linha de alvos | Aliado 400; primeiro inimigo 371; demais 400. Ignorou o aliado e parou após 29 de dano no primeiro inimigo. |
| M1911 na Arena, contra alvo de QA válido no cenário da modalidade | Alvo passou de 400 para 355 HP. |
| Factory das três pistolas | Mesmo WeaponId, dano 45 e cooldown 0,22; M1911/Glock com 28 partes cada, Magnum com 22; todos possuem efeitos no Muzzle. |
| Seleção por gamepad simulado | D-pad alcançou Glock 18; A selecionou. Magnum equipada permaneceu até morrer; após respawn veio Glock 18. |
| Visual inválido enviado ao servidor | Rifle recusado; seleção anterior M1911 preservada. |
| Disparo, recarga e troca na Arena | Cinco disparos, recarga para 12 com reserva 67; Y alternou Executor/pistola. |
| Clarão mundial e primeira pessoa | Luz mundial acionada nos cinco disparos observados. Em uma amostra separada de dois disparos, luz/chama do viewmodel também acionaram e desligaram após o pulso. O primeiro contador por ordem de callback não detectou o efeito; a repetição por alteração da propriedade confirmou o acionamento. |
| Pegada da pistola no avatar R15 | Mãos a menos de 0,001 stud das pegadas na conferência da Glock 18. |
| HUD/menu/modelo | Inspeção visual do painel com três escolhas e da Glock 18 em primeira pessoa. |
| Retorno ao hub | Sem Tool ou viewmodel residual; CombatCameraActive=false. |
| Fontes | 72 fontes iguais entre Studio e disco, incluindo os oito fontes de testes. Cada pacote dedicado contém 64 fontes de runtime. |

Os contratos novos verificam acessórios aliados, limite de alvos, parede antes/depois do primeiro alvo, proteção recusada, um acerto por personagem, corpos ignorados e combinação de perda de dano/distância/headshot. O runner continua manual e desativado na inicialização.

O teste de penetração usou o fluxo real do jogador, servidor e raycast contra NPCs temporários. Os objetos de QA foram removidos e os personagens de teste foram liberados. Não foi uma sessão PvP com vários humanos. A atualização dos tiros e percepção dos bots usa a mesma balística, mas não houve uma sessão controlada específica de bots alinhados atrás de aliados.

## Restaurar a câmera por conta própria

1. Pare o Play/Stop para voltar à edição.
2. Abra a **Command Bar** com **Ctrl+9**. Também está em **Window → Script** ou na aba **Script**.
3. Execute este comando; na barra multilinha, use **Ctrl+Enter**:

```lua
workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
game:GetService("UserInputService").MouseIconEnabled = true
```

Ele restaura o tipo padrão observado em uma Camera nova no editor e libera o mouse. Não altera CFrame, mapa ou scripts. Se estiver operando por uma ferramenta que restaura a câmera ao terminar um comando, envolva essas três linhas em `task.delay(1, function() ... end)`; essa foi a restauração confirmada nesta sessão.

A origem exata de quem manteve Scriptable no editor não foi isolada. Foi observado que uma alteração imediata por ferramenta podia ser revertida após a chamada; o reset adiado funcionou. Não foi instalado um plugin nem um controlador permanente de câmera no editor.

Referências consultadas: [Command Bar do Studio](https://create.roblox.com/docs/studio/ui-overview#command-bar), [ParticleEmitter.Emit](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter#Emit).

## Pacotes e recuperação

| Pacote | Bytes | SHA-256 |
|---|---:|---|
| [Hub](../artifacts/crossgrounds-hub-balistica-pistolas-2026-10-22.rbxm) | 137864 | 7B56D98BCADA57449BF09A888CFD29C1AC7918FAFD5495DEF985B312B378768F |
| [Arena, com dois mapas](../artifacts/crossgrounds-arena-balistica-pistolas-2026-10-22.rbxm) | 187499 | 13A889E155E837A9000BFBA60463803F91F7C7DB26027B07FC36C34D22E97FB8 |

Instâncias: ServerStorage.Crossgrounds_hub_BallisticsPistolsBundle e Crossgrounds_arena_BallisticsPistolsBundle. Backup de fontes anteriores: **BallisticsPistolsBaseline_1792697681**. Arquivos/pacotes anteriores mantidos.

Pacotes organizados por serviço; instalação manual conforme [guia de Places](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md). ArenaPlaceId=84561729907420, TeleportEnabled=false. O novo Place remoto não foi aberto/instalado nesta etapa. Projeto atual permanece combinedPrototype; legado, terreno e start place preservados.

## Pendências

- Controle físico, toque, rede com vários clientes, visibilidade dos efeitos sob latência e desempenho em aparelhos modestos.
- Acabamento dos modelos, animações completas, mira vertical do corpo/arma e matriz de avatares/R6 continuam pendentes.
- Arena segue com parâmetros provisórios de 200 HP. Este patch não implementa a regra final proposta de Arena Clássico de um acerto para eliminar nem define lotação.
- Escolha de visual da pistola não persiste entre servidores; não foi pedido um sistema de inventário/desbloqueio.
- Erros anteriores do GUIEditor e dos teleporters legados continuam separados deste patch. Nenhum erro dos módulos novos foi observado nos testes de execução.
- Instalação dos pacotes no Place dedicado, permissões, publicação e teleporte real seguem pendentes. **Nenhuma publicação foi realizada.**
