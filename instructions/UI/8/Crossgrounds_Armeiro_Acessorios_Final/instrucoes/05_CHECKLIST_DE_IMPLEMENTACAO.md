# 05 — Checklist de implementação e validação

## Compatibilidade (baseada em auditoria real)

- [ ] Inventariar os modelos em `ImportedArsenalOriginals` no Studio.
- [ ] Agrupar os nomes, origens e IDs dos attachments existentes.
- [ ] Identificar duplicatas reais, variantes e nomenclaturas equivalentes.
- [ ] Classificar cada item por slot (`optic`, `muzzle`, `magazine`, etc.).
- [ ] Confirmar plataforma de armas e pontos reais de encaixe.
- [ ] Preencher compatibilidade explícita para cada item; manter pendentes fora da montagem.
- [ ] Integrar regras no `AttachmentCatalog`/validador do Crossgrounds.
- [ ] Não aplicar um limite total arbitrário de attachments; preservar exclusividade por slot quando pertinente.

## Estatísticas

- [ ] Preservar `KitDefinitions` como fonte dos valores-base.
- [ ] Aplicar os modifiers de `AttachmentCatalog` no `WeaponStats` compartilhado.
- [ ] Validar compatibilidade e atributos no servidor.
- [ ] Refletir modificadores na prévia e no placar de estatísticas sem valores inventados.
- [ ] Testar arma sem os campos opcionais de recuo; ignorar as mudanças não aplicáveis.

## UI (conforme imagens aprovadas)

- [ ] Tela de arma: categorias, lista vertical e prévia à direita.
- [ ] Tela de acessórios: **sem painel interno esquerdo de ações**.
- [ ] Lista vertical ampla com um item por linha.
- [ ] Slots na faixa superior; rolagem longa sem perder foco.
- [ ] Dois blocos à direita: modelo 3D e resumo de estatísticas.
- [ ] Atalhos compactos abaixo: trocar arma, restaurar acessórios, salvar visual.
- [ ] Seleção direta (um clique/A) e remoção por `Sem acessório`, sem confirmação extra.
- [ ] Preservar controles e estilo de cascata existentes.

## Prévia 3D

- [ ] Reutilizar `ViewportFrame` e câmera dedicados do menu, se possível.
- [ ] Evitar clone completo a cada mudança de foco.
- [ ] Atualizar somente acessórios alterados sempre que a montagem permitir.
- [ ] Desativar scripts/sons/efeitos nas cópias de prévia.
- [ ] Invalidar cache quando trocar arma ou alterar configuração.
- [ ] Testar desempenho com muitas meshes e movimentos rápidos na lista.

## Testes de regressão

- [ ] Arma e acessórios equipam no Practice Range sem voltar a uma página extra.
- [ ] Configuração salva persiste em respawn e recuperação de equipamento.
- [ ] Compatibilidades inválidas são rejeitadas no servidor.
- [ ] `LB/RB`, D-pad, foco de losango, B voltar e scroll continuam funcionais.
- [ ] Não existem vazamentos de `ViewportFrame`/modelos após fechar e abrir o Armeiro repetidamente.
- [ ] Conferência visual final lado a lado com `imagens/01` e `imagens/02`.
