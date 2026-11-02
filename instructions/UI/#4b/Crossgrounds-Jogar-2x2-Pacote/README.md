# Crossgrounds — Pacote da reforma de Jogar / Modalidades

Pacote de referência para o Codex. Não é um `.rbxm` instalável e **não altera automaticamente o repositório**.

## Onde começar

1. `INSTRUCOES-CODEX.md` — prompt direto para implementação.
2. `PLANO-DE-IMPLEMENTACAO.md` — arquitetura, alterações, fluxos, limitações e checklist.
3. `01_referencias/02_conceito_grid_2x2.png` — **referência visual principal**.
4. `02_imagens_dos_modos/` — quatro imagens provisórias, ainda sem Asset IDs Roblox.
5. `03_exemplos_luau/` — módulos demonstrativos; **não substituir diretamente** arquivos do projeto sem integração.

## Conteúdo

```text
Crossgrounds-Jogar-2x2-Pacote/
├── README.md
├── INSTRUCOES-CODEX.md
├── PLANO-DE-IMPLEMENTACAO.md
├── MANIFESTO-IMAGENS.json
├── 01_referencias/
│   ├── 00_menu_atual.png
│   ├── 01_conceito_lista_detalhes.png
│   └── 02_conceito_grid_2x2.png
├── 02_imagens_dos_modos/
│   ├── arena.png
│   ├── ctf.png
│   ├── duels.png
│   └── get_out.png
└── 03_exemplos_luau/
    ├── ModePresentation.luau
    ├── ModeSelectGrid.luau
    └── GameCatalog-get_out.diff
```

**Estado dos modos:** Arena/CTF — dependendo do servidor; Duels — indisponível; Get Out — deve ficar indisponível na interface pública sem apagar o protótipo.
