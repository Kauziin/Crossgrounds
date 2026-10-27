# Disparos — diagnóstico anterior à alteração

23/10/2026. Inspeção das fontes locais e das nove fontes de disparos no Studio aberto (Place 4375993208, Edit). Sem publicação.

## O que já funciona e será preservado

- Armas convencionais usam Raycast autoritativo, sem Touched ou balas físicas para causar dano. Touched nas bandeiras não pertence ao disparo.
- Cliente prevê som, flash, recuo e traçante antes de enviar WeaponAction. ShotVisual evita repetir efeitos do próprio tiro.
- Ballistics ignora aliados/corpos e limita a sniper a dois personagens com perda de 20%. Dano, proteção, headshots, queda por distância, recompensas, recarga e regras dos modos permanecem nos respectivos serviços.
- Sons têm emissores independentes, preservando a cauda ao trocar de arma. Melee usa volumes de ataque e permanece fora desta reformulação.

## Causas encontradas

1. CTF aplica dispersão com math.random no servidor; previsão local não aplica a mesma dispersão e Arena a omite. A linha prevista pode divergir do acerto.
2. IDs são apenas validados como números; não impedem replay ou eventos fora de ordem. Rejeições não retornam confirmação/correção.
3. Cliente consulta somente munição replicada. Durante latência pode prever mais tiros do que a munição disponível. Previsões não são encerradas ao trocar arma/morrer.
4. Origem da primeira pessoa é limitada e verificada entre cabeça e cano, mas falta rejeitar vetores nulos antes de gastar munição. A mira da câmera e a linha do cano são calculadas separadamente nos dois lados.
5. Previsão usa um único raycast e não reproduz penetração/corpos/proteção; servidor já trata isso melhor.
6. Traçantes são linhas estáticas completas com criação/destruição por disparo. Não existe infraestrutura para projéteis matemáticos, gravidade, raio ou lifetime.
7. Cadência automática depende do frame e agenda a próxima tentativa a partir de agora, acumulando atraso quando FPS varia. Servidor mantém autoridade e não deve receber rajadas de compensação ilimitadas.
8. Rotinas de recarga podem terminar após troca de personagem; verificar pertencimento e vida antes de completar evita tarefas obsoletas.

Não há evidência medida nesta etapa que justifique rewind de personagens. Primeiro serão testados raycasts, rede e alvos móveis; eventual compensação será avaliada separadamente. Acerto continuará baseado na posição observada pelo servidor, com esta limitação documentada.

## Plano delimitado

Compartilhar geometria/dispersão e configuração; manter adaptadores de dano por modo; adicionar validação e confirmação de tiros; reservar munição prevista; oferecer simulação contínua opcional sem converter armas existentes; reutilizar traçantes com um único atualizador de efeitos. Testar contratos e integração no Studio, distinguindo simulação de inputs de aparelhos físicos e rede real.
