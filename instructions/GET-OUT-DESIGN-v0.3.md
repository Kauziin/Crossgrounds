# Crossgrounds / Get Out — especificação de fuga e contenção

**Revisão:** 2026-10-22, v0.3. **Estado:** documentação e configuração conceitual; nenhuma lógica implementada.

**Legenda:** **DEFINIDO** = decisão fornecida pelo criador; **PROPOSTO** = desenho ou recomendação não aprovada; **PENDENTE** = faltam requisitos ou parâmetros.

## 1. Estrutura da partida — DEFINIDO

- No começo de **cada rodada**, escolher **uma** das cinco formas de fuga **aleatoriamente** dentre as compatíveis com o mapa ativo. Não disponibilizar as cinco simultaneamente na mesma rodada.
- Os sobreviventes podem também **conter a Besta** como resultado alternativo, independentemente de qual rota de fuga tenha sido sorteada.
- **Minutos 0–10 (600 s):** fase normal; realizar a rota de fuga sorteada.
- **Minutos 10–15 (300 s adicionais):** a Besta torna-se **enfurecida e instável**. Somente nessa fase é possível ativar o **final secreto de contenção**. O jogo não apresenta a contenção como um objetivo explícito ao jogador.
- **Ao final dos 15 minutos:** se não houver resolução anterior, a Besta elimina os sobreviventes que permanecerem na instalação. Sem empates.
- As consequências para jogadores já escapados, capturados, ou contidos devem ser individualizadas na lógica de resultados (conforme documento anterior).
- **PENDENTE:** se as cinco formas de fuga e a fase de contenção se aplicam exatamente da mesma forma às variantes Mutação, Infestação e Juggernaut. O modo Juggernaut possui uma premissa diferente, com um Exorcista contra oito Bestas; não atribuir fuga humana automaticamente a ele.

### Sorteio e compatibilidade — proposta de implementação, não regra de balanceamento aprovada

1. Quando o mapa ativo for carregado, o servidor lê suas capacidades declaradas (PCs, portas, lasers, painéis, bancadas, containers etc.).
2. Cria a lista das rotas para as quais **todos os objetos indispensáveis existem**. Sorteia exatamente uma delas.
3. A distribuição entre rotas elegíveis permanece **PENDENTE** (probabilidades iguais ou pesos por mapa). Não selecionar rota ausente ou sem objetos necessários.
4. O método escolhido é fixado durante a rodada. A contenção não participa do sorteio: é condição alternativa independente.

## 2. Rotas de fuga — DEFINIDO

### 2.1 Travas (padrão do Flee the Facility)

1. Há **4 PCs**, **4 travas** de saída e **2 portas** no mapa.
2. Cada PC completamente hackeado participa da liberação das quatro travas. Ao completar os quatro, o conjunto de travas deixa de impedir a abertura das saídas.
3. O jogador deve **girar uma manivela longa** na saída para abrir a porta.
4. Cada sobrevivente **atravessa individualmente** e obtém o resultado de fuga correspondente.

**PENDENTE:** associação exata das quatro travas às duas portas (não presumir duas por porta), duração da manivela e se cada porta precisa ser aberta uma vez ou repetidamente.

### 2.2 Cofre

1. Hackear **4 PCs**, cada um revelando **1 dígito** diferente da combinação de quatro posições.
2. A combinação do cofre **não é definida/ativada até o quarto dígito ser descoberto**. Não permitir tentativa de código válida antes disso (inclusive tentativa e erro).
3. Com a combinação pronta, introduzir os dígitos mediante **disco rotativo de cofre bancário**.
4. Se uma combinação errada for digitada **após o código estar disponível**, o cofre rejeita entradas durante **30 segundos**.
5. A combinação correta abre a saída.

**Nota técnica:** para conciliar a descoberta gradual dos dígitos com a definição tardia da senha, o servidor pode registrar `digit` + `slot` para cada PC sem ativar a fechadura. Apenas depois de quatro revelações válidas concatena os dígitos na ordem dos slots, grava o segredo final no servidor e habilita a inserção. Esse é um **desenho sugerido**, não uma exigência de interface; a ordem/slot de cada dígito permanece **PENDENTE**.

### 2.3 Lasers

1. A saída tem **4 feixes letais** que causam **morte instantânea em qualquer personagem** que os tocar enquanto estiverem ativos.
2. **Painéis de segurança** estão espalhados pela instalação.
3. Em cada painel, realizar um **minijogo/puzzle inspirado no estilo de tarefas de Among Us**.
4. Cada painel resolvido desativa **1** dos quatro feixes.
5. Após remover todos os quatro feixes, a saída fica transitável.

**PENDENTE:** catálogo final de puzzles, tempo de resolução, penalidade por erro e se há reinicializações dos painéis por habilidades da Besta. Não considerar a habilidade Hacker como cancelamento de painel sem decisão específica.

### 2.4 Serra térmica ou arma de calor

1. Peças da ferramenta ficam espalhadas em **armários, baús, gavetas e outros containers**.
2. Jogadores localizam e transportam as peças; **todos os portadores necessários se reúnem numa bancada**.
3. Quando todas as peças estão reunidas, **montam a ferramenta**.
4. Um dos jogadores leva a ferramenta a **uma porta lacrada** e **corta/derrete as bordas**, derrubando a porta e abrindo o caminho de fuga.

**PENDENTE:** número/tipos de peças, tempo de montagem/corte, mecanismo de queda/recuperação de peças em caso de captura, formato definitivo (serra ou arma de calor).

### 2.5 Demolição

