# Correção da navegação de controle — 23/10/2026

Aplicada ao Place 4375993208 (ALPHA), sem publicação. Correção posterior ao pacote de Bots/UI.

## Causa e alterações

A integração anterior mantinha SelectedObject ativo com navegação e seleção automáticas habilitadas. O cursor próprio também processava os mesmos comandos. Isso permitia que a navegação nativa disputasse D-pad/analógicos e retomasse o foco. Após o usuário esclarecer que se referia ao seletor de botões com borda, a correção foi ampliada: desativar apenas a navegação automática era insuficiente enquanto SelectedObject continuava preenchido.

- MenuNavigation desativa GuiNavigationEnabled e AutoSelectGuiEnabled fora do menu oficial do Roblox e mantém SelectedObject vazio. Nenhum foco próprio é enviado ao seletor nativo; o destaque continua no FocusOutline/FocusGlow próprios. Uma seleção nativa externa também é limpa enquanto o jogo possui a navegação.
- O cursor virtual é desativado diretamente, sem depender de uma leitura de estado para executar DisableGamepadCursor. Existe proteção de reentrada e retomada da política após alterações externas.
- Analógicos são capturados pela navegação própria enquanto um menu do jogo está aberto. Gameplay e remapeamento continuam com seus respectivos controles.
- Quando GuiService.MenuIsOpen é verdadeiro, os valores originais de navegação são restaurados e o cursor próprio fica oculto. Ao fechar, o foco próprio é recuperado; entradas mantidas são limpas para evitar deslocamento residual.
- Mouse volta a ficar visível ao trocar para teclado/mouse nos menus ou lobby.
- CombatPresentation deixou de manter outro observador concorrente do cursor nativo e respeita o menu oficial. Menus de combate não reexibem o ícone de mouse no controle.
- Corrigido self:ClearShots() em uma função local de liberação: o receptor correto é Presentation. O erro interrompia a saída da câmera dedicada ao perder o equipamento/sair do modo.

Fontes: src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau e CombatPresentation.luau.
Backup: ServerStorage.ControllerCursorBaseline_20261023 (duas fontes originais).

## Verificações reais no Studio

- A, D-pad e A: duas confirmações produziram exatamente duas ativações, com foco no segundo botão.
- ButtonSelect não reativou seleção automática/cursor nativo.
- Tentativa de reativar GuiNavigationEnabled/AutoSelectGuiEnabled foi revertida para false.
- EnableGamepadCursor pôde ser chamado no fixture; não ativou cursor nesta sessão sem controle físico. Isso não é prova de uma ativação física seguida de supressão.
- ButtonStart abriu o menu oficial: navegação/seleção nativas ficaram habilitadas e o cursor próprio foi ocultado.
- ButtonStart fechou o menu oficial: navegação automática voltou a false e o cursor próprio reapareceu.
- Analógico direcional sintetizado e D-pad mantiveram input Gamepad, cursor nativo false e ícone de mouse oculto.
- Clique do mouse mudou input para KeyboardAndMouse e restaurou seu ícone.
- Entrada real na Arena adquiriu a câmera; saída para Hub liberou a câmera sem erro dos scripts alterados.
- Sem mensagens de erro de MenuNavigation/CombatPresentation no console da última sessão.
- Não foi repetida a suíte de 133 testes de bots/combate: as alterações são de navegação/câmera do cliente. Foram executadas as verificações de integração acima.

Ainda é necessário testar com controle físico Xbox/PlayStation, incluindo prompts, teclado virtual e painéis de compra/inspeção da plataforma. Os comandos desta sessão foram sintetizados pelo Studio; não se declara validação física concluída.
A propriedade StarterGui.VirtualCursorMode não pôde ser lida por Luau nesta sessão; a correção não depende dela.

## Evidências

```json
{
  "buttons": {
    "nav": false,
    "count": 2,
    "focus": "PadProbeB",
    "input": "Gamepad",
    "selected": "PadProbeB",
    "native": false,
    "auto": false
  },
  "coreOpen": {
    "core": true,
    "auto": true,
    "custom": false,
    "navigation": true
  },
  "coreClosed": {
    "core": false,
    "auto": false,
    "custom": true,
    "navigation": false
  },
  "finalPad": {
    "core": false,
    "auto": false,
    "focus": "shipment",
    "input": "Gamepad",
    "nav": false,
    "icon": false,
    "native": false
  },
  "mouse": {
    "camera": true,
    "input": "KeyboardAndMouse",
    "nav": false,
    "icon": true,
    "native": false
  },
  "cameraRelease": {
    "before": true,
    "nav": false,
    "auto": false,
    "active": false,
    "mode": "hub",
    "native": false,
    "icon": true,
    "done": true
  }
}
```

## Pacote

artifacts/crossgrounds-controle-cursor-correcao-2026-10-23.rbxm contém apenas as duas fontes. Aplicar **após** o pacote anterior de Bots/UI em outros Places, copiando as fontes aos caminhos equivalentes. O projeto aberto já está atualizado. Não substituir mapas ou serviços inteiros.

Na validação intermediária, 151 fontes compilaram sem erro. Após a correção específica do seletor, as duas fontes do pacote foram compiladas e verificadas novamente por serialização/desserialização contra o projeto. Pacote atualizado de 20.461 bytes; SHA-256: C8426822792BF282C42B6F486081BC011517C5F3FE4280F95965D7C63C18D6B9.

Referências: [GuiService](https://create.roblox.com/docs/reference/engine/classes/GuiService) e [GamepadService](https://create.roblox.com/docs/reference/engine/classes/GamepadService).

## Correção específica do seletor de botões

Teste posterior ao esclarecimento: duas confirmações com A = duas ativações, D-pad moveu o foco próprio para SelectorProbeB, ButtonSelect não criou seleção nativa. SelectedObject permaneceu nil; uma seleção externa forçada foi limpa. Borda e cursor próprios permaneceram visíveis. Alterada somente MenuNavigation nesta correção adicional; backup MenuNavigationBeforeSelectorFix_20261023 no ServerStorage. As evidências anteriores de SelectedObject preenchido descrevem a versão intermediária, superada por esta alteração. Controle físico continua pendente.
