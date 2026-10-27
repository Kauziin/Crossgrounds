# CROSSGROUNDS — Documento de Design

> **Documento vivo | Versão 0.4 | 22/10/2026**  
> **Estado:** base local com CTF e Arena de testes; integração publicada entre Places e validação em dispositivos reais pendentes.  
> **Convenção:** **[DEFINIDO]** é uma decisão expressa pelo criador; **[PROPOSTO]** é uma sugestão ainda não aprovada; **[PENDENTE]** requer definição ou teste.  
> Este documento reúne as informações estabelecidas nas conversas até a data acima. Ele não implica que os sistemas já foram desenvolvidos.

---

## 1. Visão geral

**[DEFINIDO]** Desenvolver uma **única experiência Roblox no formato de hub de jogos multiplayer**, inspirada em três referências distintas:

- **Flee the Facility** → modalidade provisoriamente chamada **Get Out**, voltada à perseguição, fuga e objetivos cooperativos.
- **Murderers VS Sheriffs DUELS (MVSD)** → modalidade **Duels**, voltada a duelos e confrontos com pistola, faca e habilidades.
- **Pistol Arena** → modalidade **Arena**, voltada a combate direto, reaparecimento frequente e movimentação.

**[DEFINIDO]** O projeto não deve se limitar à reprodução dos três jogos: terá modos alternativos, mais mapas, mais habilidades e eventualmente novos jogos dentro do hub. Cada modalidade conserva sua própria identidade.

**Motivação pessoal [DEFINIDO]:** propor variedade de experiências para jogar, especialmente com a irmã do criador, que costuma jogar as três referências. O objetivo é introduzir outros estilos sem perder a familiaridade dos jogos originais.

**Público/dispositivos [DEFINIDO]:** atenção explícita à acessibilidade para jogadores de **controle**, além de compatibilidade com PC e celular. O criador joga com controle; suporte a gamepad não deve ser adaptação tardia.

**[DEFINIDO]** Nome do projeto: **Crossgrounds**.

**[PENDENTE]** Identidade visual, economia, progressão, modelos de monetização, limite geral de jogadores por servidor, arquitetura final em Places e cronograma.

## 2. Terminologia e hierarquia

**[PROPOSTO]** Terminologia para organizar o projeto:

1. **Hub / Experiência:** a aplicação Roblox e os sistemas globais.
2. **Modalidade:** Get Out, Duels, Arena e, opcionalmente, Capture a Bandeira.
3. **Modo/Variante:** Clássico, Mutação, Infestação, Juggernaut, Confronto, Epidemia etc.
4. **Modificador:** restrição transversal de regras, por exemplo somente faca ou somente revólver (*Only X*).

A terminologia é organizacional, não foi formalmente aprovada. Os nomes **Get Out** e **Only X** são provisórios ou descritivos conforme a conversa.

## 3. Catálogo consolidado

| Modalidade | Variante | Jogadores | Estado | Característica |
|---|---|---:|---|---|
| Get Out | Clássico | **[PENDENTE]** (referência original: até 5) | Definido conceitualmente | Sobreviventes cumprem objetivos e escapam; nova condição de aprisionar a Besta |
| Get Out | Mutação | **7** (6 sobreviventes + 1 Besta) | Definido conceitualmente | Besta mutante com todos os poderes; cura por antídoto ou fuga |
| Get Out | Infestação | **5** | Definido conceitualmente | Cápsulas convertem sobreviventes em Bestas; sobreviventes restantes ganham vantagens |
| Get Out | Juggernaut | **9** (1 Exorcista + 8 Bestas) | Definido conceitualmente | Inversão da caçada: Exorcista persegue Bestas |
| Duels | Clássico | 2, 4, 6 ou 8 (1v1 a 4v4 de referência) | Definido conceitualmente | Pistola e faca, duas habilidades por jogador |
| Duels | Contra-Todos | **3 a 8** | Definido conceitualmente | Disputa individual por vitórias em rodadas |
| Duels | Confronto | **16** (8v8) | Definido conceitualmente | Confronto de grandes equipes, mapa fecha progressivamente |
| Duels | Epidemia | **8 a 12** | Definido conceitualmente | Um infectado inicial tenta converter os xerifes; combate com vida |
| Duels | Only X | Conforme modo hospedeiro | Modificador/família de variantes | Somente faca ou somente revólver |
| Arena | Clássico | **[PENDENTE]** (intenção: lotação padronizada entre variantes) | Definido conceitualmente | Todos contra todos, 1 acerto = eliminação, equipamento de atributos iguais |
| Arena | Mata-Mata em Equipe | Mesma lotação-alvo de Arena [a confirmar] | Definido conceitualmente | Equipes competem por eliminações |
| Arena | Alternativas com vida/dano | Mesma lotação-alvo de Arena [a confirmar] | Intenção definida; variantes a detalhar | Armas não são obrigatoriamente letais em um tiro |
| Capture a Bandeira | Protótipo integrado local: Clássico 6v6 incluindo bots | **12 (6 por lado; estado atual do CTF)** | Primeiro módulo adaptado e exercitado no Studio; lançamento público no hub ainda opcional | Captura, devolução e entrega de bandeiras; kits, armas e bots |

> **Nota:** o total de **5, 7 e 9** jogadores nos modos especiais de Get Out é central para o problema de matchmaking. Não tratar essas capacidades como intercambiáveis.

---

## 4. Get Out

### 4.1 Clássico

**[DEFINIDO]** Inspiração em Flee the Facility: Besta contra sobreviventes, perseguição, hackeamento de computadores, captura e fuga.

**[DEFINIDO]** Não existirão empates. As condições de desfecho previstas são:

- Sobrevivente escapa da instalação.
- Sobreviventes conseguem **aprisionar a Besta** (novo final alternativo; condições específicas pendentes).
- Sobrevivente é capturado.
- Tempo expira: a Besta enlouquece e elimina os jogadores que continuam dentro da instalação.

**[PENDENTE]** Definir número final do modo clássico, regras de aprisionamento da Besta, tratamento de desconexões, estados individuais e coletivos no final de uma partida, temporizações e mapa.

### 4.2 Mutação — 7 jogadores

**[DEFINIDO]** Seis sobreviventes contra uma **Besta mutante**, que tem **todos os poderes simultaneamente** e velocidade superior à habitual.

**[DEFINIDO]** Sobreviventes podem seguir duas estratégias:

1. Hackear computadores **mais vulneráveis** e fugir.
2. Vasculhar a instalação, reunir componentes e criar um **antídoto** capaz de parar a Besta.

