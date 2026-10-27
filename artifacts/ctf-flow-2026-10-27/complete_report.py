from pathlib import Path
import json
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27')
p=r/'README.md';s=p.read_text(encoding='utf-8')
s=s.replace('- Falha de chão simulada apenas no DataModel de Play:', '- Falha imediata de chão simulada apenas no DataModel de Play:')
s=s.replace('A simulação não foi gravada no Place.','A simulação não foi gravada no Place.\n- Após corrigir o tratamento da falha imediata, uma nova simulação abriu a tela de atenção com os dois botões. O clique real em Tentar carregar mapa retomou a rodada e a tela desapareceu.\n- Cliente com piso não confirmado, enquanto o mapa do servidor continuava válido: a espera expirou em LoadFailed, SceneLoading foi limpo e a interface apresentou nova tentativa e saída. Esse teste exercitou o encerramento de um pedido ativo por timeout.')
p.write_text(s,encoding='utf-8')
baseline={str(p.relative_to(r/'baseline').with_suffix('')).replace('\\','.'):p.read_text(encoding='utf-8') for p in (r/'baseline').rglob('*.luau')}
(r/'baseline.json').write_text(json.dumps(baseline,ensure_ascii=False),encoding='utf-8')
