# Crossgrounds — plano de refinamento visual das armas v0.4

**Revisão:** 23/10/2026. **Estado:** planejamento; nenhuma alteração de modelo, animação ou combate foi aplicada por este documento. O código local pode mudar enquanto outra solicitação trabalha no Studio; reconferir o inventário antes da execução.

## Ponto de partida

O `WeaponFactory.luau` local produz modelos geométricos (`ModelVersion=5`) com peças soldadas. `FirstPersonRenderer.luau` usa `ViewportFrame` e um `LocalLightingProbe.luau`; a fidelidade da iluminação e a camada em relação ao HUD ainda exigem conferência visual no Studio. As notas de [pegada e câmera](ARMAS-PEGADA-PULO-CAMERA.md) registram modelos e mãos procedurais, com animações autorais incompletas. As [notas da Arena](BALISTICA-PISTOLAS-CAMERA.md) registram que a escolha de pistola é cosmética e compartilha um único contrato de combate; o código local lista agora seis visuais. Tratar números e contagens das notas antigas como histórico, não como medição da revisão atual.

## Direção e prioridade por conjunto

| Conjunto | Identidade visual a buscar | Primeiro passe |
|---|---|---|
| Arena: M1911, Magnum, Glock 18, Desert Eagle, Luger P08 e Beretta M9 | Seis silhuetas distinguíveis pela armação, cano, ferrolho ou tambor, empunhadura e miras; mesma escala de legibilidade em seleção, primeira e terceira pessoa. | Capturas lado a lado na mesma câmera e luz; corrigir proporções e acabamentos que confundem modelos. |
| CTF: Vasnev 9mm, Kastov 545 e Lachmann LMS | SMG compacto, fuzil de perfil longo e arma de precisão com ótica evidente; distinguir peso e função pela forma antes de detalhes minúsculos. | Conferir braços, apoio da segunda mão, mira, boca e recarga em cada modelo. |
| Faca, Executor e Treme-Terra | Silhuetas e comprimentos distintos, materiais legíveis e golpe coerente com a área de contato. | Conferir posição nas mãos, arco visual do ataque e leitura do início/fim do golpe. |
| Get Out: Besta, ferramenta térmica, carga fictícia e Exorcista | Vocabulário visual próprio de horror industrial, com objetos de rota reconhecíveis e sinais de ameaça/contrajogo. | Fazer fichas de conceito depois de decidir kit e ferramenta; não reaproveitar automaticamente armas de Arena/CTF. |

## Sequência de produção

1. **Referência e captura base:** gerar imagens comparáveis de cada modelo em seleção, primeira pessoa, terceira pessoa e no chão; anotar colisões visuais, clipping, escala, leitura de cor e luz. Fixar avatar R15 padrão e um avatar de proporções extremas, mais cenas clara/escura. Registrar o estado do código e do Studio no mesmo momento para evitar concluir sobre versões diferentes.
2. **Silhueta e proporção:** corrigir volumes grandes, grip, cano, coronha/lâmina, mira e espaçamentos antes de acrescentar parafusos ou marcas. Uma arma deve ser reconhecível em resolução de controle/TV e em tela pequena. Usar o mesmo eixo de referência para terceira pessoa e viewmodel.
3. **Materiais e acabamento:** limitar paleta a metal, polímero, madeira/tecido e detalhes emissivos onde fizer sentido; variar rugosidade/cor de modo coerente com cada peça. Evitar brilho uniforme e superfícies pequenas demais para renderizar bem. Marcas visuais são originais do Crossgrounds, sem depender de logotipos de terceiros.
4. **Mãos e animações:** definir poses de equipar, repouso, corrida, mirar, disparar, recarregar, trocar, atacar e guardar. Associar mão, carregador/tambor/ferrolho, som, flash e cartucho ao mesmo marco de animação. Preparar variantes de uma mão e duas mãos; conferir prioridade do Animator e transformação da pegada durante golpes.
5. **Primeira pessoa e iluminação:** avaliar o `ViewportFrame` sob interior escuro, sol, luz colorida e transição entre salas. Ajustar a amostragem e profundidade visual para arma e mãos acompanharem o ambiente e não cobrirem retícula, munição ou menus. Checar oclusão próxima à parede, campo de visão, ADS e alternância de câmera.
6. **Efeitos e leitura de feedback:** flash, fumaça, projétil/rastro, impacto e recuo devem comunicar ação confirmada, origem no `Muzzle` e direção da câmera. Arma branca usa arco/trilha apenas na janela válida de ataque. Reduzir partículas e luzes para não ocultar alvo, aliados ou pistas de Get Out.
7. **Otimização e variante visual:** consolidar peças invisíveis/repetidas, considerar meshes/texturas quando trouxerem ganho real, e medir custo em dispositivos modestos. Preparar cosméticos sem alterar geometria funcional, hitbox ou identidade de equipe. Revisar contraste e distinção sem depender só de cor.

## Contratos que o refinamento deve preservar

- `WeaponId`, atributos de combate, cadência, alcance, munição e escolha cosmética da Arena seguem `KitDefinitions` e o serviço de combate. As seis pistolas da Arena permanecem visuais do mesmo armamento até uma decisão explícita de design.
- `Muzzle`, `RightHandGrip`, `SupportGrip`, `RestGrip`, `ReloadGroup`, pontos de animação e `Hitbox` devem manter nomes e semântica compatíveis com o runtime. Mudanças de posição desses pontos exigem revisão conjunta de arma, mãos, câmera e efeitos.
- Em armas brancas, o volume invisível de contato e a janela de dano seguem a lógica do servidor; nova lâmina ou trilha não pode criar alcance aparente enganoso.
- A renderização local não determina acerto nem dano. O servidor continua autoritativo. Cosméticos não podem criar vantagem por ocultar personagem, escurecer mira ou camuflar telegráficos.
- Modelos específicos de Get Out só entram no modo após fechar o kit da Besta, a ferramenta térmica e as regras do Exorcista. A direção visual aqui é proposta.

## Critérios de aceite do passe visual

| Verificação | Evidência esperada |
|---|---|
| Identidade | As seis pistolas e os três perfis de arma de CTF são identificáveis por silhueta em capturas de escala semelhante. |
| Pegada e animação | Sem mãos soltas, carregador atravessando dedos, mira desalinhada ou clipping persistente em repouso, corrida, ADS, recarga e ataque; verificar R15, R6 e avatar extremo. |
| Câmera e HUD | Arma e mãos acompanham a luz local de modo convincente; retícula, munição e prompts permanecem visíveis; parede próxima não revela geometria indevida. |
| Efeito e evento | Muzzle flash, rastro, som e impacto correspondem ao evento aceito; recarga, troca e golpe não mostram ação efetiva antes da confirmação. |
| Plataformas | Teste visual e de entrada em PC, gamepad e toque, inclusive escala de celular e TV; registrar FPS e custo de peças/efeitos em aparelho modesto. |
| Regressão | Atributos de combate, seleção cosmética, volumes de contato, respawn, bots, troca de modo e retorno ao hub mantêm seus contratos. |

**Entrega sugerida:** primeiro um comparativo de capturas com problemas anotados; depois protótipos de uma pistola, uma arma longa e uma arma branca; revisão estética e técnica; expansão para os demais modelos. Registrar cada passe em `changelogs/`, sem apagar entradas anteriores. O [plano de Get Out](GET-OUT-IMPLEMENTATION-DRAFT.md) e a [especificação v0.4](../GET-OUT-DESIGN-v0.4.md) permanecem as fontes de escopo do novo modo.
