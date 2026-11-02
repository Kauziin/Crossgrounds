# 06 — Ordem de implementação sugerida

1. **Inventário:** rodar o script preliminar de auditoria e exportar nomes completos/modelos da pasta `ImportedArsenalOriginals`.
2. **Deduplicação:** separar registros canônicos de variantes e marcar origens; nunca apagar modelos sem mapear referências.
3. **Compatibilidade:** registrar por arma/plataforma + ponto de montagem. Não liberar automaticamente acessórios só porque pertencem à mesma classe.
4. **Integração:** fazer `WeaponVisualConfiguration`/validação do servidor aceitar somente os acessórios auditados e respeitar seus slots.
5. **Estatísticas:** usar `AttachmentCatalog` com `statMultipliers`/`statAdd` e passar pelo cálculo central `WeaponStats`, inclusive no servidor.
6. **Armas — UI:** manter tela aprovada `imagens/01`, seleção direta e lista vertical.
7. **Acessórios — UI:** implementar `imagens/02`: remover coluna interna esquerda, expandir lista vertical, dois blocos à direita (arma e estatísticas), atalhos compactos abaixo.
8. **Renderização:** reutilizar o `ViewportFrame`, cachear modelos-base/offsets e reduzir operações durante troca de foco.
9. **Validação:** confirmar animação, compatibilidade, aplicação ao vivo, salvamento, multiplayer e controle.

## Restrições desta entrega

- Não redefinir o tema global do Crossgrounds.
- Não reintroduzir páginas intermediárias de confirmação.
- Não reintroduzir o bloco lateral de ações removido da tela de acessórios.
- Não transformar a lista vertical em grade.
- Não impor limite global de quantidade de acessórios; respeitar os slots/mounts.
- Não tratar nome/ID de modelo como evidência suficiente de compatibilidade.
- Não copiar valores ilustrativos das imagens para o balanceamento.

Os módulos citados são pontos de integração, não afirmação de que todos os recursos já estejam implementados. A checagem final exige Roblox Studio.
