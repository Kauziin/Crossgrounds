# Porte da assistência e dos perfis gráficos

Implementação de 27/10/2026 baseada no estudo do Projectile Test e no plano de integração. Sete fontes de runtime testadas em cópia isolada e incorporadas ao Studio principal em Edit, com comparação prévia integral das quatro fontes existentes e confirmação das sete escritas. Backup: ServerStorage.Development.Revisions.ProjectilePortBaseline_20261027. O pedido posterior de aguardar chegou após esse merge; novas alterações no principal foram interrompidas.

## Assistência

A arquitetura existente foi refinada com Friction independente do acompanhamento e um filtro de intenção por dispositivo. Toque expira em 100 ms usando tempo decorrido positivo e exige o dedo de mira ativo; input acumulado anterior a um hitch é descartado. Perder foco da janela bloqueia a atualização da câmera até recuperar o foco. Troca de arma, ausência de personagem, menus e dispositivo limpam os estados. Soltar o input limpa velocidade e tempo de aquisição do Tracking. Mouse continua sem assistência; analógico esquerdo não fornece intenção de mira.

Mantidos o acompanhamento parcial do movimento visível, limites de rotação, seleção por corpo/visibilidade/equipe/proteção e configurações independentes. Não houve transferência do Centering defeituoso ou do Spherecast tolerante do sample. As regras autoritativas de disparo continuam no sistema de combate existente.

## Gráficos

Opções → Gráficos → Qualidade gráfica, com quatro perfis globais persistíveis pelo serviço de preferências existente:

| Perfil | Sombras globais | Sombras de luzes locais | Bloom | SunRays |
| --- | --- | --- | --- | --- |
| Desempenho | Desligadas | Desligadas | 0 | Desligados |
| Equilibrado (padrão) | Ativas se existentes na base | Desligadas | 0,06 | Desligados |
| Alto | Ativas se existentes na base | Conforme a luz original | 0,12 | 0,02 |
| Visual | Ativas se existentes na base | Conforme a luz original | 0,20 | 0,035 |

Correção de cor leve por perfil. Profundidade de campo somente no perfil Visual durante AdminFreecam; desligada no combate. Horário, cores de ambiente e Atmosphere continuam sob o controlador de iluminação do mapa. A configuração global de qualidade do Roblox não é modificada.

Efeitos puramente cosméticos podem receber a tag CrossgroundsQualityCosmetic e o atributo MinGraphicsQuality (1–4; padrão 3), desde que não sejam avisos de combate. Sem tag, partículas/traçantes não são ocultados. Luzes e cosméticos carregados por streaming são tratados incrementalmente, sem varredura por frame. O controlador restaura propriedades capturadas ao ser destruído. Blur dos menus é preservado.

Isso implementa uma camada local de qualidade inspirada no acabamento do Projectile Test; os mapas, modelos e materiais da experiência de referência não foram importados.

## Evidências e limites

- Sete fontes compiladas no Studio e conferidas contra as fontes da cópia, normalizando apenas quebras de linha.
- 24 contratos aprovados: 16 AimAssist, quatro AnalogFilter e quatro novos de toque/foco/input inválido/perfis.
- Play na cópia: quatro perfis aplicados via PreferenceClient com eco da configuração; valores de efeitos e sombras conferidos.
- Mantidos ClockTime e Ambient; profundidade de campo habilitou em fotografia Visual e desligou ao sair dela.
- Menu acessado com mouse/Enter reais pela ferramenta; captura confirmou Gráficos e o valor EQUILIBRADO na cascata de opções.
- Sem erros no histórico do cliente durante a primeira sessão. Chamadas de inspeção que exigiram MenuNavigation criaram um contexto separado de módulo e geraram avisos de ContextActionService; a sessão foi reiniciada e a conferência de UI foi feita por input nativo.

Sem teste de controle físico, multitoque real, benchmark de frame time/memória ou persistência após reconexão publicada. Perfis mais leves são funcionais, mas ganho de FPS não foi medido. A cópia completa foi construída do backup local CrossgroundsAlphaCopy-CTF.rbxl com fontes locais atuais; pode não conter geometria de mapas editada depois desse backup. O merge para o principal é restrito às sete fontes e preserva seus mapas e assets atuais. Nenhuma publicação realizada.

Artefatos: artifacts/projectile-port-2026-10-27, com cópia de trabalho, baseline das quatro fontes existentes e diff do merge local. O teste ProjectilePort_Test permanece manual no runner de contratos.

Cópia final gerada: Crossgrounds-Projectile-Port-Final.rbxl. A sessão de Play usou a cópia anterior com o mesmo porte, atualizada em Edit para desabilitar Bloom/SunRays antes da inicialização. O arquivo Final contém essa atualização e os testes; não foi reaberto para economizar memória a pedido do usuário.
