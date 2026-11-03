# UI #9b — auditoria antes da implementação (02/11/2026)

Checkout master, origin Kauziin/Crossgrounds. Alterações de armas preexistentes preservadas.
Referências lidas em instructions/UI/#9b (três PNGs). Nenhuma pasta Local neste checkout.

ProgressionPanel.local/ProgressionView compõem perfil, ranking e amigos; MenuNavigation, MenuTheme, AccentTheme e CascadeMenu fornecem navegação, foco, layout e animações. GunsmithView e ArsenalSelectionView editam presets via ArsenalCommand; ArsenalPreview reutiliza geometria sanitizada. AttachmentArt contém thumbnails reais. MenuNavigation já oferece ações contextuais X/Y e categorias LB/RB; LT/RT precisam de extensão com foco, sem roubar ações de outros menus.

CareerService/CareerRepository/CareerPolicy são a fonte da carreira persistida v2, voluntária por prestígio, XP de arma e desbloqueios. ProgressionService faz os créditos no servidor. UnlockCatalog e UnlockService/CareerClient aplicam níveis/permanências e exceção do Practice Range. Não criar novas curvas ou concessões. Cutover de carreira em produção depende de CareerCutoverApproved, já existente. Studio usa estado de sessão.

ODEN possui modelo e combatId reais, mas slots={} e nenhuma montagem de acessório aprovada. Não preencher essa lacuna com miras inventadas nem liberar montagem. WeaponFinishCatalog oferece os acabamentos reais nos níveis 1/10/25/40/55. A tela deverá representar esses dados e explicitar a dependência dos acessórios. Comparação de estatísticas só para acessórios funcionais compatíveis pelo WeaponStats; acabamentos não mudam atributos.

Clãs já existem: ClanService/ClanRepository/ClanPolicy/ClanCatalog e ClanBridge/ClanMenu, com epochs de filiação, remoção, contribuições e XP coletiva acumulada. Recompensa real: cosméticos de clã ao atingir nível 3 e contribuição pessoal 1000, concedidos pelo servidor. Não há missões semanais nem agregação semanal: apresentar indisponibilidade e contribuições acumuladas, sem inventar números ou rótulos semanais. Integração visual deve exigir associação ativa confirmada. Manter gerenciamento do clã existente.
