# Arsenal importado e Gunsmith visual — 31/10/2026

A instrução adotada está em [instructions/Arsenal/Crossgrounds_Arsenal_Importado_Gunsmith_Visual.md](../instructions/Arsenal/Crossgrounds_Arsenal_Importado_Gunsmith_Visual.md). Experiência inspecionada: Crossgrounds (ALPHA), Place ID 4375993208. Nenhuma publicação ou operação de salvamento na nuvem pelo agente.

## Estado implementado

Os 13 imports de armas saíram do Workspace e foram preservados em `ServerStorage.ImportedArsenalOriginals`. Isso elimina sua renderização no cenário e sua replicação para clientes; não é uma medição de redução imediata de RAM do editor. Não se deixou uma exposição de dezenas de armas no mapa.

O inventário contém 229 registros: 52 modelos-base MW, 97 acessórios/itens auxiliares, 68 variantes/conjuntos e 12 containers externos. O container de espadas inclui mais 32 MeshParts individuais, também catalogados. O catálogo final possui 93 definições (52 MW, duas externas únicas, 32 espadas e sete adaptadores legados), mais 68 variantes e 97 acessórios/itens auxiliares. Variantes não foram contadas como novas armas. Nem todo item auxiliar é um acessório montável.

M4A1 e 1911 são o piloto integrado. Usam as definições ativas Rifle e ArenaPistol como adaptadores provisórios, sem importar regras de disparo MW nem inventar estatísticas. O usuário escolhe primária e secundária independentemente em cinco loadouts nomeáveis, aplicados no nascimento seguinte. A espada atual é preservada; classes e suas regras de movimentação não foram redesenhadas. A Arena continua com seu seletor cosmético próprio e bots continuam no caminho legado.

Há Gunsmith dentro da cascata existente, com foco e retorno do MenuNavigation. Modelos são solicitados individualmente ao servidor; há um único modelo de cache por jogador. A câmera do ViewportFrame é preservada ao trocar acessórios. Mouse/toque podem arrastar a prévia, scroll/pinça ajustam zoom limitado; controle possui foco de rotação específico e LB/RB alternam presets. A navegação foi implementada sobre os controles existentes; avaliação completa com console e aparelho touch reais permanece pendente.

A M4A1 tem três montagens verificadas no piloto: reflex G.I, Monolithic Suppressor e Commando Foregrip. Outras montagens não foram presumidas; os demais acessórios estão em PreviewOnly. Os modelos de miras originais são ocultados ao instalar a reflex. Magazines/bolt/slide mantêm ReloadGroup e os modelos de Tool usam Motor6D, preservando possibilidade de animação. A apresentação FP continua com braços quadrados da skin, o renderizador e movimentos procedurais existentes. Não foram inventados clipes de animação para o pacote.

Acessórios são exclusivamente visuais. Dano, dispersão, recuo, cadência, munição, alcance, zoom funcional, ruído e hit registration não recebem modificadores. WeaponStats separa baseStats, attachmentStatIntent e effectiveGameplayStats, com statsSchemaVersion=1. A UI mostra unidades verificadas e campos desconhecidos; comparação usa somente dados-base, sem bônus de acessórios.

Presets visuais são independentes do loadout, validados no servidor e limitados a 20; loadouts são limitados a cinco. O serviço possui esquema versionado e DataStore Crossgrounds_VisualArsenal_v1 fora do Studio. No Studio, o estado é explicitamente StudioSessionOnly. Falha de leitura impede salvar por cima de dados não carregados; gravações são agrupadas. Persistência real entre servidores/reconexões publicadas não foi testada.

## Prioridade MW e compatibilidade

Conforme a correção do usuário, modelos MW prevalecem sobre duplicatas externas. Os imports externos duplicados continuam arquivados, sem apagar o original. A seleção nova também oculta o adaptador procedural 725 duplicado; seu ID permanece válido para compatibilidade com kits/presets antigos. Variantes internas do próprio MW e variantes de acessórios foram preservadas separadamente.

| Import externo arquivado | Plataforma MW preferida |
|---|---|
| 725 | 725 |
| M4A1 | m4a1 |
| MP7 [ACS] | mp7 |
| MP5 | mp5 |
| P90 | p90 |
| ACS [2.0.1] PKM | pkm |
| IZhMASh Dragunov SVDS 6V3 | dragunov |
| M14 | ebr14 |
| [ACS/RCM FN FAL] | fal |

## Validação efetivamente realizada

- Nove contratos passaram na cópia e novamente nas fontes finais em novo Play: slots independentes, restrição PreviewOnly, secundária compatível, rejeição de acessórios cruzados, estatísticas sem bônus, remoção de código, grupos móveis, Arena independente, prioridade MW e variantes de acessórios.
- As 258 entradas de prévia foram construídas e descartadas sem erro; a verificação final também rejeitaria qualquer LuaSourceContainer ou RemoteEvent copiado. Isso verifica construção e filtragem, não inspeção visual individual de todas as texturas, orientações ou triângulos.
- Fluxo real de servidor: preset com M4A1 + 1911 + espada salvo, pendente e aplicado após respawn. Primária com 34 partes e 33 Motor6Ds; pistola com 11 partes e dez Motor6Ds. Três acessórios presentes sem conceder munição adicional.
- Mouse nativo: M4A1 26 → 23, disparos aceitos; troca por G equipou 1911, que disparou em FP e passou de 12 → 11 com aceitação do servidor. Estes são os atributos do núcleo atual, sem rebalanceamento.
- Seleção inválida de AK-47 PreviewOnly rejeitada sem mudar o estado anterior. Preset visual independente salvo no estado da sessão.
- Cache com UUID por solicitação verificado pela requisição da AWP; apenas um modelo permaneceu no cache.
- Capturas do menu, prévia e FP verificadas em PC. Simulação iPhone 17 Pro em landscape: viewport efetivo 749×381, jogo LandscapeSensor. A lista inicialmente excedia a área visível; foi corrigida para 107 px de altura com canvas de 394 px, permitindo rolagem interna. A prévia foi ajustada ao espaço restante e recebeu encaixe por projeção dos oito cantos. O ajuste final de projeção foi visto em PC; não equivale a avaliação em celular físico.
- Helper Edit in Workspace iniciou e retornou uma cópia sem deixar ArsenalEditTemporary no Workspace. Não se modificou o import original.
- Sem erro novo dos módulos Arsenal/Gunsmith na execução final. Os erros anteriores de CombatHUD, ArenaHUD e plugin externo GUIEditor permaneceram fora deste escopo.

