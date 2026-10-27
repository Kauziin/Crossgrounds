from pathlib import Path
p=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27\README.md')
s=p.read_text(encoding='utf-8');s=s.replace('Esse teste exercitou o encerramento de um pedido ativo por timeout.','Esse teste exercitou o encerramento de um pedido ativo por timeout. Após restaurar o piso no cliente e clicar em tentar novamente, a rodada voltou a Playing com 11 bots, sem SceneLoading nem tela de carregamento.');p.write_text(s,encoding='utf-8')
