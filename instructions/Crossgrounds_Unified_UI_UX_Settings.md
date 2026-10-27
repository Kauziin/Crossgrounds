# Crossgrounds — Unified UI/UX & Settings System

> **Instruções de implementação para o Codex**  
> Projeto: **Crossgrounds** (Roblox / Luau)  
> Escopo: melhoria da interface existente, responsividade, organização de categorias e preferências globais/por modo/por dispositivo.  
> **Estado do código: desconhecido até a auditoria. Não presumir nomes de arquivos, telas, opções ou módulos.**

## 0. Missão e regras de execução

Audite e aperfeiçoe a interface do Crossgrounds, que já utiliza um **menu lateral inspirado em Call of Duty com navegação em cascata**. A intenção **não é redesenhar a identidade visual nem substituir a estrutura de navegação**, e sim corrigir itens pequenos demais, categorias inconsistentes, problemas de ergonomia e a futura convivência de preferências universais com preferências específicas de Arena, Duels e Get Out.

**Diretrizes obrigatórias:**

1. Inspecione telas, componentes, scripts, estilo, fluxo, categorias e dados já implementados **antes** de propor alterações.
2. Preserve a navegação lateral/cascata, linguagem visual, animações e funcionalidades existentes, salvo quando houver defeitos demonstráveis.
3. Corrija organização e usabilidade com a menor intervenção possível. Não crie páginas vazias ou controles sem efeito real.
4. Reutilize componentes e tokens visuais existentes; construa uma arquitetura compartilhada somente onde ela simplificar manutenção e consistência.
5. Considere PC (mouse/teclado), gamepad (Xbox/PlayStation) e celular/tablet desde o início.
6. Separe configurações **que mudam somente a experiência local** de qualquer regra de partida/dano/competitividade definida pelo servidor.
7. Se o Studio não estiver disponível, execute verificações estáticas e forneça uma lista de testes manuais pendentes. Nunca relate testes não executados.

## 1. Auditoria do menu e das interfaces existentes

Mapeie todas as telas (menu principal, lobby, configurações, HUD, menus de cada modalidade, pop-ups e interfaces de interação) realmente presentes no repositório.

Registre por componente:

- Categoria atual, título, rótulos e posição na cascata.
- Responsabilidade, opção alterada, valor padrão, origem do dado e se já persiste.
- Tamanho em pixels/escala, tipo de layout, âncoras, constraints e comportamento com diferentes resoluções.
- Navegação por teclado/mouse, gamepad e toque.
- Problemas de fonte, contraste, clipping, truncamento, sobreposição, rolagem e área de toque.
- Dependências do Roblox CoreGui, opções gráficas ou de acessibilidade nativas.
- Campos em categorias incoerentes e opções duplicadas/sem funcionalidade.
- Identidade visual atual: tipografia, espaçamento, cores, transições, áreas vazias e consistência entre telas.

**Primeiro entregável:** tabela `Local atual → problema → local proposto → motivo`, distinguindo fatos observados de sugestões. Não alegue que determinado item está na categoria errada se ainda não viu o item real.

## 2. Estrutura de navegação: preservar a cascata

Mantenha o padrão geral **coluna de categorias → subcategoria/escopo → painel de opções**, ajustando a quantidade de colunas à área disponível:

- **PC/telas largas:** manter lateral e cascata; conteúdo principal legível e bem distribuído.
- **Gamepad:** foco inicial previsível, transição entre colunas, ações Voltar/Aplicar claras, sem foco perdido em elementos invisíveis.
- **Celular/telas estreitas:** colapsar níveis progressivamente (categorias, subseção, ajustes), com Voltar consistente e área de toque generosa; não apenas diminuir a interface inteira.

Categorias propostas, sujeitas à auditoria:

1. **Geral** — idioma, notificações e preferências gerais realmente existentes.
2. **Controles** — teclado/mouse, gamepad, toque, teclas e modalidades de input.
3. **Mira e Câmera** — sensibilidade, ADS, FOV quando permitido, retículo e balanço/recuo visual.
4. **Interface** — escala, fontes, HUD, placares, indicadores e apresentação dos menus.
5. **Áudio** — volumes, música, ambiente, UI e efeitos se o sistema de áudio os separar.
6. **Gráficos** — apenas opções gráficas **sob controle efetivo da experiência**, não duplicações enganosas das configurações nativas.
7. **Acessibilidade** — contraste, texto, movimento, flashes, legendas e pistas visuais, conforme recursos efetivamente disponíveis.

