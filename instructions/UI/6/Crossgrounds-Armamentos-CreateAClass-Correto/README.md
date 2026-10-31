# Crossgrounds — Armamentos no estilo Create-a-Class

Este pacote corrige a direção anterior.

A referência principal **não** é a tela compacta de loadout da Arena nem o armeiro simplificado. A referência principal é a tela **Create-a-Class** mostrada em `01_referencia/00_create_a_class_referencia.png`.

## Objetivo

Redesenhar a tela de **Armamentos** do Crossgrounds para seguir a linguagem visual e estrutural do Create-a-Class:

- lista de classes à esquerda;
- painéis centrais por slot de equipamento;
- painel de detalhes à direita;
- visual mais robusto e organizado;
- aparência coerente com o gunsmith/armeiro;
- suporte a controle, mouse e toque.

## Restrições funcionais importantes

A Arena **não** deve virar um sistema completo de classes livres.

A implementação deve manter a lógica atual:

- os loadouts continuam sendo predefinidos;
- o jogador apenas escolhe qual loadout usar;
- a troca entra em vigor **somente no próximo nascimento**;
- o equipamento da vida atual é preservado;
- **não** exibir barras de estatísticas da arma na Arena;
- o **Executor** deve aparecer como slot de corpo a corpo fixo do loadout;
- a Arena não precisa de primária + secundária + perks + letais funcionais independentes; isso é apenas linguagem visual de apresentação.

## Arquivos mais relevantes no repositório

- `src/StarterPlayer/StarterPlayerScripts/LoadoutMenuView.luau`
- `src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau`
- `src/StarterPlayer/StarterPlayerScripts/GunsmithView.luau`
- `src/ReplicatedStorage/Crossgrounds/LoadoutDefinitions.luau`
- `src/ServerScriptService/Crossgrounds/LoadoutService.luau`

## Conteúdo

- `INSTRUCOES-CODEX.md` → prompt curto e direto para implementação.
- `PLANO-DE-IMPLEMENTACAO.md` → detalhamento técnico e de UX.
- `01_referencia/00_create_a_class_referencia.png` → referência visual principal.

