# Arquivos de recuperação e entrega

Data: 26/10/2026. Place: Crossgrounds (ALPHA), 4375993208.

| Arquivo | Bytes | SHA-256 |
|---|---:|---|
| before.rbxm | 116179 | 49ff2b83df53f68ff15dfc2213ae29075b2f0d8fe763cf4aa64b670b41b1c100 |
| riverside-wide.rbxm | 535705 | a2ce581708668d026d339c703e523283ac0377eaaba810ab164d6a37e35e0218 |

Ambos foram serializados/desserializados pela SerializationService antes de conferir contagens e nomes/classes; fontes Lua de topo também foram comparadas na exportação nova. Os hashes foram relidos do disco e coincidem. O arquivo anterior tem nove raízes e 2.463 instâncias; o pacote novo tem oito raízes e 6.501 instâncias. TerrainRegion anterior continua preservado na biblioteca CTF exportada; não foi refeito o terreno do Workspace.

O arquivo before inclui a CTFInfrastructure antiga, os cinco objetos raiz identificados como CTFMapGeometry, a biblioteca CTF anterior e as fontes anteriores de MapManager/CTFBotObjectives. Não contém o editor de spawns da Arena nem pretende ser backup das edições feitas nele pelo usuário.

O pacote novo contém riverside_wide, CTFWideAuthoring, CTFBotObjectives, MapManager, CTFFlagLabels, AdminService, AdminCameraController e HubBootstrap. Inspecione em um Place separado e distribua as fontes pelos serviços conforme src; não insira todos os scripts diretamente no Workspace.

Veja [layout, créditos e limites da validação](../../docs/CTF-WIDE-MAP.md).
