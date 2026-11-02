# AX-50 — carregadores e estabilidade, 02/11/2026

Implementado no Crossgrounds (ALPHA), place 4375993208, sem publicação. Originais preservados em ServerStorage; nenhuma geometria foi colocada no mapa. Backup das sete fontes em `ServerStorage.Development.Revisions.AX50AccessoriesBaseline_20261102` e `artifacts/ax50-accessories-2026-11-02/before`.

## Acessórios funcionais

| Acessório | Capacidade | Velocidade de movimento | Velocidade de ADS | Tempo de recarga |
|---|---:|---:|---:|---:|
| Padrão | 5 | ×1 | ×1 | ×1 (4,145 s) |
| 7rnd .50 BMG Magazine | 7 | ×0,97 | ×0,95 | ×1,05 (4,35225 s) |
| 9rnd .50 BMG Magazine | 9 | ×0,94 | ×0,90 | ×1,10 (4,5595 s) |
| Forge Tac Hunter · adaptada AX-50 | Mantida | ×0,98 | ×0,90 | Mantido |

Os dois carregadores são modelos originais encontrados em `CoD:MW Weapon/Attachment Props.ATTACHMENTS.Magazines`. Não estavam registrados no catálogo de acessórios: criados os IDs `magazines_7rnd_50_bmg_magazine` e `magazines_9rnd_50_bmg_magazine`. Encaixe exclusivo `AX50MagazineWell`; alinhamento pelo Bullet, substituição das duas peças do carregador original e participação no grupo Magazine da recarga existente.

Hunter usa a geometria disponível em `ATTACHMENTS.Model.Forge Tac Hunter`, adaptada ao encaixe `AX50Stock`. O nome no menu explicita a adaptação; não se afirma ser uma coronha original específica da AX-50. A peça Stock nativa fica oculta enquanto equipada. Alinhamento considera a extremidade frontal real dos vértices da caixa de cada peça, independente da orientação do bounding box.

A Hunter aplica `AdsMotionMultiplier=0.4`: reduz em 60% o bob/roll/pitch cosmético da câmera, o canal de locomoção do viewmodel durante ADS e a respiração da luneta AX-50. Hipfire, movimentos de equipar/recarga, recoil e ferrolho continuam com seus canais próprios. O parâmetro é reutilizável em outras armas e não cria outro escritor de Camera.CFrame. As preferências existentes de movimento continuam valendo.

Penalidades multiplicam entre acessórios: 9 + Hunter resulta em movimento ×0,9212 e velocidade de ADS ×0,81. São valores de balanceamento, não massas físicas medidas. Dano, cadência, dispersão, velocidade de projétil e reserva mantidos. Compatibilidade exclusiva AX-50; Arena segue o resolvedor isolado já existente. Assets mantêm bloqueio de publicação preexistente.

## Validações realizadas

- Compilação das sete fontes alteradas no Studio; construção de padrão, 7, 9, Hunter e 9+Hunter em módulos novos para evitar cache do Edit.
- Três contratos em Play: capacidade exata/penalidades/invariância balística/rejeição em outras armas; composição da coronha sem mudança no recuo; redução de bob exatamente ×0,4 em ADS e ausência de mudança no hipfire a 30/60/120 FPS.
- Script nativo opt-in `tests/Integration/AX50Accessories.server.luau`: servidor aceitou um disparo de cada variante (Ammo 1→0), recusou o próximo com motivo `ammo`, recarregou de 3/20 para 7/16 e 9/14, respeitou ReloadDuration e recarregou reserva curta de 0/2 para 2/0. Fixture fica fora do gerenciador de bots entre chamadas para evitar interferência.
- Galeria de modelos em Play inspecionada: carregadores 7/9 e Hunter visíveis, originais substituídos. Prévia incremental passou por 5→7→9→5, restaurando duas peças do carregador original e Stock, sem acessórios remanescentes.
- Slots de carregador/coronha e compatibilidade validados. `git diff --check` passou, com avisos de CRLF em arquivos alheios já modificados.

Limites: não houve teste com controle físico, nova gravação contínua das animações, verificação de clipping de todas as combinações ou salvamento/respawn de preset por remoto nesta rodada. Consumo/recarga foram exercitados na autoridade nativa de NPC, não em uma partida multiplayer publicada. Avaliação subjetiva da estabilidade e penalidades continua aberta. Play encerrado; principal em Edit. Sem publicação na Roblox.
