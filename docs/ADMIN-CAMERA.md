# Câmera admin para capturas

Acesso autorizado no servidor somente ao UserId **1248190494**, conferido como usuário conectado ao Studio. A permissão não depende de um atributo enviado pelo cliente e não é concedida automaticamente a jogadores fictícios de testes multicliente.

Durante Play:

| Tecla | Ação |
|---|---|
| F6 | Ativar/desativar câmera livre |
| WASD + mouse | Voar e olhar |
| Q / E | Descer / subir |
| Shift | Acelerar 4× |
| Ctrl | Precisão, velocidade 0,2× |
| Roda do mouse | Ajustar velocidade base entre 4 e 512 studs/s |
| F7 | Ocultar/restaurar a interface e os textos 3D para captura |
| PageDown / PageUp | Abrir o próximo/anterior mapa da Arena para fotografia |

O modo sai da partida pelo coordenador normal antes de ativar. O personagem permanece ancorado no hub enquanto a câmera voa sem colisão. Ao sair, os controles, câmera, cursor e interfaces são restaurados. Uma troca de modo ou personagem também encerra a câmera.

PageUp/PageDown criam uma cópia temporária apenas da geometria do template escolhido, em uma área de fotografia distante, e levam a câmera até ela. Isso permite fotografar mapas da Arena sem depender de uma rodada nem alterar os spawns que estão sendo editados. As cópias são removidas ao trocar de mapa ou sair do modo admin. Para ver o CTF e o restante do cenário, voe normalmente pelo Workspace; sair/reativar F6 retorna a câmera à posição normal do hub.

Essa câmera é para teclado e mouse. Não é um sistema de moderação, banimento ou edição remota de mapas. O acesso funciona no jogo para a conta permitida; a alteração não publica o Place automaticamente.

Validação inicial: compilação no Studio e três verificações de permissão aprovadas (conta permitida, conta alheia e jogador fictício). Outras oito verificações do servidor em ambiente isolado confirmaram concessão, rejeições, ancoragem/restauração, saída do CTF pelo coordenador e recusa de comando inválido. Esses testes não abriram sessão de jogo. Play não foi iniciado durante a edição de spawns do usuário; movimento, ocultação e restauração em uma sessão real continuam pendentes de verificação interativa.
