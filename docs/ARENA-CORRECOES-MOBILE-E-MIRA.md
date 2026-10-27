# Arena — correções, mobile e mira

**23/10/2026.** Alterações aplicadas ao projeto integrado no Studio. Nenhuma publicação ou instalação no Place remoto foi realizada.

## Alterações

### Arma desaparecendo após uma eliminação

O script legado **ServerScriptService/Realism Mod/Blood** percorria todos os jogadores ao criar uma poça de sangue e destruía os Tools equipados dos sobreviventes. Agora os equipamentos entram na lista ignorada pela consulta de piso, sem serem destruídos.

O teste isolado executou o código completo anterior e o corrigido com eventos/jogadores simulados: a versão anterior apagou a arma do sobrevivente; a corrigida a preservou. Também foi realizada uma eliminação real de alvo de treino pelo servidor da Arena, preservando a mesma instância da arma.

### Controles mobile e editor de HUD

- MobileHUD passa a concentrar os botões de combate. ContextActionService continua recebendo teclado/controle, mas deixa de criar os botões de toque duplicados.
- Botões circulares contornados para disparo, mira, recarga/interação, pulo, corrida e troca de arma. Câmera, ombro e trava aparecem apenas quando aplicáveis.
- Disparo por pressão contínua; mira por toque para ligar/desligar. Arrastar o dedo sobre o botão de disparo também pode girar a câmera.
- O botão nativo de pulo é ocultado enquanto a camada própria está ativa e recupera a visibilidade anterior ao sair dela.
- Durante o toque, votação/retorno ficam dentro de um botão MENU compacto. Vida e munição passam para cima da região do analógico de movimento; o killfeed também recebe posição/tamanho próprios.
- **Ajustes → HUD MOBILE → ABRIR EDITOR DE HUD** funciona também como prévia no PC.
- Arraste para mover ou use os campos numéricos/setas. Posição normalizada, tamanho lógico de 40–112 e opacidade de 15–100%, com limites de tela segura.
- Salvar envia os 36 campos em uma única solicitação validada pelo servidor. Cancelar descarta o rascunho; Padrão só é aplicado ao salvar.
- Preferências usam o serviço existente: sessão no Studio; DataStore fora do Studio. Persistência publicada e teclado virtual de celular/console ainda não foram testados.

O layout padrão foi verificado matematicamente em 390×844, 740×360, 900×480 e 1280×800, incluindo separação dos nove botões. Edição por mouse e navegação registrada para D-pad estão implementadas; multitoque físico permanece pendente.

### Câmera e orientação

- **Arena exige primeira pessoa**, inclusive durante preparação e quando não há arma equipada.
- **Toda arma de fogo exige trava de mira**, no PC, toque e controle. O personagem acompanha horizontalmente a direção do alvo.
- Preferências de terceira pessoa/Shift Lock continuam disponíveis para os contextos permitidos do CTF. A Arena não altera esses valores persistidos.
- Ajustes incompatíveis de câmera ficam ocultos na Arena; remapeamentos de câmera/ombro/trava são identificados como controles do CTF.
- O CTF preserva câmera de ombro e alternância de perspectiva. Trava obrigatória para armas de fogo também se aplica nele.

### Assistência, sensibilidade e curva do analógico

A assistência anterior exigia mira fechada e limitava a correção padrão a cerca de 0,81°/s. A implementação atual:

- Atua com armas de fogo em controle/toque, inclusive sem mira fechada.
- Seleciona alvos válidos por distância, ângulo e linha de visão; ignora aliados, mortos, protegidos e jogadores fora do combate.
- Usa cone de 6° sem mirar e 8° ao mirar, até 180 studs ou o alcance da arma.
- Reduz a sensibilidade perto do alvo. A correção é limitada a 22°/s na intensidade máxima, aproximadamente 9,9°/s no padrão de 45%.
- A correção exige entrada manual: analógico de mira/movimento ou arraste recente no toque. Não dispara automaticamente, não atravessa paredes e não altera o dano do servidor.
- Mantém intensidade configurável e opção de desligar. Mouse não recebe assistência.

A sensibilidade da câmera agora aceita **0,2–4,0**. No toque, o giro considera a fração da largura da tela: meia tela corresponde a aproximadamente 120° em 1×, antes do multiplicador de mira. A posição anterior do toque é usada para calcular o deslocamento.

O analógico direito usa **Dinâmica (curva S)** por padrão, com intensidade de 65%. A curva mistura a resposta linear com smoothstep, preservando direção, monotonicidade e velocidade máxima. Há opção Linear e ajuste da intensidade. Zonas mortas padrão permanecem 5% à esquerda e 10% à direita.

