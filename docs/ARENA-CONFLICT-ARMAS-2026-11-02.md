# Arena e Conflict: regras de armas — 02/11/2026

## Arena

Removidas Blaster e AutoBlaster da lista de seleção de pistolas. As duas permanecem no Conflict. A definição compartilhada ArenaPistol agora é semiautomática. Todas as aparências utilizam o mesmo WeaponId ArenaPistol e os mesmos dados no cliente e no servidor; a geometria não altera a capacidade, o dano, a cadência, a precisão, a recarga ou o recuo.

Preservadas as seis aparências procedurais (M1911, Magnum, Glock 18, Desert Eagle, Luger e Beretta) e incluídas sete MW: 1911, .357, X16, M19, Forge Tac .50 GS, Renetti e Sykov. São 13 aparências. Glock 18 e Sykov também disparam em modo semiautomático no Arena. Configurações antigas com Blaster/AutoBlaster não passam por IsPistolVisual e são substituídas pelo fluxo normal de validação ao entrar.

Valores comuns preservados, exceto Automatic=false: dano inicial 45, mínimo 14, intervalo 1 s, carregador 12, reserva 120, recarga 0,9 s, alcance 210 e dispersão 0,2°. Modelos MW são saneados pelo ImportedWeaponVisuals já existente, sem acessórios. ArenaWeapon impede que os dados do modelo MW sejam usados como atributos de combate. Executor/faca e demais regras do modo não foram alterados.

## Conflict

Nome exibido atualizado de Capture a Bandeira/CTF para Conflict no catálogo, lobby, seleção, botão de kits e placar. ID interno ctf, remotos, perfis e persistência foram preservados.

As sete pistolas MW continuam com suas definições individuais existentes. M1911/Magnum/Desert Eagle já possuem equivalentes MW, sem necessidade de duplicar essas armas no Armeiro. Completadas três opções procedurais da família originalmente visual do Arena, como secundárias independentes:

| Opção | ID de catálogo / combate | Dano / mínimo | Cadência | Pente / reserva | Recarga | Dispersão |
|---|---|---:|---:|---:|---:|---:|
| Glock 18 | legacy_Glock18 / Glock18 | 23 / 12 | 0,085 s, automática | 17 / 102 | 1,55 s | 0,65° |
| Luger P08 | legacy_Luger / Luger | 38 / 19 | 0,27 s, semi | 8 / 64 | 1,85 s | 0,16° |
| Beretta M9 | legacy_Beretta / Beretta | 29 / 15 | 0,19 s, semi | 15 / 90 | 1,45 s | 0,24° |

Tuning de gameplay configurável, não declaração de especificação histórica. Recuo visual próprio para cada opção. Modelos procedurais existentes, grupos de recarga e poses de pistola reutilizados. Três prévias saneadas adicionadas a ReplicatedStorage.Crossgrounds.LoadoutPreviews; Arena mantém o backend compartilhado e Conflict mantém IDs próprios. Não foi ativado passe nem comprado asset novo.

## Validação

- Em Play, as 13 aparências foram construídas, todas com WeaponId ArenaPistol, ArenaWeapon=true e a mesma definição efetiva; Automatic=false em todas.
- Pelo ArenaCombat real, Sykov foi equipada, validada e recarregada de 3/20 para 12/11, usando os valores comuns.
- Tool com WeaponId AutoBlaster e ArenaWeapon=true foi rejeitada por ArenaCombat.Valid.
- Três contratos ArenaConflictWeapons passaram; três novas prévias foram construídas sem erro.
- Preset com legacy_Luger salvo pelo RemoteFunction normal e reaplicado no respawn: Tool Luger, Ammo=8, dano 38, cooldown 0,27 e sem ArenaWeapon.
- WeaponHold classificou Glock18/Luger/Beretta como pistolas. Não houve inspeção manual de todas as animações/visuais em múltiplos dispositivos nem teste multiplayer humano.
- Corrigida mutação preexistente em WeaponCatalog.Get que reinseria magazine a cada consulta: 50 consultas repetidas mantiveram o número de slots constante.
- Nome Conflict conferido no catálogo em execução. diff sem erros.

Backups em artifacts/arena-conflict-2026-11-02/before e ServerStorage.Development.Revisions.ArenaConflictBaseline_20261102. Principal deixado em Edit; QA de presets limitado à sessão Studio. Sem publicação nem teste de persistência na experiência publicada.
