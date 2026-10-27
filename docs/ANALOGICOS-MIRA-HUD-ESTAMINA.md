# Analógicos, mira, HUD e estamina — 22/10/2026

**Conferência final em 23/10/2026:** fontes e pacotes verificados após a retomada; resultados de Play e contratos abaixo são da implementação de 22/10.

## Configurações e entrada

- **Zona morta esquerda: 5%**; **direita: 10%**, por padrão. Ajustáveis de 0 a 40%, em passos de 1%, com slider, D-pad e entrada numérica. Valores fora do limite são corrigidos; texto inválido mantém o anterior.
- Filtro radial contínuo: abaixo da zona morta a entrada é zero; o restante do percurso é reescalado até 100%, mantendo a direção diagonal.
- A esquerda controla deslocamento e cursor de menu; a direita controla câmera e rolagem. Os ícones D-pad aparecem somente no ajuste em foco.
- O Gamepad nativo do PlayerModule tinha sua própria zona morta. AnalogMovement adapta GetMoveVector da instância ativa antes das transformações nativas de câmera/veículo. Não modifica as fontes do PlayerModule; teclado, toque, salto e bloqueios de menu continuam usando o fluxo existente. A integração depende da estrutura interna inspecionada nesta versão do PlayerModule.
- Preferências usam o serviço existente; no Studio são temporárias. Persistência em ambiente publicado não foi testada nesta etapa.

## Assistência de mira

Opção **Assistência de mira (controle/toque)**, ligada por padrão, com intensidade ajustável de 0 a 100% e padrão **45%**.

Atua ao mirar com arma de fogo usando controle ou toque. Usa o centro do tronco, cone de 6°, alcance máximo de 120 studs e linha de visão. Exclui aliados, personagens mortos/protegidos, espectadores e alvos fora do modo ativo. Alvos de treino da Arena podem ser usados para praticar.

Perto de um alvo elegível, a sensibilidade cai aproximadamente 20% na intensidade padrão. A correção angular é pequena e limitada a aproximadamente **0,81°/s** nesse padrão, enquanto há entrada manual de câmera. Em toque, exige movimento recente do dedo. Mira livre sem trava recebe desaceleração; a correção angular é usada com trava/primeira pessoa. Mouse, menus, força zero e opção desligada não recebem assistência. Não dispara automaticamente nem altera dano ou validação do servidor.

## Corrida, braços e HUD

- Frequência de balanço na corrida: 12 → 7, cerca de 42% mais lenta. Oscilação lateral do conjunto: amplitude 0,12 → 0,30 stud antes da intensidade configurada. Cotovelos/mangas também abrem mais para os lados.
- Poses de corrida continuam voltando ao mirar, disparar, recarregar e parar. Oscilação zero mantém os movimentos adicionais desativados. A implementação é procedural, sem um conjunto final de animações.
- Painéis principais de combate sem fundo, texto com contorno para legibilidade e barras de vida/estamina com borda. A Arena ganhou barra de estamina; o CTF teve a sua barra existente adaptada. Menus mantêm seus painéis de leitura e navegação.
- Consumo no servidor: **19 → 9,5 pontos/s**, em Arena e CTF. Capacidade permanece 100; corrida contínua passa de aproximadamente **5,26 para 10,53 s**. Regeneração, atraso e requisito para iniciar permanecem iguais. SprintDefinitions fornece o consumo compartilhado.

## Verificações

