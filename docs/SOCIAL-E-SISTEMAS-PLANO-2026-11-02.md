# Social e Sistemas — plano de progressão e grupos

Data: 02/11/2026. Situação atual: implementação parcial do primeiro bloco de carreira, desbloqueios e identidade, descrita no [relatório de implementação](SOCIAL-E-SISTEMAS-IMPLEMENTACAO-2026-11-02.md). As seções de estudo abaixo preservam o planejamento e suas decisões; não representam conclusão de grupos, clãs ou demais pendências. As propostas de balanceamento e UX continuam sujeitas às validações indicadas.

## 1. Base existente examinada

- `ProgressionService` e `ProgressionSchema` calculam nível como `floor((XP / 250)^(1 / 1.45)) + 1`, sem teto. A expressão está duplicada entre servidor e contrato compartilhado.
- O perfil `CrossgroundsProgression_v1` conserva contadores globais e por modalidade. O salvamento soma deltas positivos; esse contrato não representa resets, consumo de tokens ou operações de inventário.
- `ProgressionRanking` usa `Prestige_<modo>` para o destaque das três primeiras posições. Esse conceito deve receber outro nome semântico, com adaptação dos consumidores, antes de integrar o prestígio de progressão.
- `QueueProvider` é um controlador de entrada individual local. `SessionCoordinator` chama os adaptadores individualmente; `TravelService:Begin` envia um jogador. Não há reserva de vagas para grupo nem matchmaking global nesses módulos.
- `GameCatalog` registra Conflict com 12 combatentes, em duas equipes de 6. Get Out tem máximo de 5 no conjunto de regras examinado; catálogo ainda o marca como planejado. Duels também está planejado. A capacidade de Arena deve ser explicitada no contrato do modo antes de aceitar grupos.
- A comparação de amigos existente consulta até 60 contatos e exibe até 8 com histórico. Ela pode continuar existindo, mas não serve como lista social completa.
- `WeaponCatalog`, `AttachmentCatalog`, `WeaponVisualConfiguration` e `ArsenalLoadouts` já resolvem disponibilidade técnica, compatibilidade e presets. Desbloqueio por progressão deverá ser uma condição adicional de autorização do servidor.
- A Arena recebeu recentemente aparências de pistolas com atributos comuns. O plano preserva essa identidade; uma aparência não será tratada como arma funcional independente para criar vantagem por nível.
- `GetOutResult` registra resultados, mas não concede XP em sua implementação examinada. É necessário definir recompensas desse modo antes de comparar velocidade de progressão entre modalidades. Duels precisa de integração quando tiver produtor real de resultados.

Verificação realizada: leitura dos arquivos locais e consulta somente de leitura ao Studio principal, place 4375993208, em Edit. No Studio foram confirmadas a fórmula de nível, a fila local e a presença dos módulos centrais. Não foi feita comparação integral de todas as fontes nem teste de execução dos sistemas propostos.

## 2. Decisões confirmadas

| Assunto | Regra definida |
|---|---|
| Progressão principal | Global à conta; níveis normais de 1 a 55 |
| Prestígios normais | Até 10; cada ciclo tem limite 55 |
| Reset de prestígio | Nível/XP do ciclo e desbloqueios por nível da conta são resetados |
| Armas | XP, nível, acessórios e camuflagens conquistados pela progressão da arma são preservados |
| Itens permanentes | Permanecem disponíveis após os resets |
| Cosméticos de perfil | Calling cards, molduras, títulos e emblemas conquistados são permanentes, inclusive após prestígio e Maestria |
| Rankings de clãs | Histórico somado do elenco atual e conquistas do clã têm o mesmo destaque |
| Tokens | Cada prestígio concede 1 token para cada modalidade; o token desbloqueia permanentemente um item daquela modalidade |
| Migração | Reinterpretar o XP histórico pela nova curva; não preservar o número do nível antigo |
| Antigos níveis acima de 55 | Não há garantia de prestígio: se o XP não pagar o novo ciclo, a conta fica abaixo de 55 |
| Maestria | Após concluir Prestígio 10 / nível 55, começa no nível 1 e vai até 1000 |
| Entrada da Maestria | Repete o reset dos desbloqueios de conta e concede 1 token por modalidade |
| Lenda | Após Maestria 1000, começa no nível 1 e progride sem teto de design |
| Entrada da Lenda | Preserva os desbloqueios da conta; concede 1 token por modalidade |
| Bônus de grupo | +5% por outro membro elegível na mesma partida, aplicado ao XP da conta e ao XP das armas |
| Equipes | Líder escolhe entre permanecer no mesmo time ou aceitar divisão entre times |
| Lobby | Grupo de até 12 membros |
| Treino/testes | Entrada individual; não arrasta o grupo nem recebe bônus social |

Interpretação consolidada da última resposta: Lenda começa com seu contador de nível em 1, conforme a decisão anterior, mas não repete o reset dos desbloqueios. Sua transição continua concedendo tokens. O histórico total nunca é apagado.

## 3. Trajetória e regras de transição

1. Sem prestígio: nível 1 → 55.
2. Prestígio 1: nível 1 → 55; repetir até Prestígio 10.
3. Ao concluir Prestígio 10 / 55: entrar na Maestria, nível 1 → 1000.
4. Ao concluir Maestria 1000: optar por Lenda, nível 1 em diante.

