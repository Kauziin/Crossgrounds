# Ícones de mapas da Arena

Aplicados em Crossgrounds (ALPHA), Place 4375993208, em 26/10/2026.

- Os 14 PNGs fornecidos em MapsIcons.zip foram preservados em assets/arena-map-icons, sem edição dos pixels. Todos são quadrados.
- Enviados pelo upload de imagens do Studio. URIs persistidos em src/ReplicatedStorage/Crossgrounds/ArenaMapIcons.luau, por ID do mapa; reimportar geometria não perde a associação.
- MapLibrary.Catalog publica thumbnail. Um atributo Thumbnail explícito no template continua tendo precedência sobre o registro.
- MapVoteGrid usa ImageLabel em Crop, sombra preta independente e UIGradient vertical (90 graus), nome acima da sombra e seleção acima das demais camadas. A transparência da sombra cresce de 0 no topo até 1 na base da faixa.
- Votos usam fundo próprio para legibilidade. Seleção tem borda e marca de confirmação. Fotos são pré-carregadas em segundo plano enquanto o jogador está no lobby.
- Posto/outpost não possui imagem no ZIP e mantém o cartão sem fotografia. Não foi associado a uma foto de outro mapa.
- Cartões sem imagem preservam a apresentação anterior, inclusive o uso compartilhado pelo CTF.

## Conferência no cliente real do Studio

- 14 ImageLabels com imagens e 14 com IsLoaded=true.
- 14 sombras visíveis com gradiente a 90 graus e ordem imagem < sombra < nome.
- Capturas da votação com as fotografias carregadas, nomes legíveis, votos e destaque de Assault, Beach e Factory.
- Nova sessão após pré-carregamento: as 14 imagens já estavam carregadas na primeira votação.
- Fontes dos três módulos compiladas; console da sessão final sem erros de MapVoteGrid, MapLibrary ou ArenaMapIcons.
- Play encerrado. O servidor HTTP temporário de importação foi desligado e a GUI temporária usada para conferir uma imagem isolada foi removida.

Fontes anteriores dos dois módulos alterados em before/. A criação de ArenaMapIcons não modifica regras, geometrias ou spawns.