**Regra de organização:** categorização pelo *efeito que o jogador quer alterar*, não pelo script que implementa o efeito. Por exemplo, aparência do retículo em **Mira e Câmera**; escala da HUD em **Interface**; tamanho universal de fonte em **Acessibilidade** (ou link coerente entre as duas categorias, sem controles duplicados conflitantes).

Inclua descrições curtas quando os nomes forem ambíguos. Evite menus muito profundos, abreviações obscuras e submenus vazios.

## 3. Modelo de configurações: global + modo + dispositivo

Implemente um **registro central de definições (schema)**, não uma coleção dispersa de variáveis por tela. Para cada configuração, o registro deve informar, quando aplicável:

- `id` estável e serializável;
- categoria e subcategoria;
- rótulo/descrição (incluindo futura localização);
- tipo (`boolean`, número, escolha, cor, tecla/ação etc.);
- padrão, limites, passos e enum de opções válidas;
- escopo permitido (`Global`, `Mode`, `Device` ou combinação **explicitamente suportada**);
- modalidade(s) aplicável(is);
- se é local, persistente, experimental ou dependente de suporte do cliente;
- função/aplicador responsável por atualizar a interface ou sistema correspondente.

### 3.1. Resolução de valores por herança

Defina precedência previsível:

1. Valor padrão do registro.
2. Preferência **Global** salva pelo usuário, caso válida.
3. Preferência específica de **modalidade**, apenas quando essa chave permitir substituição por modo.
4. Preferência de **dispositivo/tipo de input**, apenas para chaves explicitamente dependentes do dispositivo.
5. Preferências de acessibilidade do Roblox: use-as como defaults/ajustes de acordo com a semântica documentada e respeite substituições explícitas de forma consistente; não multiplique a fonte duas vezes inadvertidamente.

**Observação importante:** os níveis 3 e 4 não devem disputar a mesma chave silenciosamente. Se alguma configuração precisar dos dois contextos, documente e teste a ordem, ou modele `Mode × Device` explicitamente; não crie essa matriz por padrão.

Exemplo conceitual: `ReticleColor` global = branco; `Modes.Arena.ReticleColor` = verde; Duels e Get Out sem override herdam branco. Ausência de override significa **herdar**, não gravar uma cópia da configuração global. Desativar override restaura a herança imediatamente.

### 3.2. Estrutura ilustrativa (não imponha estes nomes sem auditoria)

```lua
local SavedPreferences = {
    Version = 1,
    Global = {
        GUIScale = 1.0,
        FontScale = 1.0,
        ReticleColor = "#FFFFFF",
        CameraShake = 0.5,
    },
    Modes = {
        Arena = { ReticleColor = "#25DA88" },
        Duels = {},
        GetOut = {},
    },
    Devices = {
        KeyboardMouse = {},
        Gamepad = {},
        Touch = {},
    },
}
```

**Requisitos do resolvedor:** validar tipos, limites, cores e IDs; fornecer fallback para versão antiga/incompleta; notificar componentes quando um valor efetivo mudar; restaurar padrão por opção, por categoria e globalmente; diferenciar valor herdado de valor personalizado.

Não carregue todo o perfil a cada clique. Mantenha estado local, aplique mudanças na interface e persista de maneira controlada.

## 4. Personalizações sugeridas — catálogo a verificar

**Não adicionar tudo cegamente.** Classifique como `já existe`, `viável`, `depende de sistema`, `fora de escopo` ou `não recomendado`; implemente primeiro as opções de alto impacto que tenham efeito real.

| Categoria | Personalizações candidatas | Escopo sugerido |
|---|---|---|
| Geral | Idioma, dicas, notificações, confirmação de ações | Global |
| Controles | Remapeamento, correr/agachar segurar ou alternar, sensibilidade de analógico, deadzone, curva de resposta, vibração, botões touch | Device e/ou Global, conforme campo |
| Mira e Câmera | Sensibilidade horizontal/vertical, ADS, FOV se suportado, shake, sway, centralização | Global; override por modo somente se útil |
| Retículo (em Mira e Câmera) | Cor, tamanho, espessura, abertura, ponto, contorno, opacidade, retículo dinâmico/estático | Global + Mode permitido |
| Interface | Escala da GUI, escala da HUD, densidade, opacidade de painéis, visibilidade/reorganização de elementos | Global; alguns itens por Mode |
| Áudio | Música, efeitos, UI, ambiente, notificações, sons de confirmação | Global |
| Gráficos | Partículas cosméticas, pós-processamento opcional, flashes, efeitos de impacto/reflexos sob controle do jogo | Global |
| Acessibilidade | Tamanho do texto, alto contraste, redução de movimento/flashes, legendas, indicadores visuais de som, cores alternativas de equipes | Global |

