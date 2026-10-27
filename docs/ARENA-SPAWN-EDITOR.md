# Mapas visíveis para editar spawns

**Revisão de 26/10:** Assault, Praia, Factory e Glacier receberam [spawns manuais e perfis de iluminação](ARENA-MANUAL-SPAWNS-LIGHTING.md). Nesses quatro mapas, Apply também atualiza AuthoredSpawns no original, e a reimportação preserva esses marcadores explícitos. Praia e Glacier aparecem 400 studs mais altos somente no editor; a conversão é feita automaticamente ao salvar.

A edição atual está guardada em **ServerStorage.Development.Editors.ArenaSpawnEditor**, com os 15 mapas e os 323 marcadores preservados. Os spawns também foram salvos nos templates de jogo em ServerStorage.CrossgroundsMaps.Arena; os originais completos ficam em Development.MapSources.Arena. Para voltar a editar, com Play parado:

```lua
require(game.ServerStorage.Development.Tools.ArenaSpawnEditor).Restore()
```

Isso devolve a mesma sessão ao Workspace, com os mapas separados. Cinco marcadores de Courtyard, Neighborhood e Nuketown precisam de revisão geométrica; foram preservados. O carregador de Arena filtra esses pontos durante o jogo. Os demais 318 passaram na checagem de piso, espaço e regiões; isso não comprova equilíbrio ou conectividade.

## Editar e salvar

1. Pare o Play. Expanda `Workspace.ArenaSpawnEditor.<id>.Spawns` no Explorer.
2. Selecione um marcador e use **F** para enquadrá-lo. Os blocos verdes são spawns; a seta identifica a frente do personagem.
3. Use Move/Rotate para ajustar posição e direção. Para adicionar, duplique um marcador com **Ctrl+D** e mova a cópia. Pode manter o nome duplicado: o salvamento renumera os marcadores.
4. O **centro do marcador representa a posição do HumanoidRootPart**, cerca de 3,6 studs acima do piso. O bloco não deve ficar apoiado no chão.
5. Na Command Bar, valide o mapa e depois salve:

```lua
local editor = require(game.ServerStorage.Development.Tools.ArenaSpawnEditor)
print(editor.Validate("factory"))
editor.Apply("factory")
```

Substitua `factory` pelo ID exibido no Explorer. `Validate` pinta de vermelho os pontos inválidos e retorna a razão. `Apply` exige ao menos quatro pontos, todos válidos; se algum falhar, não substitui os spawns daquele pedido. Chamadas sem ID validam/salvam todos os mapas da área:

```lua
local editor = require(game.ServerStorage.Development.Tools.ArenaSpawnEditor)
print(editor.Validate())
editor.Apply()
```

O salvamento compensa o deslocamento da grade, preserva a orientação e os atributos dos marcadores, atualiza SpawnCount e deixa os spawns invisíveis no template do jogo. A versão anterior de Spawns/SpawnRegions fica em `ServerStorage.Development.Revisions.Maps`, com `RevisionType=SpawnsOnly`. Não restaura geometria a partir dessa revisão.

## Regiões e limites

As caixas azuis translúcidas em `SpawnRegions`, quando presentes, restringem onde o controlador aceita spawns. Ajuste-as se quiser ampliar uma área permitida. Elas também são salvas por `Apply`. A checagem confirma piso, espaço para o personagem e inclusão nessas regiões; não decide o que é interior do mapa nem comprova conectividade ou equilíbrio.

Edite os marcadores e regiões individualmente. Não mova o Model inteiro, a pasta da área ou a geometria de referência: a conversão usa o deslocamento registrado na abertura. Alterações na geometria desta área não são exportadas por Apply.

**Editar na área não salva automaticamente no template.** Use Apply antes de testar. Se reimportar o mapa depois, o importador poderá regenerar spawns e regiões; guarde esta revisão e atualize as regiões do original antes de uma reimportação. Se um mapa for reimportado enquanto esta área estiver aberta, salve/feche a edição pendente e recrie a referência antes de continuar.

## Guardar e restaurar

```lua
local editor = require(game.ServerStorage.Development.Tools.ArenaSpawnEditor)
editor.Store()   -- salva os spawns e guarda a sessão inteira em Development.Editors
editor.Restore() -- devolve essa mesma sessão ao Workspace
```

Store preserva também marcadores inválidos, identifica os templates que precisam de revisão e mantém a versão anterior em Development.Revisions.Maps. Apply continua estrito: exige corrigir os pontos inválidos antes de salvar por esse comando.

Para descartar apenas uma sessão visível e gerar outra a partir dos templates:

```lua
local editor = require(game.ServerStorage.Development.Tools.ArenaSpawnEditor)
editor.Close() -- descarta somente a área visível; salve antes
editor.Open()  -- recria as cópias a partir dos templates atuais
```

Guarde a sessão com Store antes de testar. Se deixar uma sessão aberta, o bootstrap guarda somente a cópia da simulação em Development.Editors.RuntimePreviews, sem salvar edições nos templates. Ao parar Play, a sessão original continua no Workspace. As ferramentas de edição só funcionam com Play parado. As arenas guardadas em ServerStorage não entram no Workspace; o jogo carrega somente a cópia do mapa escolhido para a rodada.

Referência da montagem original: nenhuma sobreposição dos limites de geometria e separação mínima de aproximadamente 147,7 studs; conversão de coordenadas com erro máximo menor que 0,001 stud. A quantidade atual de marcadores reflete a edição posterior feita no Studio.
