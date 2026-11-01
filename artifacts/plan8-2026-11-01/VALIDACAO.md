# Plano 8 — Armeiro e mãos das pistolas

Implementação e verificações em 01/11/2026, no Place 4375993208. As fontes locais e 13 fontes no editor foram comparadas e compiladas. Nenhuma publicação foi realizada.

## Comportamento entregue

- Armas: categorias à esquerda, lista vertical rolável, prévia e atributos reais à direita; confirmação direta. Ícones vetoriais leves, sem um ViewportFrame por linha.
- Acessórios: slots horizontais, lista ampla sem coluna interna de ações, prévia permanente e bloco separado de atributos, três atalhos compactos e informação de aplicação. A sidebar e o fundo real desfocado continuam presentes. Foco claro e losango são distintos do estado equipado turquesa.
- Salvar não retorna à lista de classes. Reconhecimento do servidor atualiza as linhas existentes e preserva slot, foco e rolagem. Falhas restauram o estado salvo. B percorre a rota de retorno: acessórios → trocar arma → B volta aos acessórios → B volta à classe.
- `AttachmentCompatibility` centraliza bloqueios, situação de verificação, armas/plataformas e mounts. A UI usa cache por arma/slot com invalidação explícita. O servidor valida IDs e calcula os modificadores no modelo compartilhado, sem aceitar multiplicadores do cliente.
- Retirado o teto global de cinco acessórios. Cada slot continua exclusivo. Corrigido o crescimento da lista de slots da AUG a cada leitura de `WeaponCatalog.Get`.
- Estatísticas preservam KitDefinitions, aplicam multiplicadores antes de adições, ignoram campos opcionais ausentes e apresentam unidades reais, sem pontuações ilustrativas de controle/mobilidade.
- A prévia conserva o modelo e a geometria base ao mudar acessórios. Os snapshots guardam peças de acessórios; bases e combinações possuem caches limitados a quatro entradas. A geometria saneada do servidor possui cache de 24 entradas. Scripts, sons e efeitos não são executados nas cópias de prévia. Pedidos obsoletos são descartados pela geração existente.
- As sete pistolas MW usam origem de empunhadura própria; M19/X16 usam a peça de magazine dentro da empunhadura, Renetti usa Default_Grip. Mão de apoio fica junto à empunhadura, e o muzzle acompanha o cano real. WeaponHold reconhece pistolas MW, legado e Arena para montagem e primeira pessoa. A montagem não desloca os attachments a cada equipagem.

## Inventário e alcance da compatibilidade

`inventory.json` contém a exportação real de 267 IDs registrados e 1.328 containers de 20 packs; nenhum ID registrado estava ausente. `INVENTARIO-COMPATIBILIDADE.md` e `compatibility-inventory.json` registram aliases, candidatos à deduplicação, origens e estados.

O catálogo possui 100 registros: seis equipáveis, incluindo a conversão lógica de rajada da AUG, e 94 pendentes. Os nove pares de arma/acessório com montagem já implementada foram construídos nos testes. Modelos adicionais e registros pendentes não foram liberados por categoria/nome: ainda exigem encaixe individual implementado e verificado. Nenhum asset foi apagado ou renomeado.

## Testes executados

| Verificação | Resultado |
| --- | --- |
| `Plan8Arsenal_Test` | 15/15 passaram, inclusive bloqueios, mounts, invalidação, seis slots sintéticos independentes, valores forjados, leitura idempotente da AUG, stats sem recoil opcional, geometria saneada, pistolas e atualização incremental da prévia |
| `SharedBindingsAndIronSights_Test` | 5/5 passaram |
| `WeaponMovement_Test` | 15/15 passaram |
| `ArsenalVisual_Test` | 9/10 passaram; uma expectativa antiga de quantidade de registros falha |
| `BurstFire_Test` | 4/5 passaram; uma expectativa antiga de dano falha |
| Fontes finais no editor | 13 compiladas e iguais aos arquivos locais normalizando CRLF |
| `git diff --check` | Passou |

