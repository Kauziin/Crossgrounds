# Sliders — sincronização e resposta local

23/10/2026 · Crossgrounds ALPHA, Place 4375993208. Alterações aplicadas às fontes locais e ao Studio. **Sem publicação.**

## Diagnóstico reproduzido

Sim, o problema principal era uma corrida de sincronização, além de trabalho visual desnecessário.

PreferenceClient escrevia o valor otimista nos mesmos atributos PreferenceState que o servidor replicava. Enquanto o jogador continuava pressionando a seta, uma confirmação de um pedido anterior sobrescrevia o valor mais novo. O próximo incremento partia desse valor antigo: não era apenas um efeito visual, **incrementos eram perdidos**.

Teste real pelos callbacks dos botões do menu: FOV inicial 70, 35 incrementos → esperado 105, observado **89**, com **sete recuos**.
Além disso, cada mudança disparava Preferences.Changed para toda a UI; InterfaceThemeController percorria tipografia e superfícies de todas as telas mesmo quando somente FOV mudava.

## Correção

- **Rascunho local separado:** PreferenceDrafts mantém o valor em edição fora dos atributos replicados. Cada clique atualiza a barra/texto imediatamente.
- **Sequências por alteração e confirmações por campo/escopo:** o servidor valida o pedido e inclui as sequências reconhecidas no estado confirmado. Uma confirmação antiga não apaga um rascunho mais novo, inclusive em sequências aumentar/diminuir que voltam ao mesmo número.
- **Snapshot atômico:** perfil, revisão e confirmações são codificados juntos em PreferenceState.Snapshot. Não se presume ordem de chegada entre atributos individuais de instâncias diferentes.
- **Revisões antigas ignoradas:** o cliente conserva o último estado confirmado válido; overlays pendentes continuam prevalecendo até sua confirmação.
- **Coalescência:** mantém o valor mais recente por campo a cada 80 ms; no máximo três pedidos por envio programado. O teste de 35 incrementos usou nove pacotes, sem enviar um pacote por clique.
- **Reenvio limitado no tempo de espera:** se um valor não foi confirmado, o cliente reenviará a mesma sequência mais recente após cerca de um segundo. O timer existe apenas enquanto houver alterações pendentes. Isso recupera descartes por quota sem fazer a interface esperar.
- **Reset e herança:** têm sequência e não deixam pedidos anteriores pendentes restaurarem valores antigos. False explícito continua diferente de ausência de override.
- **Atualização visual por chave:** apenas a linha afetada atualiza; o tema completo só é percorrido para fonte, contraste ou escala da HUD. FOV e sensibilidade não refazem o tema inteiro.
- **Compatibilidade:** preview imediato do remapeador e editor touch existente foi preservado. Ambos ainda podem usar seu protocolo legado; pedidos sem sequência continuam aceitos pelo serviço.

O servidor continua validando tipo, escopo, limites, operações e sequência; mantém o limite de 60 mensagens/s por jogador. O cliente não altera regras de combate. Persistência continua no mesmo serviço/DataStore, com os mesmos pontos de gravação; não há escrita de DataStore por clique.
O perfil persistente permanece Version 2; o envelope transitório de sincronização tem version=1. Confirmações/sequências não são persistidas no DataStore.

## Arquivos

| Fonte | Responsabilidade |
|---|---|
| src/ReplicatedStorage/Crossgrounds/PreferenceDrafts.luau | Novo ledger de rascunhos, snapshots, sequências e herança |
| src/StarterPlayer/StarterPlayerScripts/PreferenceClient.luau | Aplicação local, fila coalescida, retry e notificações por chave |
| src/ServerScriptService/MainGameScript/GameManager/SettingsService.luau | Validação de sequências e snapshot atômico no serviço existente |
| src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau | Atualiza somente a linha cuja preferência mudou |
| src/StarterPlayer/StarterPlayerScripts/InterfaceThemeController.luau | Evita reprocessar todas as telas por qualquer slider |
| src/ServerStorage/UnitTest/Cases/PreferenceDrafts_Test.luau | Oito testes de confirmações atrasadas, oscilação, ordem, reset e isolamento |

MenuNavigation e CombatPresentation não foram alterados neste patch; a correção do seletor nativo foi preservada.

## Testes executados

| Teste | Resultado |
|---|---|
| 35 incrementos rápidos por callbacks reais, iniciando em 70 | **105**, sem perda/recuo; texto correto |
| Confirmação do mesmo teste no servidor | Atributo e perfil autoritativo = **105** |
| 35 DPadRight enviados pela ferramenta do Studio | Cliente, texto e servidor = **105**; seletor nativo ausente |
| 60 ajustes rápidos alternando aumentar/diminuir | Zero divergências, terminou em **80**, como esperado |
| Alteração → reset → nova alteração com pedidos em voo | Cliente/texto/servidor terminaram em **71** |
| Global/override de Arena/false explícito/voltar a herdar | Preservados |
| Saturação deliberada da quota com mensagens desconhecidas do fixture | Rascunho manteve **83** imediatamente; retry confirmou **83** no servidor |
| Binding legado Sprint → Z | Imediato, frame seguinte e confirmado = **Z** |
| Layout touch legado TouchFireX → 0,74 | Preview preservado e valor confirmado ≈ **0,74** |
| Suíte completa com oito testes novos | **141/141 passaram** |
| Oito testes novos na rodada final | **8/8 passaram** |

Os testes de confirmação atrasada/reordenada usam snapshots controlados no módulo. Os testes de integração usam replicação real da sessão local do Studio. **Não foi emulada uma conexão WAN de alta latência.**
A rodada final de UI mediu frame médio 23,65 ms/pico 25,21 ms; a primeira amostra antiga mediu 25,33/38,84 ms. As sessões não tiveram carga gráfica idêntica: esses números não comprovam aumento de FPS; a correção comprovada é a eliminação dos recuos e incrementos perdidos.
[Evidências completas](../artifacts/sliders-sync-evidencias-2026-10-23.md).

## Limitações e instalação

Ainda pendentes: controle/touch físicos, latência WAN/perda de conexão, múltiplos jogadores e gravação/reentrada publicada. Studio continua com persistência somente durante a sessão.

O projeto aberto já está atualizado. Pacote incremental: artifacts/crossgrounds-sliders-sync-2026-10-23.rbxm, com cinco fontes de runtime e um módulo de testes. Copiar as fontes aos caminhos equivalentes, **após** os patches anteriores; não substituir mapas/serviços inteiros.
Backup das quatro fontes existentes: ServerStorage.SliderSyncBaseline_20261023. Novos módulos: PreferenceDrafts e PreferenceDrafts_Test. Nenhum projeto legado foi removido.

Aplicar os componentes de cliente, servidor e PreferenceDrafts em conjunto: o cliente novo usa o Snapshot produzido pelo serviço atualizado. Validação estática final: **153 fontes compiladas, zero erros**. As seis fontes do pacote foram recuperadas por desserialização e comparadas com o projeto, sem divergências. Arquivo de 26.730 bytes; SHA-256: 841931AE65737B4AFAAD1E87F781B3B1B6F2E3D1D38C2ECA3884B8AFFB7F258D.
