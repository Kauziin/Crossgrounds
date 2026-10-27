# Tela inicial do Crossgrounds

Redesenho restrito ao `HubController`, na cópia local. A tela de pausa, opções, catálogo de modalidades, progresso e playlist conservam seus componentes e fluxos anteriores.

## Visual

- Gradiente preto semitransparente em tela inteira: canto superior esquerdo mais escuro, transição para o cenário à direita e abaixo.
- Título CROSSGROUNDS em Gotham Black, turquesa, com linha decorativa curta e continuação discreta.
- Ordem: Jogar, Permanecer no lobby, Progresso, Ajustes, Música / Playlist.
- Ícones construídos com elementos de UI, sem dependência de imagens remotas ou caracteres de fonte não suportados.
- Opções sem fundo quando não selecionadas, separadores sutis e espaçamento compacto.
- Somente a seleção recebe superfície escura, contorno e brilho turquesa e losango lateral. O cursor de controle existente assume o losango no gamepad.

O estilo do foco compartilhado é alterado somente enquanto a tela inicial está visível, e restaurado ao entrar em outro menu. Nenhuma fonte compartilhada foi alterada para isso.

## Navegação e adaptação

As ações reutilizam os mesmos callbacks do controlador anterior. Jogar leva à cascata de modalidades; voltar ao início reativa esta apresentação. Permanecer no lobby conserva o cancelamento de entrada pendente e a ação de reabrir o catálogo.

Escala do menu e escala de fonte são consideradas no cálculo de título, margens e altura das opções. Em telas baixas, a lista rola e revela o item focado. Há reserva inferior para o rodapé de controle e para o aviso admin já existente, sem modificar essas interfaces.

## Verificação

- Compilação do controlador no motor do Roblox.
- Capturas do desktop em 1366 × 767 e do iPhone 17 Pro em paisagem, com viewport efetivo de 749 × 381.
- Ordem e exclusividade do destaque verificadas pelas propriedades dos cinco botões.
- Entrada simulada com D-pad, A e B: catálogo de modos, progresso, ajustes, playlist, permanência no lobby e retorno.
- Cor original do foco restaurada ao abrir Ajustes.
- Comparação de hashes confirma que ExperienceMenu, MenuTheme, MenuNavigation e InterfaceThemeController não mudaram durante esta etapa.

Controle físico e multitoque real permanecem sem validação. A cópia contém avisos preexistentes de carregamento e de plugin, registrados antes deste redesenho; eles não foram tratados neste escopo.

## Arquivos

- [Fonte](../src/StarterPlayer/StarterPlayerScripts/HubController.luau).
- [Place local completo](../artifacts/home-screen-2026-10-27/Crossgrounds-Home.rbxl), baseado na cópia da etapa de interface e áudio.
- [Fonte anterior](../artifacts/home-screen-2026-10-27/before/HubController.luau).
- `build-manifest.json` registra o hash do arquivo, o hash da fonte e os chunks preservados. O único script de runtime substituído nesta etapa é HubController.

O Place foi gerado sem alterar o arquivo de origem: todos os chunks binários são preservados, exceto o bloco de fontes LocalScript, no qual somente HubController é substituído. A cópia deve ser lida pelo Roblox Studio, não importada como modelo.
