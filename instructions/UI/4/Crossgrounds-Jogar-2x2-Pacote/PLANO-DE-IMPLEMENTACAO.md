# Crossgrounds — Tela Jogar: redesign em grade 2×2

**Escopo:** reformulação visual e de navegação da tela **Jogar / Modalidades** do hub.  
**Base consultada:** repositório público [`Kauziin/Crossgrounds`](https://github.com/Kauziin/Crossgrounds), branch `master`, conferido em 31/10/2026.  
**Status:** proposta para implementação com Codex. Os exemplos Luau deste pacote são bases orientativas, **não arquivos do projeto já alterados**.

## 1. Resultado visual pretendido

Use `01_referencias/02_conceito_grid_2x2.png` como referência principal. A tela mantém a identidade escura do Crossgrounds, com destaque turquesa personalizável, contraste bem definido, bordas arredondadas, losango do foco e área de navegação lateral. À direita, quatro cards grandes com imagem recortada em 16:9, degradê escuro inferior, nome, breve descrição e status:

| Linha | Esquerda | Direita |
|---|---|---|
| 1 | **Arena** — disponibilidade do servidor | **Capture a Bandeira** — disponibilidade do servidor |
| 2 | **Duels** — indisponível | **Get Out** — protótipo, indisponível para entrada pelo hub |

A posição dos quatro cards é **fixa**, independentemente da disponibilidade. Não reordenar os cartões em tempo real. A imagem anterior `01_conceito_lista_detalhes.png` é uma alternativa descartada, preservada para comparação. O arquivo `00_menu_atual.png` é a captura original do estado anterior.

### Cards

- A totalidade do card recebe foco; textos, imagens, badges e botões visuais internos não viram alvos independentes de navegação por gamepad.
- Um **único card** deve exibir a borda/foco turquesa e o losango, conforme a seleção atual. O foco não deve ser confundido com disponibilidade ou pré-seleção de fila.
- Exibir rótulos de disponibilidade **provenientes do catálogo recebido do servidor**, não dos metadados decorativos do cliente.
- Sem criar números não confirmados: jogadores online, estado de fila e capacidade só podem ser mostrados se forem dados reais e confiáveis. As legendas do conceito são visuais, não confirmação de matchmaking existente.
- Clicar/tocar uma ação do card deve usar a mesma rota de entrada existente; não introduzir cópia dessa lógica.
- Para **Duels** e **Get Out**, manter visualmente acessíveis os detalhes, mas não permitir a entrada enquanto indisponíveis.

### Responsividade

- Desktop/console: 2 colunas × 2 linhas no painel de modalidades, sem cortes.
- Telas pequenas: converter para uma coluna rolável, ajustar alturas e preservar margens/áreas seguras.
- Deixar espaço ao rodapé de instruções de controle e eventuais avisos administrativos.
- Quando a coluna lateral for exibida, ela não deve consumir a largura destinada aos cards; a tela Jogar merece layout próprio em vez de forçar o passo padrão de cascatas de 218 px.

## 2. Comportamento de entrada e navegação

| Input | Ação |
|---|---|
| D-pad ou analógico de navegação | Mover foco entre os 4 cards; ordem 2×2 determinística |
| A / Enter / Clique | Solicitar entrada na modalidade **somente se** `canEnter == true` |
| X / ação contextual | Abrir detalhes informativos da modalidade selecionada, mesmo indisponível |
| B / Esc | Retornar à tela inicial, preservando a navegação do hub |
| Mouse e toque | Foco visual ao apontar e clique/toque para entrar ou abrir detalhes |

A página de detalhes já existe (`ModeDetails`), bem como os métodos `HubBridge:Get()` e `HubBridge:Send()`; reutilizá-los. Ações atuais: `join`, `enter` e `cancel` com ticket. Manter validação no servidor e feedback de `joining`, `ready`, `entering`, `travelling`, `failed` e `idle`. Preservar tratamento atual de `quickEntry` na rota local, sem criar auto-entrada paralela.

**Limitação importante:** `QueueProvider.luau` descreve admissão local, **não um matchmaking cross-server**. O texto **“Entrar na fila”** da imagem é apenas mockup. Utilizar **“Jogar”**, **“Entrar”** ou o texto adequado ao estado real e evitar alegar busca de partida inexistente.

## 3. Mudanças por arquivo

| Ação | Caminho real no repositório | Objetivo |
|---|---|---|
| **Modificar** | `src/StarterPlayer/StarterPlayerScripts/HubController.luau` | Integrar tela Jogar 2×2 à navegação, foco e `refresh`; preservar tela inicial, outras interfaces e fluxo `HubBridge` |
| **Criar** | `src/StarterPlayer/StarterPlayerScripts/ModeSelectGrid.luau` | Construir e atualizar os quatro cards, grade, responsividade, hover/foco e elementos visuais |
| **Criar** | `src/StarterPlayer/StarterPlayerScripts/ModePresentation.luau` | Ordem fixa, textos curtos, referências a assets de imagem e mapeamento de modalidade |
| **Modificar** | `src/ReplicatedStorage/Crossgrounds/GameCatalog.luau` | Mudar `get_out` para `status="planned"` para impedir entrada pública pelo hub, mantendo o modo listado |
| **Reutilizar** | `src/StarterPlayer/StarterPlayerScripts/HubBridge.luau` | Estado e comunicação servidor-cliente, sem alteração obrigatória |
| **Reutilizar** | `src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau` | `Nav:Connect`, `Nav:SetActions`, `Nav:Focus`, foco/controle existentes |
| **Reutilizar** | `src/StarterPlayer/StarterPlayerScripts/MenuTheme.luau` | Paleta, fundos e bordas, sem alterar outras telas |
| **Reutilizar** | `src/ServerScriptService/Crossgrounds/SessionCoordinator.luau` | Bloqueio de status `planned` já existente e snapshot `canEnter` |
| **Reutilizar** | `src/ServerScriptService/Crossgrounds/QueueProvider.luau` | Não criar matchmaking novo neste trabalho |

### Ponto de integração crítico

Hoje o `HubController` constrói a lista em `browser.Panes.Modes.List` por `browser:Button()` e a cascata padrão usa larguras escalonadas em `CascadeMenu:Resize()`. Trocar apenas `UIListLayout` por `UIGridLayout` **não basta**: quando `Modes` é o segundo nível, a cascata pode conceder largura pequena ao painel dependendo do layout. Implementar **tratamento específico da tela Jogar no `HubController`** para compor menu lateral + grade larga, usando o mesmo `ScreenGui`/painel/histórico do hub. Não alterar globalmente `CascadeMenu` para acomodar apenas essa página.

Também evitar que os botões antigos da lista sejam recriados junto com os novos cards: remover/substituir a construção antiga e manter apenas **um** conjunto de alvos registrados de foco para modalidades. A página existente `ModeDetails` continua válida.

## 4. Get Out indisponível

O catálogo atual tem `get_out` com `status="prototype"` e `duels` como `planned`. Para retirar temporariamente Get Out da oferta jogável **sem apagar seus sistemas**, alterar somente seu `status` para `planned` em `GameCatalog.luau`, preservando `id`, `name`, versão e descrição caso desejado.

`SessionCoordinator:Route()` e `SessionCoordinator:Command()` já rejeitam `planned`; `Snapshot()` devolve `canEnter=false`. Assim, cliente e servidor concordam sobre a indisponibilidade. O rótulo visual “Protótipo” pode ser definido em `ModePresentation` sem alterar o protocolo.

Isso bloqueia o fluxo normal de entrada pelo catálogo, **não desinstala o protótipo nem substitui mecanismos de teste em Studio**. Testar eventuais rotas alternativas antes de afirmar que o modo foi globalmente desligado.

## 5. Imagens

Todas as imagens provisórias foram geradas como **referências conceituais**, não capturas de mapas oficiais. Estão em `02_imagens_dos_modos/`:

| ID | Arquivo | Uso |
|---|---|---|
| `arena` | `arena.png` | Card e detalhes da Arena |
| `ctf` | `ctf.png` | Card e detalhes de Capture a Bandeira |
| `duels` | `duels.png` | Card indisponível de Duels |
| `get_out` | `get_out.png` | Card indisponível de Get Out |

Os PNGs precisam ser publicados/importados para a experiência Roblox. Somente depois preencha os campos `Image` do `ModePresentation.luau` com URIs `rbxassetid://<id>` válidas. Acesso e moderação desses assets dependem do Roblox. **Não inventar IDs**. Usar `ScaleType.Crop` e gradiente escuro para manter legibilidade.

## 6. Componentes em Luau

Este pacote inclui `03_exemplos_luau/ModePresentation.luau` e `03_exemplos_luau/ModeSelectGrid.luau` como **pontos de partida**. O módulo da grade exemplifica `ImageLabel`, `UIGradient`, `UIGridLayout`, `UIStroke`, card único por modalidade e vínculos de seleção. O Codex deve adaptar o posicionamento ao painel real do Hub, a paleta configurável e os estados já utilizados pelo projeto.

### Integração orientativa no HubController

```lua
local Presentation = require(script.Parent.ModePresentation)
local ModeSelectGrid = require(script.Parent.ModeSelectGrid)

-- Após montar o contêiner largo para a tela Jogar:
local grid = ModeSelectGrid.new(modesContent, Nav, {
    Details = function(modeId)
        selected = modeId
        browser:Push({"RootPane", "Modes", "ModeDetails"})
        refresh()
    end,
    Play = function(modeId)
        local snapshot = Bridge:Get()
        if not snapshot or Bridge.Pending then return end
        local chosen
        for _,entry in snapshot.catalog or {} do
            if entry.id == modeId then chosen = entry break end
        end
        if not chosen or chosen.canEnter ~= true then return end
        selected = modeId
        local q = snapshot.queue
        if q and (q.state == "idle" or q.state == "failed") then
            quickEntry = modeId
            Bridge:Send("join", modeId)
        end
        -- Reutilizar a rotina existente de 'ready', 'enter' e 'cancel'.
    end,
})

-- Dentro do refresh já existente:
-- grid:Update(data.catalog, data.queue)

-- Quando houver redimensionamento:
-- grid:Resize()
```

Esse trecho ilustra a ligação **sem ser um patch automático**. Em particular, decidir o comportamento de entrada conforme os estados de fila já implementados e verificar se `refresh` está definido antes do callback disparar.

## 7. Validação obrigatória

1. Arena e CTF só oferecem a ação Jogar quando o catálogo retornar `canEnter=true`.
2. Duels e Get Out continuam visíveis no grid, mas sem possibilidade de ingresso público pelo hub.
3. Navegação D-pad 2×2 corretamente vinculada, inclusive em cards indisponíveis (detalhes permitidos).
4. Ação X abre `ModeDetails`; B retorna ao hub; mouse e toque continuam operacionais.
5. Não há duplicação de menu, foco ou efeitos sonoros.
6. Texto e imagens não são cortados em formatos 16:9, 4:3 e em tela vertical; na última, a grade adapta-se.
7. O `HubBridge` recebe e exibe erros de fila, entrada e teleporte sem esconder o feedback.
8. Imagens não carregadas exibem fallback escuro legível.
9. Nenhuma alteração não solicitada em configurações, progressão, ArenaHUD, loadouts ou sistemas de partida.
10. Os arquivos Luau alterados compilam e os principais caminhos foram testados no Roblox Studio; nenhuma publicação automática.

---

**Fontes consultadas:** [HubController](https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/HubController.luau), [GameCatalog](https://github.com/Kauziin/Crossgrounds/blob/master/src/ReplicatedStorage/Crossgrounds/GameCatalog.luau), [CascadeMenu](https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/CascadeMenu.luau), [MenuNavigation](https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau), [HubBridge](https://github.com/Kauziin/Crossgrounds/blob/master/src/StarterPlayer/StarterPlayerScripts/HubBridge.luau), [SessionCoordinator](https://github.com/Kauziin/Crossgrounds/blob/master/src/ServerScriptService/Crossgrounds/SessionCoordinator.luau), [QueueProvider](https://github.com/Kauziin/Crossgrounds/blob/master/src/ServerScriptService/Crossgrounds/QueueProvider.luau).