Proposta: todas as transições futuras são voluntárias, feitas no lobby, com perfil carregado, fora de partida/fila/transporte. O jogador vê os desbloqueios afetados, permanências e tokens antes de confirmar. A migração inicial é uma operação especial e automática, determinada pelo XP histórico.

Em um teto aguardando decisão, continuar somando XP histórico e XP de armas, mas não acumular XP para atravessar instantaneamente os primeiros níveis do próximo ciclo. Uma recompensa que atinja o teto pode preencher apenas o espaço restante do ciclo; sua parcela integral permanece no histórico. Não exigir uma barra extra de XP após alcançar 55 ou 1000 para habilitar a transição.

Ao chegar ao nível 55 da Maestria, todo o conteúdo cujo requisito máximo é nível 55 já poderá estar liberado novamente. Níveis 56–1000 distribuem principalmente personalização e reconhecimento; não criam centenas de vantagens de combate. A Lenda preserva esse acesso. As recompensas cosméticas devem continuar por marcos, sem exigir que se criem manualmente infinitos itens.

Prestígio e nível representam dedicação. Não os usar isoladamente como medida de habilidade do matchmaking.

## 4. Curva de XP e equilíbrio entre modos

Proposta numérica inicial para simulação, ainda não aprovada como tuning final:

`XP para subir do nível L ao L+1 = 800 + 210 × (L − 1)`, para L de 1 a 54.

| Nível alcançado | XP acumulado no ciclo proposto |
|---|---:|
| 1 | 0 |
| 10 | 14.760 |
| 25 | 77.160 |
| 40 | 186.810 |
| 55 | 343.710 |

A curva atual alcança 55 por volta de 81.267 XP; o candidato exige aproximadamente 4,23 vezes esse XP, mantidas as recompensas. Isso é comparação matemática, não previsão de horas reais. Bônus de grupo, ritmo dos modos, objetivos e alterações remotas de recompensa mudam o tempo necessário.

Proposta: mesma curva nos dez prestígios, tornando a base mais exigente sem acrescentar um multiplicador a cada reset. Maestria reutiliza a curva até 55 e passa a custos por nível com crescimento controlado; Lenda usa custo estável ou crescimento suave. Definir esses valores após simular sessões reais, incluindo grupo máximo.

Usar uma única política de cálculo para servidor e apresentação. Guardar versão da curva no perfil. Ajustes futuros não devem rebaixar silenciosamente níveis já conquistados; a migração inicial aqui autorizada é uma exceção explícita. O projeto já usa ConfigService em `ProgressionBalance`; recompensas podem aproveitar essa infraestrutura, enquanto mudanças de limiar de nível exigem política de versão.

Fontes de XP propostas: eliminações, assistências válidas, objetivos e conclusão efetiva de partida, com participação mínima. Em Get Out: contribuição nos PCs, resgate, fuga e desempenho da Besta, evitando repetir a mesma ação para gerar XP ilimitado. Separar eventos de participação dos eventos que realmente concedem recompensa.

Treino pode conservar as recompensas reduzidas já existentes, em política explícita, mas sem multiplicador social e sem conceder desafios de PvP. Bots precisam de regras próprias para não tornar o farm a rota mais eficiente. Rebalancear pelo XP por minuto observado de jogadores iniciantes e experientes, e não apenas pelo valor por eliminação.

## 5. Desbloqueios da conta, armas e permanências

Criar catálogo de requisitos por modalidade, de nível 1 a 55, permitindo vários itens por nível. A distribuição final depende do inventário tecnicamente jogável; não preencher 55 níveis liberando itens `PreviewOnly` ou incompatíveis.

Proposta de distribuição: nível 1 oferece um conjunto funcional completo; início apresenta alternativas simples; meio abre especializações; final entrega opções avançadas e recompensas de identidade. Em Conflict, garantir primária/secundária iniciais funcionais. Na Arena, liberar aparências e cosméticos preservando os atributos comuns. Em Get Out, habilidades básicas necessárias para cumprir objetivos permanecem acessíveis desde o início.

Presets que contenham itens rebloqueados serão preservados como intenção do jogador, mas a seleção ativa usará um fallback válido e explicará o motivo. Revalidar ao salvar, equipar, nascer e reconstruir a classe. A interface pode exibir itens bloqueados com requisito e prévia; o servidor decide a autorização.

Cada arma possui XP e nível próprios. A identificação deve ser da arma funcional canônica: camuflagens, variantes visuais e presets não criam perfis separados. Acessórios são liberados por marcos do nível da arma; camuflagens podem combinar nível e desafios. O teto de cada arma depende de seu conteúdo real; não fixar todas em um número que produza dezenas de níveis vazios.

O reset não apaga progresso nem conquistas da arma. Entretanto, se a arma volta a ficar bloqueada pela conta, seus acessórios só podem ser usados quando ela for desbloqueada novamente ou tornada permanente. Um token pode permitir antecipar um item específico antes do requisito normal, respeitando seus pré-requisitos técnicos.

Regra de elegibilidade do token: qualquer item desbloqueável por progressão daquela modalidade. O token não converte uma prévia técnica, item incompatível ou conteúdo sem implementação em equipamento utilizável. Para item dependente de arma, mostrar a dependência antes do gasto; desbloquear um acessório não libera automaticamente sua arma. Um item permanente ignora seu requisito de progressão, mas não compatibilidade ou disponibilidade técnica.