## Arquivos e recuperação

Novos módulos: WeaponCatalog, WeaponAssetRegistry, AttachmentCatalog, WeaponVisualConfiguration, WeaponStats, ImportedWeaponVisuals, ArsenalLoadouts e GunsmithView. A compatibilidade foi conectada a LoadoutService, KitService, WeaponController, LoadoutMenuView e ExperienceMenu. MenuNavigation recebeu somente a condição para não rolar a lista quando o foco consome o stick para girar a prévia.

Backup das fontes anteriores: ServerStorage.Development.Revisions.ArsenalBaseline_20261031. Conversões/cópias de trabalho: ServerStorage.ArsenalMigrationWork. Helper de edição: ServerStorage.ArsenalWorkshop, com fonte local em tools/arsenal_workshop.luau. Use Begin(weaponId) e Finish(true/false); o retorno nunca sobrescreve o original.

O inventário estruturado, incluindo paths segmentados, dimensões, pivot original, bounding frame, materiais, IDs de textura, componentes móveis candidatos e objetos embutidos, está em artifacts/arsenal-2026-10-31/inventory.json. Triângulos não foram mensurados; PrimaryPart ausente é registrado como tal. Os modelos originais estão no place aberto, não foram exportados para um pacote binário local pelo agente.

## Pendências e limites

- Todos os assets importados permanecem publicationBlocked=true: origem de importação conhecida no Studio, direitos de reutilização/publicação e logotipos ainda não confirmados. SourceAssetId é registrado quando o Studio o fornece; não comprova licença.
- O restante do arsenal está disponível como prévia, não como arma funcional. Expansão depende de contratos de grip/muzzle, grupos móveis, animações, orientação e montagem verificados por plataforma. Não foi declarada migração funcional de todas as armas.
- Os 94 itens auxiliares restantes não receberam montagens fictícias. Há objetos de munição, logos, peças e chassis que precisam de classificação fina antes de se tornarem acessórios equipáveis.
- Persistência publicada, multiplayer humano, navegação completa em console, pinça/multitoque reais, clipping de todos os avatares e benchmark de PC/Xbox/celular continuam pendentes.

## Tabelas de assets realmente presentes

As tabelas abaixo resumem os registros brutos. Materiais, texturas, transforms e localização completa estão no inventário estruturado. A licença de todos permanece pendente.

### Modelos-base MW

