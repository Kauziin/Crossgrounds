# Traçante simples e tolerância de acerto — 02/11/2026

**Atualização em 03/11/2026:** ShotMath e ShotCosmetics foram aplicados ao principal em Edit, junto do fechamento de armamento. A pendência de incorporação descrita abaixo foi resolvida; avaliação visual em gameplay continua pendente. Sem publicação.

Alterações locais preparadas em ShotMath e ShotCosmetics. A aplicação ao Edit do principal está pendente enquanto o Studio permanece em Play de outra atividade. Não foi interrompido nem modificado o sistema de combate dessa sessão. Testes usaram módulos clonados temporários, removidos ao final.

- Margem comum: +0,10 stud ao raio existente, limitada ao teto anterior de 5 studs. Armas comuns passam de raio zero para 0,10; Blaster/AutoBlaster, de 0,40 para 0,50. A configuração comum alimenta previsão, tiros autoritativos, NPCs, hitscan, projéteis e geometria histórica. Não converte hitscan em projétil físico nem muda dano, dispersão ou cadência.
- Largura mínima do traçante simples existente: 0,05 stud, preservando largura maior de modelos específicos. Clona ShotVisual para não mutar a definição da arma.
- Projéteis cosméticos limitam o trecho desenhado ao comprimento visual configurado e preservam o último segmento por 45 ms, com fade, antes de devolver a peça ao pool. Isso evita que um impacto no primeiro frame apague o traço antes de ser visto. Pool anterior de 128 peças e peças sem colisão/query mantidos.
- A margem participa também da colisão com cobertura. Paredes não são ignoradas para alcançar um alvo ampliado; o resultado pode parar um pouco antes da borda em tiros muito próximos da cobertura.

Validação isolada em Server, sem alterar os módulos usados pelo Play principal: raio zero errou um alvo por 0,05 stud; raio 0,10 acertou; parede de 0,05 stud bloqueou o mesmo tiro e também um projétil a 20.000 studs/s com dt de 1/30. Contrato de configuração conferiu raio, largura e imutabilidade da definição. Cópia do módulo cosmético com scheduler desativado apenas na fixture e ticks controlados conferiu visibilidade de tiro curto, retenção, fade e devolução ao pool. Fixtures removidas. git diff --check passou.

Ainda não houve aplicação persistente ao Edit, conferência visual em gameplay, teste físico de controle ou teste multiplayer/publicado desta mudança. Teste de Blaster atualizado para os novos raios; novo ShotTolerance_Test adicionado. Sem publicação.
