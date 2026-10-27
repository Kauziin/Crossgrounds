from pathlib import Path
p=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27\src\ReplicatedFirst\CrossgroundsLoading.luau')
s=p.read_text(encoding='utf-8');a='or mapBusy or request~=nil';assert a in s;s=s.replace(a,'or mapBusy or request~=nil or player:GetAttribute("SceneLoadingError")~=nil',1);p.write_text(s,encoding='utf-8')
