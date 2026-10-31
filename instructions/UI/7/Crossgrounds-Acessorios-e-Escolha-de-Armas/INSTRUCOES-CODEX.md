# Crossgrounds — Tela de Acessórios + Escolha de Armas

Implemente duas telas novas para o fluxo de armamentos do Crossgrounds, usando como referência principal:

- `01_referencias/01_menu_acessorios_m4a1.png`
- `01_referencias/02_escolha_de_armas_m4a1.png`

## Objetivo

Expandir o menu de armamentos no estilo **Create-a-Class / Armeiro**, adicionando:

1. **Escolha de Armas**
2. **Acessórios**

Ambas devem seguir a mesma direção artística do menu de armamentos aprovado: interface escura, contornos turquesa, painéis robustos, foco claro para controle e composição semelhante ao armeiro.

---

## Regra mais importante: economizar processamento

Priorize uma implementação **leve**.

### Evite custo desnecessário
- **Não** renderize múltiplos ViewportFrames 3D pesados ao mesmo tempo sem necessidade.
- **Não** recrie modelos 3D toda vez que o foco mudar, se for possível reutilizar/cachear.
- **Não** use animações caras, blur pesado, efeitos dinâmicos complexos ou loops visuais contínuos desnecessários.
- **Não** carregue prévias detalhadas de todas as armas/acessórios de uma só vez.

### Prefira
- miniaturas estáticas ou prévias simplificadas nos cards/listas;
- apenas **uma prévia grande ativa** por vez;
- cache de assets e modelos;
- atualização sob demanda, baseada em foco/seleção;
- reaproveitamento máximo de componentes já existentes no `GunsmithView` e no menu de Armamentos.

Se possível, renderize em alta fidelidade apenas o item atualmente focado, e use representações mais leves para o restante.

---

## 1. Tela: Escolha de Armas

Use `02_escolha_de_armas_m4a1.png` como referência.

### Estrutura
- coluna esquerda com categorias de arma;
- painel central com grade/lista de armas da categoria atual;
- painel direito com prévia e descrição da arma focada.

### Conteúdo esperado
#### Coluna esquerda
Categorias como:
- Fuzis de Assalto
- Submetralhadoras
- Pistolas
- Escopetas
- Atirador
- Corpo a Corpo

#### Painel central
- cards das armas disponíveis na categoria;
- nome da arma;
- categoria/subtipo;
- miniatura/previsualização leve.

#### Painel direito
- prévia maior da arma focada;
- nome;
- classe;
- descrição curta.

### Navegação
- foco principal por controle entre categorias e grid de armas;
- A seleciona;
- B volta;
- X pode servir para pré-visualizar, apenas se isso já se encaixar no fluxo existente;
- Y para detalhes, se necessário.

### Integração
Essa tela deve ser usada quando o jogador escolher trocar a arma principal/secundária dentro do fluxo de armamentos/armeiro.

---

## 2. Tela: Acessórios

Use `01_referencias/01_menu_acessorios_m4a1.png` como referência.

### Estrutura
- coluna esquerda com armas/loadouts ou lista curta de armas relevantes;
- painel central superior com a arma atual;
- faixa de slots de acessórios;
- grade/lista inferior com acessórios disponíveis para o slot atual;
- painel direito com detalhes do acessório selecionado.

### Slots sugeridos
- Mira
- Cano
- Acoplamento
- Carregador
- Coronha
- Laser

Adapte conforme o catálogo real do projeto.

### Conteúdo esperado
#### Painel central
- nome da arma;
- classe;
- grande prévia da arma;
- indicação visual do slot de acessório selecionado.

#### Grade inferior
- cards dos acessórios disponíveis para o slot atual;
- item equipado claramente marcado;
- compatibilidade visível de forma simples.

#### Painel direito
- nome do acessório;
- subtipo;
- descrição curta;
- observações de compatibilidade ou função.

### Importante
Se o sistema atual ainda não tiver efeitos funcionais completos para acessórios, a tela pode operar primeiro como seleção visual/estrutural, mas sem mentir sobre funcionalidades inexistentes.

---

## Coerência visual
Ambas as telas devem manter a mesma linguagem do menu de armamentos aprovado:
- fundo escuro com brilho turquesa;
- títulos fortes e claros;
- painéis com bordas arredondadas;
- foco luminoso;
- hierarquia clara entre navegação, seleção e detalhes.

---

## Reaproveitamento obrigatório
Para economizar tempo e processamento:
- reutilize a linguagem visual e componentes do `GunsmithView.luau`;
- reutilize componentes do menu de Armamentos/Create-a-Class aprovado;
- evite criar sistemas paralelos quando o atual puder ser estendido;
- centralize helpers de preview/cache, se necessário.

---

## Resultado esperado
Duas telas novas, visualmente coerentes com o Crossgrounds moderno, mais próximas de um armeiro, mas implementadas com foco em **eficiência**, **reaproveitamento** e **baixo custo de renderização**.