Não exponha opções que permitam remover informações, penalidades ou limitações fundamentais de forma que alterem injustamente a integridade competitiva.

## 5. Configurações específicas por modalidade

A mesma categoria do menu apresenta campos diferentes conforme o **escopo selecionado** (`Global`, `Arena`, `Duels`, `Get Out`; `CTF` somente se existir).

| Modalidade | Preferências candidatas (apresentação, não regras) |
|---|---|
| **Arena** | Killfeed (visibilidade/duração/quantidade), marcador de dano, indicador de eliminação, apresentação do placar, avisos de sequência, identificação de equipes |
| **Duels** | Posição/tamanho dos indicadores das duas habilidades, informações do adversário, cronômetro, contador de rodadas, avisos de cooldown |
| **Get Out** | Escala de interações, legibilidade dos puzzles, marcadores de objetivos, notificações de progresso, indicadores de colegas/perigo |
| **CTF — se existir** | Indicadores de bandeira, estado do portador, avisos de captura/devolução, distância dos objetivos |

Exiba controles **apenas** quando sua funcionalidade correspondente existir. Não introduza opções de HUD de uma modalidade em outra por conveniência técnica. Preferências visuais não devem permitir burlar condições de fuga, objetivos, furtividade ou limitações deliberadas do gameplay.

### UX do seletor de escopo

- Indique claramente se o valor atual é **Global (herdado)** ou **Personalizado neste modo**.
- Habilite/desabilite override por opção ou grupo apropriado; evite exigir duplicação do perfil inteiro.
- Ofereça **Restaurar padrão** e **Voltar a herdar Global** como ações distintas.
- Em modo indisponível, não mostre um conjunto de campos vazios sem explicação.
- Uma alteração em Global deve refletir imediatamente em todos os modos que herdam aquela preferência.

## 6. Legibilidade, dimensionamento e layout responsivo

Diagnostique se o problema é falta de escala ou quebra de layout. Aumentar `UIScale` **não** substitui layout responsivo.

Use e configure corretamente, conforme necessidade:

- `UIScale` para multiplicar a escala de grupos coerentes, com limites práticos.
- `UISizeConstraint` para limites mínimos/máximos de componentes.
- `UITextSizeConstraint` para texto, evitando mínimos ilegíveis e máximos que provoquem clipping.
- `AutomaticSize` para conteúdo que deve crescer com o texto.
- `UIListLayout`/`UIGridLayout` para ritmo e alinhamento consistentes.
- `UIAspectRatioConstraint` somente quando a proporção for realmente necessária.
- `ScreenGui.ScreenInsets`/áreas seguras para manter botões e textos visíveis fora de recortes e CoreGui.

**Controles preferenciais:** escala do **menu** e escala da **HUD** separadamente; tamanho de texto de forma independente quando necessário. Como **faixa inicial de exploração, não requisito imutável**, experimente 80%–140% e calibre após medições em resoluções reais. Escala máxima não pode esconder Confirmar/Voltar, bloquear rolagem ou cortar descrições importantes.

Garanta:

1. Texto legível e possibilidade de quebra controlada ou rolagem.
2. Alvos interativos suficientemente grandes para toque e controle.
3. Espaçamentos consistentes e alinhamento na cascata.
4. Foco não capturado por componentes ocultos ou desabilitados.
5. Nenhuma sobreposição com barra superior, notch, controles virtuais e pop-ups.
6. Testes com interface em português e inglês, considerando textos de comprimentos diferentes. Só incluir espanhol se ele fizer parte dos idiomas efetivamente suportados.

## 7. Tamanho da fonte versus escala da GUI

**Não confundir** escala de interface com tamanho de texto e não aplicar multiplicadores repetidos. Consulte `GuiService.PreferredTextSize` e as preferências nativas de acessibilidade quando disponíveis.

Atenção à interação entre `TextScaled`, `UITextSizeConstraint`, `AutomaticSize` e a preferência de tamanho de texto do usuário. A documentação oficial informa que `TextScaled` pode impedir a ampliação esperada por `PreferredTextSize`. Prefira componentes de texto que realmente respeitem as preferências; verifique comportamento no Studio, não apenas pelos valores das propriedades.

Recomende uma política consistente: preservar preferência nativa quando o usuário não definiu override in-game e oferecer ajuste adicional apenas se houver benefício real e sem escala duplicada.

## 8. Navegação por dispositivo

### Mouse e teclado
- Clique preciso, scroll confiável, foco em campos de entrada, sliders operáveis, botão Voltar claro, estados de hover/disabled/selecionado.
- Não exija hover para revelar informação essencial.

