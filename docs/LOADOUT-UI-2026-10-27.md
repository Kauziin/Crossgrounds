# Seleção de Loadout da Arena

Aplicada na experiência principal **Crossgrounds (ALPHA)**, Place ID **4375993208**. O redesenho atua somente no ramo de Loadout da Arena dentro de ExperienceMenu e no novo módulo LoadoutMenuView. O menu lateral e os demais fluxos permanecem existentes. A interface de Loadout do CTF não foi substituída.

## Apresentação

Seis cards em duas colunas e três linhas: M1911, Magnum, Glock 18, Desert Eagle, Luger P08 e Beretta M9. Cada card contém número, nome, miniatura 3D e indicação explícita de Executor como corpo a corpo. O loadout ativo ou pendente recebe o contorno turquesa. O foco de navegação continua distinto e permite inspecionar uma arma antes de confirmar a escolha.

O painel de equipamento apresenta a arma ampliada e uma seção separada com a espada Executor. Não há barras ou números de dano, controle ou mobilidade. O foco pode mudar a prévia, mas somente a confirmação envia a seleção pelo evento existente.

Em larguras menores, a prévia passa para baixo da grade. A rolagem revela os cards focados. A área do Loadout reserva espaço para o aviso admin e restaura o tamanho original da lista ao sair desta tela. Escalas de menu e fonte são consideradas no layout.

## Modelos

As prévias foram construídas a partir da WeaponFactory atual da experiência principal e gravadas em `ReplicatedStorage.Crossgrounds.LoadoutPreviews`. São sete Models, com 330 partes visuais ancoradas, sem Tool, scripts, sons ou colisão. A biblioteca não é equipamento de jogador.

O gerador reproduzível é `tools/build_loadout_previews.luau`, para execução deliberada no Edit. Ele preserva uma biblioteca já existente em vez de substituí-la automaticamente.

## Seleção e validação

O evento `SelectLoadout` e LoadoutService não foram alterados. As definições das armas também foram comparadas antes/depois e permaneceram intactas.

Na cópia isolada, o teste entrou na Arena pelo fluxo normal de join/enter. O personagem usava Magnum e Executor. A confirmação de Beretta criou `PendingArenaLoadout=Beretta`, preservando o personagem, a Magnum ativa e os mesmos dois objetos Tool. Após a morte e o renascimento reais na Arena, o personagem recebeu Beretta M9 e Executor, e a preferência pendente foi consumida.

Também foram verificados:

- Desktop em 1366 × 767 e iPhone 17 Pro em paisagem, com viewport efetivo de 749 × 381.
- D-pad entre os cards, atualização da prévia e confirmação pela navegação registrada.
- Oito ViewportFrames: seis miniaturas, arma ampliada e Executor. Todos os cantos dos modelos ficaram dentro das câmeras, com projeção máxima menor que 0,88 da área útil.
- Ao abrir Interface depois de Loadout, nenhum ViewportFrame permaneceu no menu e o tamanho original da lista foi restaurado.
- Compilação dos dois scripts, verificação de leitura após aplicação na principal e preservação de LoadoutService e KitDefinitions.

Os testes de execução ocorreram na cópia separada; a sessão principal permaneceu em Edit e não foi publicada. Controle físico e multitoque real não foram testados. Avisos preexistentes de plugins e assets na cópia ficaram fora deste escopo.

As fontes anteriores e os registros ficam em `artifacts/loadout-2026-10-27`. A cópia de teste teve as dependências de navegação alinhadas à versão principal; essas dependências não foram modificadas na principal por esta tarefa.