| Nome | Categoria | Tipo | Peças | Dimensões (studs) | PrimaryPart | Estado |
|---|---|---|---:|---|---|---|
| AX-50 (Default) | SNIPER RIFLES | Model | 17 | 10.02 × 2.17 × 0.81 | Ausente | Somente prévia |
| Dragunov (Default) | SNIPER RIFLES | Model | 18 | 8.91 × 1.77 × 0.66 | Ausente | Somente prévia |
| HDR (Default) | SNIPER RIFLES | Model | 15 | 11.38 × 2.03 × 0.72 | Ausente | Somente prévia |
| Rytec AMR (Default) | SNIPER RIFLES | Model | 15 | 9.44 × 2.24 × 0.81 | Ausente | Somente prévia |
| Holger-26 (Default, GUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH) | LIGHT MACHINE GUNS | Model | 16 | 7.06 × 1.70 × 1.77 | Ausente | Somente prévia |
| Bruen MK9 (Default, Postal Dude Intensifies) | LIGHT MACHINE GUNS | Model | 25 | 7.59 × 2.37 × 1.60 | Ausente | Somente prévia |
| PKM (Default, Is it Reused from MWR?) | LIGHT MACHINE GUNS | Model | 26 | 9.21 × 2.12 × 2.63 | Ausente | Somente prévia |
| M91 (Default, SKRRRRRRRAH BRRRRRRRRRRRRRT) | LIGHT MACHINE GUNS | Model | 22 | 8.45 × 2.24 × 1.03 | Ausente | Somente prévia |
| SA87 (Default, BRI'ISH???) | LIGHT MACHINE GUNS | Model | 20 | 7.33 × 2.46 × 0.63 | Ausente | Somente prévia |
| EBR-14 (Default) | MARKSMAN RIFLES | Model | 15 | 6.84 × 1.40 × 0.55 | Ausente | Somente prévia |
| MK2 Carbine (Default, Scope Included but Yee-haw) | MARKSMAN RIFLES | Model | 19 | 7.04 × 1.91 × 0.48 | Ausente | Somente prévia |
| Kar98k (Default, Scope and Clip Included) | MARKSMAN RIFLES | Model | 19 | 8.64 × 1.79 × 0.55 | Ausente | Somente prévia |
| Simonov (Default, Can't due to Copyright) | MARKSMAN RIFLES | Model | 11 | 8.35 × 1.49 × 0.44 | Ausente | Somente prévia |
| SP-R 208 (Default) | MARKSMAN RIFLES | Model | 18 | 7.40 × 1.75 × 0.62 | Ausente | Somente prévia |
| FAL (Default) | ASSAULT RIFLES | Model | 16 | 8.34 × 1.68 × 0.57 | Ausente | Somente prévia |
| M4A1 (Default) | ASSAULT RIFLES | Model | 27 | 6.12 × 2.08 × 0.63 | Ausente | Piloto visual integrado |
| Kilo 141 (Default) | ASSAULT RIFLES | Model | 16 | 5.83 × 2.09 × 0.42 | Ausente | Somente prévia |
| AK-47 (Default) | ASSAULT RIFLES | Model | 15 | 7.01 × 2.01 × 0.56 | Ausente | Somente prévia |
| FR 5.56 (Default, Spy is happy) | ASSAULT RIFLES | Model | 16 | 5.97 × 2.21 × 0.60 | Ausente | Somente prévia |
| M13 (Default) | ASSAULT RIFLES | Model | 22 | 5.78 × 2.06 × 0.51 | Ausente | Somente prévia |
| FT SCAR 17 (Default) | ASSAULT RIFLES | Model | 18 | 6.63 × 2.03 × 0.56 | Ausente | Somente prévia |
| ODEN (Default) | ASSAULT RIFLES | Model | 13 | 6.32 × 2.39 × 0.50 | Ausente | Somente prévia |
| RAM-7 (Default) | ASSAULT RIFLES | Model | 16 | 5.07 × 2.13 × 0.67 | Ausente | Somente prévia |
| Grau 5.56 (Default) | ASSAULT RIFLES | Model | 18 | 5.44 × 2.07 × 0.46 | Ausente | Somente prévia |
| CR-56 AMAX (Default, RIP El Risitas) | ASSAULT RIFLES | Model | 15 | 5.99 × 1.97 × 0.55 | Ausente | Somente prévia |
| AN-94 (Default, RIP Ivanov. Writer of SoC) | ASSAULT RIFLES | Model | 16 | 7.57 × 2.14 × 0.81 | Ausente | Somente prévia |
| AS Val (Default, Ah nuu Cheeki Breeki?) | ASSAULT RIFLES | Model | 13 | 6.64 × 1.52 × 0.53 | Ausente | Somente prévia |
| Combat Knife | SPECIAL | Model | 2 | 2.13 × 0.10 × 0.32 | Ausente | Somente prévia |
| Riot Shield | SPECIAL | Model | 4 | 1.00 × 5.23 × 3.03 | Ausente | Somente prévia |
| Minigun (Default, Rip and Tear until It's Done) | SPECIAL | Model | 11 | 7.50 × 1.87 × 2.11 | Ausente | Somente prévia |
| PILA (Kobe meme intensifies) | SPECIAL | Model | 11 | 11.85 × 2.60 × 1.48 | Ausente | Somente prévia |
| .357 (Default, Speedloader w. Snake-Shot Included) | PISTOLS | Model | 23 | 1.98 × 1.06 × 0.28 | Ausente | Somente prévia |
| 1911 (Default) | PISTOLS | Model | 10 | 1.67 × 1.07 × 0.26 | Ausente | Piloto visual integrado |
| X16 (Default) | PISTOLS | Model | 9 | 1.59 × 1.06 × 0.24 | Ausente | Somente prévia |
| M19 (Default) | PISTOLS | Model | 12 | 1.47 × 1.05 × 0.26 | Ausente | Somente prévia |
| Forge Tac .50 GS (Default) | PISTOLS | Model | 9 | 2.04 × 1.15 × 0.33 | Ausente | Somente prévia |
| Renetti (Default) | PISTOLS | Model | 10 | 1.71 × 1.08 × 0.28 | Ausente | Somente prévia |
| Sykov (Default) | PISTOLS | Model | 13 | 1.27 × 1.02 × 0.23 | Ausente | Somente prévia |
| Model 680 (Default) | SHOTGUNS | Model | 9 | 6.48 × 1.50 × 0.36 | Ausente | Somente prévia |
| Tempus Armament 725 (Default, RIP Berserk Manga Artist.) | SHOTGUNS | Model | 12 | 8.80 × 1.52 × 0.36 | Ausente | Somente prévia |
| R9-0 (Default/DP-12 SP) | SHOTGUNS | Model | 11 | 5.44 × 1.90 × 0.59 | Ausente | Somente prévia |
| Origin-12 | SHOTGUNS | Model | 19 | 5.25 × 2.30 × 1.35 | Ausente | Somente prévia |
| JAK-12 (Default) | SHOTGUNS | Model | 19 | 6.32 × 2.40 × 0.43 | Ausente | Somente prévia |
| MP7 (Default) | SUBMACHINE GUNS | Model | 22 | 4.30 × 2.16 × 0.48 | Ausente | Somente prévia |
| Striker-45 (Default) | SUBMACHINE GUNS | Model | 16 | 4.95 × 2.53 × 0.42 | Ausente | Somente prévia |
| Fennec (Default, Exusiai is that you?) | SUBMACHINE GUNS | Model | 20 | 4.29 × 2.45 × 0.51 | Ausente | Somente prévia |
| ISO (Default) | SUBMACHINE GUNS | Model | 19 | 4.09 × 1.91 × 0.42 | Ausente | Somente prévia |
| MP5 (Default) | SUBMACHINE GUNS | Model | 15 | 5.13 × 2.13 × 0.47 | Ausente | Somente prévia |
| Uzi (Default) | SUBMACHINE GUNS | Model | 16 | 5.05 × 1.68 × 0.40 | Ausente | Somente prévia |
| P90 (Default, RUSH B) | SUBMACHINE GUNS | Model | 12 | 3.78 × 1.55 × 0.44 | Ausente | Somente prévia |
| AUG (Default) | SUBMACHINE GUNS | Model | 16 | 5.23 × 2.08 × 0.66 | Ausente | Somente prévia |
| PP-19 Bizon (Default) | SUBMACHINE GUNS | Model | 14 | 5.66 × 1.59 × 0.65 | Ausente | Somente prévia |

### Imports externos

| Nome | Categoria | Tipo | Peças | Dimensões (studs) | PrimaryPart | Estado |
|---|---|---|---:|---|---|---|
| M4A1 | M4A1 | Model | 84 | 0.29 × 1.23 × 3.48 | Ausente | Arquivado; MW prevalece |
| MP7 [ACS] | MP7 [ACS] | Folder | 39 | Não mensurado no container | Ausente | Arquivado; MW prevalece |
| MP5 | MP5 | Model | 21 | 2.73 × 1.11 × 0.28 | Ausente | Arquivado; MW prevalece |
| P90 | P90 | Model | 20 | 0.45 × 1.39 × 3.28 | Ausente | Arquivado; MW prevalece |
| ACS [2.0.1] PKM | ACS [2.0.1] PKM | Model | 21 | 5.63 × 1.24 × 1.13 | Ausente | Arquivado; MW prevalece |
| AWP | AWP | Tool | 20 | 7.66 × 1.65 × 0.64 | Ausente | Somente prévia |
| IZhMASh Dragunov SVDS 6V3 | IZhMASh Dragunov SVDS 6V3 | Model | 87 | 0.40 × 2.33 × 5.04 | Ausente | Arquivado; MW prevalece |
| Barrett M82 | Barrett M82 | Tool | 31 | 16.22 × 4.82 × 18.88 | Ausente | Somente prévia |
| 725 | 725 | Tool | 15 | 0.24 × 1.03 × 5.70 | Ausente | Arquivado; MW prevalece |
| 32 Free Low Poly Fantasy Sword & Weapon Models | 32 Free Low Poly Fantasy Sword & Weapon Models | Folder | 32 | Não mensurado no container | Ausente | Somente prévia |
| M14 | M14 | Model | 16 | 4.00 × 0.94 × 0.31 | Ausente | Arquivado; MW prevalece |
| [ACS/RCM FN FAL] | [ACS/RCM FN FAL] | Model | 49 | 0.34 × 0.99 × 5.03 | Ausente | Arquivado; MW prevalece |

### Variantes e conjuntos MW

| Nome | Categoria | Tipo | Peças | Dimensões (studs) | PrimaryPart | Estado |
|---|---|---|---:|---|---|---|
| VSS Vintorez (DMR, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 15 | 6.82 × 1.72 × 0.60 | Ausente | Somente prévia |
| MK2 Carbine (Spirit of the West) | Presets/Blueprint Parts/Unofficials | Model | 19 | 8.39 × 1.91 × 0.48 | Ausente | Somente prévia |
| Grau 5.56 (SnipeLord Mark I) | Presets/Blueprint Parts/Unofficials | Model | 20 | 8.09 × 2.38 × 0.51 | Ausente | Somente prévia |
| FT SCAR 17 (Marksman SSR, Custom) | Presets/Blueprint Parts/Unofficials | Model | 18 | 7.44 × 2.13 × 0.56 | Ausente | Somente prévia |
| FT SCAR 17 (Heavy Blank Stare Auto-Sniper, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 19 | 6.70 × 2.15 × 0.54 | Ausente | Somente prévia |
| MP7 (A1 Model, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 22 | 3.46 × 1.55 × 0.47 | Ausente | Somente prévia |
| SPR-12 (Bootlegged SA110) | Presets/Blueprint Parts/Unofficials | Model | 30 | 7.06 × 1.93 × 0.91 | Ausente | Somente prévia |
| M4A1 (MW3, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 21 | 6.38 × 1.81 × 0.63 | Ausente | Somente prévia |
| CoD4 M16A4 (Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 20 | 7.77 × 2.06 × 0.63 | Ausente | Somente prévia |
| M4A1 (The CoD4 Classic, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 21 | 6.28 × 2.06 × 0.63 | Ausente | Somente prévia |
| M4A1 (MW2/Task Force, Blueprint) | Presets/Blueprint Parts/Unofficials | Model | 24 | 6.28 × 2.09 × 0.63 | Ausente | Somente prévia |
| AK-47 (Golden Dragon, Legendary Elite) | Presets/Blueprint Parts/Unofficials | Model | 18 | 8.06 × 1.76 × 1.07 | Ausente | Somente prévia |
| .357 (Snub) | Presets/Blueprint Parts/Unofficials | Model | 15 | 1.73 × 1.06 × 0.28 | Ausente | Somente prévia |
| .357 (Dark Tint, Ya' feel Lucky Punk?) | Presets/Blueprint Parts/Unofficials | Model | 15 | 2.28 × 1.06 × 0.28 | Ausente | Somente prévia |
| FT SCAR 16 (Unofficial, Don't let Fortnite kids see this!) | Presets/Blueprint Parts/Unofficials | Model | 18 | 6.63 × 2.21 × 0.56 | Ausente | Somente prévia |
| FT SCAR 16 (Blank Stare, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 22 | 6.68 × 2.22 × 0.54 | Ausente | Somente prévia |
| FT SCAR 16 (MW3, Unofficial Retexture) | Presets/Blueprint Parts/Unofficials | Model | 17 | 6.63 × 2.19 × 0.56 | Ausente | Somente prévia |
| Sykov SSL (Attachment) | Presets/Blueprint Parts/Unofficials | Model | 13 | 2.18 × 1.02 × 0.29 | Ausente | Somente prévia |
| RAM-7 (Pure White) | Presets/Blueprint Parts/Unofficials | Model | 17 | 6.22 × 2.13 × 0.67 | Ausente | Somente prévia |
| Grau 5.56 (Counter-Strike! Custom) | Presets/Blueprint Parts/Unofficials | Model | 26 | 5.44 × 2.43 × 0.50 | Ausente | Somente prévia |
| M4A1 (SOPPO, Girls' Frontline Weapon) | Presets/Blueprint Parts/Unofficials | Model | 25 | 6.28 × 2.17 × 0.63 | Ausente | Somente prévia |
| .50 GS (Fury O' Destruction) | Presets/Blueprint Parts/Unofficials | Model | 10 | 2.81 × 1.55 × 0.33 | Ausente | Somente prévia |
| M19 (Full-sized) | Presets/Blueprint Parts/Unofficials | Model | 13 | 1.52 × 1.04 × 0.26 | Ausente | Somente prévia |
| Renetti (Bootleg Auto-9) | Presets/Blueprint Parts/Unofficials | Model | 12 | 2.38 × 1.33 × 0.28 | Ausente | Somente prévia |
| Sorokin (Attachment) | Presets/Blueprint Parts/Unofficials | Model | 15 | 2.20 × 1.99 × 1.12 | Ausente | Somente prévia |
| Sykov (Svet Bochka) | Presets/Blueprint Parts/Unofficials | Model | 12 | 1.27 × 1.02 × 0.23 | Ausente | Somente prévia |
| M4A1 (The Patriot, Snaaaake Eaterrrrrr) | Presets/Blueprint Parts/Unofficials | Model | 16 | 4.43 × 1.75 × 1.77 | Ausente | Somente prévia |
| M4A1 (RO635, Unofficial but Girls' Frontline anyone?) | Presets/Blueprint Parts/Unofficials | Model | 21 | 5.55 × 2.27 × 0.63 | Ausente | Somente prévia |
| M4A1 (OG, Blueprint) | Presets/Blueprint Parts/Unofficials | Model | 23 | 7.77 × 2.06 × 0.63 | Ausente | Somente prévia |
| EBR-14 (Full-Length) | Presets/Blueprint Parts/Unofficials | Model | 15 | 7.53 × 1.40 × 0.55 | Ausente | Somente prévia |
| AK-47 (Not-MW3, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 18 | 7.17 × 2.01 × 0.65 | Ausente | Somente prévia |
| FT SCAR 17 (Blank Stare, Unofficial/ Blueprint Parts) | Presets/Blueprint Parts/Unofficials | Model | 19 | 6.70 × 2.00 × 0.54 | Ausente | Somente prévia |
| M4A1 (Future Vietnam War, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 17 | 7.77 × 1.75 × 0.63 | Ausente | Somente prévia |
| EBR-14 (MK Modified) | Presets/Blueprint Parts/Unofficials | Model | 16 | 6.85 × 1.43 × 0.62 | Ausente | Somente prévia |
| Simonov (World War, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 10 | 8.96 × 1.41 × 0.43 | Ausente | Somente prévia |
| MP5 (HL1, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 17 | 4.10 × 2.13 × 0.47 | Ausente | Somente prévia |
| FAL (OSW Para) | Presets/Blueprint Parts/Unofficials | Model | 16 | 7.69 × 1.68 × 0.59 | Ausente | Somente prévia |
| Dragunov (SVDS Modified, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 19 | 8.50 × 1.80 × 0.66 | Ausente | Somente prévia |
| AUG (A2 Modified, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 13 | 6.07 × 2.09 × 0.66 | Ausente | Somente prévia |
| Uzi (SMG PRO, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 15 | 5.04 × 1.70 × 0.39 | Ausente | Somente prévia |
| Striker-45 (UMP45, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 19 | 4.95 × 2.45 × 0.42 | Ausente | Somente prévia |
| Renetti (Guard One, Blueprint) | Presets/Blueprint Parts/Unofficials | Model | 12 | 2.16 × 1.64 × 0.28 | Ausente | Somente prévia |
| MP5 (Klassik RK, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 13 | 5.49 × 2.13 × 0.49 | Ausente | Somente prévia |
| X16 (Strike I, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 7 | 1.54 × 1.07 × 0.24 | Ausente | Somente prévia |
| Renetti (Spy's Duty Weapon Mark I, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 10 | 1.64 × 1.07 × 0.28 | Ausente | Somente prévia |
| Renetti (Spy's Duty Weapon Mark II, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 9 | 1.71 × 1.08 × 0.28 | Ausente | Somente prévia |
| M4A1 (XRK, Unofficial/Blueprint Parts) | Presets/Blueprint Parts/Unofficials | Model | 24 | 5.85 × 2.10 × 0.48 | Ausente | Somente prévia |
| Model 680 (Not-a-Mossberg, Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 7 | 7.59 × 1.55 × 0.32 | Ausente | Somente prévia |
| Holger-26 (Dream Maker, OH GOD PLEASE HELP ME) | Presets/Blueprint Parts/Unofficials | Model | 15 | 6.21 × 2.32 × 0.50 | Ausente | Somente prévia |
| ODEN (Dream Killer, AAAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHH) | Presets/Blueprint Parts/Unofficials | Model | 14 | 6.65 × 2.87 × 0.50 | Ausente | Somente prévia |
| Model 680 (Not-a-Serbu-Shotgun) | Presets/Blueprint Parts/Unofficials | Model | 8 | 4.11 × 1.45 × 0.39 | Ausente | Somente prévia |
| Model 680 (DOOM) | Presets/Blueprint Parts/Unofficials | Model | 9 | 7.59 × 1.55 × 0.32 | Ausente | Somente prévia |
| AK-47 (Draco Conversion) | Presets/Blueprint Parts/Unofficials | Model | 13 | 5.82 × 2.01 × 0.57 | Ausente | Somente prévia |
| AUG (Dame Fortuna) | Presets/Blueprint Parts/Unofficials | Model | 15 | 5.22 × 2.05 × 0.65 | Ausente | Somente prévia |
| AK-47 (Resonant, Blueprint but CYBER-RUSKI) | Presets/Blueprint Parts/Unofficials | Model | 20 | 7.40 × 2.39 × 0.70 | Ausente | Somente prévia |
| 1911 (Phantom6, My Personal Weapon) | Presets/Blueprint Parts/Unofficials | Model | 15 | 1.72 × 1.53 × 0.33 | Ausente | Somente prévia |
| M13 (Slaying Moon, HYEEEEEEEELP!) | Presets/Blueprint Parts/Unofficials | Model | 22 | 5.78 × 2.06 × 0.51 | Ausente | Somente prévia |
| RPK (Unofficial) | Presets/Blueprint Parts/Unofficials | Model | 17 | 8.30 × 1.74 × 1.07 | Ausente | Somente prévia |
| 1911 (Rusted) | Reskins | Model | 10 | 1.67 × 1.07 × 0.26 | Ausente | Somente prévia |
| Renetti (Dark Tint, Unofficial) | Reskins | Model | 10 | 1.71 × 1.08 × 0.28 | Ausente | Somente prévia |
| M19 (Dark) | Reskins | Model | 12 | 1.47 × 1.05 × 0.27 | Ausente | Somente prévia |
| X16 (Alternate Color) | Reskins | Model | 9 | 1.59 × 1.06 × 0.24 | Ausente | Somente prévia |
| M4A1 (Pure White, Requested from BB Server) | Reskins | Model | 27 | 6.12 × 2.08 × 0.63 | Ausente | Somente prévia |
| M4A1 (Dark) | Reskins | Model | 27 | 6.12 × 2.08 × 0.63 | Ausente | Somente prévia |
| X16 (Dark, hl1_fire_sound) | Reskins | Model | 9 | 1.59 × 1.06 × 0.24 | Ausente | Somente prévia |
| Renetti (Bootleg Samurai Edge) | Reskins | Model | 10 | 1.63 × 1.08 × 0.28 | Ausente | Somente prévia |
| Kilo 141 (Warcrime Desert) | Reskins | Model | 16 | 5.83 × 2.09 × 0.42 | Ausente | Somente prévia |
| FT SCAR 17 (Dark Tint, Unofficial Retexture) | Reskins | Model | 18 | 6.63 × 2.03 × 0.56 | Ausente | Somente prévia |

### Acessórios e itens auxiliares MW

| Nome | Categoria | Tipo | Peças | Dimensões (studs) | PrimaryPart | Estado |
|---|---|---|---:|---|---|---|
| XRK SP-Lite 208 Blitz | SP-R 208 Chassis | Model | 5 | 5.42 × 1.38 × 0.48 | Ausente | Prévia; montagem não verificada |
| ZLR SP-R Overseer | SP-R 208 Chassis | Model | 4 | 6.07 × 1.19 × 0.48 | Ausente | Prévia; montagem não verificada |
| FSS Virtuoso Pro | SP-R 208 Chassis | Model | 6 | 6.13 × 1.36 × 0.50 | Ausente | Prévia; montagem não verificada |
| XRK SP-TAC 208 Ultimate | SP-R 208 Chassis | Model | 6 | 6.22 × 1.38 × 0.48 | Ausente | Prévia; montagem não verificada |
| 12 Gauge Deputy | Underbarrel Launchers | Model | 6 | 2.62 × 0.70 × 0.34 | Ausente | Prévia; montagem não verificada |
| M203 Mini | Underbarrel Launchers | Model | 4 | 1.49 × 0.56 × 0.37 | Ausente | Prévia; montagem não verificada |
| 40mm Concussive (EGLM) | Underbarrel Launchers | Model | 4 | 3.21 × 0.89 × 0.53 | Ausente | Prévia; montagem não verificada |
| M203 40mm | Underbarrel Launchers | Model | 4 | 2.38 × 0.63 × 0.45 | Ausente | Prévia; montagem não verificada |
| APX5 Scope | Optics | Model | 3 | 0.71 × 0.41 × 0.29 | Ausente | Prévia; montagem não verificada |
| Solozero Variable Zoom Scope | Optics | Model | 3 | 1.88 × 0.54 × 0.53 | Ausente | Prévia; montagem não verificada |
| Cronen CR40x Scope | Optics | Model | 3 | 1.87 × 0.57 × 0.55 | Ausente | Prévia; montagem não verificada |
| Combat Corp Sight | Optics | Model | 2 | 0.67 × 0.46 × 0.43 | Ausente | Prévia; montagem não verificada |
| Viper Reflex Sight | Optics | Model | 3 | 0.76 × 0.40 × 0.32 | Ausente | Prévia; montagem não verificada |
| Cronen 2x2 Red Dot (RAM-7) | Optics | Model | 2 | 0.51 × 0.45 × 0.38 | Ausente | Prévia; montagem não verificada |
| Corvus Defense PBX Holo 7 | Optics | Model | 2 | 0.61 × 0.41 × 0.42 | Ausente | Prévia; montagem não verificada |
| XRK Operator Reflex Sight | Optics | Model | 3 | 0.48 × 0.32 × 0.29 | Ausente | Prévia; montagem não verificada |
| Scout Combat Optic | Optics | Model | 3 | 0.91 × 0.41 × 0.40 | Ausente | Prévia; montagem não verificada |
| VLK 3.0x Scope | Optics | Model | 2 | 0.89 × 0.42 × 0.35 | Ausente | Prévia; montagem não verificada |
| Corvus Defense Integral Hybrid | Optics | Model | 4 | 0.95 × 0.59 × 0.37 | Ausente | Prévia; montagem não verificada |
| Aim Op Reflex Sight (Riser) | Optics | Model | 3 | 0.43 × 0.41 × 0.26 | Ausente | Prévia; montagem não verificada |
| Aim Op Reflex Sight | Optics | Model | 2 | 0.50 × 0.35 × 0.31 | Ausente | Prévia; montagem não verificada |
| FSS Magnifier | Optics | Model | 4 | 0.71 × 0.53 × 0.39 | Ausente | Prévia; montagem não verificada |
| Monocle Reflex Sight (That's Weird, It looked Like an OKP-7) | Optics | Model | 2 | 0.80 × 0.39 × 0.39 | Ausente | Prévia; montagem não verificada |
| Solozero NVG Enhanced | Optics | Model | 3 | 0.90 × 0.47 × 0.34 | Ausente | Prévia; montagem não verificada |
| Cronen C480 4x30 (idk Doomguy Censored it) | Optics | Model | 3 | 0.89 × 0.42 × 0.40 | Ausente | Prévia; montagem não verificada |
| G.I Mini Reflex (Yikes, I Used The Same Rail Mount) | Optics | Model | 4 | 0.36 × 0.25 × 0.23 | Ausente | Montagem M4A1 |
| Merc Thermal Optic | Optics | Model | 3 | 1.07 × 0.42 × 0.41 | Ausente | Prévia; montagem não verificada |
| Cronen LP945 | Optics | Model | 3 | 0.36 × 0.26 × 0.23 | Ausente | Prévia; montagem não verificada |
| Solozero Mini Dot Sight | Optics | Model | 3 | 0.36 × 0.26 × 0.24 | Ausente | Prévia; montagem não verificada |
| XRK 208 Dragoon | SP-R 208 Barrels | MeshPart | 1 | 3.24 × 0.26 × 0.26 | Ausente | Prévia; montagem não verificada |
| ZLR Asp | SP-R 208 Barrels | Model | 2 | 2.24 × 0.20 × 0.20 | Ausente | Prévia; montagem não verificada |
| SP-R 26" | SP-R 208 Barrels | Model | 2 | 4.01 × 0.20 × 0.20 | Ausente | Prévia; montagem não verificada |
| ZLR Veratwist 9.6" | SP-R 208 Barrels | Model | 2 | 3.45 × 0.20 × 0.20 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: MW | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Mardemon | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Ravenholm | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: UK | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: This is America | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Jortelleni | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Rekt | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: StyLiS Symbol | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Action Elite | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Doomguy | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: Dio Brando | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: StyLiS Studios Forum Logo | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Kilo 141 Emblem: ArcCW+ | Kilo 141 Cosmetics | MeshPart | 1 | 0.28 × 0.13 × 1.07 | Ausente | Prévia; montagem não verificada |
| Operator Foregrip | Foregrips | MeshPart | 1 | 0.38 × 1.01 × 0.26 | Ausente | Prévia; montagem não verificada |
| Merc Foregrip | Foregrips | MeshPart | 1 | 0.43 × 0.61 × 0.35 | Ausente | Prévia; montagem não verificada |
| Operator Foregrip (alt) | Foregrips | MeshPart | 1 | 0.41 × 0.65 × 0.31 | Ausente | Prévia; montagem não verificada |
| Tac Foregrip | Foregrips | MeshPart | 1 | 0.83 × 0.29 × 0.21 | Ausente | Prévia; montagem não verificada |
| Ranger Foregrip (alt) | Foregrips | MeshPart | 1 | 0.41 × 0.88 × 0.32 | Ausente | Prévia; montagem não verificada |
| Ranger Foregrip | Foregrips | MeshPart | 1 | 0.38 × 0.91 × 0.30 | Ausente | Prévia; montagem não verificada |
| Commando Foregrip (Desert, Unofficial) | Foregrips | MeshPart | 1 | 0.88 × 0.42 × 0.26 | Ausente | Prévia; montagem não verificada |
| Commando Foregrip | Foregrips | MeshPart | 1 | 0.88 × 0.42 × 0.26 | Ausente | Montagem M4A1 |
| 32rnd Corvus Defense Drum Magazine | Magazines | Model | 2 | 0.77 × 1.66 × 1.52 | Ausente | Prévia; montagem não verificada |
| 20rnd Corvus Defense Drum Magazine | Magazines | Model | 2 | 0.75 × 1.39 × 1.27 | Ausente | Prévia; montagem não verificada |
| 6rnd .338 Lapua Mag | Magazines | Model | 2 | 0.71 × 0.56 × 0.20 | Ausente | Prévia; montagem não verificada |
| 50rnd 9x19mm Drum Magazine (ISO) | Magazines | Model | 2 | 0.52 × 1.23 × 0.67 | Ausente | Prévia; montagem não verificada |
| 10rnd .300 Win Mag | Magazines | Model | 2 | 0.71 × 0.92 × 0.19 | Ausente | Prévia; montagem não verificada |
| 21rnd 9mm Para Magazine (M19) | Magazines | Model | 2 | 0.44 × 1.01 × 0.24 | Ausente | Prévia; montagem não verificada |
| 30rnd 9x19mm Magazine (ISO) | Magazines | Model | 2 | 0.53 × 1.53 × 0.17 | Ausente | Prévia; montagem não verificada |
| 32rnd .41 AE Magazine (Uzi) | Magazines | Model | 2 | 0.38 × 1.41 × 0.23 | Ausente | Prévia; montagem não verificada |
| 30rnd 5.56x45mm NATO Magazine (Kilo) | Magazines | Model | 2 | 0.65 × 1.48 × 0.18 | Ausente | Prévia; montagem não verificada |
| 40rnd 7.62x39mm Magazine (AK-47) | Magazines | Model | 2 | 1.15 × 1.56 × 0.23 | Ausente | Prévia; montagem não verificada |
| 20rnd 5.56x45mm Normal Magazine | Magazines | Model | 2 | 0.51 × 1.07 × 0.19 | Ausente | Prévia; montagem não verificada |
| 30rnd 5.56x45mm Holger Magazine | Magazines | Model | 2 | 0.67 × 1.43 × 0.21 | Ausente | Prévia; montagem não verificada |
| Laser Cylinder | Lasers | Model | 2 | 0.67 × 0.20 × 0.20 | Ausente | Prévia; montagem não verificada |
| 5mW Laser | Lasers | Model | 2 | 0.65 × 0.17 × 0.43 | Ausente | Prévia; montagem não verificada |
| Tac Laser | Lasers | Model | 2 | 0.62 × 0.14 × 0.38 | Ausente | Prévia; montagem não verificada |
| 1mW Laser | Lasers | Model | 2 | 0.57 × 0.13 × 0.36 | Ausente | Prévia; montagem não verificada |
| Corvus Defense 1mW Laser | Lasers | Model | 2 | 0.74 × 0.39 × 0.27 | Ausente | Prévia; montagem não verificada |
| Cronen 5mW Laser Handgun | Lasers | MeshPart | 1 | 0.50 × 0.22 × 0.25 | Ausente | Prévia; montagem não verificada |
| Monolithic Pistol Suppressor | Suppressors | MeshPart | 1 | 1.18 × 0.22 × 0.22 | Ausente | Prévia; montagem não verificada |
| Lightweight Suppressor | Suppressors | MeshPart | 1 | 1.19 × 0.29 × 0.31 | Ausente | Prévia; montagem não verificada |
| Oil Filter Suppressor (Anyone Heard of Apoc Rising 2?) | Suppressors | MeshPart | 1 | 1.20 × 0.46 × 0.47 | Ausente | Prévia; montagem não verificada |
| Monolithic Suppressor | Suppressors | MeshPart | 1 | 1.37 × 0.31 × 0.31 | Ausente | Montagem M4A1 |
| Tactical Suppressor | Suppressors | MeshPart | 1 | 1.04 × 0.26 × 0.27 | Ausente | Prévia; montagem não verificada |
| Tac East Suppressor | Suppressors | MeshPart | 1 | 1.54 × 0.39 × 0.41 | Ausente | Prévia; montagem não verificada |
| Pistol Lightweight Suppressor | Suppressors | MeshPart | 1 | 0.79 × 0.25 × 0.25 | Ausente | Prévia; montagem não verificada |
| Artoria Armory .300 Win Mag Box | AMMO BOXES | Model | 22 | 1.04 × 0.19 × 0.60 | Ausente | Prévia; montagem não verificada |
| XRK 9mm M19 | AMMO BOXES | Model | 31 | 0.73 × 0.27 × 0.42 | Ausente | Prévia; montagem não verificada |
| .357 Magnum Bullets | AMMO BOXES | Model | 27 | 0.73 × 0.36 × 0.50 | Ausente | Prévia; montagem não verificada |
| Laser Mount | Handguards/Laser Mount | MeshPart | 1 | 0.19 × 0.23 × 0.51 | Ausente | Prévia; montagem não verificada |
| MLOK Rail (MP5) | Handguards/Laser Mount | MeshPart | 1 | 1.16 × 0.36 × 0.41 | Ausente | Prévia; montagem não verificada |
| Corvus Custom Marksman Handguard | Handguards/Laser Mount | Model | 2 | 2.28 × 0.48 × 0.48 | Ausente | Prévia; montagem não verificada |
| Corvus Custom Marksman Handguard (Desert) | Handguards/Laser Mount | Model | 2 | 2.28 × 0.48 × 0.48 | Ausente | Prévia; montagem não verificada |
| 40mm Grenade | ATTACHMENTS | MeshPart | 1 | 0.69 × 0.30 × 0.30 | Ausente | Prévia; montagem não verificada |
| Shotgun Shell | ATTACHMENTS | MeshPart | 1 | 0.47 × 0.17 × 0.17 | Ausente | Prévia; montagem não verificada |
| ZLR J-3600 Torrent (JAK-12) | Barrels | Model | 3 | 4.34 × 0.56 × 0.30 | Ausente | Prévia; montagem não verificada |
| ZLR J-2800 Influx | Barrels | Model | 2 | 3.64 × 0.57 × 0.32 | Ausente | Prévia; montagem não verificada |
| FSS 20.8 Nexus | Barrels | Model | 5 | 3.29 × 0.70 × 0.38 | Ausente | Prévia; montagem não verificada |
| FSS 11.8 Squall (CR-56) | Barrels | Model | 4 | 3.91 × 0.64 × 0.47 | Ausente | Prévia; montagem não verificada |
| Singuard Arms Invader | Model | Model | 2 | 1.75 × 1.15 × 0.39 | Ausente | Prévia; montagem não verificada |
| Forge Tac CQS | Model | Model | 2 | 1.69 × 1.05 × 0.32 | Ausente | Prévia; montagem não verificada |
| Forge Tac Ultralight | Model | Model | 2 | 1.63 × 0.94 × 0.27 | Ausente | Prévia; montagem não verificada |
| Forge Tac Hunter | Model | Model | 2 | 1.79 × 0.94 × 0.38 | Ausente | Prévia; montagem não verificada |
| FSS Close Quarters Stock | Model | Model | 2 | 1.43 × 0.96 × 0.31 | Ausente | Prévia; montagem não verificada |

