# UI #10b — recriação da interface como segunda experiência

Data: 03/11/2026. A seção 12 consolida as decisões mais recentes e prevalece sobre hipóteses anteriores. Estado: planejamento; nenhuma nova implementação autorizada por este documento. Substitui a interpretação de três estilos apresentada na entrega anterior.

## 1. Pedido corrigido

Existirão exatamente duas opções para o jogador:

1. **Interface atual**: experiência existente, mantida disponível.
2. **Nova interface**: apresentação e organização reconstruídas a partir das tarefas do jogador, com identidade própria e consistente.

“Geral” e “Completo” são arquétipos internos da nova interface: telas de descoberta/navegação e telas de trabalho/edição. Não serão três estilos selecionáveis e não constituem versões simplificadas por subtração de caixas.

A recriação abrange a experiência de menus e suas transições. Compartilhará dados, autorização, configurações e ações de jogo; terá composição, componentes e jornadas próprios. Esta etapa entrega o plano, sem modificar scripts, preferências, Studio ou publicação. As decisões de produto serão discutidas quando o usuário retornar.

## 2. Diagnóstico e evidência

A captura enviada mostra título, lista vertical e personagem no cenário, essencialmente na organização anterior. Há áreas escuras com transições geométricas duras que merecem investigação visual; a imagem sozinha não identifica sua causa. A nova direção deve usar máscaras/gradientes suaves, sem recortes involuntários sobre o cenário.

Inspeção atual do código:

- `HubController.local` constrói sua apresentação inicial e um fundo próprio, além de encaminhar ações a `HubBridge`/`MenuNavigation`.
- `ExperienceMenu.local` combina navegação, criação de páginas e callbacks; somente acrescentar dimensões/cores não produz uma segunda experiência.
- `InterfaceStylePolicy` oferece atualmente IDs 0/1/2 e métricas. Essa proposta anterior não atende à correção do usuário.
- `MenuTheme`, `AccentTheme`, `SettingsCard` e as Views de Progresso/Armeiro já oferecem trabalho reaproveitável, mas impõem parte da composição atual.
- O laboratório `StudioInterfaceDebug` permite comparar estados, porém algumas entradas simulam contexto. Evidência de laboratório deve ser distinguida de uma jornada normal.

A referência de Progresso oferece hierarquia e agrupamento; a de Acessórios oferece lista, prévia dominante e ferramentas contextuais. Ambas orientam a linguagem, sem obrigar a reproduzir uma estrutura inadequada para outra tarefa. Números e acessórios ilustrativos não viram regras de jogo.

## 3. Princípios da nova experiência

- Uma tarefa principal reconhecível por tela, com ação primária e consequências explícitas.
- Entrada fácil para jogar; ferramentas avançadas aparecem no contexto em que são necessárias.
- Hierarquia por tipografia, espaço, alinhamento e contraste. Bordas e brilho orientam seleção/foco, sem decorar todos os blocos.
- Menus não escondem ações importantes abaixo da dobra em resoluções de referência. Listas extensas podem rolar; ferramentas essenciais têm região própria.
- Aparência selecionada, elemento focado, opção equipada e alteração pendente são estados diferentes e visíveis.
- Mouse, controle e toque têm composições apropriadas, com os mesmos dados e resultados.
- Paleta de cores e estilo de interface são escolhas independentes. Contraste, leitura e cores de equipes/saúde continuam protegidos.

## 4. Arquitetura de informação proposta

A organização abaixo é uma hipótese para protótipo, não remoção de funções atuais.

| Entrada | Propósito | Composição proposta |
|---|---|---|
| Jogar | Escolher modalidade e entrar | Modos com disponibilidade clara, seleção e ação de entrar na mesma jornada |
| Armamentos | Escolher e editar equipamento | Classes, arma e acessórios conectados por um percurso contínuo |
| Carreira | Consultar identidade, progresso e recompensas | Resumo pessoal com entradas para estatísticas, níveis, ranking e perfil |
| Social | Amigos, grupo e guilda | Visão de grupo e convites; detalhes avançados sob demanda |
| Configurações | Ajustar jogo, controles e aparência | Categorias estáveis, busca proposta e detalhes contextualizados |
| Música | Controlar playlist | Painel secundário acessível sem substituir toda a navegação |

“Permanecer no lobby” pode tornar-se uma ação contextual de fechar/explorar, em vez de competir com todas as seções. Deve continuar fácil de descobrir. A eventual união de Progressão e Carreira precisa de validação com o usuário; funções atuais devem permanecer encontráveis.

