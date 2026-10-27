# Controle: cursor, foco e som de navegação

**23/10/2026 — aplicado no Studio, sem publicação.**

## Alterações

- O indicador visual do controle fica **na lateral do botão selecionado**, fora da área do texto. A posição lógica usada pelo analógico continua dentro do controle, preservando o cálculo de hover e navegação.
- Quando falta espaço à esquerda, o indicador pode usar a direita ou a parte superior. Sem espaço seguro, permanece o destaque do controle e o indicador é ocultado.
- Em áreas livres, o cursor continua acompanhando o analógico.
- Foco com **contorno arredondado de 4 px** e brilho externo de 10 px. Não desloca o layout nem altera cores de estado dos cards.
- Destaque também funciona na navegação pelo teclado. O cursor dedicado permanece exclusivo da navegação por controle em menus.
- Som curto ao mudar para outro controle interativo. Manter o mesmo foco não repete o áudio; há intervalo mínimo de 75 ms entre sons.
- Novo ajuste **Opções → Áudio → Sons de navegação**, padrão 0,18, com possibilidade de zerar. É independente do volume da música.

Som usado: [Smaltra UI tick, de Porevoz](https://create.roblox.com/store/asset/75458150587771), encontrado no Creator Store. Carregamento confirmado no Studio, status Success e duração aproximada de 0,0415 s. O carregamento ocorre em tarefa separada; indisponibilidade do áudio não bloqueia a navegação.

## Verificações

| Caso no Studio | Resultado |
|---|---|
| Card Arena focado com Gamepad simulado | Cursor visível à esquerda; sua área não cruza a área do botão/texto |
| Destaque | Contorno de 4 px e brilho visíveis, confirmados por captura |
| Analógico simulado dentro do card | Posição lógica avançou aproximadamente 135 px; foco continuou em Arena e indicador visual permaneceu fora do texto |
| D-pad | Seleção mudou de Arena para Get Out |
| Botão A | Abriu detalhes do modo selecionado |
| Som ao trocar foco | Contador avançou; evento Played recebido com volume 0,18 |
| Mesmo foco repetido 15 vezes | Nenhuma repetição do som |
| Volume zero | Navegação sem novo disparo de áudio |
| Ajuste em Áudio | Linha presente; servidor aceitou o valor 0,3 |
| Fontes finais | 128 compiladas sem erros; sem divergência do snapshot aplicado |

Não foram adicionados testes unitários para esta alteração de apresentação. A validação usou input simulado, scripts normais de cliente e capturas no Studio. Controle físico, saída sonora em aparelhos reais, multitoque e persistência publicada do novo ajuste ainda não foram testados.

Na última sessão permaneceram mensagens do plugin externo GUIEditor e avisos da ferramenta/ContextActionService; não foram encontrados novos erros nas fontes alteradas.

## Preservação e pacote

Três fontes alteradas: MenuNavigation, ExperienceSettings e ExperienceMenu. Backup em **ServerStorage.MenuFocusFeedbackBaseline_20261023**. Cascatas sólidas, blur por nível, ícones de plataforma, remapeamento, ajustes de mira e gameplay foram preservados.

[Pacote cumulativo](../artifacts/crossgrounds-controle-foco-som-2026-10-23.rbxm): **92.859 bytes**, 27 fontes de runtime sobre Bugs23. Inclui as entregas anteriores de UI, cascatas sólidas, lobby/playlist/progresso e aim assist.

SHA-256: **429CCE9E7BEF457DFB0262E355D26DAF5E257B58E0B09C9FE6BB176F4C3AE762**.

Substituir/adicionar por serviço sem duplicar controladores. O projeto aberto já está atualizado; não reimportar nele. O pacote não é um Place completo nem instalador automático e não inclui mapas ou todas as dependências anteriores. Total de runtime permanece 106 fontes. Instalação remota não testada. Nenhuma publicação realizada.
