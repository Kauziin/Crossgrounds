# Crossgrounds — menu, loadouts, renderização e correções de 23/10

**Correção posterior de UI:** a verificação inicial de empilhamento não detectava oclusão dos filhos pelo fundo. O defeito foi reproduzido e corrigido, com cascata compartilhada, acrílico e permanência explícita no lobby. Os pacotes completos deste relatório precisam do [incremental de UI e novas evidências](UI-CASCATA-ACRILICO.md).

**23/10/2026.** Implementação aplicada ao projeto integrado no Studio. Relato considerado integralmente: [bugs-23-10-2026-04_05_53.md](../bugs-23-10-2026-04_05_53.md). Nenhuma publicação, alteração de start place ou instalação no Place remoto da Arena foi realizada.

## Recursos do patch

- Menu substitui **Example** no TopbarPlus. A lista principal mantém **Continuar, Loadout, Opções, Render-se e Sair**. O acesso recente a **Progresso** foi preservado dentro das Opções, além do acesso do catálogo.
- Opções, Controles e a lista de ajustes são painéis distintos, com deslocamento suave e sobreposição parcial. Voltar recupera a lista anterior. Reduzir movimento desativa as transições.
- Loadout mostra número, nome e as duas armas. O servidor guarda a escolha pendente; o equipamento da vida atual é preservado e a mudança ocorre no próximo nascimento/configuração de spawn. No hub, é necessário entrar em uma modalidade.
- **Opções → Jogabilidade → Corrida automática no toque**: opcional, desligada por padrão. Avançar ativa; parar/recuar ou abrir menus interrompe. Consome estamina e evita reativação contínua quando esgotada.
- **Opções → Controles → HUD mobile → Editar posição, tamanho e opacidade** abre o editor real, com os nove botões expostos. O inspetor pode ser ocultado para liberar espaço. Salvar, Cancelar e Padrão continuam disponíveis.
- Valores aceitam digitação, vírgula decimal e correção para os limites. Sliders e ícones de D-pad apenas no campo em foco foram preservados. Remapeamento mantém os cinco segundos sem entrada.
- **Render-se** em equipe informa que a votação ainda será feita; na Arena individual permite retornar ao hub. Sair usa confirmação e retorno existente. Penalidades continuam futuras.
- **Opções → Desenvolvimento**, somente no Studio: pausar/retomar cronômetro, definir tempo por presets ou campo, reiniciar, votar, renascer e carregar um mapa da Arena. CTF mantém Travessia e o ciclo normal de encerramento.

### Arena

| Parâmetro | Atual |
|---|---|
| Rodada | 300 segundos |
| Vida | 20 HP |
| Intervalo mínimo | 1 segundo por arma na Arena, validado no cliente e no servidor |
| Recarga das pistolas | 900 ms |
| Munição | 12 no carregador e 120 de reserva |
| Visuais | M1911, Magnum, Glock 18, Desert Eagle, Luger P08 e Beretta M9 |
| Classificação | Topo central, avatares, posição, kills/mortes e contornos ouro/prata/bronze; demais posições padrão |

Desert Eagle, Luger e Beretta têm conjuntos superiores e empunhaduras distintos. Recargas procedurais movem carregador, apoio e ferrolho; Magnum abre o tambor, Luger move o mecanismo superior. Ainda faltam acabamento artístico e animações completas de combate em terceira pessoa.

### Primeira pessoa, equipamento e bots

A arma usa **ViewportFrame, WorldModel e câmera próprios**. Sua orientação não aponta diretamente para um alvo muito próximo. Uma consulta ao cenário levanta a arma diante de paredes. O FOV da arma permanece independente do mundo e o recuo é estético.

Os braços são quadrados, com cores do avatar e camisa clássica; uma skin real foi inspecionada visualmente. Roupas em camadas, acessórios e corpos especiais não têm conversão integral garantida.

EquipmentService recupera armas esperadas ausentes ou sem Handle e reequipa quando necessário. Preserva ferramentas válidas, munição, vida e loadout pendente. O hub permanece sem armas por intenção do fluxo.