A pausa será uma jornada curta: continuar, equipamento, configurações e ações da partida. Deve deixar claras seleção para o próximo nascimento e diferenças do Practice Range. Não será uma cópia reduzida da tela inicial.

## 5. Direção visual

### Telas de navegação e descoberta

Cenário preservado, gradiente escuro suave localizado atrás do conteúdo e marca forte. Poucas ações prioritárias, área de identidade/grupo discreta e conteúdo secundário contextual. Estudar uma entrada assimétrica com bloco principal e resumo contextual, para que a recriação não repita automaticamente a lista atual com outra cor.

Comparar em wireframe duas composições de inicial antes de escolher: navegação lateral enxuta com área contextual; e ação Jogar dominante com destinos secundários compactos. Ambas devem funcionar no controle sem salto de foco ambíguo.

### Telas de trabalho e edição

Área útil ampla, cabeçalho compacto e navegação de contexto. Uma superfície de trabalho, evitando várias caixas encaixadas. Listas, prévia e detalhes dimensionados pela tarefa. Rodapé com ações reais e acessíveis, não apenas uma legenda.

### Sistema de componentes novo

Definir tokens próprios de espaçamento, tipografia, superfície, foco, movimento e densidade. Criar shell, navegação, lista, card, seletor, slider, diálogo, painel contextual, prévia 3D e rodapé. Compartilhar a paleta quando adequado; não aplicar uma varredura global de recoloração para simular a nova arquitetura.

Usar os ícones atuais onde forem legíveis e coerentes. Ícones sem texto precisam de nome acessível e descrição contextual. Animações curtas, reversíveis e dispensáveis com movimento reduzido.

## 6. Jornadas prioritárias

### Inicial → jogar

O jogador identifica a ação Jogar, escolhe um modo e entende disponibilidade, grupo e destino. Estado de fila/entrada visível, cancelamento acessível e retorno ao contexto anterior. O personagem e o cenário devem continuar tendo presença visual.

### Armamentos → classe → arma → acessórios

- Card da classe como unidade, mostrando seleção ativa e eventual configuração pendente.
- A escolhe; X entra na edição; LS abre gerenciamento quando esse comando estiver disponível no contexto.
- Edição com arma em destaque, lista útil e categorias próximas do conteúdo.
- Nome, compatibilidade, equipado e bloqueio explicados sem depender de cor.
- Regra de aplicação exibida: próximo nascimento ou aplicação imediata no treino, conforme o sistema real.
- Atributos apenas quando sustentados pela modalidade; Arena continua sem estatísticas de arma.
- Uma única prévia principal reutilizada, sem gerar um ViewportFrame pesado por linha.

### Configurações e tema

Lista de categorias estável, grupos de opções e ajuda associada ao foco. Considerar pesquisa local pelos rótulos existentes. Expor somente “Atual” e “Nova” na escolha de interface.

Tema personalizado deve ser uma ferramenta visual: seleção do papel, editor de cor e prévia. Em telas grandes, organizar essas regiões; em telas estreitas, alternar etapas. Edição temporária, Aplicar/Cancelar e proteção de contraste. Expandir o esquema validado no servidor antes de persistir cores por papel; preservar permissões existentes.

### Progresso, carreira e social

Começar por resumo e ações procuradas; detalhes/rankings/trilhas têm navegação própria. Mostrar dados reais, estados vazios e falhas de carregamento. Guilda/grupo mantêm associação e autorização existentes. Não preencher espaços com recompensas, membros ou missões fictícias.

### HUD e notificações

Planejar como etapa própria: hierarquia de informações em combate, mensagens temporárias, pausa ocultando HUD e editor livre. Novo estilo de menu não deve alterar automaticamente a leitura de saúde, cores de equipes ou posição dos controles salvos. Extensão do novo estilo ao HUD inteiro será uma decisão explícita.

## 7. Separação técnica

Preservar os serviços e regras de XP, inventário, loadouts, matchmaking, guilda e preferências. Separar gradualmente os callbacks atualmente embutidos nos controladores das instâncias visuais, mantendo contratos verificáveis.

Proposta de montagem:

