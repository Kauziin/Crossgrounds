# Testes locais

Esta pasta fica fora de `src` e não deve ser sincronizada automaticamente com o Place de produção. Os testes foram retirados de ServerStorage, ServerScriptService e StarterPlayerScripts em 26/10/2026.

## Contratos de módulos

`Unit/` contém `RunUnitTest.luau`, `Cases/` e um runner manual. Em uma cópia separada do Place com os módulos do jogo, importe `Unit` como Folder, `RunUnitTest` e os casos como ModuleScripts. O runner procura `Cases` relativamente à própria pasta:

```lua
-- Exemplo em ServerStorage, somente no Place de testes:
local result = require(game.ServerStorage.Unit.RunUnitTest)()
-- Filtro opcional pelo nome do módulo:
local getOut = require(game.ServerStorage.Unit.RunUnitTest)("GetOut")
```

Se importar `UnitTestRunner.server.luau` como Script na mesma pasta, mantenha-o desativado até uma execução deliberada. A chamada pela Command Bar dispensa esse Script.

## Regressão atual de interações e movimento

`Integration/GetOutActionRegression.server.luau` e `GetOutActionRegression.client.luau` exercitam os controles e as remotes normais do cliente, incluindo segurar/cancelar interação, checks de hack, martelo, corda, cápsula, resgate, Runner, rastejamento, janela, manivela e fuga. As posições iniciais dos cenários são preparadas pelo servidor; a suíte não substitui uma sessão humana de balanceamento.

Em uma cópia isolada do Place atualizado, importe o primeiro como Script de ServerScriptService e o segundo como LocalScript de StarterPlayerScripts. Pela Command Bar/plugin, execute:

```lua
game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(3,"GetOutActionRegression")
```

Use `Integration/GetOutActionProbe.server.luau` e `.client.luau` com dois clientes e argumento `GetOutActionProbe` para o diagnóstico curto. `GetOutMovementVisual.server.luau` usa o cliente de regressão e o argumento `GetOutMovementVisual` com dois clientes para a conferência complementar de salto/animação. Execute uma suíte por vez. Os scripts de servidor só iniciam com o argumento explícito correspondente e em Studio.

As fixtures são temporárias. Não importe testes no Place publicado nem acrescente hooks de QA ao bootstrap. Ao terminar, retire os Scripts/LocalScripts de teste da cópia que será usada pelo jogo.

## Suíte histórica de perseguição

`Integration/GetOutP0Smoke.luau` e `Integration/GetOutP0TestClient.luau` preservam as fontes da suíte usada na validação de perseguição. **Esses arquivos dependem da instrumentação de teste antiga e não são diretamente executáveis no Place atual.** O bootstrap não responde mais ao argumento `GetOutP0`, o cliente não suspende controles por `GetOutP0Testing` e a sinalização exclusiva `GetOutClientReady` foi retirada.

Para reproduzir a suíte histórica, prepare uma cópia isolada do Place com os objetos do [pacote original](studio-tests-before-organization.rbxm) e a instrumentação preservada em [runtime-before](../artifacts/storage-organization-2026-10-26/runtime-before). Isso exige integração deliberada no Place de testes; inserir apenas o pacote não reinstala os pontos de entrada. Não substitua os scripts atuais do jogo por essas fontes antigas.

Os resultados anteriores continuam registrados no [relatório de validação](../artifacts/get-out-v05-validation-2026-10-26.md). Eles descrevem a execução anterior à organização, não uma nova execução da suíte.