### Gamepad
- Use seleção de GUI/foco compatível com `GuiService.SelectedObject` e navegação entre objetos; teste `NextSelection*` quando necessário.
- Garanta que D-pad/analógico consigam percorrer todos os controles e que o foco fique visível.
- Entrada/saída entre categorias, cascata e detalhes sem ciclos impossíveis; botões Confirmar/Voltar e prompts corretos.
- Teste mudanças de dispositivo durante a execução (controle para mouse e vice-versa).

### Celular e tablet
- Reorganize a cascata em níveis ou painéis navegáveis, sem encolher toda a interface de desktop.
- Respeite `ScreenInsets` e posições dos controles de gameplay.
- Evite elementos menores que uma zona de toque confortável; teste orientação/aspectos suportados.
- Teclado virtual e pop-ups não podem esconder campo ativo ou botões de saída.

Não implemente um sistema de input paralelo se o projeto já usa um serviço de ações/bindings. Integre-se a ele.

## 9. Acessibilidade e preferências do Roblox

Investigue como usar ou respeitar `GuiService.PreferredTextSize`, `GuiService.PreferredTransparency`, `GuiService.ReducedMotionEnabled` e demais APIs documentadas que façam sentido no contexto real.

Prioridades:

- Alto contraste para textos e seleção, sem depender apenas da cor para estados.
- Diferenciação de equipes por cor **e** sinais visuais quando necessário.
- Texto maior com layout que cresça/reflua.
- Redução de transições, tremores e efeitos cosméticos fortes.
- Legendas e indicadores visuais somente se houver informação sonora relevante a representar.
- Feedback de interface perceptível também sem áudio.

Não ofereça um checkbox decorativo: cada opção deve atualizar componentes reais, possuir padrão e funcionar ao reabrir o menu.

## 10. Retículo e HUD como componentes configuráveis

Projete as opções de retículo em um componente compartilhado aplicável a armas/modos compatíveis:

- Cor personalizável com presets seguros; valor de cor validado.
- Tamanho, espessura, espaço interno, ponto central, contorno e opacidade.
- Variação estática/dinâmica quando suportada pela mecânica real da arma.
- Prévia **interativa dentro do menu**, com as mesmas regras de renderização do retículo real.
- Configuração herdada de Global ou sobreposta por modo conforme o schema.

Para HUD, priorize tamanhos, visibilidade e posição de elementos sem permitir ocultar avisos necessários para compreender ações e perigo. Se a HUD ainda não usa componentes reutilizáveis, evolua-a gradualmente; não refatore cada tela por uma simples preferência de escala.

**Proteção competitiva:** personalizar cor/forma de um indicador não pode revelar inimigos ocultos, ignorar linha de visão ou expor informação que um jogador não deveria ter.

## 11. Persistência, migração e sincronização

Use o mecanismo de dados de jogador já existente. Se houver persistência via `DataStoreService`:

1. Armazene dados serializáveis, pequenos e validados, com `Version` e migração previsível.
2. Não crie uma DataStore por campo ou uma gravação por movimento de slider.
3. Debounce/coalesça alterações; persista nos pontos adequados do ciclo de vida, respeitando limites e falhas de salvamento.
4. Quando houver concorrência/múltiplos servidores alterando o mesmo perfil, avalie `UpdateAsync` e evite sobrescritas de versões antigas.
5. Valores desconhecidos, corrompidos ou fora de faixa devem retornar a defaults seguros sem danificar outros dados do perfil.
6. Mantenha preferências locais de apresentação isoladas de dados autoritativos de combate/economia.
7. Se a experiência já possui perfil central com versionamento/migração, integre-se a ele em vez de criar um segundo serviço.

Defina quando aplicar alterações imediatamente, quando depender de reentrada na partida e quando pedir confirmação, apenas quando houver razão técnica real.

## 12. Segurança e limites de personalização

- Qualquer entrada enviada por RemoteEvent deve ser validada por tipo, formato, limite e contexto no servidor, se afetar dados persistentes ou estado compartilhado.
- O cliente não pode modificar regras de dano, velocidade, cooldown, visibilidade real de outros jogadores ou condições de vitória por preferências visuais.
- Limite frequência e tamanho de mensagens/gravações de configurações.
- Não aceite índices arbitrários, caminhos de instâncias, IDs infinitos ou tabelas malformadas vindas de clientes.
- Persistência e mensagens de erro não devem expor dados de outros jogadores.

## 13. Implementação incremental e experiência de uso

Ordem recomendada:

