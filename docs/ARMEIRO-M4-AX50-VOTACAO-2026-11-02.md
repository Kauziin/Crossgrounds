# Armeiro M4A1 / AX-50 e votação — entrega parcial

Trabalho iniciado em 01/11 e registrado em 02/11/2026. Principal autorizado após encerramento da outra sessão. Fontes anteriores preservadas em `artifacts/arsenal-round-2026-11-01/before` e `ServerStorage.Development.Revisions.ArsenalRoundBaseline_20261101`. Nenhum push, publicação ou salvamento do place em nuvem foi executado. O atributo do mapa está no documento aberto do Studio e precisa acompanhar seu próximo salvamento.

## Alterações incorporadas

| Arma | Categoria | Entrega | Validação / limite |
|---|---|---|---|
| M4A1 | magazine | Três modelos MW existentes: 20 normal, 30 Kilo e 30 Holger; capacidades exatas 20/30/30 | Montagem por referência Bullets do próprio modelo, nativo oculto, peças no grupo Magazine. Galeria em Play inspecionada. Servidor aceitou exatamente 20/30/30 tiros; seguintes rejeitados por ammo. |
| M4A1 | optic | G.I. Mini Reflex existente, perfil óptico RedDot 1,35× e alinhamento FP ao Lens do acessório | Resolução do perfil conferida no cliente. Ajuste visual fino e teste físico de ADS ainda pendentes. Não usa máscara telescópica nem toma D-pad para zoom de um único nível. |
| M4A1 | muzzle | Monolithic existente, som abafado e metadados de supressão | Preserva política anterior sem bônus de alcance/dano; ruído observado pelos bots ×0,6. Escuta e multiplayer humano pendentes. |
| M4A1 | underbarrel | Commando existente | Spread ×0,6 e Roll visual ×0,85 já existentes, preservados; não aplicados novamente. |
| AX-50 | barrel | Default, Extended existente e Heavy do desenvolvedor | Boca derivada das peças reais, Extended/Heavy substituem cano nativo; Heavy também substitui Rails nativas. Galeria em Play e ciclos de prévia conferidos. |
| AX-50 | optic | Mira original preservada sem acessório; G.I. Mini Reflex como alternativa | Ao trocar, oculta Scope, Lens e Stand nativos somente na montagem derivada. Perfil físico original preservado. ADS fino pendente. |
| AX-50 | muzzle | Monolithic e Colossus pré-existentes | Seguem a boca do cano no servidor e na prévia. Colossus continua sendo a variante visual escalada do Monolithic que já existia; não é um novo mesh autêntico. Supressão agora usa metadados comuns. |
| AX-50 | underbarrel | Commando existente | Modificadores efetivos preservados. |

As categorias suportadas são as do WeaponCatalog: M4 optic/muzzle/underbarrel/magazine; AX optic/muzzle/underbarrel/barrel. Não foram inventados slots de laser/coronha sem peça verificada.

## Heavy Barrel e balanceamento

Modelo original: `ServerStorage.ImportedArsenalOriginals["CoD:MW Weapon/Attachment Props"].ATTACHMENTS.Barrels["AX-50 Heavy Barrel"]`.

ID novo: `barrels_ax_50_heavy`. Nenhum duplicado do modelo foi criado. Contém Barrel, Muzzle e duas Rails. ID registrado no WeaponAssetRegistry; publicação bloqueada.

| Campo | Extended preexistente | Heavy novo, provisório |
|---|---:|---:|
| Spread | ×0,75 | ×0,65 |
| VisualRecoil Push/Pitch/Roll | ×0,75 | ×0,60 |
| Range / falloff | ×1,25 | ×1,12 |
| ADS | ×0,90 | ×0,85 |
| Movimento | ×0,94 | ×0,90 |

Base Range 1000: Extended 1250; Heavy 1120. A estabilidade é o recuo visual existente; não foi inventado um novo recuo de câmera. Ambos têm o mesmo comprimento geométrico no asset atual. Boca padrão Z=-7,52534; Extended/Heavy Z=-9,95379, em coordenadas normalizadas da arma. Não se desloca a origem até a ponta externa do supressor. Underbarrel em trilho fixo não é movido pela troca de cano.

## Busca de 50 / 60

Inspecionados os pacotes locais e executadas três consultas Creator Store: `M4 60 round magazine`, `AR15 50 round magazine`, `STANAG+60`. Parte dos resultados era irrelevante; a busca não demonstrou ausência global de modelos.

