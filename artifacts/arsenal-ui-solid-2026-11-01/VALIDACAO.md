# Armamentos — listas, iluminação e acessibilidade

Aplicado ao editor principal 4375993208 em 01/11/2026. Nenhuma publicação nesta etapa.

As imagens abaixo são capturas nativas do Play real no preset Xbox One, em 1920×1080. O simulador foi restaurado ao estado anterior depois dos testes.

| Captura | Verificação |
| --- | --- |
| [Acessórios: lista](xbox-acessorios-lista.jpg) | Uma coluna, slots à esquerda, render inicialmente oculto, ajuda de Y. |
| [Acessórios: preview](xbox-acessorios-preview.jpg) | Y mostra o render com luz frontal e halo branco suave. |
| [Armas](xbox-armas.jpg) | Lista vertical com render permanente. |
| [Fonte 135% e alto contraste](xbox-acessibilidade-135.jpg) | Geometria ampliada; texto sem escala duplicada. |
| [Classes do CTF](xbox-classe-ctf.jpg) | Correção das faixas de hover e iluminação. |
| [Arena](xbox-arena.jpg) | Iluminação compartilhada, preservando oito previews existentes. |

Confirmados: navegação real por D-pad, preview por ButtonY, reutilização da mesma Instance ao alternar visibilidade, inspeção sem envio da seleção, rodapé dentro da área útil, adaptação a largura 540 sem sobreposição e limpeza ao sair. Sete fontes compilaram e coincidem com o editor; git diff --check passou.

Limites: Xbox emulado, sem aparelho físico ou medição de FPS/GPU; sem partida multiplayer completa. Avisos anteriores de áudio, plugin GUIEditor e Standings permanecem fora desta alteração. O Estado de desenvolvimento principal contém o registro completo e as distinções entre os backups locais e os exports posteriores do editor.
