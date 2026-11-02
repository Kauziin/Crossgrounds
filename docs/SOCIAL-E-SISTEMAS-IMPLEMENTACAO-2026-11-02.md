# Social e Sistemas — implementação inicial

02/11/2026. Entrega parcial do planejamento: progressão, persistência versionada, desbloqueios, identidade e cartão de eliminação. Fontes locais aplicadas ao Studio principal 4375993208. Sem publicação.

## Implementado

- `CareerPolicy`: curva normal de 343.710 XP até 55, dez prestígios, Maestria reiniciando em 1 até 1000, Lenda reiniciando em 1 e mantendo desbloqueios. A partir de Maestria 55, custo de 12.000 XP por nível; Lenda usa 12.000. Esses valores são a primeira versão implementada da curva, sujeitos a balanceamento e migração explícita.
- XP histórico separado do XP da etapa. XP de arma e cosméticos conquistados sobrevivem aos resets. Teto não acumula XP para consumir o ciclo seguinte. Um token por modalidade nas dez transições de prestígio e nas entradas de Maestria/Lenda.
- Migração pelo XP histórico, com excedente atravessando as etapas. Em igualdade exata ao custo de uma etapa, deixa a transição disponível para confirmação voluntária. Sem atribuição retroativa de XP de armas.
- `CareerRepository`: sessão proprietária com expiração, revisão de gravação, retenção da transação incerta e recuperação sem somar novamente. Perfis incompletos/futuros e histórico indisponível não são convertidos silenciosamente em perfil vazio.
- `CareerService`: carregamento, gravação, fila de recompensas enquanto há transação pendente, operações confirmadas de prestígio/token/identidade, projeção pública sem inventário privado e limites separados para consultas e mutações.
- `ProgressionService`: integração com os contadores existentes e crédito de XP da arma no evento de recompensa. Arena e Conflict fornecem a arma creditada pelo servidor; estatísticas antigas e moedas são mantidas.
- `UnlockCatalog`/`UnlockService`: requisitos de armas/aparências e acessórios, validação de loadout no servidor e revalidação ao equipar. Preset bloqueado mantém sua intenção salva; equipamento efetivo usa M4A1/M1911 e remove acessórios ainda indisponíveis. Arena conserva atributos comuns e bloqueia apenas escolhas de aparência.
- `CareerClient`/armeiro: requisitos visíveis e seleção bloqueada no cliente, com validação independente do servidor. Prévia continua acessível.
- Catálogo inicial de seis calling cards procedurais, quatro molduras, quatro emblemas e seis títulos. Famílias padrão, eliminações, objetivos, prestígio, Maestria e Lenda; famílias se sobrepõem entre categorias. Recompensas por 100 eliminações e 10 capturas, além das fases de prestígio.
- Menu “Carreira e perfil” no lobby: identidade, personalização, próxima etapa com confirmação, catálogo paginado e uso de tokens. Usa CascadeMenu/MenuNavigation/tema existentes.
- `PlayerIdentityView`: cartão compartilhado com avatar Roblox, fundo, moldura, título, emblema e progressão. `EliminationSpectator` recebe identidade congelada no evento do servidor, mostra também a arma e permite apresentar o cartão mesmo se o modelo do eliminador não estiver mais disponível. Não implementa replay.
- Destaque de ranking existente renomeado de `Prestige_` para `Podium_`. Ranking geral de nível usa um índice separado de nível acumulado de carreira, para não ordenar o reset como perda de histórico. Perfil pessoal exibe o nível da etapa.

## Estado de persistência e corte entre versões

No Studio, o mesmo repositório opera com armazenamento de sessão em memória e não grava DataStore real. Fora do Studio, a nova carreira só ativa quando `ServerStorage.CareerCutoverApproved=true`. Esse atributo **não foi habilitado** nesta entrega.

O bloqueio é intencional: copiar o perfil v1 enquanto servidores antigos continuam gravando nele pode perder recompensas posteriores à cópia. A ativação publicada exige corte controlado, drenagem de escritores antigos, confirmação de dados e teste em experiência publicada de validação. Enquanto a ativação estiver desligada, o serviço de progressão antigo continua sendo a rota publicada; comandos novos de carreira informam indisponibilidade.

O perfil novo usa `CrossgroundsCareer_v2`; a origem é `CrossgroundsProgression_v1`. Recompensas seguem `ProgressionBalance`, que já usa ConfigService. Curvas persistidas não mudam por configuração remota durante a migração.

## Catálogo e limites do primeiro bloco

Armas principais possuem alguns níveis explícitos, incluindo M4A1/M1911 em 1 e AX-50 em 55; demais IDs jogáveis recebem um requisito estável derivado do ID, de modo que novos itens não deslocam os requisitos existentes. Acessórios usam marcos por slot; XP de armas tem teto de nível 55 nesta versão. A curadoria manual completa de cada trilha e a distribuição editorial de recompensas pelos 55 níveis continuam pendentes.

