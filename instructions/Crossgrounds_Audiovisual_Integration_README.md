# Crossgrounds — Audio, Weapons & Animation Workflow

Pacote de instruções para o Codex. Os documentos são independentes; podem ser usados juntos para sincronizar som, arma e animação.

1. **Crossgrounds_Audio_Direction_and_SFX.md** — auditoria e pesquisa de sons, eventos, música/efeitos, mixagem e integração.
2. **Crossgrounds_Animation_Direction.md** — estados de locomoção e armas, FP/TP, slide, strafe, reload e sincronização de animações.
3. **crossgrounds-weapon-modeling/SKILL.md** — skill reutilizável para criação e refinamento de armas 3D, com templates e checklist.

## Ordem recomendada

1. Auditar assets, rig e implementações existentes nos três eixos.
2. Definir uma arma representativa e uma sequência: equipar → andar lateralmente → disparar → recarregar → sprint → slide → pulo → pouso. Testar FP e TP.
3. Ajustar pivôs e viewmodel da arma, então animações/markers, e por fim escolher e sincronizar SFX definitivos; iniciar seleção de UI SFX em paralelo.
4. Publicar/registrar IDs e testar no Studio quando houver acesso; repetir para demais armas e modos somente após validar o protótipo.

Nenhum passo precisa ser refeito do zero se os módulos existentes já o atendem. A ausência de Studio, Blender ou assets reais deve ser documentada como limitação, não mascarada.