**[PENDENTE]** Detalhes do sistema de vasculhamento, composição/uso do antídoto, significado técnico de computadores "mais vulneráveis", velocidade da Besta e balanceamento da dupla condição de vitória.

### 4.3 Infestação — 5 jogadores

**[DEFINIDO]** Cápsulas especiais modificam o DNA dos sobreviventes capturados, convertendo-os em novas Bestas. As Bestas convertidas começam com a classe de corrida padrão.

**[DEFINIDO]** À medida que os sobreviventes perdem parceiros, os restantes recebem habilidades progressivas. Ideias expressamente citadas:

- Habilidade de corrida da Besta.
- Ping periódico que revela a localização das Bestas.
- Dispositivo que altera o hackeamento e amplia significativamente a área do teste de reflexo dos computadores.

**[PENDENTE — REDAÇÃO AMBÍGUA]** A descrição original do dispositivo diz que ele "diminui a velocidade de hackeamento" e aumenta a área do teste; é necessário confirmar se a intenção é **reduzir o tempo de hackear** (bônus) ou **reduzir a velocidade** (penalidade). Não presumir uma das interpretações.

**[PENDENTE]** Limiar de aquisição de cada habilidade, condições de vitória, limite de infecções, possibilidade de reversão e estratégias para o sobrevivente final.

### 4.4 Juggernaut — 9 jogadores

**[DEFINIDO]** Uma unidade governamental especial, o **Exorcista**, é enviada para eliminar as Bestas. Um Exorcista enfrenta oito Bestas.

**[DEFINIDO]** A dinâmica de perseguição é invertida: o Exorcista é o caçador, equipado com **arma de purificação**; as Bestas usam suas armas para detê-lo e sobreviver.

**[PENDENTE]** Atributos e armas das Bestas, condições exatas de vitória, duração, efeitos da purificação, possibilidade de cooperação entre Bestas e balanceamento de 1v8.

---

## 5. Duels

### 5.1 Regras gerais

**[DEFINIDO]** Jogadores usam **pistola e faca**. Cada jogador equipa **duas habilidades simultâneas**; a combinação usual é uma ativa e uma passiva. Haverá mais habilidades e principalmente **mais mapas** do que na referência.

**[PENDENTE]** Categorias obrigatórias ou flexíveis, sistema de obtenção, recargas, parâmetros das armas, duração das rodadas, pontuação e configuração de matchmaking por tamanho de equipe.

### 5.2 Contra-Todos

**[DEFINIDO]** Entre **3 e 8 jogadores** competem entre si em rodadas; vence quem atingir o objetivo de vitórias da partida. Quantidade de rodadas diferente do clássico.

**[PENDENTE]** Número exato de rodadas/vitórias, desempates, tratamento de eliminação simultânea e distribuição de spawns.

### 5.3 Confronto

**[DEFINIDO]** Partidas **8v8**, com mais rodadas do que os duelos convencionais, **penalização de camperagem** e **limitação progressiva da área do mapa** com o tempo.

**[PENDENTE]** Critério de detecção/penalização de camperagem, como o mapa se fecha, mapas exclusivos ou adaptados, e duração de rodadas para não gerar longa espera dos eliminados.

### 5.4 Epidemia

**[DEFINIDO]** **8–12 jogadores**. Um deles é infectado com um vírus zumbi. A modalidade usa **vida**, abandonando a eliminação em um único acerto.

**[DEFINIDO]** O zumbi inicial suporta o equivalente a **até 5 tiros**. Para infectar um xerife, precisa de **dois ataques corpo a corpo**. O objetivo dos infectados é converter todos antes de serem eliminados pelos xerifes.

**[PENDENTE]** Valores exatos de vida/dano, se todos os zumbis têm a mesma resistência, respawn, condições de vitória por tempo e comportamento com grande número de infectados.

### 5.5 Only X

**[DEFINIDO]** Família de regras com restrições de armas: **somente faca** ou **somente revólver**.

**[PROPOSTO]** Tratar como modificador aplicável a vários formatos de duelo, em vez de necessariamente criar filas próprias.

---

## 6. Arena

### 6.1 Clássico

**[DEFINIDO]** Referência de ritmo: **Shipment, de Call of Duty: Modern Warfare III**. Jogador aparece, entra em combate, é eliminado e reaparece em sequência rápida.

**[DEFINIDO]** Em Arena Clássico, pistolas/armas têm os **mesmos atributos de combate**; um acerto elimina. Resultado depende principalmente de habilidade, decisões instantâneas e sorte contextual — não de vantagem estatística do equipamento.

**[DEFINIDO]** O sistema de respawn da referência é considerado ruim e **não deve ser copiado sem melhoria**.

**[PENDENTE]** Lotação definitiva, mapas, seleção/visual das armas, regras de proteção de spawn, cadência do reaparecimento e sistema de pontuação.

### 6.2 Variantes

- **Mata-Mata em Equipe [DEFINIDO]:** times competem por eliminações.
- **Modos com armas não letais em um tiro [DEFINIDO COMO INTENÇÃO]:** variantes com vida/dano e dinâmica diferente do clássico; regras específicas pendentes.

**[DEFINIDO]** Arena é a modalidade mais simples de agrupar: a intenção é que suas variantes trabalhem com **mesma capacidade de jogadores**. Assim, pode-se formar um **lobby único de Arena** e **votar no modo** depois de encontrar a sala, sem excesso ou falta de participantes por causa da escolha.

**[PENDENTE]** Confirmar a capacidade numérica igual e como se comportam equipes quando a quantidade presente for ímpar ou incompleta.

---

## 7. Capture a Bandeira (CTF) — primeiro módulo integrado localmente

**[DEFINIDO EM 22/10/2026]** O protótipo existente de Capture a Bandeira servirá de **primeira modalidade técnica integrada ao Crossgrounds**. Isso **não obriga** que CTF integre o catálogo do lançamento público: a prioridade é aproveitar a base real e validar a arquitetura do hub.

**[FONTE: `ESTADO-DO-DESENVOLVIMENTO.md`, 22/10/2026]** Projeto legado `[SENTINELAS!]Capture a Bandeira!(BETA)`, Place ID `4375993208`, workspace original `C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio`. O relatório descreve código e instâncias inspecionadas em Studio, **não** atesta a versão publicada nem uma sessão nova de Play Test.

### 7.1 Sistemas existentes no protótipo (não reimplementar sem necessidade)

