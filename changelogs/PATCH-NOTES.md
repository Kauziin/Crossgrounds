# Patch de melhoria — Capture a Bandeira
Data: 22/10/2026. Place: 4375993208.

Atualização mais recente: [acessibilidade, FOV, remapeamento e recuo](ACCESSIBILITY-PATCH-NOTES.md).

Atualização posterior de câmera, controles e menus: veja [CAMERA-PATCH-NOTES.md](CAMERA-PATCH-NOTES.md).

## Entregue no Studio
- Mapa com travessia central, três rotas, conexões laterais, depósitos e novas coberturas.
- Bandeiras em X=-160 e X=160; 24 pontos de spawn por equipe, escolhidos por segurança e ocupação.
- Proteção de spawn de 2 segundos, encerrada ao atacar.
- Lobby jogável com alvos de treino, percurso de saltos e seleção de kit. Contagem de 8 segundos após um jogador ficar pronto; retorno ao lobby sem destruir o personagem.
- Equipes de até 6 participantes, completadas por bots. Respawn dos bots em 7–9 segundos.
- Bots com reação, rajadas, munição, recarga, rotas, escolta, interceptação e busca de cobertura.
- Avatares de amigos dos jogadores, com cache e aparência aleatória reserva; indicação discreta de IA e identificação de equipe.
- Armas com novos modelos e nomes fictícios. SMG e rifle automáticos; dano reduzido com a distância.
- Mira compartilhada com o sistema de câmera e cursor, com verificação do disparo a partir da arma.
- Melee por contato com a lâmina durante a janela de ataque; um acerto por vítima por golpe. Machado maior e com dano em área.
- Serviço de dano compartilhado entre jogadores e bots, hit marker visual e sonoro, aviso local de eliminação e killfeed de até 5 entradas.
- HUD compacto com vida, estamina, munição e dois slots. Menu e confirmação de saída navegáveis pelo controle.
- Margens de segurança e escala maiores para console; ajustes de toque para celular.
- Noob decorativo estabilizado e iluminação diurna fixa.

## Balanceamento inicial
Todos os personagens de combate têm 200 HP. Headshots de jogadores multiplicam o dano das armas de fogo por 1,35. Bots usam dano base e dispersão.

| Perfil | Melee | Arma de fogo | Dano próximo / distante | Intervalo | Carregador |
|---|---|---|---|---|---|
| Leve | Faca: 26, 0,25 s | Vasnev 9mm | 19 / 11 | 0,095 s | 32 |
| Regular | Executor: 65, 0,55 s | Kastov 545 | 29 / 20 | 0,145 s | 26 |
| Pesado | Treme-Terra: 110, 1,15 s | Lachmann LMS | 150 / 125 | 1,55 s | 5 |

A queda de dano ocorre entre 45–135 studs para a SMG, 90–220 para o rifle e 250–450 para a sniper. Os perfis mantêm velocidades, corrida e saltos distintos.

## Validação realizada
- Compilação de sintaxe dos scripts alterados sem erros.
- Entrada no jogo e navegação do menu por LB/RB, D-pad e A.
- Confirmação de saída por B, D-pad e A.
- Três travessias e acesso às duas bandeiras com PathStatus.Success.
- Captura e entrega de bandeira com atualização de placar.
- Dano apenas durante ataque melee; machado atingiu dois alvos em um golpe.
- Dano de disparos, eliminação, crédito e confirmação enviados pelo servidor.
- Disparos automáticos e recarga com consumo/reposição corretos.
- Sete acertos no alvo sob o cursor após corrigir a margem superior da tela.
- Bot eliminado sem substituição imediata e substituído após o cooldown.
- Som de hit marker carregado no cliente.
- Menu e HUD inspecionados em simulações iPhone 17 Pro e Xbox One, em paisagem. Viewport restaurado ao padrão.
- Nenhum erro dos novos sistemas observado no último playtest. Há mensagens de um plugin GUIEditor externo no Studio.
- Ajuste fino de dificuldade, equilíbrio e desempenho depende de partidas com vários jogadores e de controle físico.

## Arquivos e recuperação
Os scripts em src/ refletem as instâncias do Studio, organizados por serviço.
artifacts/three-lanes-patch.rbxm contém cenário e sistemas, organizados por serviço, para recuperação.
O pacote inclui a propriedade Enabled=false do DisplayScript antigo. Preserve essa propriedade ao recuperar por arquivos de fonte.
A iluminação foi ajustada no Studio: ClockTime=14, Brightness=2, Ambient=(112,117,132), OutdoorAmbient=(146,151,164).
Um backup anterior ao patch também está em ServerStorage.ImprovementPatchBackup_1792635533.

## Publicação
O patch está aplicado no Studio. A tentativa de publicação pela API foi recusada: SavePlace só pode ser chamado por um script do servidor.
A ferramenta de controle do Windows falhou com CryptUnprotectData; a publicação pela interface ficou pendente.
Para publicar a edição atual, use Arquivo > Publicar na Roblox no Studio.
