# Cascatas sólidas e separação de profundidade

**23/10/2026 — aplicado no Studio, sem publicação.**

**Atualização posterior:** [cursor lateral, foco e som de navegação](CONTROLE-CURSOR-FOCO-SOM.md). O novo pacote cumulativo também inclui estas cascatas sólidas.

O trecho destacado na captura combinava painéis translúcidos com uma sobreposição de 12 px entre colunas. O cenário e as bordas se misturavam nessa faixa.

## Alterações

- Fundo sólido nos painéis de cascata, preservando bordas e cantos arredondados.
- Intervalo de **8 px** entre colunas, eliminando a faixa sobreposta.
- Sombra em gradiente no fundo das seções anteriores: **8%**, **14%** e **20%** conforme ficam um, dois ou três níveis atrás. Limite de 24% para profundidades maiores.
- Painel ativo sem sombra.
- Decoração posicionada atrás dos controles, sem seleção ou captura de input.
- Transição respeita Reduzir movimento dos menus.
- Área externa à cascata continua transparente e só aparece enquanto o menu está aberto. Regra de blur por profundidade preservada.

Implementação compartilhada por MenuTheme/CascadeMenu e aplicada também ao menu de opções, que possui seu próprio layout. Isso abrange perfil/amigos, lobby/modalidades, kits, playlist e votação.

## Verificações no Studio

| Caso | Resultado |
|---|---|
| Perfil com duas colunas | Fundos opacos; intervalo de 8 px; sombra apenas na anterior |
| Opções → Controles → Mira, quatro colunas | Todos opacos; três intervalos de 8 px; sombras de 20% / 14% / 8% / 0% |
| Capturas após a alteração | Sem a faixa transparente sobreposta apontada pelo usuário |
| Clique no botão Continuar da coluna anterior | Activated e MouseButton1Click recebidos; menu fechado |
| Fontes do projeto | 128 compiladas, sem erros e sem divergência do snapshot |

As verificações foram visuais e de interação no Studio. Não foram acrescentados testes unitários para esta alteração de apresentação. Aparelhos móveis e controles físicos não foram testados nesta etapa.

Na última sessão, o console não apresentou novos erros destes controladores; permanecem mensagens do plugin externo GUIEditor, da ferramenta e um aviso de personagem ainda não disponível na inicialização.

## Preservação e pacote

Três fontes alteradas: **MenuTheme**, **CascadeMenu** e **ExperienceMenu**. Backup: ServerStorage.SolidCascadeBaseline_20261023. Sistemas de gameplay e legado preservados.

[Incremental de três fontes](../artifacts/crossgrounds-cascatas-solidas-2026-10-23.rbxm): **18.925 bytes**. SHA-256: **C8864066F94CA3EA142B270D20133173721A97AA0B5FE28643E930B32F593866**.

Aplicar sobre o pacote de acessibilidade/AA anterior, substituindo as três fontes por serviço sem duplicar controladores. O projeto aberto já está atualizado; não reimportar nele. Não é um Place completo nem instalador automático. Instalação remota não testada. Nenhuma publicação realizada.