Os bots receberam diferenças de reação, busca, strafe, patrulha e separação, memória curta e investigação. Cabeça, tronco e pernas recebem movimento procedural. A etapa dos bugs acrescentou erros deliberados de pontaria por papel e distância, com reação de 0,35–1,1 s. A intenção de acerto não garante acerto físico nem representa equilíbrio final.

## Os oito bugs do relato

| Relato | Correção e evidência |
|---|---|
| 1. Sol e iluminação intensos | Exposição 0,81 → 0,05; raios solares 0,751 → 0,035. Limites para bloom, brilho da correção de cor e luzes locais. Confirmados em Play. |
| 2. Disparo visual atrasado | Clarão, recuo, som e traçador locais começam antes da confirmação de rede. ID de disparo evita repetição na confirmação. Teste: efeito imediato antes de a munição replicar; munição 12 → 11 depois; uma única voz de tiro. Dano continua no servidor. |
| 3. Braços sem iluminação e sobre o HUD | Viewport recebe aproximação do ambiente, sol/oclusão e luzes próximas, atualizada durante o jogo. Uma luz vermelha de QA alterou o ambiente. DisplayOrder passou para -10, abaixo inclusive dos HUDs com ordem padrão. |
| 4. Spawns de Dust | 56 marcadores em sete regiões, com piso, espaço livre e saídas verificadas. Três pontos são reservados aos alvos de treino antes de nascerem jogadores. **53 pontos elegíveis, zero inválidos no mapa carregado**. Seleção também penaliza exposição a inimigos. |
| 5. Invisibilidade em terceira pessoa | A restauração deixa de recuperar um modificador local já contaminado pelo modo de primeira pessoa. Transição Arena/primeira pessoa → CTF/terceira pessoa confirmou **88 peças visíveis, zero ocultas pelo modificador local**. |
| 6. Proteção inconsistente | ArenaShield é removido ao expirar, mesmo parado. Girar yaw/pitch cerca de 1,4° pede quebra da proteção do próprio personagem. Uma proteção de QA com prazo de 30 s foi removida pelo analógico simulado antes do prazo, com atributo zerado. |
| 7. Bots precisos demais | Probabilidade de intenção de acerto varia por papel/distância; os demais tiros recebem desvio lateral deliberado. Contrato com 2.000 amostras por papel passou; bots em Play registraram tanto intenção de acerto quanto de erro. |
| 8. Submenus substituídos | Opções, Controles e ajustes permanecem visíveis em camadas independentes. Teste observou quatro camadas, com X = 0/128/256/384 na janela usada. Progresso permaneceu acessível nas Opções. |

O disparo continua **hitscan**; a previsão é visual. O servidor valida munição, intervalo, origem, paredes e dano. Sob latência ou dispersão, o traçador previsto pode diferir do ponto confirmado. Não houve teste de rede real.

A iluminação da arma é uma **aproximação**; ViewportFrame não reproduz integralmente sombras e pós-processamento do mundo. Luzes/texturas específicas ainda podem exigir ajuste artístico por mapa.

## Validação acumulada

- **84/84 contratos aprovados**: os 78 anteriores, quatro de loadout/recarga/classificação e dois de precisão/saídas de spawn.
- Snapshot local: **119 fontes**, incluindo testes e integrações recentes preservadas.
- Loadout pendente preservou a arma atual e equipou Desert Eagle após renascer.
- Remoção forçada dos equipamentos foi recuperada em Arena e CTF; destruir o Handle também foi recuperado. Arena manteve 20 HP e CTF, 200 HP.
- Disparo antecipado não consumiu munição; o seguinte após o intervalo consumiu. Recarga configurada em 0,9 s completou o carregador.
- Parede próxima acionou levantamento; câmera de arma era distinta da câmera do mundo.
- Editor abriu nove botões; tamanho de Fire = 88 foi confirmado também no servidor.
- Sensibilidade 9999 corrigiu para 4. Ícones apareceram apenas no ajuste focado e o foco sobreviveu à reconstrução de listas.
- Corrida automática iniciou com movimento para frente simulado e parou ao abrir menu.
- Pausa congelou o cronômetro; definição de 1234 s e troca para Factory funcionaram. Nova rodada iniciou com 300 s.
- CTF completou equipes com onze bots para um humano; movimento de cabeça e de juntas das pernas foi observado.

