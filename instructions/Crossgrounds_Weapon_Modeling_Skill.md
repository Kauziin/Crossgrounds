---
name: crossgrounds-weapon-modeling
description: Modelar, revisar e refinar armas 3D para o Crossgrounds com referências, Blender/Roblox Studio, pivôs animáveis, geometria eficiente, materiais consistentes e validação em primeira e terceira pessoa. Use ao criar armas novas ou corrigir armas existentes.
---

# Crossgrounds Weapon Modeling — Skill

## Princípio

Qualidade não é quantidade de polígonos: uma arma precisa ter **silhueta memorável, proporção coerente, mecânica compreensível, boa leitura em movimento e compatibilidade com animação**. O projeto já conhece suas armas e estilos; consulte o repositório e assets de referência, não reinvente conceitos de gameplay ou renomeie objetos sem necessidade.

## Antes de modelar

1. Inspecionar os modelos existentes, sua hierarquia, armas equipadas, viewmodel, pivôs, escala, materiais e convenções. Detectar se o asset vive em `Tool`, `Model`, `MeshPart`, FBX/glTF/obj ou formato próprio.
2. Definir o objetivo do pedido: **refinamento** ou **arma nova**. Para refinamento, preservar identidade e partes funcionais, identificando especificamente silhueta, proporção, detalhes, textura, topologia, alinhamento ou animação problemáticos.
3. Preparar um *brief* curto: família da arma; papel em jogo; silhueta dominante; escala relativa ao avatar e mãos; referência visual (somente assets acessíveis/licenciados); padrão de materiais; mecanismos móveis; distâncias FP/TP; dispositivo-alvo.
4. Capturar/produzir uma folha de referência: perfil esquerdo, perfil direito, superior, perspectiva 3/4 e enquadramento **na mão do personagem**, não apenas imagens bonitas isoladas.

## 1. Silhueta → volumes → detalhes

- Trabalhar em **blockout** antes dos detalhes: cano, receiver/corpo, empunhadura, gatilho/guarda, mira, coronha e carregador/cilindro quando aplicáveis. Exigir reconhecimento da classe da arma em sombra sólida e em tamanho pequeno de tela.
- Ajustar os volumes considerando o **ângulo real da viewmodel**, não só ortografia lateral. A distribuição visual deve preservar campo de visão do retículo.
- Escolher linguagem de formas consistente com o projeto (chanfros, cantos, curvaturas, partes técnicas e densidade de detalhes). Não acrescentar painéis aleatórios ou parafusos só para parecer detalhado.
- A geometria deve explicar o funcionamento: porta de ejeção, ferrolho/slide, câmara, tambor, carregador, alavanca/pump, dobradiças e guias precisam ter localização e movimento plausíveis **para a animação**, sem exigência de engenharia real em partes invisíveis.
- Separar pequenas peças somente quando sua individualização ajudar animação, reuso ou material. Não converter cada parafuso em instância distinta no Roblox.

## 2. Categorias e pontos críticos

| Família | Verificações específicas |
|---|---|
| Pistola | Empunhadura, guarda-mato, conjunto cano/slide, miras, carregador e porta de ejeção |
| Revólver | Alinhamento entre cano e tambor, abertura/rotação do tambor, cão quando existente, extração e recarga |
| Rifle/SMG | Receiver, ejection port, carregador, handguard, coronha, eixo da mira e área de apoio da mão |
| Escopeta | Calha/tubo ou magazine, pump/ação, boca, alça/coronha, pontos de alimentação de cartucho |
| Arma estilizada | Regra visual própria, mas silhueta e lógica de interação devem continuar compreensíveis |

## 3. Preparação para rig, animação e scripts

Documentar coordenadas/pivôs locais consistentes, usando os nomes já existentes ou uma convenção acordada. Pontos semânticos sugeridos: `Grip`, `SupportHand`, `Muzzle`, `Aim`, `EjectionPort`, `MagazinePivot`, `BoltPivot`/`SlidePivot`, `CylinderPivot`, `LeftHandIK`, `RightHandIK` quando pertinentes. **Não criar todos por obrigação** — apenas os que a arma utiliza.

Checar posição/orientação da arma em FP e TP, alinhamento de ADS e origem dos efeitos. A direção autoritativa do tiro segue o sistema de armas; o `Muzzle` é âncora coerente para flash e traçante visual. Separar peças móveis animáveis (mag/slide/cylinder) de partes estáticas. Evitar animação dependente de offset mágico impossível de entender.

