# Spawns manuais, votação e iluminação — arquivos

Place: 4375993208. Data: 26/10/2026.

| Arquivo | Bytes | SHA-256 |
|---|---:|---|
| before.rbxm | 456634 | 75fe95b2c9de420c8c6ad623deafb08334db43040b6323593c0edb8257257f87 |
| after.rbxm | 502559 | c5241e758354d74412e40d4b48c22ddf772273cde15b7780dce7c4c8db22cce0 |

before.rbxm contém nove raízes: os quatro templates completos anteriores, os quatro conjuntos de marcadores da área de edição e a região presente nessa área. after.rbxm contém 18 raízes e 13.926 instâncias: quatro templates atualizados, ManualSourceAuthoring com marcadores/regiões dos originais e metadados de conversão, e as 13 fontes alteradas desta entrega.

Os arquivos foram serializados/desserializados no Studio, com conferência de nomes e descendentes. As fontes Lua de topo do pacote novo foram comparadas no round-trip. Os hashes foram relidos do disco. A transferência ficou restrita a um receptor Python do próprio workspace, ligado exclusivamente em 127.0.0.1, e o receptor foi encerrado após a gravação.

runtime-before preserva cópias de fontes anteriores à alteração. As regras do servidor de loadout e a seleção do menu de entrada foram mantidas após a clarificação de que a falha era apenas visual; não devem ser substituídas por versões experimentais.

Para recuperar, inspecione o arquivo em um Place separado. Os modelos de mapa pertencem a ServerStorage.CrossgroundsMaps.Arena; marcadores de ManualSourceAuthoring pertencem ao original correspondente em Development.MapSources.Arena, com as coordenadas já convertidas. As fontes precisam ser distribuídas pelos serviços conforme src; o pacote não é um instalador nem um Place completo.

Veja [detalhes, uso e limites](../../docs/ARENA-MANUAL-SPAWNS-LIGHTING.md).
