# Crossgrounds — Plano de Reformulação do Sistema de Progresso

A reformulação deve transformar o atual menu de Progresso em um sistema centralizado de estatísticas, rankings e comparação entre jogadores, utilizando as três referências visuais que criamos.

O objetivo é preservar a identidade visual do Crossgrounds, melhorar a apresentação das informações e introduzir um sistema de reconhecimento para os melhores jogadores de cada modalidade.

## 1. Estrutura principal

PROGRESSO

Estrutura proposta

Estatísticas Pessoais

Placar de Líderes

Comparativo com Amigos

Conteúdo dinâmico da página selecionada

As três páginas devem compartilhar navegação, tipografia, cores, transições e indicadores de foco, mas possuir layouts próprios.

## 2. Estatísticas Pessoais

Reproduzir a primeira referência visual, organizando a página em três regiões:

- Perfil: avatar Roblox, nome, nível, moedas e barra de XP.
- Estatísticas globais: eliminações, mortes, relação E/M, tempo jogado, vitórias e demais métricas disponíveis.
- Por modalidade: quatro cards para Arena, Get Out, Duels e Capture The Flag, mostrando indicadores relevantes a cada jogo.

Um filtro superior permitirá alternar entre visão geral e estatísticas individuais de cada modalidade.

As estatísticas devem vir dos dados reais do jogador, não de valores demonstrativos.

## 3. Placar de Líderes

Adotar a segunda referência, com ranking em formato de tabela compacta.

Filtros necessários:

- Métrica: XP, nível, eliminações, vitórias e outras métricas compatíveis.
- Classificação: Global ou Amigos.
- Modalidade: Geral, Arena, Get Out, Duels e Capture The Flag.

Os três primeiros colocados terão identificação especial. O jogador também verá sua própria posição em uma linha fixa na parte inferior, mesmo que esteja fora da lista visível.

### Sistema de prestígio dos líderes

Aqui entra seu novo recurso: os melhores jogadores globais de cada modalidade receberão nomes com gradientes exclusivos, exibidos dentro da modalidade correspondente.

PRÉVIA DOS NOMES DE PRESTÍGIO

1º lugar — Ouro

2º lugar — Prata

3º lugar — Bronze

Nomes ilustrativos. As posições devem ser determinadas exclusivamente pelos rankings reais.

### Regras do prestígio

1. Os gradientes serão concedidos aos três primeiros colocados do ranking global de cada modalidade.
2. O efeito aparecerá sobre o nome do jogador no placar, na lista de jogadores e nas identificações visíveis durante partidas daquela modalidade.
3. Um jogador poderá possuir classificações diferentes em modalidades diferentes, recebendo o gradiente correspondente em cada uma.
4. O prestígio deverá acompanhar a posição atual do ranking, sendo atualizado quando a classificação mudar.
5. Rankings de amigos não concederão prestígio, e a posição global geral não substituirá a posição específica de cada modo.

No Roblox, é possível utilizar `UIGradient` em elementos `TextLabel` para produzir esses efeitos sem depender de imagens. A posição e a autorização do prestígio devem ser determinadas pelo servidor.

## 4. Comparativo com Amigos

Utilizar a terceira referência visual.

O jogador selecionará um amigo em um menu suspenso e visualizará ambos os perfis lado a lado.

Abaixo, serão apresentadas as estatísticas correspondentes, com barras comparativas e diferenças numéricas.

As categorias serão Resumo, Arena, Get Out, Duels e Capture The Flag.

Uma observação importante: indicadores como mortes não devem ser tratados automaticamente como positivos quando possuem valores maiores. As cores de vantagem precisam considerar o significado de cada estatística.

## 5. Implementação técnica

01

Estrutura e navegação

Separar as três páginas, mantendo compatibilidade com mouse, teclado e controle.

02

Dados e estatísticas

Organizar métricas globais e por modalidade, aproveitando a persistência existente.

03

Perfis e comparativos

Construir os cards, filtros e comparações usando dados reais.

04

Rankings globais

Implementar classificação, paginação ou Top N, consultas e posição pessoal.

05

Prestígio dos líderes

Criar gradientes por colocação, sincronizados e limitados à modalidade correspondente.

06

Testes e refinamento

Validar persistência, empates, atualização dos rankings, diferentes telas e navegação por controle.

## 6. Decisões importantes

Antes da implementação completa, considero fundamentais duas definições.

Rankings por modalidade precisam de métricas próprias. Na Arena, eliminações e relação E/M fazem sentido; em Get Out, fugas e vitórias como sobrevivente ou perseguidor podem ser mais representativas. Isso evita premiar comportamentos que não correspondem ao objetivo de cada jogo.

O prestígio precisa ter uma regra de atualização estável. Recomendo recalcular e publicar periodicamente as posições, em vez de realizar consultas globais sempre que um jogador entrar em uma partida. Em caso de empate, deve existir um critério consistente de desempate.

Também é importante separar a posição global verificada da posição armazenada temporariamente em cache, para não conceder gradientes incorretos.

Resultado esperado: três interfaces visualmente distintas, porém coerentes, com dados compartilhados, rankings competitivos e um sistema de reconhecimento que torna os melhores jogadores identificáveis dentro de suas respectivas modalidades.

Esse último detalhe pode se tornar uma das características sociais mais interessantes do Crossgrounds: não apenas mostrar quem está no topo, mas fazer essa conquista ser reconhecida durante a própria partida.