## 4. Geometria, UV e materiais

- Usar peças Roblox quando o estilo da arma e o desempenho favorecerem, e `MeshPart` importada quando curvas, chanfros e formas próprias exigirem. Modelagem externa preferencial em Blender, caso disponível.
- Limpar transformações, escala/unidades, orientação de eixos, nomes, origem/pivôs; conferir triangulação, normais, faces invertidas, interseções e UVs antes da exportação.
- Respeitar as especificações Roblox; cada mesh tem limite geral de **20.000 triângulos**, mas tratar isso como teto técnico — **não como orçamento recomendado por arma**. Ser muito mais econômico em worldmodels e partes pequenas.
- Materiais PBR: `Color`, `Metalness`, `Roughness` e `Normal` quando de fato agregarem qualidade. Normal maps do Roblox são **OpenGL tangent-space**. Evitar material metalizado igual em todas as superfícies, texturas ruidosas e detalhes apenas visíveis em render gigante.
- Definir cores e roughness coerentes: metal pintado/oxidado, polímero, borracha e madeira devem ser distinguíveis sem virar um carnaval. Reutilizar mapas/atlases quando fizer sentido.
- Manter original editável (arquivo do Blender, script gerador ou equivalente) e a versão exportada. Não declarar asset final apenas entregando uma imagem renderizada.

## 5. Procedimento de produção

**A — Diagnóstico:** mostrar o que existe, identificar 3–6 problemas que de fato afetem a leitura/uso e ordenar por impacto.

**B — Brief + referências:** descrever o design em poucas linhas; listar links e justificar formas/proporções; não copiar uma arma real ou um asset de terceiros sem necessidade e autorização adequada.

**C — Blockout:** criar volumes reconhecíveis e validar dimensões no avatar. Se usar Blender via script Python, tornar parâmetros editáveis (comprimento do cano, largura do corpo, altura de grip etc.) e salvar `.blend` ou script-fonte. Quando não houver Blender/Studio acessível, criar especificação e script de construção utilizável, explicitando o que falta validar visualmente.

**D — Refinamento:** acrescentar as peças identificadoras, ajustar chanfros/arestas, topo/miras, hand placement e partes móveis; revisar de frente, perfil, cima, 3/4 e vista de jogo.

**E — Materiais:** UV, textura/PBR ou paleta coerente. Testar iluminação interna/externa, não depender de um render de estúdio com luz perfeita.

**F — Exportação/integração:** preferir `.fbx` ou `.gltf` quando estrutura de múltiplos meshes/rig/dados de material for necessária; `.obj` somente para geometria mais simples. Importar pelo Roblox Studio, verificar warnings, hierarquia, pivôs e IDs gerados. A existência de `.blend`/`.fbx` **não comprova** importação ou publicação no Roblox.

**G — Validação:** criar turntable/folha de revisão; se possível capturar arma em mãos em FP e TP, ADS, reload e disparo. Avaliar desempenho no celular, visibilidade do braço de suporte, clipping da câmera e interferência na mira.

## 6. Critérios de aprovação

Use a checklist em [`references/review-checklist.md`](references/review-checklist.md). Bloqueios principais: silhueta confusa; partes móveis impossíveis de animar; mão/arma desalinhadas; mira sem ADS coerente; escala inapropriada no avatar; normais/texturas defeituosas; modelo incompatível com o pipeline real do Roblox. Detalhes cosméticos só vêm depois de resolver isso.

## Entregas

Para cada arma criada ou refinada: fonte editável (se gerável no ambiente), export intermediário quando gerável, inventário de peças/materiais, especificação de pivôs, preview/turntable quando produzido, nota de desempenho, resultado de testes executados e pendências de Studio/asset upload. Usar [`references/asset-brief-template.md`](references/asset-brief-template.md) para briefs e versões. Não prometer modelagem/imagens/arquivos se não foram realmente criados.

## Referências

- Roblox — [Custom 3D assets](https://create.roblox.com/docs/art/modeling), [General specifications](https://create.roblox.com/docs/art/modeling/specifications), [3D importer](https://create.roblox.com/docs/studio/importer), [SurfaceAppearance / PBR](https://create.roblox.com/docs/art/modeling/surface-appearance), [Rigging and skinning](https://create.roblox.com/docs/art/modeling/rigging), [Performance](https://create.roblox.com/docs/performance-optimization/improve).
- Revisar a documentação da versão instalada do Blender antes de escrever automações de exportação.
