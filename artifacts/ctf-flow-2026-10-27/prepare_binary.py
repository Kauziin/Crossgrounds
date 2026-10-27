from pathlib import Path
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio')
s=(r/'tools/patch_ui_audio_place.cjs').read_text(encoding='utf-8')
s=s.replace("const homeOnly = process.argv.includes('--home');","const homeOnly = false;")
a=s.index('const input =');b=s.index('\nconst classes',a)
s=s[:a]+"const input = fs.readFileSync(path.join(root,'artifacts/ctf-flow-2026-10-27/before.rbxl'));"+s[b:]
a=s.index('const files =');b=s.index('const pending=',a)
s=s[:a]+"const files = "+str([str(p.relative_to(r/'artifacts/ctf-flow-2026-10-27/src').with_suffix('')).replace('\\','.') for p in (r/'artifacts/ctf-flow-2026-10-27/src').rglob('*.luau')])+";\n"+s[b:]
s=s.replace("path.join(root,'src',...name.split('.'))","path.join(root,'artifacts/ctf-flow-2026-10-27/src',...name.split('.'))")
a=s.index('const out=');b=s.index('\nconst output=',a)
s=s[:a]+"const out=path.join(root,'CrossgroundsAlphaCopy-CTF.rbxl');"+s[b:]
(r/'tools/patch_ctf_flow_place.cjs').write_text(s,encoding='utf-8')
