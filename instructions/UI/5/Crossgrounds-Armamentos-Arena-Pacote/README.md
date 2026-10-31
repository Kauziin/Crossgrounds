# Crossgrounds — Pacote da interface de Armamentos (Arena)

## Comece por aqui

- **`INSTRUCOES-CODEX.md`**: solicitação pronta para o Codex, com escopo e critérios de aceite.
- **`PLANO-DE-IMPLEMENTACAO.md`**: comportamento, arquitetura, responsividade e validação.
- **`01_referencias/00_menu_anterior_lista.png`**: captura do menu de armamentos antes da apresentação com cards 3D.
- **`01_referencias/01_conceito_grade_2x3_com_preview.png`**: imagem conceitual criada nesta conversa.
- **`02_exemplos_luau/`**: constantes de layout e contrato didático de seleção. **Não são substitutos drop-in** dos módulos atuais.
- **`03_repositorio/`**: mapa dos arquivos e o estado do projeto consultado em `master` em 31/10/2026.

## Escopo

Apenas a interface de seleção de armamentos da **Arena**. O **CTF/Create-a-Class/Gunsmith** é uma interface diferente e fica fora deste pacote. O repositório já implementa uma boa parte da apresentação aqui especificada: seis cards 2×3 com ViewportFrame, painel com prévia de arma e Executor e persistência por loadout pendente. Faça a implementação **diferencial**: audite primeiro o código atual e altere apenas lacunas de UX/visual identificadas.

## Atenção ao conceito visual

A imagem é referência de composição, não especificação fiel do gameplay. Ela contém **barras de Dano/Controle/Mobilidade e uma representação equivocada do Executor como arma de fogo**. **Não reproduza essas partes.** O Executor é uma arma **corpo a corpo** e a Arena **não terá painel de estatísticas de armas**. O layout deve seguir a intenção: 2 colunas × 3 linhas de pistolas no lado esquerdo e prévia 3D ampliada da arma + Executor no lado direito.

## Não incluso

- Arquivos originais do repositório alterados, PR ou commits.
- Modelos 3D das armas (são recursos já gerenciados no Roblox Studio por `ReplicatedStorage.Crossgrounds.LoadoutPreviews`).
- Novos sistemas de armamento, dano ou personalização de classes.

**Fonte do projeto:** https://github.com/Kauziin/Crossgrounds/tree/master
