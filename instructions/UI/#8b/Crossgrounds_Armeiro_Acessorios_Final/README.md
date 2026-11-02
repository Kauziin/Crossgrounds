# Crossgrounds — Armeiro e acessórios (telas aprovadas)

Pacote consolidado das duas telas aprovadas e das instruções de auditoria, compatibilidade, implementação e otimização dos acessórios.

## Imagens

- `imagens/01_selecao_de_armas_APROVADA.png` — tela vertical de seleção de armas, aceita na conversa.
- `imagens/02_selecao_de_acessorios_FINAL.png` — última tela de acessórios, com **remoção do bloco interno esquerdo**, lista vertical expandida e **dois painéis à direita** (prévia de arma e estatísticas).

Estas imagens são **referências visuais conceituais**, não capturas de uma implementação concluída no Studio. Números, nomes e compatibilidades mostrados nas telas são ilustrativos; os registros reais devem ser obtidos do catálogo e da auditoria.

## Instruções

1. `01_AUDITORIA_COMPATIBILIDADE_ACESSORIOS.md` — inventário, normalização, duplicatas, plataformas, slots e encaixes.
2. `02_MODELO_DE_DADOS_E_REGRAS.md` — contrato sugerido para compatibilidade e modificadores de atributos.
3. `03_UI_FINAL_ARMAS_E_ACESSORIOS.md` — requisitos concretos para implementar **as telas aprovadas**, sem alterar o design global.
4. `04_OTIMIZACAO_DE_RENDERIZACAO_NO_ARMEIRO.md` — cache, prévia e reconstrução sob demanda.
5. `05_CHECKLIST_DE_IMPLEMENTACAO.md` — passos e validação.
6. `06_ORDEM_DE_EXECUCAO.md` — sequência resumida para execução com Codex ou manualmente.

## Scripts auxiliares

- `scripts_de_auditoria/Studio_AttachmentAudit.luau`: auditoria **inicial por nomes**, para uso manual no Studio; não valida encaixe mecânico ou compatibilidade real.
- `scripts_de_auditoria/AttachmentCompatibilitySchema.luau`: exemplo de esquema; **não é substituição direta** do catálogo do jogo.

## Limites da auditoria

As imagens e o pacote anterior não contêm a árvore completa e as propriedades dos modelos dentro de `ImportedArsenalOriginals`. Portanto, este ZIP **não afirma ter identificado compatibilidades individuais de todos os acessórios**. O inventário real precisa ser conferido no Roblox Studio antes de registrar `allowedWeapons`/`allowedPlatforms` e habilitar os acessórios.

## Regras já decididas

- Sem limite **global** de quantidade de acessórios equipados por arma nesta etapa; isso não autoriza encaixar vários acessórios mutuamente exclusivos no mesmo slot.
- Um clique em arma/acessório = salvar a configuração sem tela de confirmação.
- Preservar a navegação em cascata, as cores, a tipografia, o foco de controle com losango e o cenário do Crossgrounds desfocado atrás do menu.
- Não adicionar barra global de navegação estilo Call of Duty.
- Não alterar a seleção de armas já aprovada ao implementar a nova tela de acessórios.