- Estado e ações existentes → adaptadores de apresentação → apresentação Atual **ou** Nova.
- Um coordenador escolhe qual apresentação montar. Apenas a ativa recebe entrada e mantém prévias/assinaturas caras.
- A apresentação Nova usa um shell e componentes novos, sem depender de pequenas condições de estilo espalhadas por cada View antiga.
- `MenuNavigation`/`ControlRouter` continuam como contratos de entrada; revisar foco, escopo e retorno para a nova árvore de navegação.
- Ao trocar estilo, fechar modais com segurança, resolver edição pendente e desmontar a apresentação antiga. Preservar preferências e dados de equipamento; não transportar referências de GuiObjects destruídos.

Antes de implementar, definir um retrato estável da Interface atual. O ID 0 não deve ser chamado de restauração perfeita do estado anterior sem comparação, pois houve alterações compartilhadas na entrega anterior. Preservar correções funcionais úteis, isolando as diferenças estéticas.

Migração proposta: ID 0 permanece Atual; valores experimentais 1/2 passam a uma única Nova somente quando ela estiver pronta. A escolha e o momento dessa migração precisam constar da implementação, com teste de perfis antigos e possibilidade de retorno. Não executar migração nesta fase.

## 8. Controle, acessibilidade e responsividade

- A confirma, B retorna ao contexto anterior; X/Y e ombros aparecem apenas quando há ação no foco atual. Preservar remapeamentos e atalhos compartilhados.
- Cada página declara foco inicial, adjacência, retorno e recuperação após dados carregarem ou itens sumirem.
- Rodapé acompanha o dispositivo ativo; touch oferece botões acionáveis para ações importantes, sem depender de teclas de controle.
- Foco duplo/losango e estado equipado distinguíveis mesmo sem perceber a cor.
- Validar 1920×1080, 1280×720, 4:3, ultrawide e mobile paisagem/retrato quando suportado. Evitar adaptar tudo reduzindo escala.
- No toque, meta de área acionável de pelo menos 44 px; usar reorganização/etapas quando faltar espaço. Respeitar zonas seguras e perfis de escala existentes.
- Testar aumento de fonte, alto contraste, movimento reduzido, nomes longos e texto em português. O uso com controle físico continua uma validação separada do simulador.

## 9. Execução e pontos de revisão

| Etapa | Entrega | Condição para avançar |
|---|---|---|
| 1. Inventário | Mapa de telas, ações, proprietários de estado e dependências | Nenhuma função atual fica sem destino |
| 2. Jornadas | Diagramas e wireframes de inicial, jogar, classe/acessório e configurações | Revisão de produto após o retorno do usuário |
| 3. Direção visual | Mockups de inicial e Armeiro, mais versão mobile | Aprovação de hierarquia e identidade, antes de codificar todas as páginas |
| 4. Fundação | Shell, componentes, adaptadores e seleção binária em ambiente de teste | Desmontagem, foco e retorno ao estilo atual validados |
| 5. Corte vertical | Jogar e editar um armamento usando os dados reais | Jornada completa sem quebra de regra de equipamento |
| 6. Migração gradual | Configurações/tema, Progresso/carreira, social/música e estados da partida | Paridade funcional e comparação por tela |
| 7. HUD, se incluído | Apresentação e editor próprios | Aprovação explícita do alcance e preservação dos layouts salvos |
| 8. Consolidação | Testes, capturas comparativas e documentação | Critérios de aceitação atingidos; publicação em pedido separado |

Não estimar conclusão do sistema inteiro a partir de uma tela pronta. Cada etapa deve registrar fontes alteradas, testes efetivos e limitações no Estado de desenvolvimento.

## 10. Aceitação

- O jogador vê exatamente duas opções de interface.
- A nova versão tem jornadas e composições próprias, comprovadas em comparação lado a lado; mudança de cor/tamanho não basta.
- Recursos atuais continuam acessíveis e dados permanecem consistentes entre estilos.
- Fluxos frequentes têm percurso curto e compreensível, validado em protótipo; ações perigosas/contextuais permanecem claras.
- Nenhuma ação depende exclusivamente de hover, cor ou um atalho oculto.
- Foco e rolagem permanecem previsíveis ao voltar, trocar categoria e receber atualizações.
- Edições pendentes são resolvidas antes da troca de apresentação; troca de estilo não equipa, exclui ou duplica armamentos.
- Capturas correspondem às fontes finais e jornadas reais, com fixtures identificadas.
- Medir tempo de abertura, quantidade de instâncias/conexões e custo das prévias contra a base atual; registrar a medição em vez de prometer FPS.
- Interface atual continua utilizável; sem publicação automática.

## 11. Direção confirmada pelo usuário

Após as perguntas, o usuário confirmou:

