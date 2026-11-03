# Biblioteca de interfaces do Crossgrounds

Data: 03/11/2026. Origem: Play local do Roblox Studio, lugar principal `4375993208`. O [índice](index.html) contém 170 PNGs em resolução original e busca por nome. O [manifesto](manifest.json) registra cada arquivo; [capture-records.json](capture-records.json) guarda o contexto de navegação da rodada, e [scenario-validation.json](scenario-validation.json) registra os 42 cenários executados. Os JPEGs `contact-*` são apenas folhas de consulta.

## Inventário fotografado

| Família | Imagens | Estados cobertos |
| --- | ---: | --- |
| Estruturas e dados (`0xx`) | 47 | Todas as 38 pilhas/páginas cadastradas no `CascadeMenu`, hub composto, clã e grupo com dados sintéticos selecionados. |
| Eventos (`1xx`) | 28 | HUD CTF/Arena; pegar, soltar, devolver e capturar bandeira; vitória, empate e eliminação; nível de conta e arma; convite; votação; respawn; Get Out nos quatro estados de rodada e dois papéis, vítima, arrasto, captura e hack. |
| Configurações (`2xx`) | 25 | Pausa, categorias e subcategorias, remapeamento teclado/gamepad/toque, sair em CTF, rendição indisponível em CTF e retorno ao hub em Arena. |
| Progressão (`3xx`) | 6 | Perfil, líderes, desbloqueios, amigos, guilda e filtros. |
| Armamentos (`4xx`) | 25 | Classes, categorias de armas, seis slots de acessórios, progressão de arma, prévia nativa, modais de classe, corpo a corpo, auxiliares, variantes e loadout Arena. |
| HUD e mensagens (`5xx`) | 15 | Carregamento e falha, dano, interação, diálogo, eliminador, placares, arma, ajuda de controle/câmera admin, mira e controle de ampliação. |
| Mobile (`6xx`) | 17 | iPhone 17 Pro em landscape: hub, HUDs, Get Out, editor de HUD, configurações, progressão e seu seletor, menus social/carreira/clã/armas, votação, mira e laboratório de debug. |
| Rolagem (`7xxx`) | 7 | Conteúdo inferior das configurações, remapeamento e armeiro. |

## Como interpretar

- Todas as capturas vieram dos componentes de UI do jogo em Play. O laboratório de Studio aciona os próprios `RemoteEvents` de apresentação e usa dados de teste para estados difíceis de alcançar. A tarja `STUDIO` é adicionada só à cópia congelada da interface para a biblioteca.
- `010–047` forçam as páginas internas do `CascadeMenu`. Uma página que depende de seleção pode aparecer vazia nessa condição; `050–057` mostram clã/grupo populados. `040–041` são a estrutura antiga de votação da Arena sem eleição ativa; a votação flutuante atual está em `114` e `611`.
- `401–416` mostram categorias e listas, capturadas antes da fixture de prévia local estar completa. A prévia funcional da arma é `417`. A ausência do modelo nessas imagens antigas é uma limitação daquela simulação, não evidência de falha do Armeiro no jogo.
- As telas `219`, `220` e `224` usam contextos de modo diferentes. Em CTF, a rendição informa que a votação por equipe ainda não foi implementada; em Arena existe a ação de voltar ao hub. Nenhum botão de saída, rendição, edição ou compra foi confirmado para fotografar.
- `PreferenceState`, `AccessibleMenuCursor`, `Freecam`, `FirstPersonDisplay` e as variantes de Topbar são camadas de estado, entrada, câmera, renderização ou composição, não páginas independentes. O placar superior da Arena foi ativado com dados de teste em `512`. A ajuda de câmera admin (`513`) usa somente atributo local no Play, sem sessão de câmera autorizada. O controle de ampliação (`514`) foi exposto na **cópia estrutural** da UI ao lado da mira, sem arma/ADS reais. O placar sustentado nativo está em `506–507`; a mira telescópica em `510`. Os arquivos não representam cada combinação possível de arma, tema, perfil e estado temporal.

## Limites da validação

Os 42 presets foram executados sem falha de invocação no cliente Studio; o resultado está no JSON. Houve inspeção visual de desktop e simulador landscape (`750×382` de viewport), incluindo recapturas após corrigir as fixtures. Não houve teste em hardware físico, multiplayer humano completo, publicação, compra, concessão de XP nem validação de DataStore de produção. Os avisos de ativos de áudio inacessíveis, plugin GUIEditor e TestService surgiram no console e não foram atribuídos ao laboratório.
