# Cascata, acrílico e permanência no lobby

**Ajuste visual posterior:** os painéis de cascata passaram a usar fundo sólido, intervalo de 8 px e sombra gradual nas seções anteriores. A área externa permanece transparente. [Estado mais recente](CASCATAS-SOLIDAS.md).

**23/10/2026 — implementado no projeto aberto, sem publicação.**

**Atualização posterior:** blur agora é 0 no primeiro nível e 18 nos seguintes. Cards, playlist, XP e tabelas foram refinados. O [novo relatório e incremental cumulativo](LOBBY-PLAYLIST-XP-ESTATISTICAS.md) substituem os valores e o pacote desta etapa.

## Causa do defeito

ExperienceMenu usava ZIndexBehavior.Global. Os fundos das colunas tinham ZIndex 2/3/4; vários textos e botões descendentes permaneciam em 1. Assim, o próprio fundo cobria os controles. GetGuiObjectsAtPosition confirmou o fundo antes do botão; a captura mostrava a coluna vazia.

O patch anterior verificava Visible e posição das quatro colunas. Esse teste era insuficiente: uma instância visível podia estar coberta. Agora o menu usa Sibling, e a validação incluiu captura e consulta de sobreposição sobre o campo de sensibilidade.

## Alterações

- Tema compartilhado MenuTheme: superfícies escuras translúcidas, bordas claras discretas, cantos arredondados e resposta ao foco/hover, seguindo o botão Menu.
- CascadeMenu compartilhado entre tela inicial, seleção de modalidades, entrada/kits de CTF, progresso/amigos e votação da Arena.
- Painéis anteriores permanecem acessíveis, com largura comprimida e textos truncados. O último painel recebe o espaço restante. Recorte evita textos atravessando as outras colunas.
- A área externa à cascata é transparente. Só as colunas abertas possuem fundo; fechar o menu remove os painéis e o desfoque.
- O acrílico é uma aproximação com transparência, gradiente e BlurEffect do cenário. Não é desfoque nativo independente por painel.
- HUD da Arena é ocultado enquanto seus menus estão abertos; a barra de vida/estamina mantém o fundo transparente durante a partida. Botões mobile preservam posição e opacidade configuradas.
- Navegação mantém cursor próprio, foco, voltar e rolagem; textos de perfil podem receber foco para permitir rolagem com controle.
- Inicialização do JoinMenu aguarda os remotes reais, corrigindo uma corrida encontrada em uma sessão nova do Studio.

## Permanecer no lobby

**Permanecer no lobby** é a primeira ação da tela inicial e também aparece na pausa enquanto o jogador está no hub. Fecha a interface, permite movimentação, limpa entrada rápida e cancela uma entrada pendente quando aplicável. Atualizações do servidor não reabrem o catálogo.

**Jogar / Modalidades** reabre o catálogo. Voltar de uma modalidade ao hub também permite permanecer andando nele. No menu de entrada do CTF há a mesma ação para fechar a escolha sem entrar na partida.

## Verificações realizadas

| Verificação no Studio | Resultado |
|---|---|
| Reprodução do defeito original | Fundo sobre botões confirmado por ordem de sobreposição e captura |
| Opções → Controles → Mira | Quatro colunas renderizadas; campo Value acima do fundo e acessível |
| Permanecer no lobby | Interface fechada, fora da partida, sem bloqueio de movimento |
| Atualização do estado após fechar | Catálogo permaneceu fechado |
| Desfoque | 9 com menu aberto, 0 e desativado após fechar |
| Kits do CTF | Leve selecionado no servidor; Vasnev 9mm/Faca exibidos; fechar sem entrar funcionou |
| Progresso e amigos | Painéis abriram, raiz transparente e desfoque ativos |
| Arena pelo catálogo real | Entrada local funcionou; votação abriu e voto recebeu confirmação ✓ |
| Último smoke test | stayClosed=true, mode=arena, maps=true, headerSize=15, hudHidden=true, hudTransparent=true, blur=9 |
| Fontes finais | 122 encontradas, compiladas, sem divergências em relação ao snapshot da implementação |
| Contratos existentes durante esta tarefa | 84/84 aprovados; não substituem os testes visuais |

Não foram encontrados novos erros destes controladores nas últimas sessões. O console ainda registra erro do plugin externo GUIEditor e avisos de StarterPlayerScripts da ferramenta.

**Limites:** navegação por código/entrada simulada e capturas no Studio; sem controle físico Xbox/PlayStation, multitoque real, teclado virtual, PvP humano ou latência. A adaptação de largura existe, mas não equivale a validação visual de todos os formatos de celular. CoreGui e menus nativos do Roblox não são tematizados. Rendição por votação, penalidades ao sair e modos planejados continuam pendentes.

## Fontes e pacote

Dez fontes alteradas/adicionadas em src/StarterPlayer/StarterPlayerScripts: MenuTheme, CascadeMenu, InterfaceThemeController, HubController, MenuNavigation, ExperienceMenu, JoinMenu, CombatHUD, ProgressionPanel e ArenaHUD.

Backup das fontes anteriores: ServerStorage.AcrylicUIBaseline_20261023. O legado, mapas, progressão e configurações de teleporte foram preservados. O projeto permanece combinedPrototype e TeleportEnabled=false. Runner automático desativado.

[Pacote incremental de UI](../artifacts/crossgrounds-ui-acrilico-2026-10-23.rbxm): **45.722 bytes**, dez fontes organizadas por serviço. SHA-256: **0D94F3C70B3CD6AAA9A9FD977F2A1BFAE9FBF96810FFE1DD19340BF45E3FE5C2**.

É uma atualização sobre os pacotes Bugs23 de 98 fontes, resultando em 101 fontes de runtime. Não é Place completo, não inclui mapas/dependências anteriores e não tem instalador automático. Para outro Place, substituir/adicionar cada fonte no serviço correspondente sem duplicar controladores. O projeto aberto já está atualizado: não reimportar nele.

Os pacotes completos Bugs23 continuam históricos quanto à UI e precisam desta atualização. A instalação do incremental em outro Place não foi testada. Não houve publicação ou instalação remota.
