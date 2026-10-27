# Get Out — recorte v0.5 P0

- Novo mapa original de teste com rotas físicas por porta, janela e duto, armário e terminais com vagas separadas.
- Rastejamento com colisão reduzida e bloqueio de levantar sob teto; Besta bloqueada no duto.
- Martelo derruba sem matar; a Besta prende uma corda, arrasta e deposita a vítima em cápsula próxima. Resgate limpa os vínculos e restaura movimento.
- Congelamento cumulativo e pausa por proximidade da Besta como parâmetros provisórios de teste.
- Hack cooperativo com progresso persistente, teste de tempo validado no servidor, falha audível e aviso à Besta. Rollback do Hacker sincronizado com o terminal.
- Portas comuns independentes de saídas, com estados exclusivos e fechamento impedido por personagem no vão.
- Confirmação de carregamento pelo cliente e confirmação de personagem antes de iniciar o relógio do Get Out. Pausa comum de cinco segundos mantida também na Arena e no CTF.
- HUD de estado pessoal, controles de Get Out remapeáveis, botões de toque e barra de progresso das interações.
- Isolamento dos handlers do CTF, respawn próprio após reset, pontos separados na espera e proteção física nas bordas da sala de preparação.
- Catálogo bloqueia mapas legados ainda sem travessia, slots de hack e saída segura de resgate para a v0.5.
- Facility preservada; rotas ainda sem interface jogável continuam descritas como pendentes. Nenhum novo valor foi promovido a balanceamento aprovado.

Veja `docs/GET-OUT-V05-IMPLEMENTATION.md` para a matriz de mecânicas e os limites de validação.

Validação em 26/10/2026: 44 checks com três clientes e seis contratos passaram. Reset durante espera e retorno ao hub também passaram em Play normal.
