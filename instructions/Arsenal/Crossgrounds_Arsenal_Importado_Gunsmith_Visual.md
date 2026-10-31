# Crossgrounds — Migração do Arsenal Importado e Gunsmith Visual

**Repositório de referência:** https://github.com/Kauziin/Crossgrounds (`master`)  
**Destinatário:** Codex / Roblox Studio  
**Escopo:** armas, importação, acessórios, catálogo, loadouts, estatísticas informativas e interface.  
**Fora de escopo:** reformulação de classes, rebalanceamento de disparos, balística, dano, hit registration, monetização e progressão de desbloqueios.

## Objetivo

O CTF está deixando o catálogo de armas procedurais simples para utilizar um conjunto amplo de modelos importados, incluindo um pacote com armas e acessórios inspirados em Call of Duty: Modern Warfare (2019). Inspecione **os assets realmente presentes no Studio** antes de prometer qualquer arma ou acessório; a lista exata do pacote, suas hierarquias e licenças **não foram fornecidas neste documento**. Não presuma que os arquivos já estejam versionados no GitHub.

Entregue um arsenal escalável com modelos completos, escolha de arma primária e pistola secundária, sistema de acessórios visuais modulares e tela Gunsmith com estatísticas. A substituição do núcleo de combate ocorrerá em outra etapa. Nenhuma modificação de acessório pode alterar características funcionais por enquanto.

## 1. Auditoria e inventário de assets

1. Audite `ServerStorage`, `ReplicatedStorage`, modelos e Packages existentes, além de qualquer pasta de importação que tenha sido acrescentada ao Studio. Registre cada asset por nome, localização, tipo (`Model`, `Tool`, `MeshPart`, `UnionOperation`, etc.), dimensão, `PrimaryPart`/pivot, quantidade de peças, triângulos quando mensuráveis, materiais, texturas, componentes móveis e estado de integridade.
2. Catalogue as famílias de armas que de fato existem: fuzis de assalto, batalha, DMR, SMGs/PDWs, metralhadoras, precisão, escopetas, pistolas/revólveres e corpo a corpo. Identifique duplicatas, aliases e variantes cosméticas de uma mesma plataforma; não conte cada acessório como nova arma.
3. Para cada arma, determine se os acessórios são objetos independentes, peças embutidas ou variantes completas do modelo. Registre os slots efetivamente suportados antes de produzir a UI.
4. Procure scripts, `RemoteEvent`s, `ModuleScript`s, animações, luzes e efeitos embutidos em modelos adquiridos de terceiros. Não execute código estranho durante a inspeção; integre apenas modelos e componentes necessários após revisão.
5. Preserve uma cópia inalterada dos imports e faça todas as conversões numa pasta de trabalho isolada. Não espalhe cópias de teste permanentemente no `Workspace`.
6. Registre a proveniência de cada pacote e **confirme permissão de reutilização e publicação** de modelos, texturas, áudio e logotipos; um modelo disponível para download não é automaticamente livre para republicação numa experiência Roblox. Caso a licença esteja incerta, marque `publicationBlocked` até confirmação, sem apagar o asset de trabalho.

**Entrega da auditoria:** tabela de armas e acessórios presentes, identificadores propostos, estado de prontidão, dependências ausentes e risco de publicação. Não invente um inventário do pacote MW2019.

## 2. Arquitetura de catálogo, independente das classes

A implementação atual conhecida usa `src/ReplicatedStorage/KitDefinitions.luau`, `src/ReplicatedStorage/Crossgrounds/LoadoutDefinitions.luau`, `src/ServerScriptService/MainGameScript/GameManager/WeaponFactory.luau` e serviços de equipamento. Revise a versão efetiva do projeto antes de editar: outras sessões do Codex podem ter alterado esses arquivos.

- Separe `WeaponCatalog` (metadados), `WeaponAssetRegistry` (modelos), `AttachmentCatalog`, `WeaponAttachmentCompatibility`, `WeaponPresetDefinitions`, `WeaponStats` e `LoadoutDefinitions`. Nomes exatos podem adaptar-se à organização do repositório, sem criar duplicações desnecessárias.
- Identificadores estáveis, sem depender de nomes exibidos nem de `Instance.Name`; por exemplo `ak47`, `mp7`, `scar_h`, `m1911`. Forneça nomes exibidos, categoria, família, variantes, asset de mundo, preview, rig, disponibilidade, estado de implementação e conjunto de slots compatíveis.
- Separe `WeaponDefinition` de `WeaponVisualConfiguration`: a mesma arma pode ser mostrada com acessórios distintos sem tornar-se outra definição de combate.
- Mantenha um adaptador de compatibilidade para armamentos já presentes, evitando quebrar Arena, bots ou inventários persistidos enquanto a migração ocorre. CTF não deve forçar alterações da seleção cosmética de pistolas da Arena.
- **Pause o redesenho das classes** (`Leve`, `Regular`, `Pesado`, `Invasor`, `Demolidor`). Não remova os dados antigos, mas não dependa dessas classes para cadastrar e visualizar novas armas.

