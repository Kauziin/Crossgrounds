# 03 — UI final: manter as duas telas aprovadas

## Fonte visual obrigatória

- `../imagens/01_selecao_de_armas_APROVADA.png`
- `../imagens/02_selecao_de_acessorios_FINAL.png`

As telas **já foram aprovadas**. Implementar o layout e comportamento das imagens, não fazer outro redesign. Preservar a UI Crossgrounds real, com `ExperienceMenu` e navegação em cascata, sem cabeçalho estilo COD.

## Layout compartilhado

- Mundo da partida desfocado ao fundo; não substituir por imagem militar/cenário cenográfico.
- Sidebar global à esquerda (`Continuar`, `Armeiro`, `Progressão`, `Opções`, `Render-se`, `Sair`).
- Conteúdo no painel existente: breadcrumb estreito `‹ LOADOUT`, título simples, subtítulo discreto.
- Painéis quase pretos/azul-esverdeados, cantos arredondados, linhas discretas, turquesa nos estados ativos.
- **Foco de controle** marcado por contorno claro e losango lateral; **item equipado/ativo** é estado distinto.
- Rodapé de dicas atual do Crossgrounds: A/Confirmar, B/Voltar, LB/RB/Categorias.

## Tela de seleção de armas

A imagem `01` representa o layout aprovado. Dentro do painel de conteúdo:

1. **Coluna esquerda:** categorias em cards verticais.
2. **Coluna central:** **lista vertical** rolável de armas, um card por linha, ícone/miniatura leve, nome e estado.
3. **Coluna direita:** prévia da arma, descrição curta e estatísticas compactas.

Clicar/confirmar arma salva seleção diretamente sem tela intermediária de detalhes/confirmação. A indicação `Clique para equipar` não cria botão de aplicação adicional.

## Tela de acessórios — ÚLTIMA VERSÃO, não usar o desenho antigo

A imagem `02` é a referência final. **Não há coluna interna à esquerda para `ODEN`/descrição e três botões grandes.** O espaço foi incorporado à lista:

- **Painel maior à esquerda/centro:** linha horizontal compacta de slots (`Mira`, `Boca`, `Acoplamento`, `Carregador`, `Coronha`, `Laser`, mais os realmente cadastrados); embaixo, lista **vertical** rolável, **um acessório por linha**, com ícone simples, nome e status de compatibilidade. Primeiro item `Sem acessório` para retirar a peça do slot.
- **Direita superior:** bloco de `ViewportFrame` com prévia **da arma selecionada**, incluindo acessórios montados.
- **Direita inferior:** **bloco de estatísticas** com atributos efetivos (incluindo dano, alcance, cadência, precisão/controle/mobilidade quando suportados) e resultado da seleção; usar valores reais, não copiar os números ilustrativos da imagem.
- **Abaixo da lista:** apenas **atalhos compactos**: `Trocar arma`, `Restaurar acessórios`, `Salvar visual`. Não restaurar a coluna removida.
- Nota inferior discreta sobre aplicação imediata no Practice Range.

### Interação direta

- `A`/clique equipa o acessório do slot imediatamente; seleção e foco não devem exigir uma segunda confirmação.
- Recalcular estatísticas e atualizar a prévia **somente quando o estado mudar**; navegar entre linhas não deve salvar.
- `Sem acessório` remove o item daquele slot e persiste.
- O contexto dos slots, o foco e a rolagem devem sobreviver à atualização dos dados.
- Nenhum teto global arbitrário para acessórios equipados; exclusividade por slot/mount continua.

### Complementos funcionais sem alterar o desenho

- Filtro de compatibilidade e busca podem ser incorporados com controles compactos quando o catálogo crescer, sem criar uma nova coluna nem transformar a lista em grade.
- Itens pendentes de auditoria podem aparecer com estado de prévia/incompatível, **mas não podem ser equipados** até a compatibilidade estar validada.
- Navegação LB/RB pode alternar slots; D-pad/analógico percorrem linhas; B retorna ao nível anterior.

## Critérios visuais de aceitação

- Comparar screenshot lado a lado com as duas imagens incluídas.
- A tela de acessórios não contém bloco interno esquerdo de detalhes.
- Os acessórios são exibidos em lista vertical, não grade em duas colunas.
- A direita possui **dois blocos separados**, prévia acima e estatísticas abaixo.
- Botões utilitários são atalhos pequenos, não ações principais.
- Foco do controle e seleção equipada continuam visualmente distintos.
