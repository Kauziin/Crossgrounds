# Disparo, áudio e geometria — 22/10/2026

## Implementação local

- O traçador de primeira pessoa começa no Muzzle do viewmodel visível. Os demais observadores usam a boca do equipamento real. O servidor envia o ponto final efetivamente atingido.
- CTF, Arena e bots calculam a trajetória a partir da boca da arma. Para primeira pessoa, o servidor aceita uma origem próxima e limitada ao personagem: até 6,5 studs da cabeça, deslocamento longitudinal entre -1 e 6 studs e lateral até 2 studs. Valores inválidos usam a boca real. Uma verificação entre cabeça e origem impede atravessar cobertura com esse deslocamento.
- Aliados e corpos continuam sendo ignorados. A sniper continua limitada a dois inimigos, com dano 100%/80%; paredes interrompem a trajetória.
- Cada disparo clona uma voz de áudio em um emissor independente na posição da boca da arma. Trocar o equipamento ou disparar novamente não interrompe a voz anterior. Ended remove o emissor; Debris limita sua permanência a 12 segundos. Os arquivos de som existentes foram mantidos. Referência de ciclo de vida: [Sound](https://create.roblox.com/docs/reference/engine/classes/Sound).
- O recuo usa uma mola com amortecimento, com impulso e subida visual por arma. Atua sobre o viewmodel, sem alterar a câmera ou a direção autoritativa do tiro. Fuzil e, principalmente, sniper têm perfis mais intensos.
- A seleção da Arena mostra nomes e escolha para o próximo respawn, removendo o texto explicativo sobre equivalência de atributos.

### Intervalos entre ataques

| Arma | Antes | Agora |
|---|---:|---:|
| Faca | 0,25 s | 0,32 s |
| Vasnev 9mm | 0,095 s | 0,13 s |
| Executor | 0,55 s | 0,70 s |
| Kastov 545 | 0,145 s | 0,20 s |
| Treme-Terra | 1,15 s | 1,50 s |
| Lachmann LMS | 1,55 s | 2,00 s |
| Pistola da Arena | 0,22 s | 0,34 s |

Dano, munição, alcance, mobilidade e janelas de contato não foram alterados neste ajuste.

### Geometria

WeaponFactory ModelVersion 3 acrescenta chanfros, miras, parafusos, serrilhas, detalhes de carregador, coronha, cano e mecanismos. Magnum recebe tambor com sulcos e câmaras; a sniper recebe detalhes da luneta e montagens. Melees recebem detalhes de lâmina, guarda, cabeça e cabo. Luvas de primeira pessoa passam a ter peças arredondadas.

| Modelo | Partes antes | Partes agora |
|---|---:|---:|
| M1911 | 28 | 66 |
| Magnum | 22 | 60 |
| Glock 18 | 28 | 69 |
| Vasnev 9mm | 41 | 68 |
| Kastov 545 | 41 | 67 |
| Lachmann LMS | 48 | 90 |
| Faca | 12 | 20 |
| Executor | 15 | 24 |
| Treme-Terra | 16 | 31 |

As peças permanecem sem colisão, toque ou consulta física, sem massa própria e soldadas. Marcadores de pegada e hitboxes foram preservados. São modelos procedurais provisórios; não são meshes finais com UV/texturas ou animações completas.

## Verificações realizadas

Ambiente: um cliente de Play no Studio, entradas simuladas e alvos/posições controlados para QA.

| Verificação | Resultado |
|---|---|
| Contratos automatizados | 47 aprovados, zero falhas. Novos casos cobrem limites da origem, cobertura, aliados e estabilidade/retorno do recuo. |
| Integridade | 76 fontes locais conferidas com as instâncias reais; 66 de runtime e 10 de teste. O runner automático permanece desativado. |
| Modelos | Nove variantes construídas; contagens acima conferidas. Capturas de Play de Magnum/Glock em primeira pessoa inspecionadas. |
| Disparo da Arena | Quatro tiros durante aproximadamente 1,1 s de RT pressionado, munição 12 → 8. |
| Origem visual | Quatro traçadores comparados imediatamente ao Muzzle do viewmodel; distância observada de zero studs. Origem distinta da cabeça. |
| Áudio independente | Duas vozes simultâneas tocando. Para facilitar a medição, o template foi temporariamente desacelerado para 0,25 no QA e restaurado a 1; não é avaliação auditiva da mixagem. Som original carregado, duração 1,173 s. |
| Recuo visual | Pico observado na pistola: 0,084 stud / 1,72°; na sniper: 0,496 stud / 4,13°. Retorno ao repouso observado. |
| Penetração CTF | Alvos de 400 HP: aliado 400, primeiro inimigo 250, segundo 280, terceiro 400. Fluxo real do remoto com origem de primeira pessoa. |
| Cobertura antes da boca | Parede entre cabeça e origem solicitada impediu dano: todos os alvos permaneceram com 400 HP. |
| Ciclo de equipamento | Seleção Magnum → Glock aplicada no respawn. |
| Retorno ao hub | Câmera de combate e viewmodel desativados; deslocamento/ângulo de recuo zerados. Objetos de QA removidos. |

## Entrega e recuperação

Backup de fontes no Studio: ServerStorage.MuzzleAudioGeometryBaseline_1792702122. Fontes alteradas incluem KitDefinitions, WeaponFactory, Ballistics, KitService, ArenaCombat, BotBrain, WeaponEffects, CombatPresentation, WeaponController, ArenaHUD e ArenaAdapter. Novos módulos: ShotEffects e WeaponRecoil; novos testes: MuzzleOrigin_Test e WeaponRecoil_Test.

| Pacote local | Bytes | SHA-256 |
|---|---:|---|
| [Hub](../artifacts/crossgrounds-hub-disparo-geometria-2026-10-22.rbxm) | 143147 | AC5466A39F58A54FC0793BF496B4E07E31F3BF3E42ABF895991BDF904F3C1451 |
| [Arena](../artifacts/crossgrounds-arena-disparo-geometria-2026-10-22.rbxm) | 192800 | 5C582D0F0889B618CA31FF3E0821D2FE2F5DBF06CD9E8BF5EFE8DFF9FC54DC46 |

Cada pacote contém 66 fontes de runtime, organizadas por serviço. Instâncias de recuperação: Crossgrounds_hub_MuzzleGeometryBundle e Crossgrounds_arena_MuzzleGeometryBundle. Pacotes anteriores preservados. [Instruções de instalação](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md).

O projeto atual continua combinedPrototype com entradas locais CTF/Arena e teleporte desativado. Nenhuma publicação, alteração de start place ou remoção do legado. Instalação no Place remoto da Arena 84561729907420 continua pendente.

## Limites e pendências

- Testes físicos de controle/celular, vários humanos, latência e viagens entre Places não realizados.
- Mixagem, percepção dos sons, enquadramento em todos os FOVs e paredes próximas precisam de avaliação jogando.
- O aumento de partes requer medição de desempenho em aparelhos modestos; não houve benchmark comparativo.
- Animações completas, articulação das mãos, alinhamento de miras, mira vertical do corpo/bots e arte final continuam pendentes.
- Erros legados de GUIEditor/teleporters não são resolvidos por este patch.

O relatório anterior de balística permanece como histórico; esta etapa atualiza a origem do disparo, intervalos, áudio, recuo e geometria.
