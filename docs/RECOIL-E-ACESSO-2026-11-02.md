# Recuo por arma e acesso de testers — 02/11/2026

Perfis centralizados em `WeaponRecoilProfiles`, aplicados às definições existentes antes do retorno de KitDefinitions. WeaponStats continua responsável por modificar os valores para acessórios; não são reaplicados multiplicadores no renderer. A exceção AX50.Recoil que ignorava perfis efetivos foi removida da apresentação; ferrolho AX50Motion permanece.

| Arma | Intenção | Push | Pitch | Roll |
|---|---|---:|---:|---:|
| AK-47 | pulante, potente, inclinada | 0,85 | 9 | 2,4 |
| M13 | suave | 0,20 | 2,1 | 0,25 |
| CR-56 AMAX | pulo alto, pouco recuo para trás | 0,35 | 8,2 | 0,8 |
| FR 5.56 | subida suave/progressiva em rajada | 0,28 | 3,4 | 0,35 |
| SCAR | coice profundo e baixo | 1,05 | 2,8 | 0,65 |
| AX-50 | médio-alto | 1,05 | 7 | 1,6 |
| HDR | médio-baixo | 0,75 | 4,5 | 0,95 |
| Rytec AMR | alto | 1,40 | 9,4 | 2,1 |
| Barrett M82 | alto, preparado | 1,40 | 9,2 | 2,0 |
| Dragunov | alto | 1,05 | 8,6 | 1,7 |
| Kar98k | médio | 0,85 | 5,8 | 1,25 |

Valores são impulsos de tuning, não os picos diretamente renderizados. Pitch/Roll em graus, Push em espaço de arma. Perfis também definem mola, amortecimento, atraso de retorno, sustentação da subida e intensidade recuperável da câmera. M82 permanece PreviewOnly no catálogo e não possui definição de combate: perfil armazenado, sem liberação da arma ou invenção de dano/cadência.

O mesmo WeaponRecoil alimenta a arma e uma segunda instância para câmera. A câmera usa um deslocamento temporário somado à orientação manual, não grava permanentemente cada disparo em yaw/pitch. Disparos consecutivos somam impulsos e reiniciam o prazo de recuperação; após cessarem, o deslocamento volta a zero. Troca de arma limpa o estado. Armas não incluídas e Projectile Test preservam seu caminho anterior. Os perfis existentes da Arena não foram alterados. Valores finais de sensação ainda dependem de teste manual, sobretudo com controle, ADS e acessórios.

## Acesso

`PremiumFeatureAccess` é uma política de servidor baseada nos IDs estáveis de TesterConfiguration e no proprietário 1248190494. Os seis testers existentes foram preservados: md4747_1, gustavo26432134, gabrielnog652009, kaylah_br, bosonaroeyag e isaklp73. Nenhum ID fornecido pelo cliente nem atributo de badge concede permissão.

ThemeEntitlements consulta a política antes de consultar Marketplace, inclusive quando não há passe configurado. A mesma permissão é consumida pela validação de preferências do servidor, não somente pela interface. Atributos ThemeCustomAllowed/PremiumFeaturesAllowed refletem o resultado; ThemeCustomAccess=Tester distingue essa concessão de uma compra. Jogadores normais continuam passando pelo teste de posse do passe. Futuras features pagas podem reutilizar a política em seus gates de servidor; este trabalho integra a feature paga atual Custom Color.

## Validação

- Todos os 11 perfis simulados retornaram a neutro em três segundos. Três contratos de recuo aprovaram retorno em 30/60/120 FPS, acúmulo/reinício do prazo e limpeza ao trocar arma.
- Testes dos sete IDs autorizados e de uma conta comum passaram. No Play, sua conta teve Owns=true, PremiumFeaturesAllowed=true e ThemeCustomAccess=Tester.
- Pelo RemoteEvent normal de preferências, ThemePreset=0 e AccentHue=147 foram aceitos pelo servidor; alterações foram apenas da sessão de teste.
- Play carregou as dez definições jogáveis com RecoverableRecoil=true. M82 foi confirmada como PreviewOnly, perfil não exercitado em combate.
- Apresentação compilada; diff verificado. Avaliação visual de todos os disparos e sensação em dispositivos não foi realizada.

Principal em Edit; cópias anteriores em `ServerStorage.Development.Revisions.RecoilAccessBaseline_20261102` e `artifacts/recoil-access-2026-11-02/before`. Nenhuma publicação, compra ou mudança de propriedade do passe.
