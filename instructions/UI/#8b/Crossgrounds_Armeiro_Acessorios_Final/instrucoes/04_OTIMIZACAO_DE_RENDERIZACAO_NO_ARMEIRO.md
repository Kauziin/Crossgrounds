# 04 — Otimização de renderização no Armeiro

## Problema

Com muitas armas e attachments, o preview do Armeiro pode ficar caro demais se toda mudança recriar tudo do zero.

## Objetivo

Deixar a prévia visual responsiva e estável, mesmo com vários acessórios disponíveis.

## Regras principais

### 1. Reutilizar uma única arma de preview
Em vez de criar um novo modelo a cada clique:
- manter um `PreviewWeaponModel` ativo,
- limpar e reaplicar apenas as peças que mudaram.

### 2. Cache por combinação
Criar cache leve para:
- arma base,
- attachments equipados,
- thumbnails,
- offsets de montagem.

### 3. Debounce de atualização
Ao navegar rápido na lista, não reconstrua a arma em toda mudança de foco.

Use duas camadas:
- preview leve ao destacar,
- rebuild mais completo ao equipar.

### 4. Thumbnail de item na lista
Na lista de acessórios, use thumbnail/imagem pequena do attachment.
Não precisa render 3D completo da arma para cada opção.

### 5. Preview de arma fora do Workspace principal
Coloque a arma de preview em um container dedicado:
- `ReplicatedStorage` para dados,
- `ViewportFrame` para visual,
- uma câmera própria.

### 6. Suspender partes caras
Na arma de preview:
- sem sons,
- sem scripts desnecessários,
- sem animação pesada,
- sem partículas,
- sem loops de update contínuo.

### 7. Só aplicar estatísticas uma vez
Quando o usuário equipa um attachment:
- atualize estado do draft,
- resolva compatibilidade,
- recalcule estatísticas uma única vez.

## Pipeline recomendado de preview

1. Usuário destaca item.
2. UI mostra thumbnail e efeitos.
3. Após pequeno atraso, preview visual leve é atualizado.
4. Usuário clica.
5. Attachment é salvo.
6. Preview final e estatísticas são atualizados.

## Otimizações específicas

- `WorldModel` dentro de `ViewportFrame`.
- câmera fixa por categoria de arma ou por arma.
- `BulkMoveTo` ou reposicionamento em lote quando útil.
- esconder attachments incompatíveis em vez de tentar encaixar em runtime.
- montar offsets de attachment previamente.

## Coisas a evitar

- clonar a arma inteira a cada seleção.
- reimportar meshes a cada troca.
- recalcular compatibilidade completa em toda navegação.
- aplicar física real no preview.
- reconstruir toda a UI quando só um slot mudou.

