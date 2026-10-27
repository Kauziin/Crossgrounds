# Arena: votação, loadout visual, spawns manuais e iluminação

Aplicado ao Studio Crossgrounds (ALPHA), Place 4375993208, em 26/10/2026.

## Votação e loadout

A votação da Arena e a página de votação do CTF usam `MapVoteGrid`: cartões quadrados com nome, contagem e marca de voto próprio, rolagem e ligações de navegação entre linhas/colunas. O número de colunas acompanha a largura disponível e a escala do menu. O CTF agora envia a escolha individual no snapshot, junto das contagens.

O erro visual do loadout foi corrigido sem mudar a lógica do servidor. `MenuTheme` interpretava cores de botão inativo como cor de seleção; o próprio tom neutro podia entrar nessa conversão. A paleta neutra agora é reconhecida e a página de loadout destaca uma única opção: a pendente, quando existe, ou a ativa. Trocas continuam valendo no próximo nascimento, como antes. As alterações experimentais de lógica feitas antes da explicação do usuário foram revertidas.

O piso adicional `AFKPlatform` deixou de ser criado pelo HubScene. Se houver uma cópia antiga no hub pertencente ao Crossgrounds, Ensure a retira. A região AFK, o acesso e o piso nativo do cenário continuam; o piso geral do protótipo antigo não foi confundido com a plataforma AFK.

## Spawns reconstruídos

As posições foram escolhidas explicitamente após inspeção por vistas superiores, oblíquas e de detalhe, leitura das superfícies e conferência de colisões/conexões. Nenhuma busca automática em grade escolheu os pontos finais. Raycasts serviram para conferir a altura das superfícies nos pontos escolhidos; pontos bloqueados ou sem conexão confirmada foram retirados.

| Mapa | Antes no template | Agora | Distribuição |
|---|---:|---:|---|
| Assault | 24 | 27 | Plataformas da estação, rua central/sul, pátio norte e passagens da cidade |
| Beach / Praia | 24 | 26 | Areia, orla, praça, alameda e frente das lojas, dentro dos bloqueios do mapa |
| Factory | 65 | 15 | Pátio interno e canais entre a cobertura; sem o corredor sem conexão confirmada com esse conjunto |
| Glacier | 24 | 24 | Plataformas de gelo e platô superior; sem blocos afastados, teto invisível ou o ponto isolado na caverna |

Em Praia, os pontos anteriores estavam sobre `Clip`, com topo em Y=80; a área de circulação examinada fica perto de Y=-149. Em Glacier, os pontos estavam sobre o teto invisível `MapBounds`, também em Y=80, enquanto as plataformas/platô ficam perto de Y=-167/-142. A existência de piso invisível não foi aceita como prova de área jogável. Em Assault, foram evitadas paredes de clip, carros e volumes de prédios fechados. Em Factory, a área de spawn foi limitada ao pátio que teve conexão confirmada.

Os 92 marcadores têm orientação cardinal definida, SpawnRole=Player, SpawnZone e data de revisão. As listas explícitas estão em `ServerStorage.Development.Tools.ArenaManualSpawns` e em sua fonte local. O plano de queda de Glacier foi elevado para Y=-184, abaixo das áreas de circulação e acima da posição em que o personagem ficaria apoiado na superfície de DeathWater.

## Edição e reimportação

- Templates usados pelo jogo: `ServerStorage.CrossgroundsMaps.Arena.<id>.Spawns`.
- Cópias visíveis: `Workspace.ArenaSpawnEditor.<id>.Spawns`.
- Originais: `ServerStorage.Development.MapSources.Arena.<nome>.AuthoredSpawns`, com as coordenadas convertidas de volta ao espaço do original.
- O importador prioriza AuthoredSpawns quando presente, confere cada marcador e recusa a importação se um ponto estiver inválido. Não substitui silenciosamente esses pontos pelo gerador automático.
- ArenaSpawnEditor.Apply também atualiza AuthoredSpawns e as regiões do original nesses quatro mapas. Assim, edições posteriores salvas pelo editor acompanham futuras importações.
- Os marcadores dos outros onze mapas não foram regravados.

As cópias de Praia e Glacier foram elevadas 400 studs **somente na área de edição**, para facilitar a inspeção de cenários com piso abaixo de zero. EditorOffset registra essa diferença e Apply a compensa. Os templates do jogo mantêm suas posições. Malhas de água expansivas e overlays de água receberam limites visuais nas cópias de edição para reduzir interferência entre os cenários; isso não altera a geometria dos templates.

As versões anteriores de spawns/regiões ficam em `Development.Revisions.Maps`, com RevisionType=SpawnsOnly, além do arquivo externo before.rbxm. ArenaManualSpawns.Apply é uma operação manual que restaura a lista desta revisão; não a execute sobre novas edições sem a intenção de substituí-las.

## Iluminação por mapa

| Mapa | Horário | Direção |
|---|---:|---|
| Praia | 10h | Manhã clara, luz levemente quente e atmosfera azul |
| Assault | 14h | Tarde clara, sombras mais definidas e atmosfera neutra |
| Glacier | 18h | Anoitecer, céu com tons rosados e preenchimento frio para manter leitura do gelo |

Os perfis ficam em `ReplicatedStorage.Crossgrounds.MapLightingProfiles`. ClockTime, brilho, luz ambiente, exposição, sombras e atmosfera são aplicados pelo cliente, com transição curta. A iluminação global do servidor não foi trocada; jogadores no lobby, CTF ou outro modo mantêm seu ambiente. Ao sair do mapa, o cliente restaura os valores capturados antes do perfil. Factory e mapas sem perfil usam esses valores padrão.

As prévias de fotografia do admin informam o perfil do mapa escolhido ao mesmo controlador local. Os originais e templates guardam LightingProfile para preservar a configuração na reimportação.

## Verificação

- 13 fontes compiladas no Studio.
- Alterações concomitantes das abas de remapeamento encontradas em ExperienceMenu foram preservadas na cópia local; não foram substituídas pelo snapshot anterior desta tarefa.
- Teste isolado com seis botões: somente o selecionado permaneceu com a cor de seleção.
- Medidas do grid conferidas em larguras de 220 a 900 pixels; células quadradas, com troca de colunas conforme o espaço.
- 92/92 marcadores com apoio, clearance de 4 × 5,5 × 4 studs, saídas em mais de uma direção e transformação coerente entre editor/template.
- 92/92 marcadores no conjunto conectado ao ponto de referência do próprio mapa, por busca no navmesh com raio de agente 1,5, altura 5,5, salto e escalada habilitados. Para a referência, a busca de comprimento zero foi dispensada. Isso não comprova comportamento de avatares extremos ou vantagem competitiva dos pontos.
- Três conjuntos de propriedades de Lighting/Atmosphere aceitos pelo TweenService; sete verificações isoladas de seleção de perfil, troca e restauração passaram. O ClockTime global permaneceu em 14.
- Os quatro mapas e a configuração de horário foram conferidos no DataModel Edit. Houve uma breve entrada/saída de Play durante o trabalho, iniciada pelo usuário; o agente não conduziu uma rodada ou interrompeu essa sessão. Verificação visual da UI em aparelhos reais, leitura do anoitecer em jogo e balanceamento dos spawns permanecem para playtest.

Arquivos e hashes: [manifesto de recuperação](../artifacts/arena-manual-spawns-2026-10-26/MANIFEST.md).
