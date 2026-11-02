# Social e Sistemas — evidências locais de 02/11/2026

- Principal: Place 4375993208. Aplicação de fontes com comparação da base e hash da última revisão aplicada; backup `ServerStorage.SocialGroupsBaseline_20261102`.
- Cópia de validação: `CrossGroundsWorkingOne.rbxl`, Place 0. Fontes anteriores preservadas em `edit-before.json`; `main-before.json` preserva originais capturados do principal.
- `combined-contracts-result.json`: 65 casos passaram (17 carreira, 15 clãs, 7 acabamentos/trilha, 19 grupos/admissão, 7 confirmação de transferência).
- `runtime-result.json`: 36 verificações passaram com dois clientes reais, via StudioTestService. Nenhum teleporte ou MemoryStore real foi executado. Amizade não existe entre os clientes de teste: somente o convite e a restauração são preparados no servidor.
- `clan-native-result.json`: filtragem/criação pelo menu, modais, somas separadas, contribuição de recompensa preparada, exclusão do treino e recompensa cosmética do nível 3.
- `final-native-result.json`: seis smokes de servidor e quatro de cliente passaram, incluindo arquivamento do último integrante e insígnia Astral da Maestria.
- Camuflagens: teste real via KitService construiu M4A1 dourada com Ammo 30, Handle e 65 descendentes. Tentativa de Ouro na M1911 sem nível recusada; M4A1 no nível 55 aceita pelo remoto. Primeira asserção aplicada diretamente à factory foi corrigida: ela não inicializa Ammo, que pertence ao caminho de equipamento.
- Validação final adicional encontrou uma colisão de duas leituras de clã (consulta preparada e atualização automática); leitura posterior confirmou líder e XP 0. ClanBridge passou a serializar intervalos de leitura/escrita e cancelar atualização automática já substituída por consulta mais recente. Cinco verificações do fluxo de menu passaram após a correção, em `clan-menu-final-result.json`.

As fixtures não representam partida PvP humana, curva de horas, hardware físico, corte de migração ou persistência publicada. `CareerCutoverApproved`, `TeleportEnabled` e `GroupTransferEnabled` permanecem desativados. Publicação não realizada. Competições/desafios cooperativos não fazem parte desta entrega.

## Ajuste posterior: ícones e molduras

Sete contratos novos e repetição dos 65 anteriores passaram. `profile-frames-icons-result.json` guarda os testes novos e verificações nativas do editor/ordem, cores, bloqueio, atlas e atualização do grupo. 57 fontes compiladas e idênticas ao repositório no principal em Edit; importação original de Lucide preservada em ServerStorage.LibraryImports. Sem publicação ou DataStore real.
