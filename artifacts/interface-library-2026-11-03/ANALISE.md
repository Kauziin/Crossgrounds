# Análise visual das interfaces

Base: as 170 capturas de 03/11/2026. A decisão é **manter a linguagem visual e a estrutura atual** e tratar três ajustes pontuais em uma etapa de interface. As capturas com fixtures são evidência da apresentação, não de uma partida ou economia real.

## Manter

- A navegação em cascata distingue bem hub, configurações, progressão e armamentos. Superfícies escuras, cor de destaque e estados selecionados estão consistentes; padronizar tudo em um único painel reduziria a clareza dos fluxos.
- Alertas de bandeira, avisos de nível, votação, carregamento e falha têm hierarquia e localização reconhecíveis. O erro de carregamento mostra recuperação explícita. A prévia funcional do Armeiro em `417` mostra modelo, lista e estatísticas sem esconder o armamento.
- O seletor de seções mobile da progressão (`615`) é legível e oferece acesso direto às cinco páginas. O HUD de combate mantém espaço para o cenário, inclusive nas capturas landscape.

## Mudar

1. **Prioridade alta — ações inferiores do Armeiro.** Em `417`, a primeira linha dos botões de ação aparece cortada na borda inferior do painel; `7201` confirma que a rolagem externa permite alcançá-los. Fixar ou elevar as ações principais dentro da área visível reduziria a chance de o jogador achar que elas não existem. Preservar a rolagem para o restante da ficha.
2. **Prioridade média — escaneabilidade dos dados de clã e grupo.** As telas populadas `050–057` usam texto corrido para nível, XP, histórico, contribuições e cargos, enquanto as listas de Progressão e Armeiro já têm cartões e valores separados. Aplicar essa separação aos dados de clã/grupo facilitaria a leitura, sem mudar ações nem o fluxo lateral.
3. **Prioridade média — menus no telefone.** No iPhone landscape, hub (`600`) e páginas social/carreira/clã/armas (`607–610`) ocupam uma pequena parte da largura. O padrão móvel de 60% foi escolhido anteriormente e deve ser preservado; revisar apenas limites mínimos de texto e alvos de toque dessas páginas. A captura de Progressão (`606`) mostra os cartões continuando abaixo da janela, acessíveis por rolagem; não é um corte sem saída.

## Não classificar como defeito visual desta rodada

- Páginas internas vazias forçadas em `010–047`, modelos ausentes nas prévias preliminares `401–416`, e estruturas antigas de votação `040–041` não descrevem estados finais do fluxo atual.
- `220` mostra corretamente que rendição por equipe em CTF ainda não existe. Isso é uma pendência de produto já indicada pela própria tela; o botão não deve prometer confirmação.
- A captura mobile do editor de HUD (`604`, `614`) mostra controles sobrepostos durante **edição**, quando o usuário precisa posicioná-los. A rodada não verificou o gesto real de arrastar e salvar em hardware.

Nenhuma alteração estética foi aplicada nesta tarefa. As mudanças acima exigem uma rodada própria de layout e validação de entrada/rolagem para não degradar as telas já funcionais.