- **Cinematográfica** como direção da Nova: cenário e personagem com presença, hierarquia forte e composição atraente. A inicial atual ajuda a explicar a intenção, mas não deve ser simplesmente reaproveitada como solução nova.
- **Menus principais primeiro; HUD depois.** A primeira etapa deve estabelecer a linguagem visual e as jornadas. Não alterar HUD de combate nesta etapa.
- **Liberdade para reorganizar funções e caminhos**, incluindo agrupamentos e mudanças de nomes quando melhorarem o uso, preservando recursos e regras de jogo. Não é necessário perguntar sobre cada decisão rotineira de organização.
- **Mensagens do HUD precisam de um sistema visual coerente.** O usuário identifica falta de acabamento entre blocos grandes e textos avulsos. Isso passa a requisito explícito da etapa de HUD.

### Aplicação da direção cinematográfica

A inicial estabelece identidade, cenário e ação principal. Ao entrar em configurações ou edição, a mesma linguagem continua por tipografia, cor, transições e superfícies, mas o espaço de trabalho ganha prioridade. Cinematográfico não significa impor títulos gigantes, animações longas ou reduzir a legibilidade do Armeiro.

Composição proposta para o primeiro protótipo:

1. **Jogar** como ação principal, com modalidade e estado de entrada claros.
2. **Armamentos** como destino direto, sem atravessar páginas genéricas de opções.
3. **Carreira** reunindo perfil, estatísticas, progresso, desbloqueios e rankings em seções reconhecíveis.
4. **Social** reunindo amigos, grupo e guilda, com resumo do grupo acessível na inicial.
5. **Configurações** com categorias próprias e acesso previsível pela pausa.
6. **Música** em painel rápido; explorar/permanecer no lobby como ação de fechar a navegação, com recuperação visível.

Esta organização é a proposta de trabalho para wireframes; ainda não é interface implementada. O primeiro conjunto deve mostrar inicial, seleção de modo, classe/acessórios, configurações e adaptação mobile, com um mapa de navegação conectando esses estados. Escolher a composição visual após comparação, não apenas reutilizar o layout da inicial atual.

### Requisito da etapa seguinte: linguagem de mensagens

Inventariar todas as mensagens e seus gatilhos antes de migrar: confirmação, erro, alerta de partida/objetivo, recompensa/level up e informação persistente. Criar uma família de apresentação com tipografia, espaçamento, ícones, cores semânticas, entrada/saída e posições consistentes.

Variações devem corresponder à importância e à ação necessária. Uma confirmação breve não precisa ocupar o espaço de um alerta de objetivo, mas ambas devem parecer do mesmo sistema. Definir prioridades, fila limitada, agregação de repetições, duração adequada, regiões sem sobreposição e som proporcional à relevância. Preservar volumes, movimento reduzido, leitura ampliada e acesso às mensagens importantes. Não transformar cada informação em um bloco grande nem depender de texto avulso sem hierarquia.

Pendências de design que podem ser resolvidas no protótipo: nome público da Nova, composição final da inicial, posicionamento exato dos painéis rápidos e tratamento de rascunhos na troca de estilo. Sem novas perguntas necessárias para continuar o planejamento visual.

## Validação desta etapa

Planejamento fundamentado em inspeção das fontes citadas, referências #10b já analisadas e captura nova fornecida. Nenhuma fonte funcional alterada, nenhum teste de runtime executado, nenhuma interface nova implementada ou publicada. O relatório anterior é histórico e não substitui esta direção corrigida.


## 12. Especificação consolidada após esclarecimentos do usuário

Esta seção prevalece sobre propostas incompatíveis das seções anteriores. O usuário concedeu liberdade de reorganização e delegou a escolha do processo de revisão. A etapa atual continua sendo planejamento e prototipação; não é autorização para publicar.

### 12.1. Identidade e referência

- Exatamente duas experiências: **Atual**, com a aparência anterior ao trabalho Geral/Completo; e **Nova**, construída com foco em facilidade de navegação e acabamento.
- Preservar a identidade Crossgrounds. Evitar aparência genérica de simulator, excesso de cores, caixas promocionais e decoração sem função.
- As imagens #10b deixam de ser alvo visual ou de hierarquia. Em especial, não reproduzir a organização do Armeiro atual, considerada confusa pelo usuário.
- Direção cinematográfica, interface aberta e transições fluidas com som. Isso não impõe personagem ao fundo de todas as páginas nem colunas persistentes em cascata.
- Uma cena/renderização dedicada à inicial é permitida como alternativa ao fundo do lobby. Propor a solução de menor custo que entregue o resultado; demais menus não precisam mostrar o jogador.
- Modalidades podem ter composições e ambientação diferentes, usando a mesma família tipográfica, cores/tokens, componentes e princípios estruturais. Evitar mudanças radicais de linguagem entre modos.

