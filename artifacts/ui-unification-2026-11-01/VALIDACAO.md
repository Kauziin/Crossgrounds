# Validação — padronização, temas e interface mobile

Data: 01/11/2026. Place principal: 4375993208, Crossgrounds (ALPHA). Implementação local aplicada ao editor principal; sem publicação ou push. Fontes de ADS/áudio que já estavam alteradas foram preservadas.

## Resultado implementado

- MenuTheme e AccentTheme compartilham superfícies, botões, bordas, raios e estados de seleção entre as famílias existentes. MouseEnter/MouseLeave também desenham o contorno de navegação nos botões e seletores registrados. A estrutura própria de cada fluxo continua sendo usada.
- Nomes principais alinhados: Configurações, Progressão e Armamentos. Pausa recebeu ícones e o HUD CTF passou a ordenar vida, arma/munição, estamina e slots como a Arena. A votação compartilha o estado MenuSelected.
- Configurações estreitas mostram o painel ativo, sem abas de categoria duplicadas. A lista de remapeamento no iPhone passou de 34 px na análise anterior para 141 px antes da redução global solicitada posteriormente. Essa medida não representa a altura física final após a escala de 60%.
- Painel Temas dedicado com 22 opções livres, amostras de três tons e marcador de seleção. A cor atinge superfícies, bordas, seleção, barras de rolagem e gradientes azuis/cianos; cores semânticas e artes preservadas. Paleta corrige contraste de cores personalizadas muito escuras.
- HSV preparado para gamepass. CustomThemePassId=0 em src/ServerStorage/ThemePassConfiguration.luau porque o passe ainda não foi criado. Sem ID, a compra não é acionada e o editor personalizado fica indisponível. O servidor verifica acesso e rejeita edições protegidas pelos caminhos antigo e novo de preferências. Após cadastrar o ID, o fluxo usa UserOwnsGamePassAsync e revalida após PromptGamePassPurchaseFinished.
- MobileMenuScale exclusivo de Device:Touch, padrão final 0,60 e ajuste entre 0,35 e 1,00. A solicitação inicial de redução de 60% gerou uma prévia em 0,40; o usuário pediu aumento, e o padrão passou para 60% do tamanho original. A redução se aplica ao painel terminado, sem aumentar artificialmente suas dimensões lógicas. Desktop manteve fator 1.
- Zona segura horizontal/vertical de 0 a 20% por lado, adicional aos insets do aparelho. Aplica-se aos menus, blocos do HUD e controles próprios de toque. Arrasto usa coordenadas relativas à área segura; o raio completo do botão permanece dentro dela.
- Slide, Sprint, perspectiva, trava, ombro e atalhos administrativos são opcionais. Podem ser ocultados nas opções de Toque/HUD ou no editor; no editor continuam como prévia apagada para recuperação. Disparo, mira, recarga/interação, pulo e troca de arma não têm chave de ocultação. Salvar/cancelar e padrão preservam o fluxo existente.
- Confirmação de restauração usa MenuDialog e ajusta altura ao conteúdo, evitando recorte de Cancelar. O pulo nativo do Roblox fica oculto enquanto menus/editor estão abertos no toque.

## Testes automatizados

Rodada final em Play/Server: **92 executados, 92 passaram, zero falhas**, distribuídos em nove suítes:

| Suíte | Passaram |
| --- | --- |
| ThemeAndInterface | 16/16 |
| MobileMenusAndSafeZone | 6/6 |
| PreferenceDrafts | 8/8 |
| PreferenceProfile | 8/8 |
| SharedBindingsAndIronSights | 5/5 |
| Plan8Arsenal | 15/15 |
| WeaponMovement | 15/15 |
| PistolReloadAndArt | 15/15 |
| AX50Prototype | 4/4 |

