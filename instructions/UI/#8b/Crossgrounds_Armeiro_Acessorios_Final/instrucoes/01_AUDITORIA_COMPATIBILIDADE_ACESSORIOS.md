# 01 — Auditoria de compatibilidade dos acessórios

## Objetivo

Transformar a pasta massiva de attachments em um catálogo utilizável pelo Crossgrounds, com três perguntas respondidas por item:

1. **Que tipo de acessório é este?**
2. **Em quais armas / plataformas ele pode ser usado?**
3. **Ele é funcional, apenas visual, ou ambos?**

## Ordem ideal da auditoria

### Etapa 1 — Normalização de nomes

Antes de pensar em compatibilidade, normalize os nomes.

Exemplos:
- `Monolithic Suppressor`
- `Monolithic Suppressor 2`
- `Mono Suppressor`
- `MONOLITHIC_SUPPRESSOR`

Tudo isso deve apontar para um registro canônico, por exemplo:

`muzzle_monolithic_suppressor`

Campos mínimos por item:
- `id`
- `displayName`
- `slotType`
- `sourceGame`
- `sourcePack`
- `isVisualOnly`
- `requiresMount`
- `mountType`
- `compatibilityMode`

### Etapa 2 — Classificação por slot

Cada acessório precisa cair em um slot principal.

Slots-base recomendados:
- `Muzzle`
- `Barrel`
- `Laser`
- `Optic`
- `Stock`
- `Underbarrel`
- `Magazine`
- `RearGrip`
- `Ammunition`
- `Perk`

Slots extras opcionais para o futuro:
- `Trigger`
- `Bolt`
- `Guard`
- `Receiver`
- `Conversion`
- `Bipod`

### Etapa 3 — Determinar o modo de compatibilidade

Cada attachment deve usar um destes modos:

#### 1. Universal
Compatível com qualquer arma que possua o ponto de montagem.

Exemplos:
- algumas ópticas reflex
- alguns lasers
- alguns supressores genéricos

#### 2. Por plataforma
Compatível apenas com armas da mesma família/plataforma.

Exemplos:
- AK family
- M4/AR platform
- MP5 platform
- SCAR platform
- Shotgun tube-fed family

#### 3. Por arma específica
Compatível apenas com uma arma.

Exemplos:
- conversão exclusiva
- cano proprietário
- magazine shape exclusivo
- stock integrado

## Regra principal do Crossgrounds

Use esta prioridade:

1. **Plataforma específica**, quando conhecida.
2. **Compatibilidade universal com mount válido**, quando fizer sentido.
3. **Categoria ampla**, apenas como fallback temporário.

Não recomendo basear tudo apenas em `AssaultRifle`, `SMG`, `LMG`, etc., porque isso causa falsos positivos demais.

## Como decidir compatibilidade na prática

Para cada attachment, verifique:

- O nome menciona arma/plataforma?
- O modelo encaixa visualmente apenas em um padrão específico?
- A peça usa geometria universal ou proprietária?
- A arma alvo possui ponto de montagem correspondente?
- A peça altera algo que só existe naquela plataforma?

### Exemplos práticos

#### Óptica reflex simples
- Slot: `Optic`
- Compatibilidade: `Universal`
- Exige mount: sim
- Mount: `TopRail`

#### Monolithic Suppressor
- Slot: `Muzzle`
- Compatibilidade: `Universal` ou `ByCaliberGroup`
- Exige mount: sim
- Mount: `MuzzleThread`

#### 45 Round MP5 Mag
- Slot: `Magazine`
- Compatibilidade: `SpecificPlatform`
- Plataforma: `MP5`

#### Spetsnaz Grip
- Slot: `Underbarrel`
- Compatibilidade: `SpecificPlatform`
- Plataforma: `AK`

## Duplicatas

Como você puxou vários packs, haverá duplicatas.

Tipos de duplicata:
- **Duplicata real**: mesmo acessório, mesmo propósito, mesmo encaixe.
- **Duplicata visual**: mesmo acessório, malha diferente.
- **Variante legítima**: nome parecido, efeito ou formato diferente.

Regra recomendada:
- manter 1 registro canônico,
- deixar variantes como `skins` ou `visualVariants`,
- evitar vários IDs funcionais para a mesma peça.

## Resultado esperado da auditoria

Ao final, cada attachment deve sair com:

- slot correto,
- regra de compatibilidade,
- plataforma ou armas-alvo,
- se precisa de mount específico,
- se é funcional, visual ou híbrido,
- observações sobre duplicata e qualidade do modelo.