## 3. Loadouts nesta etapa

- Construir loadouts CTF editáveis, contendo pelo menos `primaryWeaponId`, `secondaryWeaponId` (pistola/revólver compatível) e eventual `meleeWeaponId` preservado conforme regras já existentes.
- Oferecer múltiplos presets nomeáveis, com escolha pendente até respawn quando essa for a regra atual. Preservar o loadout existente quando a seleção é inválida.
- Não fixar loadouts ao índice de uma classe; manter compatibilidade temporária com atributos e fluxo existentes.
- Cada slot referencia o ID da arma e sua configuração de acessórios (não uma cópia de Model). Validar disponibilidade, categoria, compatibilidade e limites.
- Permitir listar e pré-visualizar modelos ainda não integrados ao combate com estado explícito `PreviewOnly`/`NotPlayable`; **não mostrar uma arma como equipada e funcional se ainda não estiver integrada**.

## 4. Acessórios — Gunsmith visual

Defina slots configuráveis por arma, não universalmente: `optic`, `muzzle`, `barrel`, `underbarrel`, `stock`, `magazine`, `rearGrip`, `laser`, `rail`, `ammunition`, `special` conforme a estrutura real dos modelos.

- Registre `attachmentId`, categoria, descrição, modelos compatíveis, dependências de rig, modelo de preview e pontos de montagem; `physicalAssetPath` apenas quando existir.
- Cada arma declara `AttachmentMounts` (Attachments/pivots estáveis), bases visuais, subcomponentes ocultáveis, restrições e exclusões mútuas. Um cano longo pode ocultar o cano original; uma nova mira pode ocultar miras originais somente se necessário. Não deixe peças duplicadas sobrepostas.
- Ao trocar acessórios, preserve alinhamento de armas e mãos; suporte à passagem entre FP e TP, prévia do menu e modelo no chão. Garanta que `Muzzle`, `RightHandGrip`, `SupportGrip`, `RestGrip`, `ReloadGroup` e demais contratos necessários sejam adequadamente remapeados ou adaptados.
- Visuais de mag e de ferrolho devem permanecer animáveis; componentes que exigem movimento não devem ficar soldados ao corpo fixo de maneira irreversível. Para revólveres/shotguns, aceite estruturas específicas.
- Limite inicial sugerido: até cinco acessórios equipados, mas deixe configurável por modalidade/arma, sem esconder categorias que não existam no pacote.
- Implemente estado `Equipped`, `Available`, `Incompatible`, `UnavailableAsset` e `PreviewOnly`; feedback claro nos dispositivos PC, console e mobile.
- **Acessórios por enquanto são 100% visuais.** Não alteram recoil real, dispersão, dano, alcance, velocidade, cadência, capacidade de munição, zoom funcional, ruído para bots, duração de recarga ou hit detection. Um carregador estendido visual não concede munição adicional; sinalize essa situação com clareza na UI para evitar confusão.

## 5. Estatísticas — fonte de verdade e apresentação

Mostrar no detalhe de cada arma: `Dano`, `Alcance`, `Precisão`, `Controle`, `Mobilidade`, `Cadência` e opcionalmente `Capacidade`, `Tempo de recarga`, `Manejo`.

**Três camadas de dados distintas:**

1. `baseStats`: atributos informativos da arma, originados dos dados existentes quando adequados e marcados como provisórios se o combate será refeito.
2. `attachmentStatIntent`: efeito pretendido de cada acessório **futuro e não aplicado**, como `+controle`/`-mobilidade`, sem conexão com gameplay.
3. `effectiveGameplayStats`: somente os valores reais fornecidos pelo núcleo ativo; nunca calculá-los a partir dos acessórios visuais na fase atual.

- Enquanto o novo núcleo não existir, não apresente deltas de acessórios como bônus ativos. Pode haver uma aba **'Efeitos planejados (sem efeito no jogo)'**, preferencialmente desativada por padrão, ou apenas descrições qualitativas.
- Barras normalizadas 0–100 são **índices comparativos de exibição**, não unidades físicas nem garantia de dano. Exibir também unidade real (`RPM`, munições, segundos, studs) apenas quando confirmada. Não inventar valores.
- Comparar arma atual vs. arma candidata por valores-base; ressaltar atributos desconhecidos e diferenciação por categoria. Não confundir `accuracy` visual com precisão efetiva.
- Adicionar `statsSchemaVersion` para migrar depois para o novo núcleo sem refazer o UI.

