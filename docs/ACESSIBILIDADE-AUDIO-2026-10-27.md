# Acessibilidade, FOV das armas e feedback sonoro

Aplicado ao modelo de edição do Crossgrounds (ALPHA), placeId 4375993208, em 2026-10-27. Sem publicação e sem iniciar Play na experiência principal.

## Preferências

As seis opções usam ExperienceSettings e o protocolo de preferências existente; perfis antigos recebem os padrões sem migração destrutiva.

| Categoria | Opção | Padrão / funcionamento |
| --- | --- | --- |
| Acessibilidade | Animações simples | Desligada. Ligada reduz movimentos de personagens, oscilação da câmera e movimentos das armas. Mantém posturas necessárias do Get Out. |
| Acessibilidade | Movimento das armas | 100%; ajuste de 0 a 100% para balanço, ações, recarga e recuo visual. |
| Acessibilidade | Velocidade do FOV | 100%; valores menores suavizam e desaceleram as transições até 15% da velocidade normal. |
| Câmera e perspectiva | FOV das armas | Menos intenso / normal / mais intenso. Normal preserva a câmera de armas de 70°. As outras opções modificam a perspectiva e sua resposta ao FOV do cenário. |
| Áudio | Sons da partida | 50%; volume dos novos avisos e eventos. |
| Áudio | Proximidade da Besta | 35%; volume independente para o Get Out, inclusive silenciamento completo. |

As preferências de movimento são cosméticas e locais ao observador. Não alteram velocidade física, dano, alcance, hitboxes, duração da recarga ou regras de seleção de armas. A compensação de profundidade mantém o enquadramento ao alterar a câmera de armas; a origem visual dos tiros continua usando a projeção correspondente.

## Áudio

Vinte tipos de sinais no GameAudioCatalog: bandeira roubada, adquirida, derrubada, retornada, capturada e perdida; eliminação, renascimento, dano, início/fim de rodada; teste de hacking, falha, computador concluído, sobrevivente derrubado, capturado, resgatado, fuga, fúria e proximidade da besta.

A bandeira usa o CTFFlagAlert existente e distingue a bandeira do próprio time. A eliminação na Arena continua funcionando quando ArenaPlaying é limpo antes de Humanoid.Died. Os sinais de Get Out comparam snapshots e não repetem eventos antigos ao abrir o modo ou receber snapshots iguais. O teste de hacking avisa uma vez por janela.

O pulso da besta cresce e acelera entre 70 e 15 studs. É exclusivo de sobreviventes ativos, vivos, não presos na cápsula e na mesma rodada da besta. Para ao sair do modo, morrer, encerrar a rodada ou silenciar seu volume. As vozes possuem limites de repetição e dois canais reutilizados por sinal.

A navegação agora usa o som oficial Roblox Hover 01 no foco. Ativações por controle de elementos registrados sem Nav:Connect também recebem feedback, preservando o feedback já existente das conexões e ajustes.

## Fontes dos sons

Pesquisa no Creator Store via Studio: RBLX UI, heartbeat, heartbeat 01, UI notification e game alert. Selecionados os SFX Roblox e o Human_Heartbeat_Full_01 de Alexware. ContentProvider:PreloadAsync retornou Success para todos os oito IDs utilizados e os dois sons locais de reserva.

- [Roblox RBLX UI Hover 01](https://create.roblox.com/store/asset/10066931761)
- [Roblox RBLX UI Hover 02](https://create.roblox.com/store/asset/10066936758)
- [Roblox RBLX UI Select 01](https://create.roblox.com/store/asset/10128760939)
- [Roblox RBLX UI Select 02](https://create.roblox.com/store/asset/10066968815)
- [Roblox RBLX UI Swipe](https://create.roblox.com/store/asset/10128766965)
- [Roblox RBLX UI Delete](https://create.roblox.com/store/asset/10066926605)
- [Roblox RBLX UI Purchase](https://create.roblox.com/store/asset/10066947742)
- [Human_Heartbeat_Full_01](https://create.roblox.com/store/asset/2936809023)

## Validação e limites

57 verificações isoladas no Luau do Studio: 30 de preferências, migração e política de eventos; 9 do controlador; 5 do renderizador real com ViewportFrame; 8 de vozes e silenciamento; 5 da simplificação/restauração de juntas reais. Os testes usam sinais e estados injetados, instâncias reais quando necessário, e removem os objetos temporários. Não equivalem a uma partida com vários jogadores nem a uma avaliação auditiva em celular físico. As doze fontes aplicadas compilam, e sua leitura de volta confirmou a aplicação.

Os arquivos de teste e as fontes anteriores estão em artifacts/access-audio-2026-10-27/. As alterações existentes foram aplicadas com comparação das fontes do principal para preservar edições concorrentes. Os sistemas de persistência, combate e estado de rodada do servidor não foram modificados.