### 12.2. Sequência e liberdade

Menus principais primeiro, HUD depois. Reorganizar nomes, destinos, agrupamentos, atalhos de menu e entradas redundantes é permitido, preservando recursos, regras de jogo e remapeamentos. Inicial aberta e páginas internas com uma região de trabalho predominante; profundidade indicada por título/retorno, sem empilhar colunas a cada passo.

Mobile será projetado como experiência própria: composições por etapas, navegação próxima do toque, ações contextuais visíveis e prévias alternáveis quando necessário. Não tratar a tela pequena como desktop reduzido. O antigo fator de 60% não será usado para justificar texto pequeno; valores salvos e o comportamento de migração precisam ser preservados/definidos explicitamente durante implementação.

### 12.3. Controles e identidade de plataforma

Remapeamento terá representação do método de entrada:

- Teclado com teclas usadas destacadas e relação clara entre tecla e ação.
- Controle ilustrado, com ações associadas aos botões e representação Xbox/PlayStation quando a identificação disponível for confiável.
- Dispositivo físico, plataforma e método de entrada ativo são conceitos distintos: usar controle em PC não transforma o jogador em console. Não inferir fabricante com certeza quando a API não o informar; prever visual neutro ou escolha de representação, sem fingir detecção.
- Ícones de plataforma no placar in-game, mantendo identificação textual/acessível. Auditar sinais realmente disponíveis e transporte aos demais jogadores antes de implementar. Informação declarada pelo cliente é cosmética e nunca concede confiança, acesso ou vantagem.
- No HUD de gameplay, retirar o painel permanente de dicas de controle; manter no máximo o acesso ao menu no canto superior direito. Isso não remove comandos contextuais necessários nos menus, telas de remapeamento ou botões acionáveis de toque.

### 12.4. HUD — composição aprovada para a segunda etapa

**Inferior esquerdo:** vida e estamina. Valor da vida dentro da barra. Espaço extensível para estados reais como blindagem ou efeitos, sem criar sistemas ou indicadores fictícios. Retirar desse grupo informações de arma.

**Inferior direito:** grupo de equipamento puramente informativo. Arma atual em silhueta/miniatura maior, nome acima e munição em tamanho grande à esquerda da arma. Abaixo, arma secundária menor e melee ao lado. Posição exata e interpretação do equipamento atualmente empunhado serão demonstradas no protótipo, sem alterar lógica de slots/troca. Usar artes/silhuetas cacheadas; evitar modelos 3D continuamente renderizados só para ícones de HUD.

**Região de combate:** killfeed compacto; mini-placar com proporção e leitura adequadas, corrigindo a combinação atual de texto pequeno e largura excessiva. Eventos relacionados ao jogador mantêm destaque, sem aumentar exageradamente a região toda. Headshot mantém iconografia reconhecível, incluindo a caveira alaranjada já solicitada.

### 12.5. Bandeira e mensagens

- Aviso de bandeira como faixa com movimento direcional para a direita, comunicando urgência. Não confundir movimento da faixa com indicação da posição do objetivo.
- Ao portar bandeira: cantos da tela recebem a cor da bandeira carregada; ícone grande de bandeira na região superior esquerda com pulsação de tamanho.
- Alertas não devem competir com dano, objetivos, killfeed ou controles de toque. Cor de bandeira/equipe é semântica e não acompanha livremente a paleta de personalização.
- Movimento reduzido troca a pulsação/deslocamento por sinal estável com bom contraste. Intensidade dos cantos deve preservar visão de combate e respeitar preferências de efeitos visuais.
- Integrar tudo em uma família de mensagens com hierarquia, tipografia, ícones, duração, posição, prioridade, fila/agregação e sons coerentes. O acabamento deve parecer de um único jogo.

### 12.6. Eliminações, sequência e medalhas

Proposta aprovada de apresentação compacta: `×N  +XP  [medalha mais recente]`, com mínimo de texto. N conta eliminações consecutivas dentro de uma janela temporal; cada eliminação renova a janela e soma o XP realmente recebido para essa sequência. Ao expirar, iniciar nova sequência. Janela inicial de **5 segundos é hipótese de protótipo**, não regra confirmada de balanceamento; torná-la configurável e validá-la em teste.

