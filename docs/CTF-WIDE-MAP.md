# Travessia Ampliada e textos de bandeiras

Aplicada no Studio Crossgrounds (ALPHA), Place 4375993208, em 26/10/2026. Mapa atual: **riverside_wide / Travessia Ampliada**. A Travessia anterior continua como `ServerStorage.CTFMaps.riverside` e como opção do catálogo.

## Layout

| Parâmetro | Travessia anterior | Versão ampliada |
|---|---:|---:|
| Posição X das bandeiras | -160 / +160 | -360 / +360 |
| Distância entre bandeiras | 320 studs | 720 studs |
| Centros das três rotas em Z | -70 / 0 / +70 | -180 / 0 / +180 |
| Separação entre rotas adjacentes | 70 studs | 180 studs |
| Área da nova fundação | — | 940 × 560 studs |
| Spawns por equipe | 24 | 24 |

- **Norte:** corredor de trincheira rebaixado seis studs, contenções de madeira, travessas alternadas e fortificações nas bordas. Passagens laterais e rampas conectam ao restante do mapa.
- **Centro:** fábrica atravessável, maquinário central, esteiras e cobertura lateral. O maquinário bloqueia a visão direta entre as duas entradas.
- **Sul:** rua larga, oficinas atravessáveis, depósitos e barricadas alternadas.
- **Entre rotas:** prédios e muros altos quebram a visão lateral. Há conexões nos setores X=-240, -80, +80 e +240.
- **Bases:** telas de proteção, cobertura lateral e spawns recuados; bandeiras acessíveis a partir das três rotas.
- **Torres:** duas estruturas nas bordas do setor norte. Sua utilidade e vantagem de tiro ainda precisam de avaliação humana.

O terreno original foi preservado. A nova fundação tem piso principal em Y=80 e trincheiras em Y=74, acima das amostras de terreno examinadas (máximo Y=68). O lobby CTF em Z=365 fica fora da região jogável. Não foram movidos mapas, marcadores ou regiões da área de edição da Arena.

## Construções pesquisadas e usadas

Os originais ficam em `ServerStorage.Development.Assets.CTFExpansionSources`. As cópias ativas foram ancoradas e tiveram scripts, prompts, cliques, GUIs e conexões de toque importadas retirados. Os originais foram preservados para referência; o kit da Roblox contém scripts de banco em sua hierarquia original, que permanecem fora da geometria ativa.

| Asset | Criador informado pela loja | Uso |
|---|---|---|
| [Modular Building Kit - Modern City](https://create.roblox.com/store/asset/13168370735) | Roblox | Quatro blocos de prédios e dois depósitos, derivados dos prefabs C e G |
| [SandBag War Barricade](https://create.roblox.com/store/asset/48314114) | LuigiRoblox | Seis barricadas de sacos de areia |
| [trenches](https://create.roblox.com/store/asset/12892949175) | Yulikeville Nuclear Power Company | Duas fortificações nas bordas da trincheira |
| [Watchtower](https://create.roblox.com/store/asset/3330023556) | snowdoah | Duas torres |

Todos foram encontrados como gratuitos no Creator Store durante esta tarefa. A montagem complementa esses assets com fábrica, oficinas, rampas, muros, maquinário, bases e cobertura construídos com peças do Studio.

Referências de pesquisa: [montagem modular da Roblox](https://create.roblox.com/docs/tutorials/use-case-tutorials/modeling/assemble-modular-environments), [cobertura em combate](https://book.leveldesignbook.com/process/combat/cover) e [composição/linhas de visão](https://book.leveldesignbook.com/process/blockout/massing/composition). A distribuição adotada é uma decisão de implementação para este mapa, não uma validação de balanceamento derivada dessas referências.

## Bandeiras e navegação

`CTFFlagLabels` controla os textos localmente. O servidor/template mantém FlagLabel desativado. O texto aparece somente com CrossgroundsMode=ctf, InArena=true, humanoide vivo, RoundState=Playing, posição dentro de PlayRegionCenter/PlayRegionSize e câmera admin desativada. O controle acompanha troca de mapa e chegada de novos labels; sair da região ou da modalidade oculta o texto.

Os bots usam `CTFInfrastructure.BotRoutes.North/Center/South` e LaneSpacing=180 na versão ampliada. O código anterior de travessia é mantido como fallback para a Travessia original. Foram criados 33 pontos de navegação, com objetivos intermediários em volta dos obstáculos. O carregador publica/remove a geometria em lotes para evitar uma única inserção grande no DataModel.

## Verificação e limites

- Sete fontes envolvidas compilaram no Studio.
- Permissão admin: conta autorizada aceita; conta alheia e UserId fictício rejeitados.
- Onze verificações isoladas do controlador de labels passaram, incluindo modo, participação, rodada, região horizontal/vertical, vida, admin e label adicionado depois do carregamento. Nenhum texto foi habilitado na cena Edit por esse teste.
- 48 spawns com piso e espaço livre para personagem; 33 pontos de rota com piso e clearance.
- 30/30 buscas entre pontos consecutivos das três rotas encontraram caminho no navmesh em Edit.
- Mais 12 buscas entre bases/bandeiras e as extremidades das rotas, e oito conexões entre rotas, encontraram caminho. Um destino artificial inicialmente usado em Z=180 estava dentro de uma barricada; as conexões foram então conferidas pelos pontos reais de autoramento, que contornam a barricada. São 50 buscas válidas no total; não são 50 partidas nem execução física de bots.
- As três linhas centrais de tiro, do X=-350 ao X=+350, são interrompidas pela geometria. Isso não demonstra que todas as linhas longas foram eliminadas.
- A geometria ativa tem 3.669 BaseParts e nenhum script importado. A área de edição da Arena permaneceu com seus 15 mapas; seus marcadores não foram regravados por esta tarefa.
- **Play não foi iniciado durante a edição do usuário.** Falta confirmar voo, ocultação/restauração da interface, captura/retorno de bandeiras, comportamento dos bots, desempenho e equilíbrio em uma partida real. Caminho calculado pelo navmesh não comprova que um bot completa o trajeto em combate.

## Fontes, arquivos e próximos ajustes

- Autoramento: `ServerStorage.Development.Tools.CTFWideAuthoring`. Build recusa sobrescrever um template existente; Activate recusa substituir a versão já ativa, preservando edições manuais.
- Templates: `ServerStorage.CTFMaps.riverside_wide`. Cena visível: `Workspace.CTFWideWorld` e `Workspace.CTFInfrastructure`.
- [Arquivo anterior à ampliação](../artifacts/ctf-wide-2026-10-26/before.rbxm): cena antiga, biblioteca CTF e fontes anteriores do carregador/objetivos.
- [Pacote da versão ampliada](../artifacts/ctf-wide-2026-10-26/riverside-wide.rbxm): template novo e sete fontes envolvidas, incluindo admin. Não é um Place completo ou instalador; a integração pressupõe a biblioteca/serviços existentes.
- [Modo admin para fotografias](ADMIN-CAMERA.md).

Requisito registrado para uma futura alteração de UI: **a votação será um grid de cartões quadrados**. A apresentação da votação não foi modificada nesta etapa.
