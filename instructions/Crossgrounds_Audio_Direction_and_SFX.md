# Crossgrounds — Audio Direction, Sound Research & SFX Integration

> Instruções de produção para o Codex. O projeto e suas modalidades já são conhecidos; examine os recursos existentes antes de substituir qualquer coisa.

## Missão

Elevar a qualidade percebida do Crossgrounds com **identidade sonora coerente, feedback imediato e legibilidade competitiva**. Trabalhar em três eixos: (1) navegação de menus; (2) armas e combate; (3) movimentação, interações, ambientes e eventos dos modos. Não basta trocar IDs: especificar, pesquisar, comparar, tratar, integrar e testar os sons.

## 1. Auditoria e mapa de eventos

Inspecione todos os usos atuais de `Sound`, `SoundGroup`, áudio modular, bibliotecas de assets e eventos de gameplay. Levante um inventário de **evento → fonte/ID → categoria → origem 2D/3D → volume relativo → situação → problemas**. Escute e compare os efeitos reais, quando houver acesso ao áudio. Não descreva sons que não foi possível ouvir.

Classifique: ausente, duplicado, inconsistente, agressivo, atrasado, sem variações, com corte abrupto, inaudível, espacialização incorreta ou tecnicamente indisponível. Preserve os efeitos que já cumprem bem seu papel. Defina uma assinatura sonora: **interface precisa e discreta; armas com presença e materialidade; movimento informativo; tensão e objetivos distintos por modo**. Evite fazer todos os sistemas parecerem um menu de ficção científica ou todos os tiros parecerem o mesmo estalo.

## 2. Navegação de menu — gramática sonora

Crie uma pequena família de sons combinando *ataque curto*, assinatura tímbrica compartilhada e diferenças funcionais claras:

| Evento | Direção sonora | Observações |
|---|---|---|
| `UI.Focus` | toque leve, curto, agradável | Ao mudar foco via teclado/controle; não tocar continuamente por mouse-over estacionário |
| `UI.Navigate` | tick seco com variação sutil | Percorrer categorias e itens da cascata; limitar repetições em navegação muito rápida |
| `UI.Expand` / `UI.Collapse` | movimento tonal curto em direções distintas | Reforçar expansão/retorno sem soar como notificação |
| `UI.Confirm` | ataque nítido + resolução curta | Seleções efetivadas, não para qualquer hover |
| `UI.Cancel` | versão curta e suave de retorno | Evitar tom punitivo |
| `UI.ToggleOn` / `UI.ToggleOff` | mesmo material, inflexão distinta | Acessibilidade: não depender só da diferença tonal |
| `UI.SliderStep` | clique discreto ou escala de pitch moderada | Debounce/coalescência para analógico e drag contínuo |
| `UI.Disabled` | resposta leve e distintiva | Nunca soar como confirmação bem-sucedida |
| `UI.Warning` / `UI.Error` | assinatura rara e inteligível | Evitar alertas estridentes para erros triviais |
| `UI.Apply` / `UI.Save` | confirmação de conclusão | Só quando houver mudança efetivamente aplicada |
| `Match.Found` / `Match.Countdown` | identidade memorável, mas breve | Reconhecível mesmo fora do menu; não atrapalhar voz/comunicação |

Distinguir **hover do mouse**, mudança de **foco com gamepad**, clique, confirmação e confirmação de servidor. Não tocar dois sons por uma única interação de UI. Construir regras de prioridade, cooldown leve apenas onde necessário e limite de vozes simultâneas. Botões próximos devem ter uma identidade coesa, sem uma mistura aleatória de dezenas de samples.

## 3. Armas — desenho por camadas e contexto

A experiência deve reconhecer o disparo imediatamente, mas ter textura e identidade distintas por família de arma. Investigue separar em **transiente/ataque**, **corpo**, **mecânica**, **cauda acústica** e, opcionalmente, **subgrave discreto**. Não é obrigatório usar cinco instâncias em todo disparo: prefira pré-combinar camadas quando a quantidade de sons simultâneos ou a latência prejudicar o resultado.

- **Pistolas:** transiente definido, massa moderada, mecanismo breve. Calibres/armas distintas precisam de variação reconhecível; não usar só pitch para caracterizá-las.
- **Revólveres:** ataque mais encorpado, mecânica perceptível, cauda controlada. O movimento do tambor e a abertura/fechamento devem soar separados do disparo.
- **Submetralhadoras:** transiente curto e repetível, cauda limpa para que a cadência não produza um borrão contínuo.
- **Rifles:** ataque forte com corpo e cauda proporcionais. O jogador deve identificar a classe sem depender do HUD.
- **Escopetas:** explosão curta, corpo amplo, ação/pump distinguível; recarga por cartucho deve corresponder à animação.
- **Armas especiais:** manter linguagem comum, mas permitir identidade não convencional quando a modalidade exigir.