- **Objetivos:** roubar, carregar, largar, recuperar e entregar bandeiras; placar funcional.
- **Partida:** 5 minutos, vitória com 3 capturas e preparação de 8 segundos.
- **Equipes:** Azul e Vermelho; máximo operacional atual de 6 participantes em cada lado, completando vagas com bots.
- **Spawns:** 24 por equipe, escolha por segurança/ocupação e proteção temporária.
- **Combate:** 200 HP, munição, recarga, cadência, queda de dano e ataques corpo a corpo.
- **Kits:** leve, regular, pesado; atributos e armas conforme o relatório original, sem recalibrar durante a migração.
- **Câmeras/ações:** terceira pessoa por ombro, primeira pessoa, Shift Lock, mira, corrida, HUD e remapeamento.
- **Menus:** seleção de kits, preferências, votação, retorno ao lobby; navegação por controle com cursor dedicado, D-pad e ícones por plataforma.
- **Bots:** papéis e objetivos, combate, pathfinding e preenchimento de equipes.
- **Mapa:** `riverside` / Travessia; catálogo já existe em `ServerStorage.CTFMaps`, mas atualmente há somente esse mapa.
- **Persistência de preferências:** DataStore em ambientes publicados e sessão temporária nos testes do Studio.

### 7.2 Lacunas confirmadas ou pendentes no legado

- Empunhadura de duas mãos e animações dedicadas de combate incompletas.
- Primeira pessoa com braços/peças rígidas e efeitos ainda provisórios.
- Bots sem percepção/movimento suficientemente naturais e **acoplados às coordenadas do mapa Travessia** (`X = ±32/±42`, `Y = 41`, `Z = -70/0/70`). Novos mapas exigem navegação por dados de mapa ou outra estratégia de objetivos.
- Sons de interface, eventos de bandeira e apresentação detalhada ainda incompletos.
- Acessibilidade expandida e validação em gamepads físicos e consoles pendentes.
- Testes longos com clientes reais, desempenho, latência, assets publicados e persistência de produção pendentes.
- Os equipamentos são `Tool` do Roblox, embora inventário e HUD próprios ocultem a mochila; não alegar que foram completamente migrados.

### 7.3 Expansão futura de CTF

**[INTENÇÃO ANTERIOR]** Mais equipes, mapas de maior escala e direção possivelmente mais militar são possibilidades posteriores, **não** requisitos da primeira migração. Preservar primeiro o 6v6 existente.

### 7.4 Regra de migração

**[PROPOSTO COMO ESTRATÉGIA]** Separar a entrada, o ciclo de vida e a interface de navegação do hub das regras exclusivas do CTF. Migrar por etapas, com comportamento legado preservado, testes locais e nenhum ato de publicação/remoção sem autorização do criador. Consultar `CROSSGROUNDS-CODEX-MIGRACAO.md`.

**[IMPLEMENTADO LOCALMENTE, v0.3]** Bootstrap, catálogo e CTFAdapter já aplicam essa separação no protótipo integrado. Preparação CTF e retorno ao Crossgrounds possuem ações distintas. O loop global do CTF permanece inicializado no mesmo servidor; a saída limpa a participação e apresentação do jogador. A divisão em Places, o teleporte publicado e o descarregamento integral de jogos continuam pendentes. Resultados reais e limites estão na seção 14.

---

## 8. Matchmaking, lobby e votação

### 8.1 Princípios

**[DEFINIDO]** As partidas usarão **votação**. A quantidade de filas deve ser controlada para não pulverizar jogadores entre muitos modos pouco populados.

**[DEFINIDO]** Não é aceitável montar um lobby com mais pessoas do que o modo eleito comporta e **expulsar participantes** para acomodar a escolha.

### 8.2 Arena — solução conceitual estabelecida

1. Jogador entra na **fila geral de Arena**.
2. O matchmaking reúne os participantes para uma sala com a capacidade comum das variantes.
3. Depois da formação do lobby, os participantes **votam no modo**.
4. O modo escolhido começa com os mesmos jogadores, sem precisar retirar participantes por incompatibilidade de lotação.

**[PENDENTE]** Votação de mapas: junto ou após a votação de modalidade; regras de abstenção, empate na votação e reconexões.

### 8.3 Get Out — separação definida

**[DEFINIDO]** Dividir a entrada em duas categorias:

- **Get Out Clássico**.
- **Get Out Especial** — agrega Mutação, Infestação e Juggernaut.

**Dificuldade central [DEFINIDO]:** modos especiais exigem **5, 7 ou 9 jogadores**. Se nove forem reunidos primeiro, votar em um modo para cinco ou sete criaria participantes excedentes. Se cinco forem reunidos, não se pode oferecer imediatamente um modo que exige nove.

### 8.4 Caminhos possíveis — nenhum aprovado

**[PROPOSTO A — pré-votação com lotação determinada depois]:**

1. Jogadores entram em uma **fila compartilhada de Get Out Especial**.
2. Um grupo inicial de participantes **vota antes de a partida ser fechada**.
3. A opção vencedora determina a **capacidade exata** de participantes (5, 7 ou 9).
4. O sistema completa apenas os lugares necessários **antes de iniciar** a partida.
5. Demais jogadores continuam na fila para outra sala, sem serem expulsos de uma partida na qual já ingressaram.

**Trade-offs a resolver:** tamanho do grupo inicial de votantes, direito de voto de quem entra depois, o que fazer se faltar gente para completar uma partida de nove, tempo máximo de espera e efeito de grupos de amigos.

**[PROPOSTO B — rotação/programação]:** a fila Especial escolhe a variante da próxima sessão **antes** de alocar os participantes; o matchmaking busca a capacidade necessária. Uma votação pode selecionar mapas/modificadores, mas a modalidade principal não depende da lotação já fechada.

**[PROPOSTO C — preferências na fila]:** jogadores indicam modos especiais aceitáveis ou preferidos; o agrupador forma sessões viáveis sem separar necessariamente três filas fixas. Requer política para lidar com preferências incompatíveis e modos raros.

**[PENDENTE — DECISÃO ARQUITETURAL PRIORITÁRIA]** Selecionar o método de matchmaking de Get Out Especial. Evitar determinar uma solução só porque ela é tecnicamente fácil; avaliar votação real, tempo de espera, grupos e capacidade.

### 8.5 Duels — aberto

**[PENDENTE]** Formato das filas e da votação com capacidades **2, 4, 6, 8, 16 e 8–12**, dependendo da variante. Mesma dificuldade estrutural de Get Out, ampliada por equipes. Não assumir a solução de Arena para Duels.

