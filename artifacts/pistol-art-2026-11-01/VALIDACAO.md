# Artes de acessórios e recargas de pistolas — 01/11/2026

Implementação aplicada ao Place principal Crossgrounds (ALPHA), 4375993208, após desenvolvimento e testes na cópia local. Nove fontes finais compilaram e coincidem com GetEditorSource nas duas instâncias, normalizando CRLF. Ver main-final-edit.json e copy-final-edit.json. Nenhuma publicação do jogo. Cópia local salva pelo Studio em test-runs/pistol-art-20261101/Crossgrounds-Pistol-Art.rbxl, após remoção dos ganchos e fixtures temporários.

## Implementação

- Acessórios usam linhas de 44 px, nome em uma linha, arte estática e indicador de equipado; removida a segunda linha de descrição/status. Compatibilidade e detalhes continuam no painel de inspeção. Estados pendentes continuam diferenciados. Nenhum ViewportFrame individual nos botões.
- 101 tiles cobrem o catálogo de 100 entradas e a remoção: 99 modelos físicos renderizados no Studio, símbolo da conversão lógica e símbolo sem acessório. Três páginas de até 960×768, tiles de 160×96. Uma primeira imagem grande foi reduzida automaticamente pelo Roblox; substituída pelas três páginas para preservar os recortes. Assets ativos e origem em assets/ui/attachments/provenance.json.
- PistolReloadMotion cobre sete pistolas MW, seis cosméticas da Arena e fallbacks. Curvas quintic com início/final suaves. Magazine sai/reentra/assenta; recarga parcial preserva a câmara; vazia mantém e libera o slide. Luger usa toggle. Revólver abre tambor, ejeta, usa speedloader e fecha. Peças estáticas não acompanham o slide/tambor. Speedloader alternativo removido do visual e loader padrão oculto fora da fase de inserção.
- WeaponReloadMotion usa ReloadStartedAt/ReloadDuration do servidor. Cancelamento volta à pose de repouso em 0,14 s. WeaponPose e FirstPersonRenderer compartilham transformações/pivôs e trajetória da mão de apoio. KitService registra ReloadWasEmpty antes do início. Tempos, munição, reserva e balanceamento mantêm o fluxo existente. Modificações paralelas da AX-50 preservadas.

## Testes efetivamente realizados

Principal, em Play novo: **49/49** passaram (main-unit-results.json): PistolReloadAndArt 15/15, Plan8Arsenal 15/15, WeaponMovement 15/15 e AX50Prototype 4/4. Isso cobre endpoints de 13 perfis, parcial/vazia, Luger, loader, duração real, cancelamento, 30/144 FPS matemáticos, pivô, valores finitos, peças importadas, atlas completo/limites e lista sem descrição/viewport. A suíte Plan8 também cobre contratos de aplicação por modo e mãos. Não equivale a repetir partidas humanas completas de todos os modos.

Cópia: recargas reais pelo remote WeaponReload, com munição inicial controlada somente na sessão de teste. M19 vazia: 2,14 s, 59 amostras, curso de Magazine ~0,872 stud, retorno a zero e Ammo=17. M19 parcial: ReloadWasEmpty=false e slide sem curso. .357: 3 s, tambor com curso ~0,405 stud e retorno a zero, Ammo=6. A janela inativa impedia o dono normal da câmera; a revisão visual da cópia usou o módulo FirstPersonRenderer real temporariamente, acionado por RenderStepped e atributos reais de recarga. Loader observado durante a fase de carregamento e oculto ao final. O gancho de navegação temporário existiu só na cópia, foi removido antes de finalizar e nunca entrou no bundle.

Principal: foco recuperado pela skill computer-use. Navegação normal F2 → Armeiro → X no slot secundário abriu acessórios; imagens visíveis com IsLoaded=true e recortes corretos. Captura em acessorios-principal-final.jpg. Cliente normal criou Players.LocalPlayer.PlayerGui.FirstPersonDisplay. Recarga vazia da 1911 acionada pelo remote real, após Ammo=0 controlado no servidor: ReloadWasEmpty=true, ReloadDuration=1,64, estado Reloading observado e retorno a Ammo=7/Reloading=false. Captura em m1911-recarga-principal.jpg e 40 amostras em main-pistol-live-trace.json. Não houve renderer manual no principal.

Capturas da cópia: acessorios-artes-final.jpg (1920×1080), m19-recarga-copia.jpg e revolver-recarga-copia.jpg. Capturas do principal refletem a resolução real da janela, 1103×774; não são prova de Xbox físico ou 1920×1080.

Play encerrado nas duas instâncias. StopSimulationAsync bem-sucedido em ambas. Confirmados no editor: ausência de PistolArtReview, PistolArtTests e AttachmentArtBake. git diff --check passou (avisos de conversão LF/CRLF). Backups anteriores preservados em before/ e main-before.json.

## Limites

Sem publicação, push, teste em Xbox/mobile físico, benchmark FPS/GPU, DataStore de produção ou multiplayer humano completo. Arena/Luger têm contratos de mecanismo e montagem testados; não foi realizada uma partida completa para cada cosmética. A suavidade matemática e as capturas foram verificadas; avaliação perceptiva em controle físico e visual de terceira pessoa em rede continuam pendentes.
