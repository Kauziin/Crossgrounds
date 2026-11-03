# Referências de empunhadura das armas importadas

Inspeção e implementação em Edit no Crossgrounds (ALPHA), place 4375993208. Nenhum Play iniciado nesta rodada, sem publicação.

## Problema e mudança

Dezoito modelos longos jogáveis não possuem uma BasePart chamada Grip. A construção usava o centro do bounding box como origem da arma e um SupportGrip genérico. Dragunov e Kar98k tinham exceções recentes; os outros dezesseis ainda dependiam desse fallback.

Novo módulo `ReplicatedStorage.Crossgrounds.WeaponGripReferences` registra referências por arma, consumidas por `ImportedWeaponVisuals`. O gatilho e um deslocamento de calibração definem a mão direita quando a empunhadura está integrada à malha. Bruen usa Grip (Placeholder), RAM-7 usa Back Grip, Model 680 usa a junção dianteira da Default Stock. A mão esquerda segue o guarda-mão, cobertura, chassi, base de madeira ou bomba identificados no modelo. P90 e MP7 recebem distâncias de apoio próprias de armas compactas. Kar98k conserva o apoio relativo ao gatilho da correção anterior, evitando selecionar uma Base homônima da luneta/receiver.

Armas cobertas: CR-56 AMAX, FAL, ODEN, RAM-7, MP5, MP7, P90, Holger-26, Bruen MK9, JAK-12, Model 680, 725, MK2 Carbine, Simonov, EBR-14, SP-R 208, Dragunov e Kar98k. As dezesseis primeiras são novas correções desta rodada. Pistolas com referências específicas e armas com Grip válido mantêm suas referências anteriores. Nenhum valor de dano, cadência, munição ou recuo foi editado.

O construtor normaliza a geometria com a nova origem e posiciona o apoio no mesmo sistema local. A chave do cache distingue a normalização nova; referências cadastradas ausentes produzem erro explícito, em vez de ocultar o problema com bounding box. O renderizador e a pose externa existentes consomem os attachments resultantes.

## Validação efetivamente realizada

- Studio permaneceu em Edit.
- Inspecionadas as peças dos modelos reais no ServerStorage e as referências existentes das 48 armas importadas jogáveis.
- 48 modelos construídos por uma cópia nova do construtor, incluindo as 18 referências específicas. Verificados Handle, RightHandGrip e SupportGrip; para as 18, verificados igualdade com a referência normalizada, apoio à frente da mão direita e distância inferior a 4 studs em escala original.
- Verificação de fallback: nenhuma das 48 armas jogáveis restantes depende do centro do bounding box para a empunhadura; pistolas consideram os aliases já implementados.
- Dois contratos em `tests/Unit/Cases/WeaponGripReferences_Test.luau`: transladar o asset preserva a diferença entre mão e apoio; arma fora do registro mantém o fluxo anterior, referência obrigatória ausente gera erro.
- Compilação e igualdade das duas fontes do principal com o repositório; `git diff --check`.

As calibrações são aproximações geométricas em studs, não posições capturadas de animações. Não houve inspeção visual em Play nesta rodada, nem aprovação de dedos, clipping, todas as poses de ADS/recarga ou rigs R6/R15. Prévia estática e contratos em Edit não substituem esses testes. Fixtures de validação removidas; backup do construtor em `ServerStorage.Development.Revisions.WeaponGripSweep_20261102`. Módulo de referências é novo.
