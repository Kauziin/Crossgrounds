# Crossgrounds — Reformulação da Interface de Configurações

Reformule a interface de configurações do Crossgrounds utilizando a referência visual fornecida. O objetivo é modernizar a navegação em cascata, melhorar a experiência com controles e padronizar os elementos visuais sem comprometer a funcionalidade existente.

Antes de implementar, examine a arquitetura atual da interface e reutilize seus componentes e sistemas de navegação.

## 1. Navegação em Cascata

- Substitua as colunas permanentemente expandidas por **cascatas retráteis e animadas**.
- Níveis anteriores devem se recolher em barras verticais estreitas, exibindo ícones representativos e indicadores da categoria selecionada.
- Preserve todos os níveis anteriores visíveis, mesmo em navegações profundas.
- Mantenha expandida apenas a cascata de navegação contextual, juntamente com o painel principal de conteúdo.
- Ao retornar com **B**, expanda a cascata anterior, revelando seus textos e opções.
- Ao avançar, retraia suavemente a cascata anterior e expanda a nova.
- Preserve a última seleção e posição de rolagem de cada categoria.
- Utilize transições suaves, preferencialmente entre 180 e 250 ms, sem bloquear entradas durante animações.

## 2. Navegação por Controle

Implemente um modelo consistente de navegação:

| Entrada | Comportamento |
|---|---|
| LB / RB | Alternar categorias irmãs no nível atual |
| D-pad ↑ / ↓ | Navegar entre opções |
| D-pad ← / → | Ajustar valores e alternar seletores |
| A | Confirmar ou abrir opção |
| B | Voltar ao nível anterior |
| X | Inserir valor personalizado |
| Y | Restaurar valor padrão |

Regras adicionais:

- LB/RB devem alternar categorias sem obrigar o jogador a retornar à cascata anterior.
- Mostre as categorias disponíveis no cabeçalho, com indicação da categoria atual.
- Mantenha o indicador de foco em losango e a borda luminosa.
- Realize rolagem automática para manter o elemento selecionado visível.
- Elementos não interativos e componentes internos de cards não devem receber foco pelo controle.
- Preserve integralmente a navegação por mouse, teclado e toque.

## 3. Reformulação dos Sliders

Adote o novo modelo compacto e horizontal da referência visual.

Cada configuração deve possuir um **único card selecionável**, contendo:

- Ícone da configuração.
- Nome e descrição curta à esquerda.
- Separador vertical sutil.
- Slider ou seletor à direita.
- Valor atual destacado e alinhado à direita.

### Interação

- O D-pad horizontal altera diretamente o valor enquanto o card estiver selecionado.
- Segurar uma direção permite ajustes contínuos, com repetição controlada.
- **X** abre um campo de entrada numérica personalizada, respeitando os limites e a precisão da configuração.
- **Y** restaura somente a configuração selecionada ao valor padrão.
- O botão de restauração geral da categoria permanece separado e exige confirmação.
- Não permita que o controle selecione individualmente o preenchimento do slider, seus botões auxiliares ou ícones internos.
- Mouse e toque continuam podendo arrastar diretamente o slider.

Para seletores, como a curva de resposta do analógico, utilize ←/→ para alternar entre valores disponíveis.

## 4. Identidade Visual

Padronize a aparência da interface conforme a referência:

- Fundo preto com tonalidade azulada discreta.
- Cards escuros, compactos e arredondados.
- Cor de destaque turquesa, com iluminação suave na seleção.
- Ícones consistentes e tipografia hierarquizada.
- Descrições em cinza-claro, sem excesso de contraste.
- Sliders com trilhos discretos e preenchimento na cor de destaque.
- Cabeçalhos com nome da categoria, descrição e navegação LB/RB.
- Rodapé com comandos contextuais de controle.

**Centralize as cores de destaque em tokens reutilizáveis**, permitindo personalização futura da paleta sem modificar cada componente individualmente.

## 5. Responsividade e Acessibilidade

- Adapte os painéis às diferentes resoluções e proporções de tela.
- Preserve áreas seguras para Xbox, computadores e dispositivos móveis.
- Priorize a largura do painel de conteúdo, reduzindo o espaço consumido pelas cascatas recolhidas.
- Evite sobreposição de textos, corte de controles e sliders pequenos demais para toque.
- Mantenha o foco visual claramente distinguível independentemente da cor de destaque escolhida.

## 6. Restrições e Compatibilidade

- Não reconstrua a lógica de configurações existente.
- Não altere os valores padrão, limites, comportamento real ou persistência das configurações.
- Não modifique outras interfaces desnecessariamente.
- Não introduza sistemas paralelos de foco ou navegação quando os existentes puderem ser adaptados.
- Preserve a compatibilidade com as configurações globais e específicas de cada modalidade.
- Garanta que animações, entradas rápidas e mudanças de categoria não provoquem perda de foco ou seleção incorreta.

## 7. Validação

Teste especialmente:

1. Navegação profunda entre cascatas, avançando e retornando.
2. Alternância rápida de categorias com LB/RB.
3. Ajuste dos sliders com D-pad e entrada personalizada com X.
4. Restauração individual com Y e restauração geral com confirmação.
5. Retenção do foco e dos valores após navegar entre categorias.
6. Compatibilidade com mouse, teclado, controle e toque.

**Resultado esperado:** uma interface de configurações compacta, fluida e consistente, com cascatas animadas, navegação por controle simplificada e componentes reutilizáveis, preservando os sistemas funcionais já implementados.