### 8.6 CTF — comportamento existente, fila do Crossgrounds a decidir

**[ESTADO ATUAL]** O protótipo preenche equipes Azul/Vermelha até seis por lado com bots. Isso não significa que já possua matchmaking entre servidores do Crossgrounds. **[PROPOSTO]** Utilizar o CTF como primeiro teste ponta a ponta de catálogo, lobby, prontidão, sessão, votação de mapas e retorno; manter a regra 6v6 com bots sem impor tal regra aos outros modos.

---

## 9. Sistemas compartilhados possíveis

A reutilização é uma **direção arquitetural [PROPOSTA]**. Alguns desses recursos possuem implementações dentro do CTF, mas **ainda não são serviços globais do Crossgrounds**:

- **Estados de partida e vitória:** inicialização, contagem, término, resultados individuais e coletivos.
- **Papéis e equipes:** Besta, sobrevivente, Exorcista, xerife, infectado, equipes de Arena, etc.
- **Combate:** danos, armamentos, projéteis, validação de acertos e efeitos.
- **Habilidades:** duas equipáveis em Duels; kits distintos para Get Out; limitações por modo.
- **Efeitos temporários e de estado:** congelamento, infecção, purificação, lentidão, revelação, aumento de velocidade.
- **Interação e objetivos:** hackear, abrir/fechar, vasculhar, fabricar antídoto, capturar, ativar.
- **Mapas:** seleção, votação, spawn e eventos ambientais por modo.
- **Movimentação:** correr, deslizar e outras capacidades conforme o modo; configurações por modalidade.
- **Espectador, placares, grupos, estatísticas e progressão:** regras específicas e apresentação consistente no hub.
- **Spawn inteligente:** verificar proximidade de inimigos, linha de visão, recentes mortes e proteção de reaparecimento, especialmente em Arena.

### Controle e acessibilidade — requisito de primeira ordem

**[DEFINIDO]** O projeto precisa ser agradável no controle, não apenas jogável.

**[PROPOSTO]** Concentrar em um sistema de ações: duas habilidades sem excesso de combinações, menus navegáveis por foco, botões contextuais, indicadores visuais claros, sensibilidade configurável e feedback adequado a consoles. Planejar também toque e teclado/mouse.

**[PENDENTE]** Layout definitivo, assistência de mira e equilíbrio competitivo entre dispositivos, câmera e HUD adaptativo.

## 10. Identidade, prioridades e riscos

### Identidade por modalidade

- **Get Out:** tensão, fuga, perseguição e resultados alternativos.
- **Duels:** confronto técnico, domínio de armas e habilidades.
- **Arena:** combate imediato e reaparecimento recorrente.
- **CTF (eventual):** objetivo territorial em mapas amplos, potencialmente militar.

### Riscos identificados

1. **Fragmentação das filas**, especialmente em modos de capacidades diferentes.
2. **Tempos de espera e falta de jogadores**, caso modos de 9, 12 ou 16 não encham.
3. **Balanceamento assimétrico** (Mutação, Infestação, Juggernaut e Epidemia).
4. **Esperas excessivas após eliminação** em Confronto 8v8.
5. **Spawns injustos** na Arena, problema identificado na referência.
6. **Suporte a controle adicionado tarde demais**.
7. **Escopo amplo**: muitos modos sem infraestrutura compartilhada podem atrasar tudo.

### Direções técnicas ainda não decididas

**[PENDENTE]** Arquitetura final de Places, estratégia de servidores reservados, persistência de dados, matchmaking entre servidores, telemetria e segurança de RemoteEvents. **[PROPOSTO PARA A PRIMEIRA IMPLEMENTAÇÃO]** Separar `Hub` e `CTF` como Places na mesma experiência, desde que a criação/associação de Places seja confirmada no Studio/Creator Dashboard; preservar intacto o Place legado até validação.

**[FATO TÉCNICO]** Teleporte real entre Places não funciona em Play Test do Studio; exigir testes no cliente Roblox publicado, e usar simulação local explicitamente identificada para testes isolados. Não publicar automaticamente a experiência antiga.

**[PROPOSTO]** Independente da arquitetura escolhida, o servidor deve validar danos, acertos, habilidades, progresso e condições de vitória. Não usar o cliente como autoridade para resultados competitivos.

---

## 11. Questões abertas para futuras decisões

- Identidade visual do **Crossgrounds** (nome já definido).
- Get Out Clássico terá exatamente cinco jogadores? Qual a distribuição inicial?
- Como funciona, passo a passo, **prender a Besta**?
- Como é obtido e aplicado o **antídoto** em Mutação?
- No dispositivo de Infestação, deve-se **reduzir o tempo** ou **reduzir a velocidade** de hackeamento?
- Quais habilidades entram no lançamento do Duels? Como combinar ativa/passiva?
- Qual lote mínimo e máximo de jogadores para cada fila pública de Duels?
- Como escolher os modos de **Get Out Especial** sem remover participantes?
- Arena terá quantos jogadores por sala? Como funcionam respawn e spawn seguro?
- CTF entrará no lançamento público ou continuará como primeiro módulo/protótipo técnico?
- Como serão mapas, HUD e navegação com gamepad? Quais módulos do CTF podem ser compartilhados sem alterar seu comportamento?
- Que sistemas de progressão devem ser globais e quais pertencem a cada modalidade?

---

## 12. Referências de inspiração

Páginas Roblox citadas na pesquisa anterior; servem para orientar estudo, não para copiar assets, interfaces ou marcas:

