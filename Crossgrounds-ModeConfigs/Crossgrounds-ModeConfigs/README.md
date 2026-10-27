# Crossgrounds — Configurações por modalidade

Estado: **base conceitual**, sem sistemas em execução.

## Finalidade

Um arquivo de configuração por modalidade, mantendo regras de Get Out, Duels, Arena e CTF separadas. `GetOutConfig.luau` contém cinco rotas de fuga **sorteadas uma por rodada**, fases de 10+5 minutos, habilidade Hacker e sugestões claramente isoladas no campo `Suggestions`.

- `GetOutConfig.luau`: Clássico, Mutação, Infestação, Juggernaut, cinco rotas de fuga por sorteio, fase de fúria, contenção secreta, classe Hacker, desfechos, classes sugeridas e ideias adicionais.
- `GET-OUT-DESIGN.md`: descrição passo a passo dos objetivos, lacunas de design e recomendações **não aprovadas** com parâmetros concretos.
- `DuelsConfig.luau`: esqueleto das variantes e modificadores já discutidos.
- `ArenaConfig.luau`: esqueleto das variantes; fila comum e votação posterior.
- `CTFConfig.luau`: dados descritivos do protótipo; **não substituir** `ExperienceSettings.luau` ou alterar o CTF existente.

## Instalação sugerida

A organização sugerida é `ServerScriptService/ModeConfigs/`, como `ModuleScript`s **apenas depois de conferir como Rojo/Studio organiza a pasta**. Informações públicas de interface devem ser expostas em um módulo/serviço separado, sem segredos de objetivos ou estados ocultos. O projeto original do CTF possui instâncias que não são representadas integralmente por `src/`.

Esses arquivos **não habilitam gameplay**. Não representam `GetOutService`, validação de objetivos, geração do mapa ou compatibilidade concluída entre dispositivos. A arquitetura definitiva poderá compartilhar apenas dados públicos de UI, mantendo a validação e combinações secretas no servidor.

## Regras para futuras implementações

1. `Status = "defined"` significa concepção aprovada, **não** recurso programado ou balanceado.
2. `Status = "proposed"` deve permanecer fora das partidas até aprovação explícita.
3. `"pending"` jamais deve ser interpretado como número ou decisão final.
4. Selecionar **uma** das cinco rotas aleatoriamente por rodada, somente dentre as compatíveis com o mapa; não ativar todas ao mesmo tempo. A contenção é alternativa secreta durante a fase de fúria (10 a 15 min).
5. Servidor valida objetivo concluído, permissão de abrir saída, efeitos de classe e resultado individual.
6. Considerar teclado/mouse, controle e toque para todas as interações (especialmente cofre rotativo).
7. Não criar empate; sobreviver, escapar e ser capturado são resultados distintos.
8. Preservar divisão Get Out Clássico / Especial e os tamanhos de Mutação (7), Infestação (5), Juggernaut (9).

Fonte de referência: `roblox_hub_design.md` v0.2, Crossgrounds, 22/10/2026.

## Revisão v0.3 — 22/10/2026

- Get Out: método aleatório por partida (um dentre cinco possíveis); compatibilidade por mapa.
- Travas: quatro PCs/travas, duas portas e manivela, escape individual. Cofre: quatro dígitos revelados por quatro PCs, combinação finalizada depois de todos os dígitos, erro bloqueia por 30 s.
- Lasers: quatro feixes letais, puzzles em painéis. Serra térmica: buscar peças, juntar portadores na bancada, montar e cortar porta. Demolição: componentes coletáveis, bancada, carga com temporizador de 15 s.
- Partida: 600 s de fase normal + 300 s de Besta enfurecida/instável; contenção secreta disponível exclusivamente na segunda fase, sem texto de objetivo.
- Hacker (Besta): desfazer hackeamento de PCs a cada 150 s **ou**, quando a missão não usa PCs, varredura EMP circular com cinco pulsos de 2 s, recarga de 180 s. Efeitos não explicitados pelo criador permanecem pendentes.
- Contratos não especificados ou sugestões de ajuste continuam marcados como `pending` / `proposed`.