## 6. Gunsmith na interface em cascata

Reutilizar o menu existente e seu padrão de navegação; não criar interface paralela nem refazer o sistema de foco.

Fluxo: **CTF → Armamentos → Loadouts → Primária/Secundária → Arma → Personalizar**. O detalhamento de arma mostra preview 3D grande, nome, categoria, família, estado de integração, slots de acessórios, estatísticas e ações de escolher/aplicar/resetar.

- Slots em volta ou abaixo da arma conforme resolução; clicar ou confirmar abre seletor de acessórios compatíveis.
- Atualizar a montagem no preview sem destruir/recriar indiscriminadamente a câmera ou reiniciar foco a cada seleção. Botão de aplicar, cancelar e restaurar padrão.
- Gamepad: D-pad navega slots e opções, A confirma, B retorna, LB/RB alterna categorias relevantes, analog direito gira o preview quando estiver em foco específico. Sem foco em decorações.
- Mouse: rotação arrastando, scroll para navegar e ajustar zoom controlado; touch: gesto equivalente com limites.
- Evitar painéis de estatísticas que ocluam arma ou ocupem toda tela pequena; estado de 'ainda não funcional' deve ser visível sem poluir o layout.
- Permitir salvar presets de personalização independentemente do loadout. Validar no servidor a compatibilidade antes de persistir.

## 7. Importação e montagem robusta

- Criar fluxo de 'Edit in Workspace' temporário para modelos em `ServerStorage`, com cópia, armazenamento do pivot original e retorno seguro; a pasta temporária deve ser removida após finalização. Não editar diretamente o original.
- Normalizar orientações/escala sem deformar o conjunto; usar `Model:PivotTo()` para deslocar conjunto e `Attachment`s para montar partes. Mudar pivots de peças individuais apenas quando necessário.
- Corrigir `MeshPart`s com colisão inútil, peças soltas, `CanCollide`, `Massless`, soldas e objetos que devem ou não renderizar na prévia; oculte partes internas apenas se comprovadamente não visíveis.
- Se um asset depender de scripts próprios do pacote, preferir adaptá-lo aos contratos do Crossgrounds a manter múltiplos sistemas de armas concorrentes.
- Estabelecer nível de detalhe/performance para PC, Xbox e celular; não carregar o inventário 3D inteiro em todas as telas nem deixar dezenas de cópias ativas no Workspace.

## 8. Ordem de execução

**Fase 0 — Auditoria:** localizar pacote real e produzir inventário fiel.  
**Fase 1 — Catálogo:** IDs estáveis, compatibilidade e metadados; preservar legado.  
**Fase 2 — Piloto:** converter **uma arma primária, uma pistola e três acessórios** até completar o ciclo modelo → preview → equipar → persistência visual.  
**Fase 3 — Loadouts:** primária e secundária configuráveis, sem dependência de classe nova.  
**Fase 4 — Gunsmith:** slots, montagem, preview, compatibilidade e aplicação de acessórios visuais.  
**Fase 5 — Estatísticas:** exibir valores-base verificados; definir contrato para modificadores futuros sem aplicá-los.  
**Fase 6 — Expansão:** integrar o restante das armas conforme nível de prontidão, com logs de problemas de assets e migração progressiva.  
**Fase 7 — Validação:** salvar/carregar preset, equipar após respawn, trocar modo, bot com arma antiga, acesso via console e celular, armas sem attachment, modelos com parts faltando, clipping, preview e performance.

## 9. Critérios de aceite

- O usuário consegue escolher uma primária e uma pistola secundária por loadout no CTF, independentemente da futura reformulação de classes.
- Armas importadas presentes são catalogadas com estado real; não inventar assets inexistentes.
- Acessórios montam e desmontam corretamente em preview e em jogo quando a arma estiver integrada.
- A UI mostra estatísticas-base de maneira honesta, sem afirmar bônus funcionais de acessórios visuais.
- A substituição do núcleo de combate pode consumir catálogo, configurações e slots de acessórios sem retrabalho de dados.
- Arena, bots e sistemas existentes não sofrem regressões decorrentes da migração.
- O Codex entrega inventário real, lista de alterações, testes feitos/não feitos e pendências de assets/licença.

**Resultado esperado:** catálogo amplo e expansível, Gunsmith visual utilizável, loadouts com arma primária e pistola secundária, arquitetura pronta para estatísticas funcionais futuras — sem alterar o núcleo de combate ou o sistema de classes nesta etapa.