As duas falhas antigas foram verificadas contra o baseline anterior: o teste espera 97 registros físicos, mas o catálogo já tinha 99; outro espera dano 28 na M4A1, enquanto KitDefinitions em HEAD já define 32. As expectativas e o balanceamento não foram alterados para ocultar as falhas. Resultado agregado dessas cinco suítes: 48/50, com os 15 testes novos passando.

### Play real

- Practice Range: entrada pelo protocolo normal. Doze passos de D-pad e rolagem de 540 unidades preservaram CTFArsenalState e a mesma arma de prévia. A confirmou a mira G.I Mini Reflex; servidor aplicou imediatamente, e a mesma linha, a rolagem e a mesma Instance de Model foram preservadas. LB/RB alternou os slots. Colossus pendente para M4A1 foi recusado. Payload com APX5 não verificada foi rejeitado pelo servidor e a seleção anterior permaneceu salva.
- CTF normal, RoundState=Playing: salvar M4A1 com mira/Commando e Renetti criou pendência, preservando o Character e as Tools da vida atual. Morte e respawn reais criaram outro Character; a configuração passou a ativa, a pendência foi limpa e as Tools receberam os acessórios e a Renetti. Evidências: `mode-results.json` e `ctf-respawn.json`.
- Hub e Arena: ArsenalCommand recusou save do CTF com “Indisponível nesta modalidade.” A tentativa na Arena preservou personagem e Tool atual. As seis pistolas cosméticas da Arena continuaram como ArenaPistol e mantiveram distância de aproximadamente 0,274 stud entre os grips.
- Sete pistolas MW foram salvas/equipadas uma a uma no treino, preservando Character. Os erros medidos entre Right/LeftGripAttachment das mãos R15 e seus alvos ficaram abaixo de 0,00005 stud em repouso. Primeira pessoa da Sykov e da M19 conferida visualmente. Na M19, tiro real reduziu munição de 17 para 16; recarga foi observada ativa e depois encerrada, com retorno dos grips abaixo de 0,00005 stud. Não se trata de avaliação de todos os avatares possíveis.
- Cinco fechamentos verificados após abertura real: nenhum Gunsmith/WeaponPreview restante no PlayerGui; referências anteriores de raiz e modelo destruídas. Quatro repetições estão em `cleanup-final.json`. Não houve perfil de heap ou benchmark de FPS/GPU.
- A navegação acessórios → Trocar arma → B → B retornou a ACESSÓRIOS e depois CRIAR CLASSE, sem tela adicional de confirmação.

### Visual e tamanhos

Capturas finais de 1920×1080, dimensões verificadas nos arquivos:

- `armas-final.jpg`
- `acessorios-final.jpg`
- `m19-maos-final.jpg`

Comparadas com as duas referências aprovadas. Preservadas as proporções adaptativas e as estatísticas reais do jogo, com ícones vetoriais simplificados. No conteúdo estreito, prévia/atributos vão abaixo da lista e usam a rolagem externa existente. Conferida resolução de 960×540, canvas de 970 unidades e ausência de sobreposição entre blocos; teste de módulo também cobre conteúdo de 500 unidades e geometria com fonte de 135%. Isso não substitui teste de toque em aparelho físico.

## Limites e encerramento

Sem publicação, partida humana multiplayer completa, Xbox/telefone físicos, DataStore de produção ou medição de FPS/GPU. O Studio usa persistência de sessão durante esses testes. Compatibilidades pendentes continuam bloqueadas. Permanecem avisos anteriores de áudio, GUIEditor, assets externos e uma chave de ConfigService ausente, sem nova exceção observada dos componentes alterados na última rodada de Play.

As alterações paralelas de tema, lunetas e opções de classes foram preservadas. Testes e bridges ficam fora de src; fixtures de Play são temporárias. O Estado de desenvolvimento é o registro principal da entrega.

Conferência final: Studio em Edit, device `default`, nenhuma fixture Plan8Tests/Plan8LatestView no editor. Treze fontes recompiladas e iguais aos arquivos locais. Evidência em `final-editor-state.json`.