O token só compra itens de progressão realmente catalogados para Arena/Conflict; não libera IDs inexistentes ou implementações de prévia. Tokens de Get Out/Duels ficam preservados para os catálogos futuros. Os cosméticos pessoais de feitos não entram no catálogo de equipamento comprado por token.

Não há ainda molduras em todas as listas/placares, vitrine de insígnias/contadores, edição de perfil offline ou um catálogo extenso de arte. Os cartões iniciais são composição de interface, sem novas imagens externas.

## Validações realizadas

- **16/16 contratos isolados no Studio**, em módulos temporários removidos após a execução: fronteiras de todos os níveis normais, dez prestígios, Maestria/Lenda, migração exata/excedente, preservação de armas/cosméticos, token por modo, projeção pública, versão inválida, corrupção de perfil, leitura indisponível, sessão concorrente/expirada e recuperação de resposta perdida na abertura/gravação.
- Resultado persistido em `artifacts/social-systems-2026-11-02/foundation-result.json`; suíte reproduzível em `tests/Unit/Cases/CareerFoundation_Test.luau`.
- **8/8 verificações no servidor em Play**: perfil pronto; iniciais liberadas/AX-50 bloqueada; fallback sem alterar preset; catálogo; XP de arma/teto; prestígio preservando arma/cosmético; token/duplicata; projeção pública sem dados privados.
- Consultas pelo remoto normal no cliente confirmaram rejeição de cosmético não conquistado, transição expirada e item inexistente.
- Em outro Play, chamada real de recompensa de Conflict creditou conta e arma. O helper normal de equipamento construiu `Sword`, `m4a1` com Ammo 30 e `m1911` com Ammo 7, sem AX-50 bloqueada. Isso valida a integração de recompensa/equipamento, não uma eliminação PvP humana completa.
- Personalização por remoto confirmou os quatro campos no servidor e o título “Linha de frente” no cartão renderizado.
- Menu aberto pelo roteador real dos LocalScripts e cartão inicial inspecionado visualmente. Corrigida disputa entre atualização automática e comando de personalização, separando limites de leitura/escrita; cartão começa com identidade padrão válida, sem textos “Label”.
- Eliminação simulada por fixture de servidor exibiu cartão do adversário e arma M4A1. Após respawn, jogador vivo, cartão oculto e `SpectatingEliminator=false`. A fixture não representa uma kill PvP real ou teste multiplayer.
- Compilação e igualdade local/Studio confirmadas para **26 fontes**. `git diff --check` dos arquivos alterados passou, com aviso de conversão de finais de linha do Git em ProgressionSchema.

Permanecem sem validação: DataStore real, corte de produção, teleporte, hardware físico, partidas humanas multiplayer, curva de horas, todas as armas/acessórios e revisão visual em todos os dispositivos. O console manteve avisos anteriores de assets sem permissão/arquivados, plugin GUIEditor e pasta histórica de StarterPlayerScripts em TestService; não foram atribuídos à nova carreira.

## Pendências do pedido integral

1. Amigos/presença e jogadores recentes além do comparativo existente.
2. Formação e liderança de grupo, convites, bônus de +5% em XP de conta/arma, escolha de equipe e admissão coletiva.
3. Matchmaking e transporte entre servidores com reserva/recuperação do grupo.
4. Clãs persistentes, contribuições, progressão e os dois rankings com igual destaque.
5. Ampliação do perfil público, aplicação de molduras nas listas/placares e catálogo editorial de cosméticos/desbloqueios.
6. Balanceamento e validação publicada da migração/persistência.

Competições permanecem reservadas ao jogo público e polido; desafios cooperativos dependem de Get Out jogável e futuras funções Médico/Engenheiro em Conflict.

## Recuperação e franquia

Backups das fontes anteriores em `artifacts/social-systems-2026-11-02/before` e `ServerStorage.SocialSystemsBaseline_20261102`. O snapshot inicial do Studio está em `studio-before.json`. `tools/serve_social_systems.py` é uma ponte de loopback para fontes/validação; não é componente do jogo. `tools/integrate_career_20261102.py` foi usado como transformação única, com âncoras que impedem repetição silenciosa.

Franquia de 5 horas consultada ao longo da execução: disponível caiu de 29% para **5% na consulta final**. Ao se aproximar desse limite, o trabalho se concentrou em estabilizar este bloco, sem iniciar implementação parcial de grupos ou clãs. Fechamento confirmou 26 fontes compiladas/iguais às locais, migração publicada desativada e principal em Edit. Ponte temporária de validação encerrada. Não foi usado o crédito de reset da conta.