- Exibir somente a medalha da eliminação mais recente, sem acumular uma fila de ícones na mesma linha.
- Headshot, defesa e ataque usam eventos confirmados no servidor.
- Defesa inclui os exemplos do usuário: eliminar portador inimigo ou eliminar em contexto de defesa enquanto ocupa objetivo/porta bandeira. Ataque inclui eliminar inimigo em objetivo. Auditar volumes/estados de objetivo e resolver sobreposição de critérios antes de codificar.
- A forma de escolher uma medalha quando várias condições ocorrerem simultaneamente precisa de prioridade documentada; apresentar combinações no protótipo. Não assumir que uma medalha visual concede XP adicional.
- `+50 XP` é exemplo visual do usuário, não novo valor de recompensa. Não conceder XP no cliente nem duplicar concessões ao agregar mensagens. Correlacionar eventos/recompensas para evitar contagem repetida.
- Separar sequência temporária da notificação de estatísticas persistentes ou de streaks com recompensas, caso existam.
- O item “Kills e recarga” não especificou uma nova mecânica de recarga; preservar funcionamento atual e estudar apenas a apresentação/estado visual ao detalhar o HUD.

### 12.7. Entrega de design escolhida

1. Elaborar um mapa das jornadas com destino de cada função existente.
2. Produzir **uma proposta coesa**, com duas alternativas apenas para a composição da inicial, evitando conjuntos inteiros de estilos concorrentes.
3. Mostrar inicial, seleção de modo, classe/arma/acessório e remapeamento, incluindo versões mobile. Mostrar também um quadro de HUD para confirmar a disposição de vida/equipamento e a linguagem de avisos, embora sua implementação fique para depois.
4. Incluir estados de foco, selecionado, equipado, pendente, bloqueado, carregamento e erro. Mostrar animações/sons em protótipo funcional posteriormente; imagem estática não prova fluidez.
5. Revisar esse conjunto com o usuário antes de implementar a Nova em escala. A criação de protótipos não exige novas perguntas sobre decisões rotineiras já autorizadas.
6. Implementar um corte vertical e depois expandir. Atual permanece isolada; migração das opções experimentais 1/2 só ocorre com a Nova pronta e testes próprios.

Nenhum desses quadros visuais foi produzido nesta atualização documental. Esta seção consolida decisões e critérios, não declara implementação ou validação concluída.


## 13. Primeiro corte de prototipação entregue

Criado artifacts/ui-nova-prototype/index.html, protótipo local navegável separado do Roblox: iniciais A/B, modos, classes, acessórios, configurações/remapeamento e quadro do HUD futuro. Mobile tem alternância Lista/Prévia em acessórios. Fundos, silhuetas e conteúdo ilustrativos identificados; Carreira/Social são destinos incompletos rotulados. Dez capturas e 13 verificações de navegador passaram; limites detalhados no README e validation.json da pasta. Não é implementação no Studio, nem valida dados de jogo/controle físico/sons finais. Resta revisão do desenho com o usuário antes da integração ampla.


### Correção de orientação e localização do XP

Mobile do jogo é paisagem. Direção confirmada substitui suposições anteriores de retrato; validar layout mobile horizontal como alvo. Aviso de XP terá duas posições: esquerda do retículo, com espaçamento adaptado à lente/área de scope durante ADS; ou inferior, mais próximo da borda inferior, sem colidir com vida/equipamento/toque. Preferência final deve usar sistema existente; protótipo já alterna as duas posições e simula limite da lente. Ainda não integrado à câmera ou às preferências Roblox.


### Simulações por método de entrada

PC/console compartilham o desenho, com opção de XP inferior ou esquerda/afastamento por scope. Simulações mobile devem sempre incluir controles de toque e joystick nas posições propostas, com área suficiente para uso e separação do HUD informativo. Não usar capturas sem botões para declarar o mobile validado. O protótipo atual inclui os controles essenciais/auxiliares e alternância de método para comparação; ainda não valida controle multitoque físico nem altera preferências/layouts Roblox.


### Direção prevalente — Clássica/Neo e inicial compartilhada

Usuário definiu nomes Clássica para a interface existente e Neo para a nova. A própria inicial Clássica será usada nos dois temas, sem recriação/variante. Sua linguagem limpa e simples deve se estender às telas internas Neo, substituindo a tentativa de inicial com grade de cards. Preservar regras e caminhos existentes; continuidade visual, não repetição literal da composição em todas as tarefas.
