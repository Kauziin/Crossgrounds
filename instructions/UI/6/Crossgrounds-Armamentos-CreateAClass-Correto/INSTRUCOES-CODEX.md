# Crossgrounds — Tela de Armamentos no estilo Create-a-Class

Redesenhe a tela de **Armamentos** da Arena usando como referência principal a imagem `00_create_a_class_referencia.png`.

## Direção visual

A tela deve lembrar um **Create-a-Class**, com:

- coluna de classes/loadouts à esquerda;
- área central com blocos por slot de equipamento;
- painel de detalhes à direita;
- visual escuro, limpo e robusto;
- contornos luminosos na seleção;
- forte coerência com o gunsmith/armeiro do Crossgrounds.

## Adaptação para a Arena

Não implemente um sistema completo de Create-a-Class funcional. Adapte apenas a apresentação.

### O que a Arena deve mostrar

- lista de loadouts à esquerda;
- slot principal com a pistola do loadout;
- slot de corpo a corpo com o **Executor**;
- espaço para identificar o loadout e sua arma;
- painel lateral de detalhes com nome, categoria e descrição curta;
- aviso de que a seleção entra em vigor apenas no próximo nascimento.

### O que NÃO deve existir

- barras de dano, cadência, precisão, controle, mobilidade ou alcance;
- progressão de arma;
- acessórios funcionais para a Arena;
- habilidades, perks ou equipamentos independentes como sistemas reais;
- troca imediata do equipamento atual.

## Regras funcionais obrigatórias

- Preserve a lógica atual de `SelectLoadout`.
- Preserve o comportamento de `PendingArenaLoadout`.
- A arma atual não pode ser alterada na vida presente.
- A confirmação continua válida apenas para o próximo nascimento.
- O loadout focado atualiza a prévia; o loadout confirmado envia a escolha ao servidor.

## Estrutura recomendada

### Coluna esquerda

Lista vertical com os loadouts:

- número ou nome do loadout;
- nome da arma principal;
- pequeno ícone/miniatura;
- destaque visual do item focado/selecionado.

### Área central

Blocos maiores no estilo Create-a-Class:

- **Arma principal**: prévia maior da pistola do loadout;
- **Corpo a corpo**: Executor como melee fixo;
- opcionalmente um bloco visual secundário para “Aparência” ou “Visual”, se isso ajudar a coerência com o armeiro, mas sem criar nova lógica obrigatória.

### Painel direito

Mostrar:

- nome da arma principal;
- categoria (ex.: Pistola);
- descrição curta;
- informação de status atual:
  - equipada agora, ou
  - agendada para o próximo nascimento.

## Navegação

- D-pad / analógico navega entre os loadouts na coluna esquerda.
- A confirma a escolha.
- B volta.
- X pode abrir uma ação secundária apenas se já existir algo equivalente; não invente fluxo novo à força.
- O foco precisa continuar compatível com `MenuNavigation.luau`.

## Implementação

- Reaproveite a lógica existente de `LoadoutMenuView.luau`.
- Use `GunsmithView.luau` como referência de linguagem visual e composição.
- Não replique as estatísticas do gunsmith na Arena.
- Não reescreva `LoadoutService.luau` além do necessário.

Resultado esperado: uma tela de Armamentos da Arena com visual de **Create-a-Class adaptado**, mais alinhada ao armeiro e mais forte visualmente, mas ainda obedecendo a lógica simples de loadout predefinido da Arena.