Propostas de operação dos tokens: não gastar automaticamente; confirmar item e modalidade; operação única e persistente; rejeitar item já permanente sem consumir saldo. XP histórico e moedas não são consumidos pelo prestígio. Cosméticos externos à trilha de nível não devem desaparecer por efeito colateral do reset.

Modos futuros: registrar o direito aos tokens por transição e creditar a modalidade quando ela for habilitada, descontando o que já foi concedido. Isso evita perder direitos por um modo ainda não existir ou duplicar tokens quando o catálogo mudar. Falta fechar o catálogo exato de itens que aceitam tokens e o tratamento de itens compartilhados entre modos; proposta inicial: permanência com escopo da modalidade onde o token foi gasto.

## 6. Maestria e identidade

Proposta: escolha de emblema, moldura, paleta e título entre opções conquistadas, com marcos em 100, 250, 500, 750 e 1000. Separar marco real da aparência escolhida: escolher um emblema antigo não esconde o nível ou a fase verdadeiros.

Lenda recebe identidade própria e contador próprio, além do histórico de Maestria concluída. Sem novos resets cíclicos automáticos. Novos bônus de dano/vida por prestígio não fazem parte deste plano; as recompensas permanentes propostas são acesso a itens e identidade visual.

## 7. Amigos e grupo

Proposta de primeira versão social: usar as amizades do Roblox, com lista paginada, busca, avatar, estado de presença disponível, modalidade e ações de convidar/solicitar entrada. Presença indisponível não deve aparecer como certeza de offline. Separar convites para abrir a experiência de convites para entrar no grupo interno.

`SocialService` oferece convites e consulta de parties da plataforma. Integrar por um adaptador; o grupo interno do Crossgrounds conserva liderança, limite por modo, permissões e bônus próprios. Não inferir autoridade de líder pela ordem de membros retornada pela plataforma. Não assumir que um grupo de plataforma equivale automaticamente a um grupo interno de 12.

Propostas de regras:

- Criar, convidar, aceitar/recusar, sair, expulsar e transferir liderança. Uma pessoa pertence a um grupo interno por vez.
- Amigos podem ser convidados; convidados de membros entram com autorização do líder. Convites expiram e podem ser recusados; não transportar quem não aceitou participar.
- Líder controla modalidade, variante, opção de equipe e início/cancelamento da busca. Um membro que quer jogar separadamente pode sair; treino individual não dissolve o grupo.
- Entrada real do líder leva os membros elegíveis ao mesmo destino. Usar aviso de início e contagem curta para permitir sair, sem exigir confirmação em toda partida.
- Antes de enfileirar, todos precisam estar no lobby e prontos para transição. Membro em treino retorna primeiro, por ação própria; não é arrancado do treino em andamento.
- Grupo acima do limite bloqueia a busca e mostra as pessoas/vagas excedentes. O líder remove membros ou escolhe outro modo; o sistema nunca remove pessoas automaticamente.
- Em Conflict, opção mesma equipe limita a 6; opção dividir equipes permite até 12, sujeita ao balanceamento. Em Get Out, máximo 5; grupos não escolhem livremente todos os papéis. Arena e Duels precisam publicar capacidade e política próprias.
- Saída do líder no lobby transfere a liderança para o membro elegível mais antigo. Durante busca, cancelar o ticket antes da transferência. Durante partida, não retirar os membros do round automaticamente.
- A formação continua entre rodadas. Retorno voluntário ao lobby pelo líder oferece retorno conjunto ao fim do round; não interrompe uma partida dos demais. Desconexão admite janela de reconexão com reserva temporária quando possível.

Âncora de matchmaking significa que o líder inicia a busca e guia destino/roteamento do grupo. A elegibilidade e o tamanho de todos os membros também contam. Em eventual matchmaking por habilidade, considerar o conjunto do grupo para não permitir que um líder iniciante reduza artificialmente a dificuldade dos demais; não implementar um sistema competitivo completo nesta etapa.

## 8. Bônus social

`multiplicador = 1 + 0,05 × (membros elegíveis − 1)`

| Membros elegíveis | Bônus individual |
|---|---:|
| 1 | 0% |
| 2 | 5% |
| 3 | 10% |
| 6 | 25% |
| 12 | 55% |

O número inclui o jogador beneficiado; por isso se subtrai 1. O bônus é aplicado a cada integrante elegível, no XP de conta e da arma correspondente. Não aumenta moedas, contadores de eliminações ou pontos do placar.

Proposta: contar somente membros conectados, participantes da mesma partida e do mesmo grupo, excluindo AFK, espectadores e pessoas no lobby/treino. Morte normal durante a partida não retira elegibilidade. Não contar todo jogador morto como espectador; considerar o papel de participante do round.

Para recompensas imediatas, usar composição válida no instante do evento. Para recompensa final, usar participação efetiva ao longo da partida, evitando entrar no grupo no último segundo para ganhar o bônus completo. Acumular frações de XP para não perder bônus por arredondamento a cada ação pequena. Se houver outros bônus no futuro, somá-los sobre o XP base e arredondar no ponto central de concessão, sem multiplicações acidentais.

Se o grupo estiver dividido entre equipes, seus membros na mesma partida continuam contando para o bônus, conforme a opção de divisão aprovada. Recompensas por eliminar repetidamente membros do próprio grupo exigem tratamento de farm: proposta de redução progressiva por par de jogadores e métricas de repetição, sem impedir a partida casual entre amigos. Ajustar após observar partidas legítimas.

## 9. Infraestrutura e dados

Responsabilidades propostas:

