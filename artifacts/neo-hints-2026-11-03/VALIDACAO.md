# Neo — gradiente e dicas por ícones

Fundo integral suavizado: transparência base .03 → .07; extremo direito do gradiente .22 → .28, centro .08 preservado. Continua preto, com a mesma cobertura e margens.

Novo NeoNavigationHints compartilhado entre ExperienceMenu e páginas internas NovaHubView: símbolos das ações, teclas em keycaps e glifos nativos de controle fornecidos por InputIcons. A API existente identifica Xbox/PlayStation; remapeamentos de alternância de categoria respeitam ControlRouter. Ajustar, valor personalizado e restaurar aparecem conforme a linha selecionada. Sem palavras de instrução no rodapé Neo; mensagens de captura/resultado de remapeamento continuam textuais. Rodapé legado suprimido quando o novo está ativo.

Mobile: dicas Neo e rodapé global de controle ocultos, inclusive em dispositivos híbridos com TouchEnabled. ExperienceMenu também deixa de mostrar instruções de navegação textuais na Clássica mobile. Botões interativos e navegação existentes preservados.

Validação em Play novo:
- Teclado desktop: ícones/teclas, Enter com imagem em vez de caractere sem suporte, status sem instruções textuais.
- Contexto de slider: ajustar, valor personalizado e restaurar presentes.
- Apresentação Gamepad simulada temporariamente no cliente: glifos nativos Xbox, seleção e rodapé único. Não equivale a controle físico ou console real.
- iPhone 17 Pro paisagem: tela física 874×402 e viewport 750×382; dicas e rodapé legado ocultos; fundo integral. Clássica mobile também sem instruções. Página de modalidades Neo aberta e sem dicas.
- Captura de remapeamento real iniciada e expirada sem aplicar tecla: ícones escondem durante captura e retornam depois. Essa verificação foi repetida em Play novo após o último ajuste.
- Quinze fontes do conjunto compiladas antes da aplicação; git diff --check passou. Console sem novo erro observado nas fontes alteradas; avisos antigos de assets, plugin GUIEditor e TestService permanecem.

Capturas 01-teclado.png, 02-controle.png e 03-mobile.png inspecionadas. Elas antecedem apenas a proteção adicional de tipo da regra e a atualização imediata ao iniciar captura de remapeamento, verificadas posteriormente em Play novo.

Limites: sem teste físico de teclado/controle/toque, PlayStation, todas as telas legadas ou persistência em produção. Alterações visuais concentradas nos menus Neo já migrados; não houve migração integral das demais interfaces. Sem publicação ou #11b.
