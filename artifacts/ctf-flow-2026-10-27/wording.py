from pathlib import Path
p=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27\src\StarterPlayer\StarterPlayerScripts\CTFFlagLabels.luau')
s=p.read_text(encoding='utf-8')
a='table.insert(lines,(own and "INTERCEPTE: " or "ESCOLTE: ")..name..(own and " está com a sua bandeira!" or " está com a bandeira "..flagName(team).."!"))'
b='''if carrier==player.Character then
    table.insert(lines,"LEVE À BASE: você está com a bandeira "..flagName(team).."!")
   else
    table.insert(lines,(own and "INTERCEPTE: " or "ESCOLTE: ")..name..(own and " está com a sua bandeira!" or " está com a bandeira "..flagName(team).."!"))
   end'''
assert a in s;s=s.replace(a,b);p.write_text(s,encoding='utf-8')