Durante os testes foram corrigidos retorno múltiplo de gsub na entrada numérica, destruição do contorno de foco, aritmética de Color3 na iluminação e disputa entre alvos de treino e pontos de nascimento.

**Limites:** controle físico Xbox/PlayStation, multitoque em celular, teclado virtual, PvP humano, latência, longa sessão pós-patch e persistência publicada ainda não foram validados. O runner automático continua desativado.

O console preservou erros externos do GUIEditor e avisos de StarterPlayerScripts da ferramenta. A integração recente de progresso emitiu avisos de ConfigService sem valores opcionais; não foi tratada como balanceamento/persistência de produção concluídos. Também foram vistos anteriormente assets de mapas/animações indisponíveis, sem remoção dos originais.

## Preservação, pacotes e versão

As alterações recentes de progressão, recompensas, HeldStandings, catálogo e lobby foram mantidas. A revisão automática rejeitou inicialmente a cópia de uma rotina que destruía o hub anterior. A alternativa aplicada **arquiva intacto o protótipo anterior pertencente ao Crossgrounds**, em CrossgroundsHubArchives, e monta o novo lobby em lotes. Teste: novo LobbyWorld e Spawn presentes, personagem pronto no hub e os 21 descendentes anteriores preservados no arquivo.

Backup deste patch: **ArenaBugsBaseline_20261023**. Backup da primeira etapa: **ArenaRefinementBaseline_1792733002**. Fontes dos mapas e pacotes anteriores preservados.

| Pacote atual | Bytes | SHA-256 |
|---|---:|---|
| [Hub](../artifacts/crossgrounds-hub-bugs23-2026-10-23.rbxm) | 263210 | CAF670D2A9BCF32D2D1869A2C62F11B2404B443B223577EDE40520D25F9256BE |
| [Arena](../artifacts/crossgrounds-arena-bugs23-2026-10-23.rbxm) | 1120014 | F763CD0B3358F4CBED6101BF0C933441256E6DB8F418130128E2624EE2C44818 |

São pacotes **por serviço, com 98 fontes cada**, não Places completos nem instaladores. Hub inclui a fonte do lobby; Arena inclui **sete templates**, com Dust revisado. Nuketown foi encontrado no catálogo durante o fechamento e preservado, sem exploração/validação própria neste patch. Originais de Arena/Get Out permanecem no projeto principal.

Instâncias: Crossgrounds_hub_Bugs23Bundle e Crossgrounds_arena_Bugs23Bundle. Não incluem o Realism legado nem o TopbarPlus; o menu dispõe de botão alternativo. Os pacotes anteriores de 90/80 fontes são históricos e não contêm todas estas correções.

O projeto principal mantém combinedPrototype, entrada local de CTF/Arena e TeleportEnabled=false. A instalação no Place remoto 84561729907420 e o teleporte entre Places continuam pendentes de configuração e teste.

## O que continua incompleto

- Votação de rendição por equipe e penalidades ao sair.
- Modelos, animações e sonorização finais; mira vertical em terceira pessoa, sincronização completa do melee e roupas especiais nos braços.
- Navegação de bots independente de Travessia, coordenação entre papéis e equilíbrio contra humanos.
- Shadowing/iluminação totalmente equivalentes ao mundo no exibidor.
- Testes humanos prolongados dos spawns e de pressão sobre bases.
- Progressão/economia de produção, validação completa das integrações paralelas e persistência entre servidores.
- As ideias do relato — sliding, crouch/deitar, rebirth, passe, presentes/trades, leilões, destruição e equipes alternativas — não foram implementadas por este patch. As regras de Get Out/Duels continuam fora desta entrega.
