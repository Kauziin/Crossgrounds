# 02 — Regras de compatibilidade e estrutura dos dados

**Status: proposta de arquitetura, não mapeamento final dos modelos importados.**

## Informações por arma

- `id` — manter os IDs reais do `WeaponCatalog`.
- `platform` — família de encaixes, quando verificada (ex.: `AR_M4`, `AK`, `MP5`); **não confundir com a categoria** `ASSAULT RIFLES`, `SMG` etc.
- `mountPoints` — pontos de instalação efetivamente presentes ou implementados no modelo (optic, muzzle, magazine, stock etc.).
- `sourcePack` e `sourceGame` — origem para rastrear modelos duplicados.

## Informações por acessório

- `id`, `name`, `slot`, `sourcePack`, `sourceGame`, `assetId`.
- `compatibleWeapons`/`compatiblePlatforms` (listas verificadas) e `blockedWeapons`/`blockedPlatforms` (exceções).
- `mountType` ou identificação da montagem visual realmente suportada.
- `visualOnly` ou status equivalente, separado da existência dos modificadores.
- `statMultipliers` e `statAdd` **apenas para atributos já consumidos pelo núcleo**; estes nomes seguem a integração anterior do Crossgrounds com `WeaponStats`.

### Exemplo ilustrativo de registro

```luau
-- Exemplo de esquema, não inserir cegamente no AttachmentCatalog atual.
{
    id = "optic_demo",
    name = "Óptica de demonstração",
    slot = "optic",
    compatiblePlatforms = {"AR_M4"},
    blockedWeapons = {},
    mountType = "TopRail",
    statMultipliers = { Spread = 0.95 },
    statAdd = {},
}
```

### Compatibilidade — precedência

1. **Bloqueio explícito** da arma/plataforma tem precedência.
2. Acessório específico: somente os `weaponId` auditados e autorizados.
3. Acessório por plataforma: somente as plataformas auditadas.
4. Universal: **somente se** o ponto de encaixe, a geometria e a montagem suportarem a arma — não basta o mesmo tipo de slot.
5. Informação desconhecida: classificar `pendingAudit` e **não tornar montável automaticamente**.

## Duplicatas

- Se mesmo item e mesmo encaixe, manter um registro canônico e apontar variantes visuais para ele.
- Se acessórios diferentes têm o mesmo nome mas proporções e funções distintas, manter registros separados.
- Não renomear/remover assets no Studio sem conferir as referências de `AttachmentCatalog`, montagens e presets salvos.

## Regras de quantidade

**Sem limite global** de acessórios equipados por arma, conforme solicitado. Preservar exclusividade nos slots cujas peças se substituem (por exemplo: uma óptica por ponto de óptica; magazines mutuamente exclusivos). Restrições por encaixe físico continuam válidas. Verificar tanto a UI quanto o validador do servidor; o campo `Config.MaxAttachments`, caso ainda exista, não pode manter um teto global arbitrário.

## Validação e segurança

A compatibilidade e os bônus devem ser determinados pelo **servidor**, usando IDs de acessórios selecionados, nunca multiplicadores enviados prontos pelo cliente. O cliente calcula a prévia com o mesmo modelo compartilhado. A configuração inválida deve ser rejeitada ou saneada pelo validador já existente.

## Cache

Após a auditoria, organizar por `(weaponId, slot)` com invalidação quando catálogo/versão mudar. Não reavaliar todos os modelos em cada frame.