| Verificação | Resultado |
|---|---|
| Contratos | **72 aprovados, zero falhas**; filtros, configurações, seleção/limites de assistência e balanço ampliado incluídos. |
| Integridade | 93 fontes conferidas entre disco e Studio, sem diferenças após normalizar espaços finais. Os 77 fontes de cada pacote correspondem aos atuais, exceto a configuração de papel intencional. SHA-256 dos arquivos exportados conferidos. |
| Valores iniciais | Servidor e UI: esquerda 0,05 / campo 5; direita 0,10 / campo 10; assistência 45%. |
| Entrada numérica real | No painel aberto para QA: 999 → 40%, -10 → 0%, texto abc manteve 10%; padrões restaurados depois. |
| D-pad | Foco em LeftStickDeadzone exibiu seus ícones; RightStickDeadzone permaneceu sem ícones. Direita ajustou 5 → 6%; esquerda restaurou 5%. |
| Assistência no cliente | Controle simulado e mira ativa: alvo visível habilitou assistência; parede a desabilitou; remoção restaurou. Opção desligada desabilitou novamente. Cena temporária removida. |
| HUD | Painel transparente e contornos de vida/estamina verificados em Arena e CTF. Captura de Play inspecionada. |
| Estamina Arena | Corrida real a 25 studs/s: 52 pontos após aproximadamente 4,88 s da primeira amostra; última amostra de sprint com 1 ponto em 10,35 s. Corrida parou e WalkSpeed voltou a 18. |
| Estamina CTF | Após fechar a seleção de kit, corrida no treino consumiu 100 → 63 pontos no percurso de QA; consumo configurado em 9,5/s. O tempo das chamadas inclui latência da ferramenta. |
| Limpeza | Retorno ao hub deixou assistência false e pose zero, com zonas restauradas a 5%/10%. Plataformas e alvos de QA removidos. |

A primeira tentativa de corrida no CTF ocorreu com o menu de kit aberto e foi corretamente bloqueada; foi repetida com ele fechado. A abertura por clique sintético dos ajustes falhou; o painel foi aberto diretamente para testar os campos e a navegação. Isso não foi considerado validação desse clique.

## Limites

- **Sem controle físico conectado:** a leitura fracionária e o caminho nativo de movimento com hardware ainda precisam de validação. Filtro, câmera/menus, matemática e UI foram testados; os botões simulados não ativaram um controlador nativo de analógico para validar o adaptador completo.
- Toque físico, sensação da assistência em celular/console, equilíbrio PvP e avatares extremos não foram testados. O caminho de toque está implementado, mas não foi validado em aparelho.
- Reavaliar AnalogMovement se Roblox alterar a estrutura interna do PlayerModule. As fontes reais de ControlModule/Gamepad foram inspecionadas antes desta alteração.
- Permanecem os erros conhecidos do plugin GUIEditor e avisos da ferramenta sobre StarterPlayerScripts/câmera. O erro da abertura sintética dos ajustes foi de QA. Não apareceram falhas dos módulos novos no percurso executado.
- Sem instalação no Place remoto, testes publicados ou publicação. Arena permanece com 20 HP; CTF com 200 HP. Get Out continua indisponível.

## Fontes e recuperação

Novos módulos: AnalogFilter, SprintDefinitions, AimAssist, HUDStyle e TargetingAssist. Novo LocalScript: AnalogMovement. Atualizados Settings, ExperienceMenu, MenuNavigation, CombatPresentation, WeaponLocomotion, os dois HUDs e os consumidores de estamina. Novos testes AnalogFilter_Test e AimAssist_Test; Locomotion_Test ampliado.

São **93 fontes**, 77 de runtime/autoramento e 16 de teste. Backup no Studio: **AnalogAssistHUDBaseline_1792712981**. Runner automático desativado; pacotes anteriores e originais dos mapas preservados.

| Pacote | Bytes | SHA-256 |
|---|---:|---|
| [Hub atualizado](../artifacts/crossgrounds-hub-analogicos-mira-2026-10-22.rbxm) | 158321 | 42E1712F9184A478232EF706B5EAD2E27A1624F4C0314DCCA9DD66D9DA8F263B |
| [Arena atualizada](../artifacts/crossgrounds-arena-analogicos-mira-2026-10-22.rbxm) | 999251 | 0EA94D29BCA771949DAF84A8818BDD2BDCAD7E89B392A7F0850935FAA06DFA93 |

Pacotes por serviço com 77 fontes cada; Arena inclui os cinco mapas. Instâncias de recuperação: Crossgrounds_hub_AnalogAssistBundle e Crossgrounds_arena_AnalogAssistBundle. [Guia de instalação](CROSSGROUNDS-PLACES-E-ARENA-TESTES.md). Estado final: Studio em edição, combinedPrototype e teleporte desativado. Nenhuma publicação ou remoção do legado.

Referência consultada durante a inspeção: [Player:Move](https://create.roblox.com/docs/reference/engine/classes/Player#Move). A implementação preserva o tratamento nativo de movimento em vez de disputar chamadas Move a cada frame.