| Componente | Responsabilidade |
|---|---|
| Política de progressão | Curvas, fases, limites, transições e leitura da versão |
| Perfil persistente | Sessão proprietária, histórico, estado do ciclo, moedas e operações |
| Catálogo de desbloqueios | Requisitos de conta/arma, modalidade, dependências e elegibilidade de token |
| Serviço de desbloqueios | Autorizar equipamento, consumir token e conceder permanência |
| Progressão de armas | Crédito por arma canônica e marcos conquistados |
| Serviço social/grupos | Convites, líder, formação, revisão e reconexão |
| Matchmaking/admissão | Ticket coletivo, reserva do conjunto, modalidade, equipes e cancelamento |
| Transporte de grupo | Confirmação de chegada, tentativas e recuperação de falhas parciais |

Modelo lógico: `schemaVersion`, `curveVersion`, `lifetimeXP`, `phase`, `prestigeCount`, `cycleXP`, `masteryXP`, `legendXP`, estatísticas existentes, `weaponProgress[canonicalId]`, `tokensByMode`, `permanentUnlocksByMode` e histórico limitado de operações/entitlements. Derivar níveis do XP da fase com uma política comum; evitar duas fontes independentes de verdade.

XP histórico e moedas continuam persistentes. Token gasto e item permanente devem ser confirmados na mesma operação de perfil; a resposta de sucesso vem depois da confirmação durável. Migração, concessão de token, prestígio e recompensa de partida precisam de identificador de operação para tolerar repetição sem duplicar efeitos.

O salvamento atual por deltas positivos precisa evoluir antes de aceitar resets. Proposta: perfil v2 com posse de sessão, gravações condicionadas por versão e fila de operações; totais de ranking continuam sendo projeções derivadas. Não enviar XP, tokens ou inventário como autoridade por TeleportData.

Para grupos entre servidores, usar estado temporário com expiração em MemoryStore e notificações entre servidores; DataStore fica com progresso permanente. Um convite/ticket transporta referência opaca; o destino consulta e valida a formação/revisão e os membros autorizados. Preservar revisionamento para impedir que uma reserva antiga carregue uma formação alterada.

Reservar o conjunto de vagas antes de confirmar entrada. A API de teleporte aceita vários jogadores, mas isso não torna chegada e início de partida uma operação indivisível. Se parte falhar, manter os que chegaram em preparação por prazo limitado e recuperar/reunir os ausentes; não lançar silenciosamente uma partida incompleta como se todo o grupo tivesse chegado. Repetições devem apontar para a mesma sessão de destino.

Evoluir `SessionCoordinator`, `QueueProvider`, `TravelService` e adaptadores existentes. O protótipo local também exige reserva de capacidade e preparação coletiva antes de chamar entradas individuais. O caminho entre servidores deve usar o mesmo contrato de admissão, com transporte diferente.

## 10. Migração do histórico

1. Congelar uma versão da nova curva e suas regras de transição. Não usar um valor remoto variável no meio da migração.
2. Ler o perfil v1 como fonte histórica, preservando XP, moedas e estatísticas existentes. Não fabricar XP por arma a partir de eliminações globais: o histórico não identifica a arma.
3. Aplicar o XP total à sequência: ciclo inicial, dez ciclos de prestígio, Maestria e Lenda. Cada ciclo normal custa o XP necessário para chegar de 1 a 55. Ao pagar um ciclo inteiro e existir XP excedente, atravessar a transição e conceder seus direitos; em igualdade exata, deixar a conta no teto daquela fase, com opção de transição voluntária.
4. Se o XP não completar o novo primeiro ciclo, a conta não ganha prestígio, mesmo que seu nível antigo fosse superior a 55. Essa consequência foi explicitamente aceita pelo usuário.
5. Levar o excedente para a fase seguinte, inclusive além de Prestígio 10 e Maestria 1000. Conceder tokens dos prestígios/transições efetivamente atravessados pela migração.
6. Registrar resultado, versão e marca de migração de forma idempotente. Conservar a origem recuperável; repetir o login não reaplica XP nem tokens.
7. Não expor perfil v2 ao writer v1, cujo saneamento descarta campos desconhecidos. Planejar corte entre versões, encerramento controlado de sessões antigas e transferência final de deltas antes da ativação. Uma cópia de v1 para v2 sem esse corte pode perder o progresso ganho nos servidores antigos.

Proposta: perfis de arma começam sem XP retroativo, preservando apenas dados de arma que de fato existirem em fonte confiável. A política para equipamentos já disponíveis antes da migração deve ser explícita: a autorização atual é rebloquear pela nova progressão; não presumir que todo preset antigo equivale a um desbloqueio permanente.

## 11. Sequência de implementação e validação futura

1. Fechar catálogo inicial, curvas e regras propostas ainda em aberto. Modelar casos de iniciante, veterano, conta no teto e modos futuros.
2. Implementar perfil v2, posse de sessão, migração, política única e operações de transição/token. Validar fronteiras dos dez prestígios, Maestria/Lenda, arredondamento, repetição e falhas de gravação.
3. Integrar desbloqueios ao loadout e aos pontos reais de equipamento. Conferir fallback, item permanente, dependências e prévias técnicas.
4. Integrar crédito de XP de armas ao evento autoritativo de dano/eliminação. A chamada atual de recompensa precisa carregar identidade canônica da arma e contexto; nunca confiar no ID enviado isoladamente pelo cliente.
5. Implementar social/grupo no lobby e entrada coletiva local. Testar limites, líder, convites simultâneos, cancelamento, treino individual, composição alterada e escolha de equipe.
6. Implementar matchmaking entre servidores, reserva e recuperação de transporte. Testar capacidade disputada, expiração, desconexões e chegada parcial em ambiente publicado de teste.
7. Integrar apresentação ao menu/progresso/armeiro existentes; validar requisitos e transições em mouse, toque e controle. Mostrar XP base, bônus social, progresso de arma e próximo desbloqueio no resultado.
8. Simular e medir ritmo por modalidade e tamanho do grupo. Ajustar recompensas e curvas antes da migração de produção.