- [Flee the Facility — Roblox](https://www.roblox.com/games/893973440/Flee-the-Facility)
- [Murderers VS Sheriffs DUELS — Roblox](https://www.roblox.com/games/12355337193/Murderers-VS-Sheriffs-DUELS)
- [Pistol Arena — Roblox](https://www.roblox.com/games/87018676608089/Pistol-Arena)

---

## 13. Histórico de decisões

### 22/10/2026 — Primeira base técnica local (v0.3)
 
> Etapa posterior v0.4: o criador autorizou Arena como próximo protótipo para testar o hub, com mapas prontos e votação. Regras definitivas e lotação permanecem pendentes.

- Catálogo, fluxo de entrada/saída e CTFAdapter implementados no projeto existente, sem publicação.
- Protótipo integrado explicitamente local; divisão final de Places ainda pendente.
- Preservadas as regras do CTF e as decisões abertas dos outros jogos.
- Testes e limites registrados na seção 14 e no relatório de implementação.

### 22/10/2026 — Integração com legado do CTF (v0.2)

- **Crossgrounds** aprovado como nome oficial.
- Arquivo `ESTADO-DO-DESENVOLVIMENTO.md` analisado: CTF é protótipo funcional, não apenas tentativa incompleta.
- CTF escolhido como **primeiro módulo a adaptar à base do hub**, com lançamento público ainda opcional.
- Registrados Place ID e workspace do legado, mecanismos implementados, débitos técnicos e testes pendentes.
- Proposta inicial de arquitetura Hub + CTF em Places distintos, sem converter em decisão definitiva.
- Instrução técnica para o Codex definida em `CROSSGROUNDS-CODEX-MIGRACAO.md`.

### 22/10/2026 — Documento inicial (v0.1)

- Projeto estabelecido como **hub com três modalidades centrais**.
- Consolidados Get Out, Duels, Arena e as variantes especificadas.
- Marcado **CTF independente como opcional**, com possibilidade de múltiplas equipes e abordagem militar.
- Registrado suporte a **controle como prioridade**.
- Registrado que **Arena usa fila geral e votação após montar lobby**, pretendendo mesma capacidade entre variantes.
- Registrada a divisão **Get Out Clássico / Get Out Especial**.
- Documentado impasse entre **5 / 7 / 9 jogadores** em Get Out Especial, com propostas sem decisão definitiva.
- Registrada motivação de proporcionar novas experiências de jogo à irmã do criador.
- Registradas questões pendentes sem convertê-las em decisões.

---


## 14. Estado da primeira base técnica — 22/10/2026 (v0.3)

Esta seção registra implementação e testes; não transforma propostas de regras ou de lançamento em decisões do criador.

### [IMPLEMENTADO LOCALMENTE]

- Núcleo com catálogo, bootstrap, coordenação de ingresso, provedor local de solicitações, adaptador de preferências e preparação de TravelService.
- CTF integrado como único protótipo jogável. Get Out, Duels e Arena aparecem como planejados e sem entrada/fila; nenhuma capacidade indefinida foi inventada.
- Tela Crossgrounds navegável por foco, controle simulado, teclado e mouse; componentes usam Activated para toque. Ajustes existentes compartilhados, incluindo FOV e remapeamento.
- Área provisória isolada em (900, 80, 340), sem mover o mapa Travessia ou regenerar terreno.
- Fluxo local: catálogo → preparar → confirmar → preparação CTF → kit/partida. Cancelamento antes da entrada e retorno explícito ao Crossgrounds.
- Preparação/treino CTF e hub Crossgrounds têm destinos distintos. A votação de mapas continua exclusiva do CTF.
- Limpeza da participação, ferramentas, voto, transporte de bandeira e apresentação do jogador ao sair; GameManager/equipes globais permanecem inicializados e ociosos no protótipo integrado.
- Preservadas regras e definições do CTF: 200 HP, duas equipes de seis incluindo bots, 300 s, três capturas, oito segundos de preparação, três kits e 24 spawns por lado.
- Fontes aplicadas no Studio e em src/: 58 arquivos iguais na conferência final; 56 transformações/tamanhos das bases inalterados.

### [TESTADO NO STUDIO]

- Entrada/cancelamento/retorno, três ciclos repetidos e recusa de modalidade planejada/ticket inválido/Place ID enviado pelo cliente.
- Partida com um humano e 11 bots; coleta, transporte, queda por morte, recuperação e vitória após três entregas.
- Disparo com dano no servidor, reposição de munição, HUD, primeira pessoa e restauração de câmera na saída.
- Ajustes por controle simulado, FOV pelo D-pad, mouse de PC e navegação de teclado.
- Simulação visual de Xbox One e iPhone 17 Pro em paisagem. Toque físico não validado; clique sintético de ajustes falhou nessa simulação de celular.
- Papel hub isolado com spawn/respawn e sem iniciar CTF.
- 25 testes automatizados de catálogo, protocolo, provedor local e TravelService com dependências simuladas, todos aprovados.

### [PROPOSTO / PREPARADO, NÃO ATIVADO]

A organização final em Places separados da mesma experiência continua proposta. A consulta real encontrou somente o Place 4375993208 no Universe 1404405130. A implementação usa combinedPrototype explicitamente local; não é fila ou teleporte de produção.

TravelService tem validação de destino/Universe e tratamento de falhas, mas TeleportEnabled=false, HubPlaceId/CTFPlaceId/ApprovedUniverseId não estão preenchidos. Nenhum Place novo foi criado, publicado ou liberado para acesso privado.

Para futuros mapas, permanece proposta a substituição das coordenadas fixas por marcadores de navegação/objetivos. Não foi feita nesta entrega.

### [PENDENTE]

- Confirmar/criar os Places e configurar permissões e IDs reais; testar teleporte com autorização para publicação privada.
- Controle físico Xbox/PlayStation, toque e teclado virtual; persistência publicada, vários humanos, latência e desempenho.
- Matchmaking/reservas entre servidores, caso aprovados; sem MemoryStore ativo.
- Polimento e débitos do CTF: empunhadura, animações, viewmodel, áudio, comportamento visual dos bots e mapas adicionais.
- Decisões originais sobre Get Out Especial 5/7/9, filas de Duels, capacidade comum da Arena e inclusão pública do CTF continuam abertas.

Evidências, arquivos alterados, problemas observados e instruções de recuperação: [relatório de implementação](docs/CROSSGROUNDS-IMPLEMENTATION-REPORT.md). Inventário anterior às mudanças: [CTF-MIGRATION-AUDIT.md](docs/CTF-MIGRATION-AUDIT.md).

## 15. Arena de testes e preparação de Places — v0.4

**[AUTORIZADO PELO CRIADOR]** Arena foi escolhida como a próxima modalidade para testar o hub. Uso de mapas prontos e votação autorizado.

**[IMPLEMENTADO LOCALMENTE]** ArenaAdapter, combate/respawn próprios, votação de dois mapas reais, HUD e retorno ao Crossgrounds. CTF e Arena aparecem como protótipos; Get Out e Duels continuam planejados. Os dois cenários da Arena são alternados dentro do mesmo Place, sem alterar a votação do CTF.

**[PARÂMETROS DE TESTE, NÃO REGRAS FINAIS]** 200 HP, equipamento Regular igual para todos, votação de 12 s, rodada de 120 s, respawn de 3 s e resultados de 6 s. Não substituem o conceito definido de Arena Clássico de um acerto para eliminar nem definem lotação. Os alvos estáticos são para treino; não há bots de Arena.

**[TESTADO NO STUDIO]** Voto e carregamento real de Posto, fluxo completo de controle simulado, respawn, disparo/dano em alvo, câmera, retorno ao hub, transição para CTF e inicialização dedicada de Arena sem loop CTF. Contratos: 32 aprovados, zero falhas.

**[PREPARADO, AINDA NÃO INSTALADO EM NOVOS PLACES]** Pacotes locais separados de Hub e Arena, com papéis configurados. Consulta ainda encontrou somente o Place 4375993208 no Universe 1404405130. Nenhum Place novo foi criado/publicado automaticamente; IDs de destino continuam vazios, teleporte desativado e start place intacto.

**[PENDENTE]** Criar os Places, instalar pacotes, confirmar IDs/permissões, publicar manualmente versões de teste e validar viagens no cliente Roblox. Também faltam testes PvP com vários humanos, aparelhos/controles físicos, desempenho e acabamento. A divisão de Places permanece uma integração a realizar.

Procedência dos mapas, instruções passo a passo, configuração e limites: [Places e Arena de testes](docs/CROSSGROUNDS-PLACES-E-ARENA-TESTES.md). A seção 14 e o relatório da primeira base são fotografias anteriores à autorização da Arena.

## 16. Armas, controle e Arena confirmada — v0.5

**22/10/2026 — [AUTORIZADO PELO CRIADOR]** O Place **84561729907420**, KAuZiiN_4k's Place: 10222026_1, foi criado pelo usuário na experiência 1404405130 e confirmado por ele como **Arena**. A consulta real confirmou o ID e o vínculo. Isso atualiza as referências anteriores a um único Place.

**[IMPLEMENTADO LOCALMENTE]** Modelos procedurais retrabalhados; pegada de duas mãos em R15 para armas de fogo e machado, após o Animator, para jogadores/bots e compatível com as juntas novas. Pulo no controle corrigido. Oscilação e inclinação leves de câmera, reduzidas ao mirar e configuráveis de 0 a 100. FOV de corrida preservado.

**[TESTADO NO STUDIO]** Pulo por A e remapeamento para RB, bloqueio nos ajustes, mãos nas pegadas, contato do machado durante ataque, tiro/recarga na Arena, câmera em repouso/intensidade zero, entrada numérica com limites e retorno ao hub. 32 contratos aprovados. 69 fontes iguais entre Studio/disco e 56 referências das bases preservadas. Controle físico e multiplayer humano continuam sem validação.

**[PREPARADO, NÃO PUBLICADO]** ArenaPlaceId preenchido; pacotes atualizados de Hub/Arena com 62 fontes de runtime cada. TeleportEnabled=false, demais destinos vazios, start place e legado preservados. O novo Place não estava aberto na conexão disponível; instalação e teste nele continuam pendentes.

**[PENDENTE]** Animações completas, mira vertical do corpo/arma, avatares extremos/R6, acabamento dos modelos, naturalidade dos bots, áudio completo, desempenho, controles físicos e viagens publicadas entre Places. Arena continua um protótipo de teste do hub, sem alterar suas regras finais propostas.

Resultados e recuperação: [armas, pegada, pulo e câmera](docs/ARMAS-PEGADA-PULO-CAMERA.md). Os estados v0.3/v0.4 acima são históricos e foram atualizados por esta entrada.

## 17. Balística e pistolas cosméticas — v0.6

**22/10/2026 — [AUTORIZADO PELO CRIADOR]** Tiros ignoram aliados; sniper atinge até dois inimigos, com 100%/80% do dano e interrupção por paredes. Clarão na boca das armas e no viewmodel. Arena recebeu pistolas inspiradas em M1911, Magnum e Glock 18, com atributos de combate idênticos.

**[IMPLEMENTADO]** Balística compartilhada entre jogador CTF, bots e Arena; filtro de aliados também na pontaria do cliente. Seleção de visual no painel da Arena, navegável por controle, aplicada no próximo respawn. Pistola substitui o fuzil; Executor permanece. 45 de dano próximo, cooldown 0,22 s, 12 tiros e reserva 72 são parâmetros provisórios iguais para todos os visuais.

**[TESTADO NO STUDIO]** 40 contratos aprovados; tiros pelo fluxo real do CTF contra NPCs alinhados, aliado intacto, sniper com danos 150/120 e terceiro inimigo intacto, parede interrompendo e fuzil parando no primeiro inimigo. M1911 causou 45 de dano na Arena; seleção por D-pad/A, troca no respawn, recarga, Y, clarões e retorno ao hub verificados. 72 fontes iguais entre Studio/disco e pacotes dedicados com 64 fontes de runtime.

**[LIMITE]** A Arena de teste continua com 200 HP; a regra final de Arena Clássico de um acerto permanece pendente. Não houve teste PvP com vários humanos, controle físico, efeitos sob latência, instalação no Place remoto ou publicação. Teleporte segue desativado. A câmera do editor voltou a funcionar após restauração confirmada pelo usuário; procedimento registrado para uso manual.

Evidências, pacotes e pendências: [balística, pistolas e câmera](docs/BALISTICA-PISTOLAS-CAMERA.md). Os estados das etapas anteriores permanecem como histórico.

## 18. Origem do disparo, recuo e geometria — v0.7

**22/10/2026 — [IMPLEMENTADO LOCALMENTE]** Traçador de primeira pessoa parte da boca do viewmodel. Servidor valida a origem solicitada e bloqueia cobertura entre cabeça e boca; CTF, Arena e bots compartilham esse fluxo. Sons independentes por disparo, cooldowns maiores, mola de recuo visual por arma, geometria procedural versão 3 e remoção do texto explicativo de atributos na seleção de pistolas.

**[TESTADO NO STUDIO]** 47 contratos aprovados; quatro traçadores com origem coincidente com o Muzzle visível, vozes de som simultâneas, retorno do recuo, bloqueio de origem atrás de parede e preservação da penetração da sniper com danos 150/120. Nove variantes de modelos construídas e capturas de primeira pessoa inspecionadas. 76 fontes conferidas entre disco/Studio, 66 de runtime nos pacotes locais atualizados.

**[PENDENTE]** Arte final, animações completas, avaliação auditiva e de desempenho, controles físicos, multiplayer humano/latência e instalação no Place remoto da Arena. Sem publicação; teleporte desativado e legado preservado. Os parâmetros desta etapa substituem os intervalos históricos da v0.6, incluindo pistola da Arena com cooldown de 0,34 s.

Resultados, limites e pacotes: [disparo, áudio e geometria](docs/DISPARO-AUDIO-GEOMETRIA.md).

## 19. Biblioteca e preparação de mapas — v0.8

**22/10/2026 — [DEFINIDO PELO CRIADOR]** Meat Factory, Backrooms e Office pertencem a Get Out. Shipment, Dust e Factory pertencem à Arena.

**[IMPLEMENTADO LOCALMENTE]** Biblioteca ServerStorage.CrossgroundsMaps separada por modalidade; originais em CrossgroundsMapSources e workshop de entrada no Workspace. Importador de geometria estática e spawns, catálogo dinâmico, votação com grade rolável e navegação por D-pad. Arena inclui os três novos mapas e preserva Pátio/Posto. House foi preservado em Pending, sem atribuição arbitrária.

**[TESTADO NO STUDIO]** 53 contratos aprovados; oito mapas com 24 pontos livres cada, carregamento dos cinco cenários de Arena e validação temporária dos três de Get Out. Navegação por controle até o último cartão, votação real em Factory, nascimento com 200 HP e retorno ao hub com limpeza. Pacotes locais atualizados com 69 fontes cada.

**[PENDENTE]** Get Out continua indisponível: seus mapas preparados não implementam regras, objetivos, portas interativas ou spawns por papel. Conectividade de todas as salas, equilíbrio, desempenho, controles físicos e multiplayer humano precisam de teste. Arena remota ainda sem instalação pelo agente; nenhuma publicação ou alteração do legado/terreno CTF.

Estrutura, importação de próximos mapas, pacotes e limites: [mapas e importação](docs/MAPAS-E-IMPORTACAO.md).

## 20. Arena com 20 HP e apresentação mais rápida — v0.9

**22/10/2026 — [AUTORIZADO PELO CRIADOR / IMPLEMENTADO LOCALMENTE]** Arena passa a 20 HP, sem números de dano, com confirmação de eliminação contendo arma/headshot/XP e killfeed. CTF/hub permanecem com 200 HP. XP de sessão: 100 por eliminação PvP e bônus 50 por headshot, sem recompensa por treino. Não há progressão persistente ou níveis.

**[IMPLEMENTADO]** Pose procedural de corrida nos braços/viewmodel e em R15, mais inclinação angular de câmera e movimento discreto do HUD. Retorno ao mirar/disparar, respeito à opção de oscilação zero e FOV de corrida preservado. Magnum com tambor menor em diâmetro e maior em comprimento, cano estendido e efeitos de áudio mais fortes para a Arena.

**[TESTADO NO STUDIO]** 62 contratos aprovados; 20 HP na Arena, headshot com Magnum no alvo de treino, ausência de recompensa por treino e números de dano, pose de corrida e retorno ao mirar. Notificação completa de XP/feed verificada por prévia de QA sem conceder XP; regras de recompensa testadas com objetos simulados. Transição Arena → hub → CTF confirmou 200 HP fora da Arena e restauração da exibição anterior de vida.

**[PENDENTE]** PvP humano, progressão permanente, animações finais, avatares extremos/R6, controles físicos, latência e mixagem auditiva. Texturas indisponíveis em Shipment registradas. Pacotes locais atualizados com 71 fontes; sem instalação remota, publicação ou alteração do legado.

Evidências e pacotes: [Arena: ritmo e feedback](docs/ARENA-RITMO-E-FEEDBACK.md). Os parâmetros históricos de 200 HP na Arena, presentes nas entradas anteriores, foram substituídos por esta decisão.

## 21. Analógicos, assistência de mira e HUD — v0.10

**23/10/2026 — [AUTORIZADO PELO CRIADOR / IMPLEMENTADO LOCALMENTE]** Zonas mortas configuráveis, padrões esquerda 5% e direita 10%, aplicadas ao movimento/câmera e navegação. Filtro radial, entrada numérica em porcentagem e D-pad. Adaptador do controle nativo preparado a partir das fontes reais do PlayerModule; validação com analógicos físicos pendente.

**[IMPLEMENTADO]** Assistência leve para mira com controle/toque, desativável e com intensidade padrão 45%. Seleção por cone/alcance/visibilidade, desaceleração e correção pequena durante entrada manual. Sem assistência para mouse, menus, aliados ou mortos/protegidos. Balanço de corrida mais lento e amplo, HUD de combate transparente e barras contornadas de vida/estamina. Consumo reduzido de 19 para 9,5/s nos dois modos: cerca de 10,5 s por carga.

**[TESTADO NO STUDIO]** 72 contratos aprovados; padrões e limites numéricos, D-pad e ícones apenas no campo em foco, alvo visível/oculto por parede, desativação da assistência, HUDs e consumo de estamina. Retorno ao hub limpou assistência e pose. Controle simulado não ativou o controlador nativo de analógico; esse caminho completo e toque real continuam sem validação física.

**[PENDENTE]** Hardware e ajuste de sensação da mira, PvP humano, latência, persistência publicada e revisão do adaptador se o Roblox alterar o PlayerModule. Pacotes locais com 77 fontes; nenhuma publicação, instalação remota ou alteração do legado.

Detalhes, evidências e pacotes: [analógicos, mira, HUD e estamina](docs/ANALOGICOS-MIRA-HUD-ESTAMINA.md).

## 22. Correções de Arena, mobile e mira — v0.11

**23/10/2026 — [SOLICITADO PELO CRIADOR / IMPLEMENTADO LOCALMENTE]** Arena exclusivamente em primeira pessoa; armas de fogo com trava obrigatória em todas as plataformas. Corrigida a destruição de equipamentos dos sobreviventes pelo Blood legado. Factory com 65 spawns dentro de três zonas explícitas do complexo; importador preserva SpawnRegions.

**[IMPLEMENTADO]** Botões mobile próprios e separados, editor de posição/tamanho/opacidade com salvar/cancelar/padrão e gravação atômica validada. Sensibilidade até 4×, giro por fração de tela no toque, curva S configurável do analógico direito e assistência disponível sem ADS, com desaceleração, correção limitada e verificação de visibilidade. Catálogo com entrada local direta e ajustes por categoria.

**[TESTADO NO STUDIO]** 78 contratos aprovados. Regressão isolada do Blood; disparo pelo roteador mobile com munição 12 → 11, alvo 20 → 0 e arma preservada; morte/respawn em Factory; campos numéricos e editor; assistência no cliente real com entrada/alvo de QA; retorno hub/CTF com 200 HP e bots ativos. O catálogo real já incluía House e conteúdo adicional em preparação, preservados como encontrados.

**[PENDENTE]** Celular físico/multitoque, analógicos reais Xbox/PlayStation, teclado virtual, PvP humano, latência e persistência publicada. A assistência foi validada com preferência de entrada e movimento manual simulados; ergonomia e equilíbrio ainda exigem aparelhos reais. Sem publicação ou instalação remota. Pacotes dedicados com 80 fontes cada; script de sangue legado corrigido separadamente no projeto integrado.

Relatório, evidências, limites e pacotes: [Arena, mobile e mira](docs/ARENA-CORRECOES-MOBILE-E-MIRA.md).

## 23. Menu em camadas, apresentação e bugs — v0.12

**23/10/2026 — [SOLICITADO / IMPLEMENTADO LOCALMENTE]** Cinco ações principais; Progresso preservado nas Opções. Submenus independentes empilhados, loadout pendente até renascer, corrida automática opcional no toque e editor de HUD acessível. Arena com 300 s, intervalo de 1 s, recarga de 900 ms, seis visuais de pistola e classificação central.

**[IMPLEMENTADO E VERIFICADO NO STUDIO]** Arma em ViewportFrame, braços quadrados com skin, levantamento em paredes, iluminação aproximada local abaixo do HUD, previsão visual do disparo sem duplicar áudio, restauração de visibilidade em terceira pessoa e proteção removida por prazo/rotação. Dust com 56 pontos preparados: três reservados ao treino e 53 elegíveis, sem pontos inválidos no mapa carregado. Bots com variação e erros deliberados de mira.

**[PRESERVAÇÃO]** Progressão, recompensas, HeldStandings e novo lobby conciliados. O protótipo anterior do hub é arquivado intacto em vez de destruído. Nuketown foi encontrado no catálogo e preservado, sem validação própria deste patch.

**[LIMITES]** 84 contratos aprovados; 119 fontes locais; pacotes de 98 fontes. Sem publicação, instalação remota ou atestado de hardware/PvP/latência. Rendição por votação, penalidades, animações finais e ideias futuras do relato continuam incompletas.

Evidências e pacotes atuais: [menu, renderização e correções](docs/MENU-LOADOUT-VIEWMODEL-ARENA.md).

## 24. Cascata e tema compartilhados — v0.13

**23/10/2026 — [IMPLEMENTADO LOCALMENTE]** Corrigida renderização dos filhos das colunas com ZIndexBehavior.Sibling. Cascata aplicada a tela inicial/modalidades, entrada/kits de CTF, progresso/amigos e votação da Arena. Estilo do botão Menu com superfícies translúcidas e desfoque temporário. Permanecer no lobby fecha o catálogo sem entrada automática; atualizações de estado não o reabrem.

**[VERIFICADO NO STUDIO]** Capturas, sobreposição do campo de sensibilidade, escolha de kit, voto, retorno ao lobby e ciclo de desfoque. 122 fontes compiladas; 84 contratos existentes aprovados durante a tarefa. Pacote incremental de dez fontes; hardware e instalação em outro Place pendentes. [Relatório](docs/UI-CASCATA-ACRILICO.md).

## 25. Lobby, áudio e progressão — v0.14

**23/10/2026 — [IMPLEMENTADO LOCALMENTE]** Blur por profundidade (0 no primeiro nível, 18 nos seguintes), modalidades jogáveis primeiro, estados verdes e cards menores para modos indisponíveis. Playlist local com pausa, sequência, aleatório, inclusão e ordenação, duas faixas adicionais carregadas no Studio. Bots concedem 50 XP; treino, 10 XP. Perfil/placar usam células alinhadas e a comparação exige histórico real do amigo.

**[VERIFICADO NO STUDIO]** Sete contratos relevantes aprovados; bot real do template concedeu +50 XP e treino +10 sem repetição durante recuperação; morte de Arena incrementou o perfil. Blur, cards, playlist e tabelas verificados por integração/capturas. 128 fontes compiladas. DataStore publicado, amigos offline, hardware e instalação remota pendentes. [Resultados e pacote](docs/LOBBY-PLAYLIST-XP-ESTATISTICAS.md).

## 26. Aim assist por componentes — v0.15

**23/10/2026 — [IMPLEMENTADO LOCALMENTE]** Após pesquisa em documentação oficial de CoD e exemplo técnico independente, a atração ao centro do tronco foi substituída por desaceleração e acompanhamento parcial da área escolhida pelo jogador. Há intenção direcional, aquisição gradual, saída manual e redução por distância. Dois componentes configuráveis, sem alteração das regras de dano/disparo.

**[VERIFICADO NO STUDIO]** 16 contratos aprovados; raycast com parede/proteção, input simulado, alcance e câmera normal confirmados. Rotação zero em alvo parado com intenção de strafe; a 120 studs houve desaceleração leve e rotação zero. Paridade competitiva e conforto em controle/celular reais continuam pendentes. [Pesquisa e evidências](docs/AIM-ASSIST-COMPONENTES.md).

## 27. Separação visual das cascatas — v0.16

**23/10/2026 — [IMPLEMENTADO E VERIFICADO NO STUDIO]** Fundos sólidos nos painéis, 8 px entre colunas e sombra gradual no fundo das seções anteriores. Painel ativo sem sombra. Aplicado à cascata compartilhada e às opções, com captura de duas/quatro colunas e clique no botão da coluna anterior. Blur por profundidade preservado. [Resultados](docs/CASCATAS-SOLIDAS.md).

## 28. Foco e feedback de navegação — v0.17

**23/10/2026 — [IMPLEMENTADO E VERIFICADO NO STUDIO]** Indicador visual lateral ao controle selecionado, sem cobrir texto; posição lógica do analógico preservada. Contorno arredondado de 4 px e brilho externo; som curto por mudança de foco, com ajuste independente em Áudio. D-pad, A, movimento lógico, ausência de repetição e mute confirmados com input simulado. Hardware e áudio em aparelhos reais pendentes. [Resultados e pacote cumulativo](docs/CONTROLE-CURSOR-FOCO-SOM.md).

*Em alterações futuras, atualizar as seções relevantes e acrescentar uma entrada datada ao histórico de decisões. Nunca promover propostas a decisões sem manifestação explícita do criador.*