1. Jogadores encontram **pólvora e outros componentes fictícios de jogo** espalhados pela instalação.
2. Assim como na rota térmica, coletam os recursos, levam-nos à bancada e **fabricam cargas explosivas de jogo**.
3. Um jogador **planta a carga na porta**; inicia uma contagem regressiva de **15 segundos**.
4. Ao fim dos 15 s, a carga destrói a porta e abre a passagem.

**PENDENTE:** quantidade de cargas, locais válidos, interrupção/desarme, alcance/dano da explosão de gameplay e persistência do temporizador se quem plantou for capturado. Não interpretar como instruções reais de fabricação.

## 3. Habilidade de Besta: Hacker — DEFINIDO

A classe/habilidade **Hacker** atua de maneira distinta conforme **a rota de fuga efetivamente sorteada**, e não apenas conforme objetos existentes no mapa.

| Rota ativa | Ação | Recarga |
|---|---|---:|
| **Travas** ou **Cofre** | Reverter hackeamento de PC(s). Quais e quanto progresso são **PENDENTES**. | **150 s (2 min 30 s)** |
| **Lasers**, **Serra térmica** ou **Demolição** | Emitir **PEM/EMP** circular e expansivo que interage com **objetos/itens metálicos**, localizando-os por **5 pulsos**, cada um de **2 s**. Duração total da sequência: **10 s**. | **180 s (3 min)** |

**PENDENTE no EMP:** alcance, como selecionar objetos metálicos, se o destaque é visível só para a Besta, persistência do destaque e se existe efeito de desligamento ou somente detecção. Não converter automaticamente a detecção em desativação ou dano.

**PENDENTE nos PCs:** se o Hacker desfaz progresso parcial ou total, qual PC pode selecionar, como isso interage com dígitos já exibidos e a partir de quando não é possível reverter uma porta já aberta.

## 4. Propostas detalhadas — NÃO APROVADAS

Nenhuma destas ideias está ativa por estar descrita aqui. São opções para teste ou discussão.

### 4.1 Três puzzles de painel para Lasers

- **Fiação pareada:** quatro cabos de entrada e quatro saídas embaralhadas, cada par com a mesma combinação de **cor + símbolo** (redundância para daltonismo). O jogador seleciona a entrada e depois a saída; quando concluir os quatro pares, o feixe associado se apaga. Não exige arrastar com mouse.
- **Circuito giratório:** cinco peças de trilha (linhas/cantos) com quatro orientações de 90°. Selecionar uma peça gira-a; um fluxo visível sai da origem e, quando alcança o destino, o painel libera o feixe. Deve existir pelo menos uma solução gerada e verificada pelo servidor.
- **Sintonia de frequência:** três canais, cada qual com cinco níveis discretos. Cada canal exibe seu nível-alvo; ajustar com botões esquerda/direita, confirmando ao alinhar os três. Em controle, mover o foco entre canais pelo D-pad e alterar pelo analógico ou botões.

### 4.2 Contenção secreta na fase de fúria

- **Minuto 10:00:** a sala de contenção recebe energia, indicada **somente por uma mudança ambiental** (luz intermitente + ruído de gerador). Nenhum objetivo novo aparece no HUD.
- Sobreviventes precisam ativar **dois quadros de segurança**, em pontos separados da instalação, com **8 s de interação contínua** cada.
- Após ambos, a câmara fica operacional. Eles precisam atrair a Besta para a região demarcada pelo próprio cenário e acionar **uma alavanca externa por 4 s**.
- Se a Besta permanecer dentro até o fechamento, fica contida e a rodada termina com esse desfecho. Se sair antes, a contenção falha e os dois quadros precisam ser rearmados.
- O barulho da câmara e as luzes revelam risco tanto para a Besta quanto para os sobreviventes; o objetivo continua secreto na interface.

### 4.3 Limites de teste para o Hacker

- **Rollback de PC:** escolher um PC já totalmente hackeado, reverter **somente um** dos quatro avanços por ativação; não permitir fechar saída já aberta nem apagar objetivo de rodada já encerrado. Esse limite impede um bloqueio interminável do progresso.
- **EMP:** raio máximo de **45 studs**, cinco anéis sucessivos durante 10 s; todo item com atributo `Metallic=true` detectado é destacado para a Besta por **4 s**, inclusive atrás de paredes. O EMP **não** causa dano nem desativa equipamentos nessa proposta inicial.
- **Contrajogo:** um prenúncio audiovisual de **1 s** anuncia a ativação do Hacker aos sobreviventes próximos, permitindo que escondam ou larguem equipamento metálico antes da varredura.

### 4.4 Uma regra adicional de fúria para testes

- Durante os últimos cinco minutos, a Besta recebe **20% de velocidade adicional por 12 s** a cada **40 s**. Após cada surto, há **4 s de instabilidade** sem usar habilidade de classe. Isso evita que a fase seja apenas aumento contínuo de velocidade. **Não é uma decisão aprovada.**

## 5. Contratos mínimos antes de implementar no Roblox

- O estado oficial dos objetivos, senhas, travas, itens carregados, explosões fictícias e resultados permanece no **servidor**; o cliente só solicita interações.
- A seleção de rota ocorre quando um mapa já declarou que tem os objetos exigidos; modelos gratuitos sem painéis/containers deverão ser adaptados para cada rota, e não receber objetivos inexistentes.
- O tipo do objetivo selecionado é um dado de partida; o Hacker escolhe o comportamento a partir desse tipo para não ativar o rollback quando não existem PCs **ativos na missão**.
- Testar manivela, dial, puzzles e fabricação com **gamepad, teclado/mouse e toque**. Em especial, não exigir ação exclusiva de mouse para o cofre rotativo.
- Não incluir as propostas do item 4 em implementação automática, mesmo que o desenvolvedor importe diretamente o arquivo de configuração.
