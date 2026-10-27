# Crossgrounds: testes simultâneos no Roblox Studio

## Objetivo

Cada linha de teste usa uma cópia **completa** e independente do mesmo Place local. Assim, o Codex de bots e o Codex de armas podem iniciar Play ao mesmo tempo em **instâncias diferentes** do Studio. Um `studio_id` pertence a uma linha de teste; nunca inicie um segundo Play na mesma instância.

O workspace contém `CrossgroundsAlphaCopy.rbxl`, uma cópia completa do Place salva em 26/10/2026. Os `artifacts/*.rbxm` são pacotes de modelos por serviço e não servem como Place completo. Também não há commit inicial neste Git; worktrees ficam para depois que o projeto tiver um histórico versionado. O isolamento abaixo funciona sem worktrees.

## Preparação única

1. Na instância de edição do Crossgrounds, em modo **Edit**, use **File → Save to File** (ou **Download a Copy**) e salve uma cópia completa `.rbxl` em um local escolhido. Não use *Publish* para isso.
2. Abra PowerShell neste workspace e execute:

   ```powershell
   .\tools\Open-StudioTestLanes.ps1 -PlaceFile 'C:\caminho\Crossgrounds.rbxl' -Lanes bots,weapons
   ```

   O script copia o snapshot para `test-runs/<execução>/bots/` e `test-runs/<execução>/weapons/`, confere o hash SHA-256 das duas cópias e abre cada uma em uma janela do Studio. O CSV da execução registra os caminhos e PIDs. Para preparar as cópias sem abrir janelas, acrescente `-PrepareOnly`.

3. Use `list_roblox_studios` para obter os IDs atuais. Confira o nome/arquivo e o estado de cada janela com `get_studio_state`, depois atribua **um `studio_id` distinto a cada Codex**. Ignore entradas transitórias sem nome que não correspondam a uma janela aberta. Se aparecer só uma instância real, abra manualmente as duas cópias preparadas e consulte a lista novamente. Não presuma que PIDs ou IDs antigos ainda estejam válidos.

## Durante os testes

| Linha | Responsável | Escopo sugerido |
| --- | --- | --- |
| `bots` | Codex A | IA, navegação, equipes e spawn |
| `weapons` | Codex B | disparo, recarga, dano, câmera e efeitos |

- Cada agente opera somente o `studio_id` atribuído à sua linha. Antes de iniciar Play, consulte `get_studio_state`; se já estiver em Play, continue a sessão existente ou encerre-a **naquela instância**.
- Playtests separados podem ocorrer em paralelo. Para vários clientes na **mesma partida**, use **Server & Clients** dentro de uma única linha; esse é outro tipo de teste e não isola bots de armas.
- Se o snapshot contiver `ServerStorage.UnitTest.RunUnitTest`, a suíte continua manual e desativada no startup. Para executá-la, no servidor do Play da linha desejada:

  ```lua
  require(game.ServerStorage.UnitTest.RunUnitTest)("BotIntelligence_Test", 5)
  ```

  Troque o filtro pelo nome do caso desejado. Executar a suíte no Play usa o conteúdo **do snapshot daquela linha**. O `CrossgroundsAlphaCopy.rbxl` salvo em 26/10/2026 não contém `ServerStorage.UnitTest`; instale a suíte em uma cópia de teste antes de usar esse comando.
- Registre resultado e `studio_id` junto da linha, do hash do snapshot e do teste. Logs e resultados de uma linha não validam a outra.
- Alterações feitas em uma cópia local do Place não voltam automaticamente ao Place principal nem aos arquivos de `src/`. Integre mudanças de código conscientemente no workspace e gere **novo snapshot** para uma rodada de regressão.
- Não publique nem salve uma linha de teste sobre o Place principal. A cópia local é descartável; mantenha os arquivos da rodada enquanto precisar das evidências.

## Limites

Dois Playtests interativos consomem memória e CPU de duas instâncias do Studio. Comece com duas linhas e aumente somente se a máquina suportar. Testes de teleporte real entre Places exigem versões privadas publicadas e o cliente Roblox; as cópias locais não validam esse fluxo. Testes de persistência publicada, latência real e controles físicos também precisam de ambientes específicos.

Referências: [modos de teste do Studio](https://create.roblox.com/docs/studio/testing-modes), [arquivos de Place](https://create.roblox.com/docs/projects/place-files), [CLI do Studio](https://create.roblox.com/docs/studio/cli).

## Validação de 26/10/2026

- O snapshot `CrossgroundsAlphaCopy.rbxl` (SHA-256 `B22643DD106C133D704B8E37195453AD788D2285198D4FF10B3D1A7436373730`) foi copiado para duas linhas com hashes iguais.
- As cópias `Crossgrounds-bots.rbxl` e `Crossgrounds-weapons.rbxl` abriram em processos e janelas próprios. O conector Roblox retornou um `studio_id` distinto para cada uma, ambas em modo **Edit**, e permitiu ler o DataModel de cada cópia.
- Não foi iniciado Play nessas cópias. Com as janelas já em uso abertas, a memória livre caiu a aproximadamente 0,5–0,6 GB durante o carregamento das duas novas instâncias. As instâncias criadas para esta verificação foram encerradas; as janelas preexistentes foram preservadas.
- Portanto, a abertura e o endereçamento independente pelo MCP estão confirmados. Dois **Playtests simultâneos** do Crossgrounds permanecem sem validação nesta máquina enquanto as outras sessões estiverem consumindo esses recursos.

## Retomada de 27/10/2026

- Foram preparadas duas cópias novas em `test-runs/20261027-031838-c2503403/`, a partir do mesmo snapshot e com o mesmo SHA-256. Nenhuma cópia em uso por outro agente foi modificada.
- Com quatro instâncias preexistentes do Studio abertas, havia aproximadamente 3,3 GB de RAM livre. A abertura apenas da linha `bots` elevou o consumo desse processo a cerca de 3,1 GB e reduziu a memória livre a aproximadamente 0,9 GB, ainda antes de iniciar Play.
- A instância `bots` criada nesta retomada foi encerrada após conferência do caminho do processo. As quatro instâncias preexistentes continuaram abertas; a memória livre voltou a aproximadamente 4,7 GB após o encerramento.
- A linha `weapons` não foi aberta, e Play não foi iniciado. O Play simultâneo do Crossgrounds permanece **não validado** sob a carga atual. Repita a prova quando houver memória suficiente para carregar as duas cópias e os respectivos Plays sem comprometer as sessões em uso.