Critérios materiais de conclusão: nenhuma perda de histórico; nenhuma duplicação de token/recompensa; item bloqueado não equipa por remoto/respawn/preset; progresso de arma sobrevive ao reset; grupo não é dividido por falta de vagas sem uma falha tratada; nenhum arraste ou bônus social em treino/testes; Lenda preserva os desbloqueios.

Limites de validação: teleporte real não funciona no playtest do Studio e exige experiência publicada e cliente Roblox. Não houve publicação, migração real, Play ou teste multiplayer nesta tarefa de planejamento.

## 12. Complementos sociais sugeridos, fora do primeiro escopo

- Jogadores recentes e ação de convidar novamente após a partida.
- Permanecer com o grupo ao fim da partida e convite de revanche.
- Favoritos entre amigos e preferências de convite; solicitações podem ser silenciadas.
- Desafios cooperativos por objetivos, restritos a uma etapa futura de Get Out jogável e de Conflict com funções como Médico/Engenheiro; fora do escopo atual, conforme esclarecimento do usuário.
- Cartão público com prestígio, arma favorita e conquistas selecionadas.
- Clãs persistentes podem ser uma etapa posterior, após grupos e matchmaking estarem estáveis; não misturar seu ciclo de vida com o grupo temporário da sessão.

## 13. Fontes de plataforma consultadas