Para cada família, especificar **próprio atirador 2D/3D próximo**, **aliado/inimigo a média distância**, **disparo distante**, **mecânica/reload**, **impacto por material**, **passagem/ricochete somente quando o evento existir**. A clareza direcional de inimigos tem prioridade sobre uma reverberação cinematográfica longa. Usar variabilidade moderada por conjunto de amostras, volume e pitch: sem comprometer reconhecimento e sem alterar a cadência percebida.

**Interior/exterior e distância:** produzir caudas diferentes ou usar processamento acústico conforme contexto. Testar se uma parede deve atenuar o som de acordo com o sistema espacial real; não presumir oclusão automática. Sons próprios e de outros jogadores podem precisar de mixes diferentes. Tiros distantes devem informar ameaça sem competir com disparos próximos.

**Timing:** som e flash do tiro imediatamente no cliente do atirador; replicar eventos essenciais aos demais ouvintes sem replicar som por frame. Conectar `Fire`, `Bolt`, `MagOut`, `MagIn`, `Chamber`, `Equip` aos eventos reais. A mudança de munição e permissões de disparo continuam regidas pelo estado da arma; áudio e markers não devem decidir essas regras.

## 4. Movimento e interações

Produza uma matriz de eventos com contexto:

- **Passos:** pé esquerdo/direito via marcadores ou evento locomotor confiável; material de piso (concreto, metal, madeira, grama, terra, água, se existirem); velocidade, walk/sprint/crouch; evitar passos no ar e em personagem parado.
- **Strafe e marcha à ré:** sincronizar a passada correspondente, sem reutilizar ritmo frontal se a animação não o representa.
- **Slide:** início (impulso/roupa), sustentação (fricção por piso e velocidade) e final (recuperação). Encerrar loops suavemente ao interromper o movimento.
- **Pulo e aterrissagem:** impulso discreto, tecido/arma opcional, pouso dependente da intensidade; não repetir som forte em pequenos degraus.
- **Equipamento:** sacar/guardar, mira, manuseio e recargas, com materiais coerentes. Não criar sons ao acaso por variação de câmera.
- **Impactos:** superfície de metal, concreto, madeira, vidro, terra e carne/armadura, se houver essas categorias; evitar tocar simultaneamente impactos incompatíveis.
- **Objetivos:** hack, digitação, acerto/erro de puzzle, conclusão de etapa, abertura de porta, alarme, contador, bandeira e vitória/derrota; priorizar notificações importantes.

**Get Out:** tensão a partir de ambiente, espacialidade e sinais específicos dos mecanismos; não usar música/efeitos que tornem ruídos essenciais impossíveis de perceber. **Arena/Duels:** priorizar legibilidade dos passos, tiros, habilidades e confirmação de acerto.

## 5. Pesquisa fina de fontes — procedimento obrigatório

Não parar no primeiro resultado e **não inventar IDs de áudio**. Para cada evento importante:

