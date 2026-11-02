# Crossgrounds — Plano técnico da interface de seleção de armamentos

**Escopo:** Arena, não CTF. **Natureza:** refino visual e de UX, com preservação das regras existentes. **Referência:** `01_referencias/01_conceito_grade_2x3_com_preview.png`.

## 1. Diagnóstico do estado atual

Na branch `master` inspecionada em **31/10/2026**, `ExperienceMenu.luau` delega a página Loadout para `LoadoutMenuView.new(...)` com `Mode="arena"`, passando a lista de `LoadoutDefinitions.List(mode)` e o callback `SelectLoadout`. `LoadoutMenuView` já implementa:

- grade de seis cards 2×3 (pistolas da Arena);
- câmeras 3D via `ViewportFrame`/`WorldModel` para miniaturas, arma ampliada e Executor;
- prévia atualizada com o foco;
- envio da escolha somente por ativação do card via navegação;
- leitura dos atributos de loadout ativo/pendente para destacar a seleção;
- layout empilhado para largura menor e reposicionamento respeitando escala e aviso admin;
- branch `Mode=="ctf"` que delega para `GunsmithView`, **fora do escopo**.

Não repetir trabalho existente. O primeiro passo é comparar visual e comportamento atuais com os critérios abaixo.

## 2. Hierarquia visual desejada

Área lateral: preservar os botões existentes da pausa. Área principal:

1. Título `LOADOUT` e informação de que a escolha **entra em vigor no próximo nascimento**.
2. Esquerda: cards 2×3 numerados, com foto/modelo 3D discreto, nome da pistola, classe `PISTOLA` quando aplicável e a legenda `Executor · corpo a corpo`.
3. Direita: arma em tamanho grande com nome e identificação; abaixo, compartimento menor do **Executor melee** com seu modelo 3D.
4. Ações e indicadores contextuais de controle discretos. Foco com contorno turquesa e losango, consistente com o Crossgrounds.
5. Estados visuais nítidos: **sob foco / confirmado para próximo nascimento / ativo na vida atual**. Nenhum deve depender exclusivamente de cor.

**Não incluir:** barras de atributos de armas, vantagens por dano, gráficos de controle/mobilidade, Create-a-Class completo, cosméticos/skins não solicitados, indicação de Executor como arma de fogo.

## 3. Regras da interação / confirmação

- **Foco:** percorrer a grade, hover e seleção do cursor atualizam a prévia, **sem enviar** o evento ao servidor.
- **Confirmar:** tecla A no gamepad ou clique/acionamento no card envia apenas o id correspondente pelo callback existente de `ExperienceMenu`. Aguardar a confirmação de estado replicado.
- **Pendente:** somente após o servidor aceitar, `PendingArenaLoadout` reflete a arma que será equipada **no próximo respawn**.
- **Ativo:** `ArenaPistolVisual` identifica a arma desta vida; não trocá-la quando a seleção pendente mudar.
- **Retorno ao menu:** manter última escolha real e, se possível, prévia/foco anterior, sem reaplicar a seleção.
- **Erro/espera:** não indicar "confirmado" por otimismo; respeitar o limitador existente (`LoadoutService` aplica 0,2 s por jogador). Não enviar um evento por frame, hover ou repetição direcional.
- **Cancelar/voltar:** B retorna à navegação anterior; não cria uma confirmação pendente adicional.

## 4. Controle e acessibilidade

| Entrada | Comportamento |
|---|---|
| D-pad / analógico de navegação | Percorrer 2×3 com `NextSelection` apropriados |
| A | Confirmar o card em foco uma vez |
| B | Voltar para a interface de pausa |
| Mouse | Hover inspeciona; clique confirma |
| Toque | Tocar card confirma e exibe o conteúdo associado |

Somente o card é alvo de foco; `ImageLabel`, `ViewportFrame`, legenda e miniaturas são decorativos. Separar claramente foco de seleção real. Adaptar rolagem, escala tipográfica e alto contraste.

## 5. Responsividade e desempenho

- **Desktop/console:** grade à esquerda e painel de detalhes à direita, com margem constante.
- **Largura reduzida:** preview abaixo da grade, scroll acessível, sem sobrepor avisos de administrador.
- Clonar prévias de `ReplicatedStorage.Crossgrounds.LoadoutPreviews`; não gerar modelos nem Tool no cliente.
- Verificar existência dos assets antes de configurar as câmeras; usar fallback textual para modelo ausente.
- Manter os oito ViewportFrames já existentes, liberar conexões e referências ao destruir a tela, sem vazamentos de memória.
- Animações rápidas e discretas, respeitando configuração de redução de movimento.

## 6. Arquivos e impacto

| Arquivo | Papel | Necessidade |
|---|---|---|
| `src/StarterPlayer/StarterPlayerScripts/LoadoutMenuView.luau` | UI Arena e ponte para Gunsmith em CTF | **Principal**: aperfeiçoar apresentação, seleção/foco e responsividade, se necessário |
| `src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau` | Abre a interface e passa callbacks | Alterar **somente se** precisar ajustar integração, visibilidade ou estado |
| `src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau` | Registro do foco e navegação no controle | **Reutilizar**. Alterar apenas se houver bug específico demonstrado |
| `src/ReplicatedStorage/Crossgrounds/LoadoutDefinitions.luau` | Define lista, nomes e atributos | **Não alterar** por motivo visual |
| `src/ReplicatedStorage/KitDefinitions.luau` | Modelos, armas, categorias e propriedades | **Não alterar** |
| `src/ServerScriptService/Crossgrounds/LoadoutService.luau` | Validação no servidor, grava pendência e aplicação no respawn | **Não alterar** |
| `ReplicatedStorage.Crossgrounds.LoadoutPreviews` (Studio) | Modelos de prévia 3D | **Reutilizar**, sem inventar arquivos `.rbxm` inexistentes |
| `src/StarterPlayer/StarterPlayerScripts/GunsmithView.luau` | Interface CTF | **Não alterar** |

## 7. Critérios de aceite

- As seis pistolas aparecem na ordem real do projeto, com grade 2×3 quando houver espaço.
- Executor aparece corretamente como melee e com preview 3D quando modelo existente for encontrado.
- Não existem números ou gráficos de dano/controle/mobilidade na Arena.
- A mudança de foco altera **apenas a prévia**.
- A confirmação envia um único pedido; o estado visual pendente só é exibido após retorno do servidor.
- A arma da vida atual permanece até o respawn; após respawn, a escolhida entra em vigor.
- Navegação direcional, mouse, teclado e toque continuam operando; ao sair não restam elementos de prévia ativos.
- Menus de outros modos e o restante da experiência continuam intactos.
- Fornecer checklist real dos testes executados (não afirmar teste no Studio sem executar).

## 8. Diferenças entre o mockup e a implementação desejada

A imagem conceitual gerada na conversa mostra barras de Dano/Controle/Mobilidade, que devem ser **descartadas**, e representa o Executor como se fosse uma pistola, o que está **incorreto**. O texto e as regras deste plano prevalecem sobre esses detalhes do mockup. A imagem serve principalmente para **composição visual**, espaçamento, iluminação e hierarquia de miniaturas e detalhes.