Os 22 novos casos cobrem catálogo, acesso, fallback, contraste, migração, isolamento de dispositivo, escala, área útil, botões essenciais/opcionais, preservação de false, limites geométricos em três tamanhos e arrasto sem salto. A primeira rodada revelou uma expectativa antiga de TouchFireX=.96; foi corrigida para 1, coerente com o domínio normalizado já existente de 0..1. A contenção do raio e da zona segura tem testes separados de geometria; o limite funcional de coordenada não foi reduzido para satisfazer a expectativa antiga. Resultados finais em unit-final-mobile.json; resultados intermediários foram preservados.

## Verificação em Play e simulador

- iPhone 17 Pro landscape: captura 874×402, viewport do Studio 750×382; jogo LandscapeSensor. Desktop/Xbox One simulado: 1920×1080. Sem teste portrait, pois o jogo é landscape.
- Padrão final mobile confirmado em sessão nova: SettingMobileMenuScale=0.6 e UIScale=0.6000000238. Painel mediu aproximadamente 435,6×182,4 px sem margem extra; desktop mediu fator 1 ao trocar o dispositivo.
- 22 presets construídos no cliente. Ciclo entre Laranja, Prata, Crossgrounds e Cereja confirmou atualização das superfícies e retorno sem acumular mudança de tom. Fixture de UIGradient passou por mudança de tema e retorno exato à cor anterior. Rolagem no Cereja retornou RGB normalizado 1,0.392157,0.517647.
- Mouse moveTo gerou borda de 2 px e FocusOutline visível; contorno 195×80 em botão 189×74, com margem de 3 px. Não é validação de controle físico.
- Escalas de fonte/menu ampliadas reorganizaram a grade do telefone de quatro para duas colunas na rodada anterior à redução global mobile. O último preset continuou acessível por rolagem/foco.
- Diálogo final com escala mobile 0,6: Cancelar integralmente dentro do conteúdo. Nenhuma restauração de categoria foi confirmada.
- Zona segura testada com X=0,12 e Y=0,10. Cancelar o editor manteve o perfil anterior; ocultar Sprint e salvar gravou false no perfil Touch; entrar em CTF e depois Arena preservou a ocultação. Fire permaneceu visível e seu controle de ocultação permaneceu desativado. Margens foram restauradas a zero durante a sessão de revisão.
- Atributo de acesso personalizado falsificado somente no cliente permitiu prévia dos três controles HSV, mas o servidor rejeitou a seleção protegida. O atributo foi restaurado e as fixtures desapareceram ao parar Play. Não é simulação de uma compra confirmada.
- Preferências no Studio indicam StudioSessionOnly: essas operações não gravaram no DataStore de produção.

## Evidências e limites

Capturas finais: temas-mobile-final-60.jpg e configuracoes-mobile-final-60.jpg. editor-zona-segura.jpg e hud-ctf-zona-segura.jpg mostram a margem de teste. As demais capturas registram etapas anteriores, incluindo o layout sem redução global, o diálogo corrigido e a paleta Cereja antes da inclusão final da barra de rolagem no tema. Os 13 JPEGs foram abertos e verificados pelo Pillow.

25 fontes de runtime compilaram com loadstring e coincidem com o principal; final-source-match.json registra os caminhos. git diff --check passou. Backups anteriores à etapa em before/. Instrumentação de navegação e módulos de teste foram temporários em Play; não integram as fontes de inicialização.

A navegação programática chamou MenuNavigation/callbacks reais por uma ponte temporária por causa das limitações de foco das ferramentas do Studio. Não comprova todos os gestos físicos, gamepad, joystick nativo, desempenho, multiplayer humano ou acessibilidade em aparelhos reais. Não foram repetidos todos os estados únicos da análise anterior após cada alteração; Get Out/Duels continuam indisponíveis pelo catálogo. Nenhuma compra real, persistência em produção ou autorização de um proprietário real foi validada. O ID do gamepass permanece pendente. Avisos preexistentes de assets sem acesso/arquivados e erro do plugin GUIEditor não foram corrigidos nesta etapa.
