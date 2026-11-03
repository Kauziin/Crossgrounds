# Configurações Neo — validação

Implementado NeoSettingsLayout com uma única página visível: categorias, subcategorias ou opções. Layout separado do ramo Clássica, reutilizando callbacks e componentes de preferências existentes. Lista sem caixas permanentes, título de categoria em destaque, linhas de configuração transparentes e contorno no foco. Proteção NeoSettingsPage evita que atualização de tema recoloque painéis opacos. Escala de conteúdo passa pelo fator efetivo do painel para manter geometria dos controles no mobile.

Fontes desta etapa: NeoSettingsLayout.luau (novo), ExperienceMenu.local.luau, SettingsCard.luau e MenuTheme.luau. Sem novas regras de dados, remotes, HUD ou diagramas #11b.

Play novo após fontes finais. Conferidos: categorias com somente Options visível e transparente; caminho Mira e Câmera/Câmera; opção Interface; Controles/Analógicos. Alteração de killfeed pelo callback real true→false→true, restaurado o valor inicial. Alternância Clássica/Neo preservou a página e restaurou atributos/escala de cada apresentação. No mobile, a primeira expectativa do teste supunha colunas Clássica visíveis; foi corrigida porque a Clássica já oculta as colunas em modo compacto. Verificação correta confirmou escala Clássica 0.6 e Neo 1, sem reescrever a preferência mobile.

Capturas: categorias e Interface no desktop (viewport atual do Studio); Interface no iPhone landscape 874x402, viewport 750x382. Painel mobile 702x304, lista 678x176, linha InterfaceStyle 672x82 e seletor 270x44 px. Rolagem necessária para demais opções; não equivale a teste de toque físico.

Treze fontes do conjunto runtime foram compiladas e comparadas com o editor; o conjunto inclui fontes anteriores, não treze alterações novas desta etapa. git diff --check passou. Nenhum novo erro das fontes alteradas observado no console; avisos antigos de assets/plugin/TestService permanecem. Repetida com sucesso a verificação Edit após transição do DataModel ao encerrar Play. Play encerrado e simulador padrão.

Não foram adicionados testes unitários espelhando o layout; validação foi de navegação e comportamento real em Play. Sem controle/toque físico, todas as categorias/estados, fonte máxima, produção, persistência, multiplayer ou FPS. Telas de temas, editor de HUD e remapeamento especializados mantêm componentes existentes; suas recriações específicas não foram implementadas. Sem publicação.


## Correção do fundo

Fundo integral separado em ScreenGui sem insets, com conteúdo preservado na área segura. Desktop 1459x748; mobile 874x402 físico versus câmera 750x382. Fundo some ao fechar ou usar Clássica. Captura 04 mostra topo coberto. Igualdade entre tamanho físico e câmera não é uma expectativa válida no simulador mobile; cobertura foi confirmada por dimensão física e inspeção visual.