Importado para inspeção, fora do Workspace: [(Warbound/WB) STANAG magazines — 13698202839](https://create.roblox.com/store/asset/13698202839), criador emanuelbayah. Caminho: `ServerStorage.ImportedArsenalOriginals.STANAG_Magazines_Review_13698202839`. O pacote tem duas peças Mag e uma peça de apresentação, sem capacidade 50/60 comprovada. Não habilitado como acessório e nenhuma de suas fontes foi executada.

Modelo local adicional examinado: `ServerStorage.ImportedArsenalOriginals["MW3 : Machine Guns & Shotguns"]["Light Machine Guns"]["Holger-26"]["60rnd 5.56x45mm NATO Holger Drum Magazine"]`. Duas peças em outra escala de autoria; encaixe específico na M4 não comprovado. Tambores 9mm, 5,8mm e 7,62mm rejeitados como substitutos. Não foi introduzida capacidade 50/60 usando o modelo nativo ou modelo genérico.

**Pendência real:** obter/verificar modelos de 50 e/ou 60 adequados à M4, montagem, escala, recarga e condições de uso. Assets existentes/importados continuam bloqueados para publicação; presença no Creator Store não comprova licença de redistribuição.

## Testes efetivamente executados

- 14 contratos de ArsenalVisual/ArsenalRound aprovados em módulos isolados, além de rejeição de override fracionário.
- Prévia: padrão → Extended+Colossus → Heavy+Colossus → padrão; boca e partes do filho iguais às da construção do servidor. Invalida muzzle mesmo quando o ID do supressor não mudou.
- Geometria saneada sem fontes Lua/RemoteEvent; grupos de carregador substituto presentes.
- Play, servidor nativo, caminho ShotAuthority.FireNPC: 20, 30 e 30 tiros aceitos; disparo seguinte rejeitado por ammo; reserva 300 preservada. Isso não é teste de gatilho físico do jogador.
- Recarga nativa NPC: 13/100 → 20/93; 0/7 → 7/0. Encontrado e corrigido ReloadNPC que ainda consumia KitDefinitions direto em vez de ResolveTool. Caso usou cópia do módulo com o ajuste final; produção em Edit alinhada depois.
- Preset salvo via RemoteFunction normal, respawn real do jogador: M4 com os quatro slots selecionados, Ammo=20, ReserveAmmo=300, secundária e melee mantidos. Estado StudioSessionOnly; DataStore publicado não exercitado.
- ArenaWeapon ignora configurações de acessórios no resolvedor. Nenhuma regra de loadout, combate ou HUD Arena foi alterada.
- `riverside_wide.Enabled=false`; MapManager:Catalog não lista o mapa e riverside permanece habilitado. Ferramenta CTFWideAuthoring alterada para não reabilitar o mapa na criação/carregamento. Não foi necessário ocultar itens na interface de votação nem apagar mapa. Nova rodada de votação por usuários não foi testada.
- `git diff --check` sem erros. Play encerrado; fixtures e alterações de preset de QA não persistem fora dele.

## Fontes principais

- WeaponCatalog, AttachmentCatalog, WeaponAssetRegistry, AttachmentCompatibility existente: slots, registros e restrições específicas.
- WeaponStats: override inteiro restrito a Magazine, aplicado depois dos modificadores; guarda ArenaWeapon.
- ImportedWeaponVisuals: canos antes dos filhos, origem física, carregador substituto e referências de recarga; restauração sem acessório.
- ArsenalPreview: invalidação do filho muzzle na mudança estrutural.
- AttachmentEffects e ShotAuthority: supressão por metadados, redução de ruído e dados resolvidos na recarga NPC.
- SightDefinitions, FirstPersonRenderer, OpticalSight, CombatPresentation: mini-reflex de um nível, ponto vermelho, alinhamento à lente e preservação dos comandos normais de D-pad.
- CTFWideAuthoring e atributo do mapa no Studio: elegibilidade de votação.
- ArsenalRound_Test e ArsenalVisual_Test: contratos novos e atualização da expectativa antiga de acessórios sem efeitos.

Não considerar o documento de solicitação integralmente concluído: faltam estendidos 50/60 aprovados, validação física de ADS, clipping em todos os estados/terceira pessoa e controle, recarga automática/HUD em todas as combinações, persistência publicada e confirmação de direitos. Os itens Available possuem contrato geométrico e validação de dados nesta rodada; isso não equivale à aprovação final de apresentação em todos os estados.
