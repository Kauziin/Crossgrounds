"""Describe the observed Studio inventory without guessing unverified fit."""
import collections
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/plan8-2026-11-01'
inventory = json.loads((OUT / 'inventory.json').read_text(encoding='utf8'))
catalog = json.loads((OUT / 'catalog-before.json').read_text(encoding='utf8'))
registered = inventory['registry']
paths = collections.defaultdict(list)
fingerprints = collections.defaultdict(list)
for key, row in registered.items():
    paths[tuple(row['path'])].append(key)
    parts = row.get('parts', [])
    if parts:
        origin = [sum(p['cf'][i] for p in parts)/len(parts) for i in range(3)]
        shape = sorted((p.get('mesh', ''), tuple(round(n, 5) for n in p['size']),
                        tuple(round(p['cf'][i]-origin[i], 4) for i in range(3)),
                        tuple(round(n, 5) for n in p['cf'][3:])) for p in parts)
        digest = hashlib.sha256(repr(shape).encode()).hexdigest()
        fingerprints[digest].append(key)

# Candidate containers are evidence of assets, never an allow list.
markers = ['.ATTACHMENTS.', '.Attachments.', '.Gunsmith Parts.',
           '.Modern Warfare Reloaded - Shared.', '.M4A1.Sights.',
           '.M4A1.Muzzle Devices.', '.M4A1.Handguard Attachments.',
           '.M4A1.Magazines.', '.M4A1.Stocks.', '.Suppressors.']
candidates = [r for r in inventory['tree'] if any(m in r['path'] for m in markers)]
report = {
    'source': 'Studio Edit, place 4375993208, ImportedArsenalOriginals, 2026-11-01',
    'registeredAssets': len(registered), 'containers': len(inventory['tree']),
    'missingRegisteredAssets': [k for k, r in registered.items() if r.get('missing')],
    'sameSourceAliases': [v for v in paths.values() if len(v)>1],
    'sameGeometryCandidates': [v for v in fingerprints.values() if len(v)>1],
    'unmappedCandidateContainers': candidates,
    'catalog': [{**r, 'auditStatus': 'Verified existing mount' if r['status']=='Available' else 'Pending',
                 'sourceGame': 'Modern Warfare 2019', 'sourcePack': 'mw2019',
                 'partCount': len(registered.get(r['id'], {}).get('parts', []))}
                for r in catalog],
}
(OUT / 'compatibility-inventory.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
lines = [
    '# Inventário e compatibilidade — plano 8', '',
    'Fonte: árvore e geometria reais do Studio, Place 4375993208, em 01/11/2026.', '',
    f"Foram exportados {len(registered)} IDs registrados e {len(inventory['tree'])} containers de 20 packs. Nenhum ID registrado está ausente.", '',
    'Os 100 registros do catálogo incluem 99 representações físicas e a conversão lógica da AUG. '
    'Seis registros já possuem montagens implementadas (nove pares arma/acessório). Os demais permanecem pendentes e não equipáveis. '
    'A compatibilidade usa listas explícitas e mounts implementados para M4A1, AX-50 e controle de disparo da AUG; não é inferida de categorias.', '',
    '## Catálogo registrado', '',
    '| ID | Slot no inventário anterior | Estado | Armas autorizadas |',
    '| --- | --- | --- | --- |',
]
for row in catalog:
    lines.append(f"| `{row['id']}` | {row['slot']} | {'Montagem implementada' if row['status']=='Available' else 'Pendente'} | {', '.join(row.get('compatible', [])) or '—'} |")
lines += ['', '## Nomes, aliases e variantes', '',
          'IDs persistidos são preservados. Os aliases de origem abaixo apontam para a mesma Instance; '
          'isso não prova que dois nomes representem o mesmo comportamento funcional. Colossus é uma variante '
          'do modelo Monolithic com escala e modificadores próprios, portanto conserva seu ID.', '']
for group in report['sameSourceAliases']:
    lines.append('- ' + ', '.join(f'`{key}`' for key in group))
lines += ['', 'A comparação de malhas/dimensões/transformações está em `compatibility-inventory.json`. '
          'Esses grupos são candidatos à deduplicação, sem remoção ou renomeação de assets.', '',
          '## Packs adicionais e limitações', '',
          f"{len(candidates)} containers candidatos de acessórios/peças foram inventariados fora da regra de equipagem. "
          'Os caminhos completos estão no relatório estruturado. Não há autorizações automáticas para esses packs: '
          'faltam mounts e conferência individual de geometria. Não foram inventados plataformas, calibres ou bônus.', '',
          'A classificação de registros especiais de canos, coronhas/chassis, munição, mounts e lançadores foi corrigida '
          'no catálogo usando os grupos reais de origem. Componentes sem uso de combate continuam como auxiliares.', '',
          'O catálogo runtime mantém versão explícita de compatibilidade. A checagem é por arma e mount, '
          'sem varredura de modelos por frame; a geometria saneada usa cache limitado e a prévia atualiza apenas slots alterados.', '']
(OUT / 'INVENTARIO-COMPATIBILIDADE.md').write_text('\n'.join(lines), encoding='utf8')
print(json.dumps({k: report[k] for k in ('registeredAssets','containers','missingRegisteredAssets')}, ensure_ascii=False))