1. Definir um *brief acústico* de uma linha: função, tom, duração pretendida, intensidade, distância, referências do próprio projeto.
2. Pesquisar usando variantes em inglês com termos de produção: `dry`, `close`, `mechanical`, `short`, `foley`, `button select`, `UI click soft`, `revolver cylinder`, `magazine insert`, `slide scrape concrete`, `footsteps metal`. Ajustar consultas conforme os sons ouvidos.
3. Priorizar [Roblox Creator Store](https://create.roblox.com/store/audio), [Kenney UI Audio](https://kenney.nl/assets/ui-audio), [Sonniss GDC 2026](https://gdc.sonniss.com/), [arquivo Sonniss](https://sonniss.com/gameaudiogdc/) e [Freesound](https://freesound.org/). Pesquisar por arquivo/sample individual e não apenas pelo nome da coleção.
4. Para eventos principais, fazer **shortlist de 3–5 candidatos realmente localizados**: URL da página, nome exato, autor, licença, duração/formato quando conhecidos, impressão auditiva **somente se houve escuta** e motivo da seleção. Nunca transformar suposição de busca em auditoria auditiva.
5. Preferir CC0/royalty-free comprovado quando possível. Para CC BY, registrar créditos; não presumir que toda licença Creative Commons seja comercialmente compatível. Para arquivos importados, verificar acesso/permissões da experiência Roblox.
6. Ouvir candidatos isoladamente e em contexto (menu real, disparo repetido, múltiplos jogadores), fazer comparação A/B e escolher pela função — não apenas pela qualidade do sample isolado.
7. Se não houver acesso aos arquivos/áudio da rede, entregar a shortlist documentada e passos de audition, marcando **não ouvido**. Não declarar SFX integrado sem o asset ser validado e autorizado.

**Manifest obrigatório por asset:** `event_key`, `source_url`, `original_filename`, `creator`, `license`, `attribution_text`, `file_hash` (se disponível), `duration_ms`, `variation_set`, `asset_id`, `visibility/permissions`, `status` (`candidate`, `auditioned`, `approved`, `uploaded`, `integrated`), `notes`. Manter arquivos originais e versões trabalhadas distinguíveis.

## 6. Tratamento e mixagem

- Remover silêncio desnecessário antes do ataque; evitar pops em recortes; aparar caudas longas que se acumulam; normalizar **percepção de volume**, não automaticamente todos os picos para o mesmo valor.
- Usar EQ/compressores apenas quando o sample exigir; preservar transientes e dinâmica útil. Comparar com volume baixo e em alto-falantes de celular.
- Organização de mix sugerida: `UI`, `WeaponsLocal`, `WeaponsWorld`, `Movement`, `Impacts`, `Objectives`, `Ambience`, `Music`. Esses são **barramentos lógicos**, não uma obrigação de instanciar oito SoundGroups.
- Se o projeto ainda usa `Sound` e `SoundGroup`, avaliar custo/benefício antes de migrar. Documentação atual recomenda objetos modulares (`AudioPlayer`, `AudioEmitter`, `AudioListener`, `Wire`, `AudioEqualizer`, `AudioCompressor`, `AudioReverb`). Escolher arquitetura compatível com o projeto e o rollout; prototipar antes de uma migração completa.
- 2D para menus, indicadores locais e música; 3D para ameaças e interações no mundo. Definir distâncias/atenuação por função. Não aplicar reverb global a tudo.
- Pré-carregar **somente os essenciais** para a primeira interação/arma inicial e interface inicial; não carregar a biblioteca inteira ao entrar no jogo.
- Pooling/reutilização para eventos repetidos; não interromper uma instância única de disparo quando outra bala é disparada. Limitar simultaneidade com regras de prioridade audível.

## 7. Integração com animações e estados

Definir vocabulário estável de eventos compartilhados: `UI.Navigate`, `Weapon.Fire`, `Weapon.MagOut`, `Weapon.MagIn`, `Weapon.Bolt`, `Movement.FootLeft`, `Movement.FootRight`, `Movement.SlideStart`, `Movement.SlideStop`, `Movement.Land`, `Objective.Completed`.

Marcadores de animação podem sincronizar contatos físicos e ações cosméticas, mas cada evento precisa de fonte de verdade clara: **o movimento/arma controla o estado**, a animação e o som o apresentam. Prever abortos (morte, troca de arma, sprint, fim de partida), evitando sons atrasados de animações canceladas.

## 8. Entrega e critérios

Entregar: auditoria antes/depois, mapa de eventos, shortlist linkada e avaliada, manifest de licenças/IDs, alterações pontuais, amostras aprovadas quando acessíveis, e teste ouvido em gamepad/PC/celular quando disponível. Critérios:

- Navegar rapidamente por menus não produz cacofonia nem sons duplicados.
- Ações confirmadas soam diferentes de foco e erro.
- Armas são distinguíveis e audíveis em rajadas; som local parece imediato.
- Passos, slide, pulo, reload e impactos estão sincronizados com ações reais.
- Informações cruciais continuam audíveis durante combate intenso.
- Nenhum ID/arquivo indisponível é apresentado como validado.

## Referências verificadas

- Roblox — [Audio objects](https://create.roblox.com/docs/audio/objects), [Effects](https://create.roblox.com/docs/audio/effects), [Audio assets](https://create.roblox.com/docs/audio/assets), [Asset privacy](https://create.roblox.com/docs/projects/assets/privacy), [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider), [Performance](https://create.roblox.com/docs/performance-optimization/improve).
- Roblox — [Animation events](https://create.roblox.com/docs/animation/events).
- [Kenney UI Audio](https://kenney.nl/assets/ui-audio) (CC0); [Sonniss GDC 2026](https://gdc.sonniss.com/) e [licença](https://sonniss.com/gdc-bundle-license/); [Freesound FAQ](https://freesound.org/help/faq/).
