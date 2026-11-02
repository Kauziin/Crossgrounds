# Plano de Implementação — Armamentos da Arena no estilo Create-a-Class

## 1. Objetivo

Substituir a apresentação atual da tela de Armamentos da Arena por uma interface inspirada diretamente na referência de Create-a-Class, sem transformar o modo Arena em um sistema de personalização completa.

A meta é melhorar a leitura, reforçar a identidade visual e aproximar a Arena do armeiro já existente.

---

## 2. Princípio principal

A referência visual é **estrutural e estética**, não funcional.

Em outras palavras:

- a tela deve **parecer** um Create-a-Class;
- mas a Arena continua usando **loadouts prontos**.

Isso evita aumentar o escopo do sistema enquanto melhora bastante a qualidade visual.

---

## 3. Mapeamento do conteúdo atual para a nova tela

### Referência de Create-a-Class
A imagem de referência possui:

- lista de classes à esquerda;
- painel principal para arma primária;
- painel para arma secundária;
- slot de corpo a corpo;
- slots de habilidades/equipamentos;
- painel lateral com estatísticas e nível.

### Adaptação correta para o Crossgrounds Arena

#### Coluna esquerda
Usar os seis loadouts da Arena como “Classes”.

Cada item deve exibir:

- `Loadout 1`, `Loadout 2` etc. ou nomes próprios se existirem;
- nome da arma principal;
- indicação de que se trata de um preset.

#### Painel principal
Substituir o bloco da “arma primária” por um painel grande com:

- modelo/previsão 3D da pistola;
- nome da pistola;
- subtítulo `Pistola`;
- destaque visual de seleção.

#### Painel secundário
Na Arena, não há necessidade de uma secundária independente. Este espaço pode ser usado de uma destas formas:

1. **preferencial**: painel “Visual do Loadout” com miniatura adicional, ou
2. painel reduzido de apoio contendo o nome do loadout e um lembrete de seleção pendente.

Evite criar um slot falso que pareça funcional sem realmente ser.

#### Corpo a corpo
Criar um bloco próprio para o **Executor**:

- ícone/modelo;
- nome `Executor`;
- subtítulo `Corpo a corpo`.

#### Habilidades / equipamentos
Não implementar como sistema real na Arena.

Se houver necessidade de preencher a composição visual, usar placeholders visuais discretos ou simplesmente omitir esses painéis. A melhor opção é não mentir para o jogador sobre sistemas que o modo não possui.

#### Painel lateral
Deve conter:

- nome da arma principal;
- categoria;
- descrição curta;
- texto de estado:
  - `Equipado nesta vida` quando ativo;
  - `Agendado para o próximo nascimento` quando pendente.

Não incluir barras numéricas de atributos.

---

## 4. Comportamento

### Foco
Focar um loadout:

- atualiza a prévia central;
- atualiza o painel direito;
- move o destaque visual.

### Confirmação
Confirmar um loadout:

- envia `SelectLoadout`;
- define `PendingArenaLoadout` via servidor;
- não altera a arma equipada imediatamente.

### Atualização visual
Quando `PendingArenaLoadout` mudar:

- atualizar o estado visual do loadout correspondente;
- atualizar o texto do aviso principal.

---

## 5. Arquivos que devem mudar

### Arquivo principal
`src/StarterPlayer/StarterPlayerScripts/LoadoutMenuView.luau`

Responsável pelo novo layout.

### Arquivo de integração
`src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau`

A chamada para abrir Armamentos já existe. Ajustes devem ser mínimos, idealmente apenas para comportamentos auxiliares ou dimensões.

### Arquivos de apoio / referência
`src/StarterPlayer/StarterPlayerScripts/GunsmithView.luau`

Usar como referência para:

- linguagem visual;
- proporção dos painéis;
- estilo da prévia 3D;
- sensação de armeiro.

### Sem mudanças estruturais relevantes
- `src/ReplicatedStorage/Crossgrounds/LoadoutDefinitions.luau`
- `src/ServerScriptService/Crossgrounds/LoadoutService.luau`

Esses devem permanecer praticamente intactos.

---

## 6. Reaproveitamento da implementação atual

A versão atual já oferece:

- grid de loadouts;
- ViewportFrames;
- prévia grande;
- detecção de loadout ativo e pendente;
- navegação com `MenuNavigation`.

Portanto, a tarefa é principalmente:

- reorganizar o layout;
- trocar a hierarquia visual;
- enriquecer a composição;
- alinhar o visual com o Create-a-Class.

Não trate esta tarefa como reimplementação do zero.

---

## 7. Navegação por controle

Requisitos mínimos:

- foco principal na lista de loadouts da esquerda;
- A confirma;
- B volta;
- rolagem automática se necessário;
- elementos decorativos ou internos não devem capturar foco à toa.

Se forem adicionados sub-blocos clicáveis, o comportamento deve continuar claro e rápido no controle.

---

## 8. Responsividade

Em larguras menores:

- a coluna de loadouts continua à esquerda, mas pode reduzir largura;
- a prévia central e o painel direito podem empilhar parcialmente;
- o conteúdo mais importante deve continuar sendo: lista → prévia → estado da seleção.

---

## 9. Resultado esperado

Ao abrir **Armamentos** na Arena, o jogador deve sentir que entrou em uma tela premium, parecida com um **Create-a-Class / armeiro simplificado**, mas sem se confundir sobre as regras reais do modo.

A interface final deve comunicar:

- escolha de loadout;
- inspeção da arma;
- identidade visual forte;
- confirmação pendente para o próximo nascimento.

Esse é o alvo correto.
