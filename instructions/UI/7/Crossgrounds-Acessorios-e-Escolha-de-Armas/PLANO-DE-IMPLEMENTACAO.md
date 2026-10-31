# Plano de Implementação — Acessórios e Escolha de Armas

## 1. Meta

Adicionar ao fluxo de armamentos duas telas complementares:

1. **Escolha de Armas**
2. **Acessórios**

As duas devem parecer parte do mesmo sistema do menu de Armamentos/Create-a-Class já aprovado.

---

## 2. Prioridade técnica

A prioridade não é apenas o visual. A prioridade também é:

- **baixo custo de processamento**;
- **baixo custo de renderização**;
- **reaproveitamento de UI e preview**;
- **resposta rápida ao foco/navegação**.

---

## 3. Estratégia de performance

### 3.1 Preview grande único
Idealmente, manter apenas **um preview principal ativo por vez**:
- na Escolha de Armas: preview da arma focada;
- em Acessórios: preview da arma atual ou do acessório selecionado quando necessário.

### 3.2 Cards leves
Nos grids/listas:
- usar imagens estáticas quando possível;
- usar ícones ou thumbnails leves;
- evitar ViewportFrame para todos os cards ao mesmo tempo.

### 3.3 Cache
Criar/reaproveitar um cache simples para:
- modelos da arma em foco;
- miniaturas ou thumbnails;
- dados de compatibilidade de acessórios.

### 3.4 Atualização por foco
Atualizar preview/detalhes somente quando:
- o item focado mudar;
- o slot de acessório mudar;
- a categoria mudar.

---

## 4. Tela de Escolha de Armas

### Estrutura sugerida
- **esquerda:** categorias;
- **centro:** grade de armas;
- **direita:** preview e descrição.

### Responsabilidades
#### Coluna de categorias
- trocar o conjunto exibido no painel central;
- permitir navegação rápida por controle.

#### Grade de armas
- mostrar as armas disponíveis da categoria atual;
- destacar arma focada;
- confirmar seleção com A.

#### Painel direito
- arma focada em tamanho maior;
- nome, classe e descrição.

### Fluxo
1. jogador entra em “Trocar”;
2. escolhe categoria;
3. escolhe arma;
4. confirma;
5. retorna ao fluxo anterior.

---

## 5. Tela de Acessórios

### Estrutura sugerida
- **esquerda:** armas relevantes ou contexto atual;
- **centro superior:** arma atual;
- **centro intermediário:** slots de acessórios;
- **centro inferior:** grade de acessórios do slot atual;
- **direita:** detalhes do acessório.

### Fluxo
1. jogador entra em “Acessórios” para uma arma;
2. escolhe um slot;
3. vê os acessórios disponíveis;
4. seleciona um acessório;
5. confirma/retorna.

### Sinalizações úteis
- `Equipado`
- `Disponível`
- `Incompatível` (apenas se fizer sentido real)

---

## 6. Arquivos prováveis

### Novos módulos sugeridos
- `WeaponSelectView.luau`
- `AttachmentSelectView.luau`
- `PreviewCache.luau` (opcional, se ajudar a evitar duplicação)

### Arquivos existentes a revisar
- `src/StarterPlayer/StarterPlayerScripts/GunsmithView.luau`
- `src/StarterPlayer/StarterPlayerScripts/LoadoutMenuView.luau`
- `src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau`
- catálogos de armas / acessórios em `ReplicatedStorage/Crossgrounds`

---

## 7. Navegação por controle

### Escolha de Armas
- D-pad / analógico: navegar categorias e armas
- A: selecionar
- B: voltar
- X: pré-visualizar (opcional)
- Y: detalhes (opcional)

### Acessórios
- D-pad / analógico: navegar entre slots e lista de acessórios
- A: equipar / confirmar
- B: voltar
- X/Y: ações secundárias apenas se fizerem sentido

Evitar múltiplos focos inúteis dentro do mesmo card.

---

## 8. Coerência artística

As duas telas devem herdar:
- azul turquesa de destaque;
- fundo escuro e cinematográfico;
- painéis amplos;
- tipografia forte;
- layout próximo do armeiro.

---

## 9. Resultado esperado

O jogador deve sentir que:
- entrou em um sistema de armamentos mais completo;
- a interface é premium e coerente;
- a navegação é confortável no controle;
- o custo técnico continua controlado.
