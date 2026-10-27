# Get Out: do recorte técnico ao beta fechado

Avaliação em 26/10/2026, baseada nas fontes atuais, nas instâncias do Studio e no design v0.5. Este documento propõe um recorte de beta; não altera decisões do design nem aprova números de balanceamento.

## Situação confirmada

Correção posterior de 26/10: o bug que rejeitava interações foi reproduzido no cliente normal (HoldEnded chegava antes de Triggered) e corrigido. Uma nova sessão com três clientes passou 35 verificações pelo fluxo de controles/remotes: hack, golpe, corda, cápsula, resgate, quatro PCs, manivela e fuga de ambos os sobreviventes até results. Isso substitui a suposição de completabilidade baseada apenas nas chamadas diretas anteriores. As posições dos cenários foram preparadas pela suíte; ainda não é uma sessão humana de balanceamento. Runner agora é a classe padrão, com +150% por 3 s e salto bloqueado; rastejar exige segurar; dutos e janelas do laboratório foram compactados conforme Facility. [Evidências atuais](../artifacts/getout-actions-runner-2026-10-26/validation.md).

Atualização de 26/10 após a integração da tela de carregamento: conferidos novamente o catálogo e a configuração no Studio; somente pursuit_lab é elegível e permanece selecionado para Clássico/Travas. Existem dez templates armazenados. GetOutAdapter, GetOutMaps, GetOutPrototype e GetOutRules do Studio foram comparados com as fontes locais. A tela de ReplicatedFirst acompanha loading/deploying; Get Out continua exigindo a confirmação própria de geometria/piso e posicionamento antes de iniciar o relógio. Essa atualização não constitui uma nova sessão humana de rodada completa.

**Para quem joga:** há um protótipo para 2–5 jogadores, com uma Besta e sobreviventes. Os sobreviventes cooperam em quatro computadores, abrem uma das duas saídas com manivela e escapam; a Besta derruba, arrasta e prende vítimas em cápsulas, das quais os aliados podem resgatá-las. O cenário disponível é um laboratório de mecânicas. O próximo salto de qualidade é um mapa de perseguição representativo, explicação clara dos comandos e estados, e ações com feedback visual e sonoro legível.

**Classificação atual:** protótipo funcional para testes guiados. Ainda não foi demonstrado que um grupo novo consegue jogar, terminar e repetir rodadas sem acompanhamento. A integração do carregamento resolve uma parte da entrada, mas não substitui esse critério de beta.

Existem dez templates de Get Out armazenados. O catálogo atual de perseguição aceita apenas `pursuit_lab`, com 120 descendentes. O adaptador escolhe o mapa fixo configurado e permite somente a rota `locks` (Travas). Facility tem um manifesto antigo, mas ainda não cumpre o contrato atual; os outros oito templates não têm o manifesto GetOut.

O código já reúne carregamento confirmado por cliente e preparação dos personagens, papéis de Besta/sobrevivente, porta comum, rastejamento físico com animação dedicada e transição interrompível, duto, janela, esconderijo, hack cooperativo com checks, martelo, queda, corda/arrasto, cápsula/resgate, manivelas, fuga individual, relógio e encerramento. Runner é a habilidade padrão; há implementação inicial de fúria/contenção e código legado de Hacker com rollback de PC. A presença dessas funções não comprova qualidade de perseguição ou estabilidade com jogadores humanos.

A validação anterior registra 44 checks com três clientes no laboratório; a organização posterior confirmou entrada/retorno pelo hub. Não equivalem a uma sessão de beta em mapa representativo. As fontes dessa suíte estão fora do Place atual, em tests; não existem mais pontos de entrada automáticos de QA no bootstrap.

## Proposta de primeiro beta: Clássico/Travas, um mapa, 2–5 jogadores

O objetivo é permitir que um grupo entre sem o desenvolvedor, entenda os dois papéis, termine uma partida e comece a próxima. As outras quatro rotas e variantes podem ficar fora de um beta explicitamente limitado a esse recorte. A entrega completa do design continua exigindo sua implementação posterior.