Referências consultadas: [Roblox: assistência dos templates FPS/Laser Tag](https://devforum.roblox.com/t/get-aim-assist-in-studio-templates-or-add-it-to-your-experience/4082644), [Roblox: entrada mobile](https://create.roblox.com/docs/input/mobile), [Microsoft: zonas mortas e respostas não lineares de analógicos](https://learn.microsoft.com/en-us/windows/win32/xinput/getting-started-with-xinput). A implementação é própria; não foi importado um template inteiro.

### Factory e importação

Factory recebeu **65 pontos** distribuídos em três zonas explícitas do complexo: PatioInterno, CorredorInterno e PassagemOeste. O terreno externo e as estruturas decorativas sólidas não são usados como área automática de spawn.

As zonas ficam em **CrossgroundsMapSources/Arena/Factory/SpawnRegions** e são convertidas junto do mapa. As 2392 partes da geometria foram preservadas. ArenaMaps rejeita marcadores fora das zonas e revalida ocupação antes de escolher um nascimento.

O importador aceita SpawnRegions em mapas futuros. Sem zonas, mantém o comportamento anterior. [Instruções de autoria](MAPAS-E-IMPORTACAO.md).

O catálogo real também já continha **House**, com 19 pontos e 1326 partes. Ele foi preservado como encontrado; não foi movido de modalidade nem redesenhado nesta etapa. O pacote atual inclui os seis templates disponíveis. House não recebeu exploração jogável neste patch.

### Menus

- Modos jogáveis aparecem primeiro; Get Out e Duels ficam marcados **EM BREVE**.
- Descrições explicam a partida e o próximo passo. Entrada local usa um único botão Jogar.
- Ajustes separados em Câmera/visual, Mira/sensibilidade, Analógicos e Áudio, além de abas de controles e HUD mobile.
- Campos numéricos selecionam o conteúdo ao receber foco e corrigem entradas para os limites.
- Placas físicas do hub também distinguem CTF/Arena em teste dos modos futuros.

## Evidências de teste

| Verificação | Resultado |
|---|---|
| Contratos no Studio | **78/78 aprovados**; inclui câmera obrigatória, curva S, toque proporcional, limites do HUD e zonas rotacionadas. |
| Arma e script de sangue | Código anterior removeu equipamento do sobrevivente; código corrigido preservou, em teste isolado com dependências simuladas. |
| Disparo pelo roteador mobile | Munição 12 → 11; alvo autoritativo 20 → 0 HP; mesma arma permaneceu equipada. |
| Respawn Factory | Após morrer: 20 HP, pistola com 12 balas e posição dentro de SpawnRegions. |
| Câmera Arena | V/Shift e troca para Executor mantiveram primeira pessoa/trava. Respawn recuperou a câmera dedicada. |
| Assistência no cliente real | Alvo detectado sem ADS; parede bloqueou; remoção restaurou; desligar e mouse não selecionaram alvo. |
| Correção com entrada simulada | Erro aproximado 2,78° → 0° em 0,35 s, com movimento manual simulado e sem disparo automático. |
| Editor | Arraste, tamanho e opacidade salvos; cancelar conservou os valores anteriores; restaurar + salvar recuperou o padrão. |
| Entrada numérica | Digitação de 99 no campo de sensibilidade corrigida para 4,00 no cliente e 4 no servidor. |
| Layout mobile no cliente | Seis botões ativos, sem interseção entre seus retângulos ou com MENU; atalhos antigos ocultos. Abrir/cancelar o editor pelo navegador de menus funcionou. |
| Retorno hub/CTF | Mundo da Arena removido, 200 HP no CTF e bots ativos; fuzil continuou travado com preferência de Shift Lock desligada. |

O teste de assistência usou um LocalScript temporário com os módulos reais do cliente, substituição temporária da preferência de entrada e um alvo de QA. Isso valida a integração e os bloqueios, **não comprova a sensação de um analógico ou dedo físico**. A rodada foi temporariamente ampliada durante QA; a fonte final voltou a 120 s.

## Limites e recuperação

- Ainda precisam de teste: celular físico/multitoque, consoles Xbox/PlayStation, teclado virtual, latência e PvP com múltiplos humanos.
- Geometria dos botões foi verificada em vários tamanhos; isso não substitui avaliação visual e ergonomia em cada aparelho.
- Assistência usa ponto de tronco e não constitui um sistema completo de seleção de membros sob cobertura parcial.
- Animações finais, bots da Arena e refinamento dos modelos continuam fora deste patch.
- Persistem erros externos conhecidos do plugin GUIEditor e avisos da ferramenta sobre StarterPlayerScripts. A falha de inicialização de MobileHUD encontrada durante QA foi corrigida com WaitForChild e não reapareceu no percurso final.
- Fontes locais: **98**; 81 de runtime/autoramento incluindo a correção do Blood legado, 17 de testes.
- Integridade final: as 98 fontes do disco correspondem às do Studio; os 80 fontes de cada pacote correspondem aos de runtime, exceto a configuração intencional de papel Hub/Arena. Compilação sintática das 98 fontes sem erros.
- Backups no Studio: **ArenaAccessibilityBaseline_1792728366** e **ArenaBugfixSourcesBaseline_1792729964**. Mapas anteriores permanecem em CrossgroundsMapRevisions.
- Pacotes dedicados têm **80 fontes** cada: o script de sangue legado não é acrescentado a Places limpos. Se um destino já possui Realism Mod/Blood, aplique também a [fonte corrigida](../src/ServerScriptService/Realism%20Mod/Blood.luau).

## Pacotes locais

Os pacotes são organizados por serviço. [Guia de instalação](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md).

| Pacote | Bytes | SHA-256 |
|---|---:|---|
| [Hub atualizado](../artifacts/crossgrounds-hub-arena-mobile-2026-10-23.rbxm) | 169236 | B6DD440DF9F36676D20956F52F0344ABEBE234A13E967F03A91D6B0E99FE5549 |
| [Arena atualizada — seis templates](../artifacts/crossgrounds-arena-mobile-2026-10-23.rbxm) | 1038080 | 016F8C0A9C957CC8C5A50282E2F9768819A73D9EE84815895C3C16B89588EDB7 |

Instâncias: ServerStorage.Crossgrounds_hub_ArenaBugfixBundle e Crossgrounds_arena_ArenaBugfixBundle. Studio em edição, combinedPrototype, teleporte desativado e UnitTestRunner desativado. Nenhum conteúdo do Place remoto 84561729907420 foi alterado pelo agente.