1. **Inventário real** de telas, campos, categorias, ações e erros.
2. **Correções imediatas de usabilidade**: campos no lugar errado, tamanhos inadequados e estados quebrados, preservando o layout original.
3. **Sistema de componentes/registro de configurações** reutilizando a arquitetura existente.
4. **Herança Global → Mode** nas opções adequadas; Device apenas onde há semântica clara.
5. **UI de edição**: seletor de escopo, valor herdado, override, restaurar padrão, prévia do retículo.
6. **Escala/menu/HUD/acessibilidade** com ajustes responsivos.
7. **Persistência e migração** sem quebrar perfis existentes.
8. **Regressão multiplataforma** e medição de performance.

Não crie dezenas de campos antes da infraestrutura. Comece com um pequeno conjunto vertical (por exemplo: escala do menu, escala da HUD, texto e retículo) e prove que alterar, salvar, herdar e restaurar realmente funcionam. Expanda só depois.

## 14. Testes obrigatórios

| Teste | Resultado esperado |
|---|---|
| PC em 16:9 e outras proporções disponíveis | Menu em cascata legível, sem clipping |
| Tela pequena / celular | Navegação por níveis e toque acessível |
| Gamepad somente | Todos os controles alcançáveis e foco visível |
| Troca dinâmica de input | Prompts e foco recuperados corretamente |
| Escala mínima e máxima | Sem ocultar botões essenciais |
| Texto ampliado | Quebra/rolagem corretas, sem sobreposição |
| Retículo Global personalizado | Aplicado a modos que herdam |
| Override de Arena | Não altera Duels/Get Out |
| Override removido | Valor volta a herdar o Global |
| Restaurar padrão vs. herdar | Operações distintas e previsíveis |
| Reabrir menu / reiniciar sessão | Preferências persistem corretamente |
| Perfil antigo/corrompido | Migração/fallback seguros |
| Sons/gráficos/opções sem suporte | Não expor controles sem funcionamento |
| Contraste, redução de movimento | Efeito perceptível nos componentes reais |
| Servidor com vários usuários | Preferências permanecem por jogador, sem vazamento |
| Notificações e pop-ups | Não obstruem ações críticas ou controles touch |

Teste também a troca de modo sem reiniciar o cliente, configurações durante uma partida, localizações realmente suportadas, links entre menus e ausência de duplicação de listeners após abrir/fechar repetidamente.

## 15. Critérios de conclusão

A tarefa só estará completa quando:

1. A navegação lateral em cascata tiver sido **preservada e refinada**.
2. O inventário de categorias equivocadas estiver documentado e os casos reais corrigidos.
3. A GUI e o texto puderem ser dimensionados **sem quebrar o layout**.
4. Os controles funcionarem de modo utilizável em PC, gamepad e toque.
5. Configurações universais e específicas por modo tiverem resolução/override previsíveis.
6. As opções implementadas produzirem efeito real e respeitarem disponibilidade do modo/dispositivo.
7. As preferências sobreviverem ao ciclo de vida do jogador quando deveriam persistir.
8. Não existirem regressões conhecidas de HUD, menus, input, dados ou segurança.
9. Resultados de testes realmente executados e pendências forem entregues sem invenção.

## 16. Relatório final obrigatório

Apresente:

1. **Inventário e diagnóstico** da UI atual, com itens encontrados em categorias erradas.
2. **Mapa anterior → novo mapa** de navegação e configurações.
3. **Lista de opções implementadas**, não implementadas e dependências.
4. **Schema/precedência** da herança e exemplos de valores efetivos.
5. **Mudanças por arquivo** e decisões sobre componentes existentes.
6. **Testes reais** (resolução, input, persistência, acessibilidade) e resultados.
7. **Pendências e limitações**, inclusive áreas não verificáveis sem Roblox Studio.

**Princípio central:** permitir personalização ampla **sem** comprometer a clareza dos menus, multiplicar telas desnecessárias ou alterar a justiça do gameplay.

## Referências técnicas (Roblox Creator Hub)

- [Modificadores de tamanho e constraints da UI](https://create.roblox.com/docs/ui/size-modifiers)
- [GuiService e preferências de acessibilidade](https://create.roblox.com/docs/reference/engine/classes/GuiService)
- [Gamepad — input e navegação](https://create.roblox.com/docs/input/gamepad)
- [Contêineres de UI, áreas seguras e ScreenInsets](https://create.roblox.com/docs/ui/on-screen-containers)
- [Boas práticas de DataStores](https://create.roblox.com/docs/cloud-services/data-stores/best-practices)
- [Segurança na fronteira cliente-servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary)

> A documentação é referência técnica, não autorização para substituir contratos do projeto sem auditoria. Confirme a disponibilidade e o comportamento das APIs no Roblox Studio atual antes da implementação.
