# CTF integrado no original

Aplicado no Studio **Crossgrounds (ALPHA)**, Place **4375993208**, em 27/10/2026, após solicitação expressa do usuário para integrar na versão original.

- As 12 fontes do patch CTF foram aplicadas no original. Todas as fontes originais deste escopo ainda coincidiam com a base do patch; não houve conflito na integração do Studio.
- Backup das fontes originais: `before.json`. Fontes integradas: `merged/`. Diff: `merge.diff`.
- O mesmo conjunto de correções foi integrado em `src/`, usando mesclagem de três vias para preservar diferenças locais. A única sobreposição era uma proteção de DataStore já equivalente, com diferença de espaço; a versão local existente foi preservada. Backups locais ficam em `local-before/`.
- Validação no original: boot concluído; entrada hub -> CTF; rodada Playing; InArena=true; SceneLoading=false; tela de carregamento liberada; 11 bots.
- Coleta de bandeira confirmada no original: estado carried, referência/nome do portador, Highlight, BillboardGui e aviso de posse na interface.
- Play encerrado após validação. Alterações permanecem no DataModel de edição do original e nas fontes locais. A experiência não foi publicada no Roblox por esta tarefa.

As alterações de outros sistemas fora dessas 12 fontes foram preservadas. Detalhes do patch e testes extensos de falha/recuperação estão em `../ctf-flow-2026-10-27/README.md`.
