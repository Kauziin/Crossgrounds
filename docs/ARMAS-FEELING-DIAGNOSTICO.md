# Diagnóstico antes do patch de armas

23/10/2026. Place 4375993208, Edit. Fontes e instâncias reais inspecionadas; sem publicação.

- KitDefinitions contém três classes CTF e seis cosméticos de pistola na Arena; LoadoutDefinitions/KitService são dinâmicos. Novas classes podem usar esse fluxo sem um segundo sistema de equipamento.
- ShotAuthority só consulta ShotHistory quando ping >40 ms; nos demais tiros usa raycast no presente. O cliente envia câmera, direção, ponto de mira e tempo, sem observação da pose visual do alvo.
- ShotHistory captura a 30 Hz, interpola caixas e mantém obstáculos atuais. Não move personagens reais. A seleção temporal depende apenas de tempo/ping; a janela é de 400 ms.
- ShotQuery pode interceptar acessórios e o root invisível do personagem; o histórico inclui acessórios com CanQuery. Isso pode transformar visual cosmético em hitbox ou bloquear um headshot.
- Headshot em Kits.ShotDamage multiplica por 1,35. Alcances/falloff de pistola Arena não mudam o número de tiros necessários contra 20 HP até o alcance máximo.
- A arquitetura já suporta múltiplos pellets, mas KitDefinitions força todas as armas a um pellet. Cliente e servidor já compartilham direção determinística e efeitos locais imediatos.
- WeaponFactory gera geometria própria; Renderer já suporta grupos de recarga, braços da skin, dois grips e buffer de profundidade separado. Será estendido para escopetas e seus melees.
- DamageService e ArenaCombat sabem quem eliminou cada jogador, mas não enviam um evento de espectador à vítima. PlayerManager/ArenaAdapter já controlam respawn; a câmera de espectador pode terminar no CharacterAdded sem alterar o cronômetro.

Plano: ampliar precisão temporal com uma pista de pose validada no histórico (nunca dano/resultado declarado pelo cliente), preservar obstáculos atuais e limites de rewind; headshot 1,5; falloff perceptível e indicação discreta de faixa; duas classes CTF, modelos/grupos de recarga novos, câmera do eliminador e testes de integração.
