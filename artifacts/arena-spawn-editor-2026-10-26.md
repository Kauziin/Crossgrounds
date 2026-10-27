# Área de edição de spawns da Arena

Aplicada no Studio Crossgrounds (ALPHA), Place 4375993208, em 26/10/2026.

- Workspace.ArenaSpawnEditor: 15 mapas em quatro colunas, 24.676 partes de geometria de referência e 396 marcadores visíveis. Templates e originais mantidos em ServerStorage.
- Comparação de limites de geometria em X/Z: nenhum par se sobrepõe; separação mínima de 147,675 studs. A grade foi colocada além dos limites dos objetos existentes no Workspace.
- Conversão dos 396 marcadores entre coordenadas da área e do template: erro máximo de 0,000273 stud, inferior ao limite de 0,001 usado na conferência.
- Validação geométrica: 396/396 pontos aceitos por MapSpawns.Validate e InRegions nas cópias. Isso não valida o que é interior/exterior, conectividade ou equilíbrio de jogo.
- Verificação temporária de Apply: oito verificações aprovadas, incluindo gravação de quatro pontos com nomes duplicados, conversão de posição, orientação, atributos de papel, partes invisíveis sem adornos, revisão anterior e rejeição de ponto sem chão sem substituir o template vigente. Todos os objetos temporários foram removidos ao terminar.
- Open não salva alterações nos templates. Apply salva somente Spawns e SpawnRegions, registra a versão anterior em Development.Revisions.Maps e atualiza SpawnCount. A geometria da área serve de referência.
- Compilação do editor e do HubBootstrap no Studio: passou. Fontes locais e Studio conferidas por tamanho e hash com finais de linha/espaços externos normalizados.
- Play normal após a alteração: a área de edição estava ausente tanto no servidor quanto no cliente; 15 templates mantidos em ServerStorage; hub pronto, fila idle e bootstrap executado uma vez.
- Após parar Play: os 15 mapas e os 396 marcadores continuavam na área do modo Edit. Câmera posicionada para visão geral e Shipment selecionado no Explorer.

Uso: [guia do editor](../docs/ARENA-SPAWN-EDITOR.md). Avaliação do outro pedido: [prontidão do Get Out para beta](../docs/GET-OUT-BETA-READINESS.md).