- [Teleporte entre places](https://create.roblox.com/docs/projects/teleport): transporte de vários jogadores, destinos e necessidade de teste fora do Studio.
- [SocialService](https://create.roblox.com/docs/reference/engine/classes/SocialService): convites e leitura de parties da plataforma.
- [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores): armazenamento temporário entre servidores e filas de matchmaking.

Pendências antes de codificar: aprovar tuning final; definir catálogo 1–55 por modalidade, teto/marcos de armas e personalização de Maestria; fechar itens compartilhados/token; fechar capacidade de Arena/Duels e parâmetros operacionais de convite/reconexão. Estes pontos têm propostas no documento, mas não foram todos confirmados pelo usuário.

## 14. Ampliação do estudo: clãs e perfil pessoal

Atualização de 02/11/2026, ainda somente planejamento. O usuário demonstrou interesse em progressão de clãs e leaderboards agregados dos integrantes. Competições entre clãs ficam explicitamente para quando o jogo estiver público e polido. Desafios cooperativos ficam para outras etapas: Get Out ainda não jogável e Conflict com futuras classes como Médico e Engenheiro. A existência desse planejamento não autoriza antecipar esses sistemas.

O perfil pessoal passa a ser uma peça central do desenho: calling card, imagem/avatar com moldura, emblema, título, conquistas selecionadas e apresentação do eliminador. Não é necessário pertencer a um clã para possuir identidade ou evoluir cosmeticamente.

Leituras adicionais locais: `EliminationSpectator.local`, `KillFeedView`, `DamageService`, `ArenaCombat`, `StandingsService`, `CTFMatchStats`, `PreferenceProfile` e os kits atuais. Consulta somente de leitura ao Studio confirmou `EliminationSpectator`, seu estado de espectador ao vivo e a ausência de calling cards nesse script. Não foram encontrados serviços com os nomes `ClanService`, `PlayerIdentityService`, `PlayerProfileService` e `CosmeticService` no contêiner principal consultado; isso não prova ausência de toda implementação equivalente em outras partes do projeto.

## 15. Referências estudadas e aplicação ao Crossgrounds

- Call of Duty combina calling cards conquistados com uma vitrine de até três cartões e insígnias de domínio. A aplicação proposta é distinguir a identidade equipada, vista rapidamente, da coleção de conquistas visitada no perfil completo. Não importar a quantidade de conteúdo ou toda a estrutura de desafios desses jogos.
- Apex distingue molduras, poses e contadores de estatísticas no banner. A aplicação proposta é permitir que a apresentação pessoal valorize diferentes estilos de jogo por meio de contadores e conquistas, sem obrigar todo perfil a exibir apenas eliminações.
- O projeto já separa estatísticas globais, por modo e por round. O perfil precisa identificar claramente a origem e o período de cada número; um contador de carreira não deve parecer uma estatística da partida atual.

## 16. Composição do perfil pessoal

| Elemento | Função proposta | Primeira versão |
|---|---|---|
| Nome e identificação | DisplayName acompanhado de identificação Roblox no perfil completo | Sim |
| Avatar/retrato | Imagem do avatar Roblox; ponto de reconhecimento | Sim |
| Calling card | Arte horizontal de identidade; uma equipada por vez | Sim, estática |
| Moldura | Decoração da imagem do avatar | Sim |
| Emblema pessoal | Símbolo independente da imagem do avatar | Sim |
| Título | Uma expressão conquistada de um catálogo traduzido | Sim |
| Fase e nível reais | Nível, prestígio, Maestria ou Lenda verificáveis | Sim |
| Insígnias | Até três conquistas selecionadas | Sim, quantidade proposta |
| Estatísticas em destaque | Até três contadores escolhidos entre os disponíveis | Sim, quantidade proposta |
| Identidade do clã | Tag, emblema e vínculo ao clã atual | Quando clãs existirem |
| Vitrine | Até três calling cards ou conquistas adicionais | Etapa posterior ao cartão básico |
| Pose/retrato 3D | Apresentação de personagem em cenário controlado | Posterior e opcional |

O emblema de prestígio é separado do emblema pessoal. A personalização permitida pela Maestria pode alterar a arte desse emblema, mas não falsificar a fase real. Títulos de função administrativa dependem da autorização real; não entram como títulos comuns da coleção.

Proposta de coleção inicial contida: uma identidade padrão completa e pequenas famílias de carreira, domínio de arma, modo e prestígio. Cada cosmético informa como foi obtido ou qual requisito falta. Não pressupor loja, caixas aleatórias ou monetização nesta etapa. Arte de itens de coleção usa assets aprovados do projeto; títulos são opções predefinidas e traduzidas.

Contadores sugeridos: vitórias de Arena, capturas de Conflict e domínio de uma arma. Contadores de resgates/fugas ou suporte aparecem somente depois que seus eventos forem implementados e validados. Não reconstruir números históricos que nunca foram registrados. Relações como E/M usam a soma dos numeradores e denominadores, sem somar ou tirar a média simples das razões individuais.

Decisão confirmada pelo usuário: cosméticos de perfil conquistados sobrevivem a prestígio/Maestria, inclusive os liberados inicialmente por nível. Requisitos de nível funcionam como condição de conquista; a propriedade adquirida permanece. Calling cards, molduras, títulos e emblemas pessoais são permanentes. O reset continua afetando os desbloqueios funcionais da conta conforme as regras anteriores.

Tokens de desbloqueio funcional não compram automaticamente troféus, títulos ou cartões de feitos. Proposta: separar o catálogo de equipamento elegível a token do catálogo de reconhecimento, para que um cartão continue comprovando seu feito. A regra final de elegibilidade cosmética do token precisa ser confirmada, pois o pedido original permite escolher qualquer item.

## 17. Um perfil, apresentações por contexto

| Contexto | Conteúdo e comportamento |
|---|---|
| Perfil completo no lobby | Calling card, avatar, moldura, título, fase/nível, estatísticas, insígnias, coleção e clã; ações sociais disponíveis |
| Amigos, jogadores recentes e grupo | Cartão compacto com avatar, moldura, nome, título curto e fase; presença quando disponível |
| Placar da partida | Identidade pequena, priorizando nome, time e números da partida; detalhes ao selecionar |
| Após eliminação | Cartão do eliminador com calling card, avatar/moldura, nome, título, fase/nível, clã e arma que causou a eliminação |
| Resultado/MVP futuro | Cartão completo com conquista ou destaque daquela partida, quando o resultado existir |
| Killfeed | Manter compacto e legível; evitar inserir banners, animações e títulos completos em cada linha |

A preferência privada de tema da interface continua controlando a interface de quem está vendo. A arte pública do cartão pertence à identidade do jogador apresentado. Contraste, tamanho de texto e redução de movimento do observador continuam respeitados. Cartões animados, se entrarem depois, precisam de versão estática e animação discreta, sem flashes ou áudio obrigatório.

O jogador pode escolher quais estatísticas opcionais destacar e ocultar parte do histórico público. A identidade mínima da partida e o resultado autoritativo da eliminação continuam exibidos. Consultar perfil de outra pessoa retorna apenas uma projeção pública; nunca inventário completo, saldo de tokens, preferências de controle ou convites privados.

## 18. Cartão de eliminação integrado ao fluxo existente

Hoje `DamageService` e `ArenaCombat` enviam `CombatFeedback` com `kind="Eliminated"`, personagem da vítima, modelo/nome do eliminador e arma. `EliminationSpectator` mostra legenda e câmera ao vivo até o respawn; o comentário do script explicita que não é replay. O evento não contém ainda o contrato completo de identidade nem um `killerUserId` explícito nesse payload específico.

Proposta: enviar um retrato público da identidade no instante da eliminação, com ID do evento, ID do usuário, apresentação equipada validada pelo servidor, fase/nível, referência de clã e identificação canônica da arma usada. O cartão conserva esses dados mesmo se o eliminador sair, morrer, trocar de equipamento ou editar o perfil em seguida.

Não exigir consultas de DataStore nem carregar uma coleção inteira no momento da morte. Usar projeção pública em cache e carregamento antecipado dos cosméticos equipados. Falha de imagem usa a identidade padrão sem atrasar respawn. O cartão pode aparecer mesmo se o modelo do eliminador já tiver sido removido; a câmera só acompanha um modelo válido.

Morte ambiental ou sem autoria usa apresentação própria, sem inventar um eliminador. Bots usam identificação explícita de IA e arte padrão, sem parecer membros reais de clãs. A apresentação de bots no placar também precisa continuar separada.

Prévia do próprio cartão no editor permite alternar entre perfil completo, lista e eliminação. A apresentação deve limpar corretamente em respawn, troca de modo, menu e nova morte. Não ampliar o período de exposição da câmera adversária nem implementar gravação de killcam como efeito colateral do perfil.

## 19. Clã persistente e sua progressão

Grupo é a formação temporária usada para entrar junto. Clã é uma comunidade persistente, com membros que podem estar em horários e servidores diferentes. Pertencer ao mesmo clã não coloca automaticamente as pessoas no mesmo grupo nem concede outro multiplicador de XP pessoal.

Proposta de primeira versão: um clã por jogador; capacidade igual para todos, com 30 membros como candidato ainda não aprovado; líder, oficiais e membros; nome, tag curta, emblema montado a partir de opções do catálogo, descrição, regras de entrada e histórico básico de gestão. Entrada por convite ou solicitação aprovada. Liderança pode ser transferida; o líder deve transferir antes de sair, ou encerrar o clã se for o último membro. Encerramento conserva o registro histórico do clã.

Nome, tag e descrição são texto criado por usuário e exigem filtragem apropriada no servidor e ao reexibir conteúdo persistido. A primeira versão não precisa de upload livre de imagens, editor de desenho ou chat próprio de clã. Usar os sistemas de comunicação existentes evita criar um segundo canal de texto nesta etapa.

XP de clã proposto: soma das contribuições elegíveis dos integrantes enquanto pertencem ao clã. Não exigir grupo simultâneo para contribuir; isso possibilita progredir em fusos/horários diferentes. Usar XP base elegível de partidas reais, antes de multiplicadores sociais, com bots discriminados e treino excluído. Participação mínima e política de farm seguem as regras do modo. O ganho pessoal continua seguindo a política já planejada.

O nível do clã sobe por XP próprio e não reinicia com prestígio pessoal. Recompensas propostas: fundos de calling card do clã, símbolos, bordas do emblema, paletas e títulos de participação. Evitar dar dano, vida ou outro bônus pessoal de XP por nível de clã na primeira versão. Capacidade de membros não deve crescer como recompensa de nível antes de avaliar o impacto sobre os rankings de soma.

Quem sai não leva o XP do clã consigo, e suas contribuições passadas não são apagadas. O novo clã começa a receber apenas contribuições futuras. Troca de clã nunca transfere o histórico conquistado em outro. Aplicar a associação válida no momento do resultado: a partida captura uma versão de vínculo; sair/trocar antes do término não pode atribuir retroativamente a partida a um novo clã. A política final pode encerrar elegibilidade ao sair ou creditar apenas a participação anterior, mas nunca creditar os mesmos eventos aos dois.

Identidade do clã atual, como tag e brasão, deixa de poder ser usada ao sair. Troféus pessoais já conquistados por participação podem permanecer, identificando sua origem histórica. Proposta: recompensas pessoais de clã exigem contribuição mínima após entrar; ingressar em um clã avançado não concede imediatamente toda a coleção. A exigência precisa de tuning e não foi aprovada.

## 20. Leaderboards agregados: semântica e apresentação

| Visão | Como calcular | Efeito de entrada/saída |
|---|---|---|
| Histórico do elenco atual | Soma dos contadores de carreira dos membros atuais | Recalcula a soma; o passado de quem entra passa a compor essa visão |
| Conquistas do clã | Soma dos resultados elegíveis obtidos durante vínculos válidos | O passado já conquistado permanece; só contribuições futuras mudam de destino |
| Participação individual | Contribuição de cada integrante ao clã no período | Permite reconhecer suporte e contribuição, com período identificado |

Decisão confirmada pelo usuário: as duas primeiras visões têm o mesmo destaque e rótulos próprios. Apresentar histórico do elenco e conquistas do clã como opções de igual hierarquia, sem relegar uma delas a um submenu secundário ou chamar uma de ranking principal. A distinção de cálculo permanece explícita.

Exemplo: uma pessoa entra com 100 mil eliminações de carreira. O histórico do elenco sobe 100 mil; o clã não recebe retrospectivamente 100 mil eliminações conquistadas em seu nome. Se ela obtiver 50 enquanto membro, o histórico do clã recebe essas 50. Ao sair, a visão do elenco remove o histórico dela e a trajetória do clã conserva as 50 válidas.

Somas representam volume e dedicação coletiva; não apresentam uma medida automática de habilidade. Exibir número de integrantes/ativos e período de atualização. Manter métricas por modo, como capturas de Conflict e vitórias de Arena, em vez de somar indiscriminadamente capturas, fugas e eliminações num único placar.

Se quatro integrantes vencem a mesma partida, a soma individual gera quatro vitórias de membros. Rotular dessa forma. Uma vitória de clã por partida exige um resultado coletivo próprio, com regras para membros em equipes adversárias; esse resultado pertence à futura etapa competitiva. Não anunciar quatro partidas vencidas a partir de uma só partida.

Na primeira etapa, ranking regular não pressupõe temporadas com prêmios, ligas ou confrontos marcados. Competições futuras podem usar períodos separados e elenco inscrito, quando houver infraestrutura e regras adequadas. Não criar agora um placar competitivo usando prestígios somados ou pontuação sem semântica definida.

## 21. Infraestrutura adicional necessária

- Identidade pessoal: catálogo por ID estável, propriedade, requisito de conquista, apresentação equipada e projeção pública versionada. A identidade compartilha o proprietário do perfil persistente; `PreferenceProfile` continua sendo preferências de interface/controle, sem virar um segundo inventário de cosméticos.
- Conquistas: eventos autoritativos de partida/arma concedem reconhecimento uma única vez. Uma identidade padrão está sempre disponível. Item removido temporariamente do catálogo recebe fallback visual sem apagar sua propriedade.
- Clã: registro persistente de identidade, membros, permissões, revisão e progresso. A associação do usuário precisa de versão própria e operação recuperável para impedir dupla filiação em servidores concorrentes. Gravações em chaves distintas não formam uma transação única; usar reserva, confirmação e reparação explícitas.
- Resultados: eventos duráveis de contribuição com identificação de partida, usuário e versão de vínculo. Registrar envio pendente e permitir processamento repetido sem somar novamente. Não incrementar clã diretamente em cada tiro ou ler todos os perfis de todos os membros a cada abertura do ranking.
- Agregação: lotes por fim de round ou pontos de confirmação, contribuições rastreáveis e projeções reconstruíveis. Ranking pode ter atraso de atualização informado; indisponibilidade temporária não pode virar pontuação zero definitiva.
- Ranking ordenado: usar OrderedDataStore como índice de pontuação, conservando metadados, histórico e origem num DataStore normal. OrderedDataStore não fornece o mesmo suporte de versionamento/metadados do perfil; não deve ser a única fonte das conquistas do clã.
- Perfil público offline: projeção consultável sob limite/cache, sem carregar estado privado do jogador. Evitar publicar atividade/horário detalhado além do que o sistema social realmente disponibiliza.

Clãs e perfis não exigem desafio cooperativo nem classes novas para existir. O contrato de eventos pode prever extensões futuras sem emitir curas, reparos ou resgates inexistentes. Não implementar Médico/Engenheiro dentro do trabalho de perfil.

## 22. Etapas sugeridas após este estudo

1. Aplicar a permanência cosmética já confirmada e definir o catálogo inicial; inserir identidade no perfil persistente já planejado.
2. Entregar editor/coleção, perfil público e cartão compacto; integrar cartão do eliminador aos dois modos de combate existentes.
3. Integrar jogadores recentes, ações sociais e grupo usando a mesma identidade pública.
4. Entregar clãs, filiação, contribuição comum, nível e leaderboards com semântica explícita, após a persistência de resultados estar confiável.
5. Em outras etapas de gameplay: Get Out jogável e funções Médico/Engenheiro no Conflict; depois avaliar desafios cooperativos próprios desses modos. Arena não recebe esses desafios cooperativos.
6. Somente com jogo público e polido: estudar e implementar competições entre clãs, inscrições, resultados coletivos, reconexão, critérios de empate e recompensas.

Validações futuras materiais: aparência equipada pertence ao usuário; reset preserva cosméticos conforme regra final; trocar nome/avatar não troca autoria; cartão sobrevive à saída do eliminador e desaparece no respawn; bots/ambiente não simulam perfis humanos; clã não duplica contribuição em retry; troca de clã não importa passado nem credita dois destinos; soma do elenco acompanha filiação; ranking indisponível conserva o último estado identificado; texto público passa pela filtragem apropriada.

## 23. Fontes adicionais e limites do estudo

- [Call of Duty — progressão, calling cards e vitrine](https://www.callofduty.com/uk/en/blog/2024/10/call-of-duty-black-ops-6-launch-progression-leveling-prestiging-challenges-intel): referência de categorias, cartões e exibição de conquistas.
- [Apex Legends — FAQ oficial](https://www.ea.com/games/apex-legends/about/frequently-asked-questions): categorias de banner, molduras, poses e contadores.
- [Roblox — Data stores](https://create.roblox.com/docs/cloud-services/data-stores): persistência e diferenças de índices ordenados.
- [Roblox — filtragem de texto](https://create.roblox.com/docs/ui/text-filtering): textos criados por usuário, persistência e apresentação.

Este estudo acrescenta desenho de produto, contratos e dependências. Não foram criados cosméticos, interface funcional, serviço de clãs, gravação em DataStore, testes de Play ou publicação. As propostas de capacidade, recompensas, limites de exibição e marcos continuam sujeitas à definição do usuário.

## 24. Complementos sociais de menor dependência

- Jogadores recentes: registrar participantes humanos realmente encontrados em partidas, com lista limitada, deduplicada e expiração. Oferecer abrir perfil e convidar, sujeitos às permissões; não transformar a lista num histórico público de quem jogou com quem. Não preencher com bots ou fabricar presença online.
- Favoritos: lista privada dentro do Crossgrounds para localizar amigos; não altera automaticamente amizades, favoritos ou configurações da conta Roblox. Reutiliza a identidade pública e as permissões sociais existentes.
- Permanecer juntos: conservar o grupo após resultado e oferecer nova busca pelo líder. Para jogadores sem grupo, convite de formar grupo depende da aceitação de cada um. Não gerar grupo permanente só por terem sido aliados numa rodada.
- Revanche: numa etapa de fluxo de partidas, oferecer nova partida com aceitação dos envolvidos e nova verificação de vagas. Recusar não penaliza progressão; aceitar não garante repetir lado ou mapa. Partidas repetidas continuam submetidas à política de farm.
- Preferências sociais: controlar convites recebidos, avisos e pedidos de entrada. Silenciar convites não exige sair do clã ou remover amigos. A interface distingue indisponibilidade técnica de uma recusa.

Prioridade proposta: perfil/identidade → integração com amigos e jogadores recentes → grupo e permanência após partida → clãs. Revanche depende de ciclo de partidas estável; competições e desafios cooperativos seguem as restrições da seção 22.