| Prioridade | Falta para o beta | Condição observável de entrega |
|---|---|---|
| 1 | Um mapa de perseguição representativo, além do laboratório | Autorar portas por ambos os lados, dutos, janelas, esconderijos, quatro PCs com slots, cápsulas com saída de resgate, duas saídas separadas e spawns por papel; completar a validação de contrato e percorrer todas as conexões com ambos os papéis. |
| 2 | Informação suficiente para jogar sozinho | Apresentar papel e comandos no começo; distinguir PC disponível/falho/concluído, porta comum/saída, saída bloqueada/liberada/aberta e aliado derrubado/preso/eliminado; mostrar progresso e prompts sem sobreposição. Os HUDs atuais já mostram parte desses dados, mas ainda são de protótipo. |
| 3 | Feedback de ações e percepção da ameaça | Golpe com preparação/acerto/recuperação legíveis, corda e arrasto estáveis, cápsula com ocupação/congelamento/resgate claros, manivela com ação visual, sons distintos de PC/porta/perigo. O áudio atual de gameplay usa um som genérico de motor como placeholder. |
| 4 | Robustez de rodadas repetidas | Rodadas completas com humanos, múltiplos resgates e recapturas; saída de Besta e vítima durante ataque/arrasto/captura/carregamento; reset, entrada tardia e retorno ao hub; nenhum avatar preso, constraint sobrando, objetivo impossível ou resultado duplicado. Confirmar também fúria, timeout e contenção se estiverem ativos no recorte. |
| 5 | Controles, câmera e desempenho utilizáveis | Verificar no hardware que será convidado ao beta, especialmente toque e controle físico; checks legíveis, prompts acessíveis, rastejamento/câmera coerentes, sem botão cobrir outro; medir mapa real sob ping/FPS variados. O suporte em código não substitui essa verificação. |
| 6 | Parâmetros consistentes e protocolo de sessão | Reunir os números efetivamente usados, separar regras fixas de ajustes de teste e registrar duração, resultados e dificuldades. Há valores antigos em GetOutRules.Prototype e novos em GetOutPrototype; por exemplo, resgate aparece com 4 s no primeiro e 3 s no segundo. Não assumir que ambos governam a mesma interação. |
| 7 | Entrega e retorno do tester | Uma versão identificável em Place privado de teste, instrução curta de entrada, comportamento definido para entrar sozinho e após escapar/ser eliminado, resultado compreensível e forma de relatar reprodução, dispositivo e versão. Espectador é uma melhoria útil para a espera; persistência e progressão não precisam bloquear esse recorte. |

## Critério proposto para convidar testers

- Um grupo novo conclui o ciclo hub → preparação → partida → resultado → próxima rodada sem comandos administrativos ou orientação constante.
- Os dois papéis conseguem usar as travessias previstas; perseguições comuns oferecem alternativas reais, não um corredor obrigatório ou fuga por fora do mapa.
- Hack, golpe, arrasto, cápsula, resgate e fuga funcionam repetidamente em um mapa representativo, com estados claros para todos os envolvidos.
- Não há bloqueadores conhecidos de carregamento, spawn, câmera ou restauração de personagem; interrupções críticas têm saída administrada para o hub.
- As plataformas incluídas no convite foram verificadas em aparelhos reais. Limitações e parâmetros de teste estão descritos junto da versão.

Isso é uma meta de aceitação proposta, não uma afirmação de que esses testes já passaram. Quantidade de partidas e limites de desempenho devem ser definidos conforme o grupo/aparelhos do beta; não foram inventados números de aprovação.

## Depois do primeiro beta

Integrar Cofre, Lasers, Ferramenta térmica e Demolição como ciclos físicos completos, com interfaces e feedback; habilitar sorteio somente entre rotas realmente jogáveis; implementar o EMP do Hacker nas rotas correspondentes; adaptar outros mapas; resolver regras das variantes antes de habilitá-las; refinar balanceamento, animações, som, espectador e progressão.

Os métodos de estado para essas rotas em GetOutRound são uma base, mas ainda não representam uma rota que o jogador possa executar no mundo. O primeiro ganho de qualidade deve ser um ciclo Clássico/Travas completo em um mapa representativo, seguido por sessões humanas observadas e correções dos bloqueadores encontrados.

Fontes: [design v0.5](../instructions/GET-OUT-DESIGN-v0.5.md), [matriz de implementação](GET-OUT-V05-IMPLEMENTATION.md), [validação anterior](../artifacts/get-out-v05-validation-2026-10-26.md), GetOutAdapter, GetOutGameplay, GetOutHUD, GetOutController, GetOutRules e GetOutPrototype em src.
