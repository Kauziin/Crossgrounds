"""Local Studio bridge and offline screenshot gallery builder."""
from pathlib import Path
from http.server import BaseHTTPRequestHandler,HTTPServer
import json,html,re
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/interface-library-2026-11-03'
FILES=['ReplicatedStorage/Crossgrounds/StudioInterfaceScenarios.luau','ServerScriptService/Crossgrounds/StudioInterfaceDebug.server.luau','StarterPlayer/StarterPlayerScripts/StudioInterfaceDebug.luau','StarterPlayer/StarterPlayerScripts/StudioInterfaceDebugController.local.luau','StarterPlayer/StarterPlayerScripts/CascadeMenu.luau','StarterPlayer/StarterPlayerScripts/MenuNavigation.luau','StarterPlayer/StarterPlayerScripts/LevelUpNotices.local.luau','StarterPlayer/StarterPlayerScripts/LobbyPlaylist.luau']
def bundle():
 extras=['StarterPlayer/StarterPlayerScripts/EliminationSpectator.local.luau','StarterPlayer/StarterPlayerScripts/ExperienceFeedback.local.luau','StarterPlayer/StarterPlayerScripts/HeldStandings.local.luau','StarterPlayer/StarterPlayerScripts/GunsmithView.luau']
 result=[]
 for file in FILES+extras+['StarterPlayer/StarterPlayerScripts/ControlHints.local.luau']:
  path=file.removesuffix('.luau');kind='ModuleScript'
  if path.endswith('.local'):path=path.removesuffix('.local');kind='LocalScript'
  if path.endswith('.server'):path=path.removesuffix('.server');kind='Script'
  result.append(dict(path=path.replace('/','.'),className=kind,source=(ROOT/'src'/file).read_text(encoding='utf-8-sig')))
 return result
def gallery():
 OUT.mkdir(parents=True,exist_ok=True)
 images=sorted(OUT.glob('*.png'))
 groups=[('Estruturas e dados','0'),('Eventos','1'),('Configurações','2'),('Progressão','3'),('Armamentos','4'),('HUD e mensagens','5'),('Mobile','6'),('Rolagem e detalhes','7')]
 def group(name):
  match=re.match(r'(\d+)',name)
  return (match.group(1)[0] if match else '?')
 records=[]
 for p in images:
  records.append({'file':p.name,'title':p.stem,'group':group(p.name),'bytes':p.stat().st_size})
 (OUT/'manifest.json').write_text(json.dumps({'created':'2026-11-03','source':'Roblox Studio Play, local client','count':len(records),'images':records},ensure_ascii=False,indent=2),encoding='utf-8')
 buttons=''.join(f'<button data-group="{key}">{html.escape(label)}</button>' for label,key in groups)
 body=''.join(f'<figure data-group="{group(p.name)}" data-name="{html.escape(p.stem.lower())}"><a href="{p.name}"><img loading="lazy" src="{p.name}" alt="{html.escape(p.stem)}"></a><figcaption>{html.escape(p.stem)}</figcaption></figure>' for p in images)
 page='''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Crossgrounds · Biblioteca de interfaces</title><style>body{background:#101820;color:#e9f2f7;font:16px system-ui;margin:0;padding:24px;max-width:1800px}a{color:#70e4e9}header{position:sticky;top:0;z-index:1;background:#101820ee;padding:0 0 12px;backdrop-filter:blur(8px)}h1{font-size:1.6rem;margin:0 0 8px}.meta{color:#bbd1dc;margin:6px 0 12px}.controls{display:flex;gap:8px;flex-wrap:wrap}button,input{background:#19303e;color:#e9f2f7;border:1px solid #3e6675;border-radius:7px;padding:8px 12px;font:inherit}button{cursor:pointer}button.active{background:#117c8d}input{min-width:220px;flex:1}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,420px),1fr));gap:16px}figure{margin:0;background:#1a2935;padding:10px;border-radius:10px}figure[hidden]{display:none}img{width:100%;height:auto;display:block;aspect-ratio:16/9;object-fit:contain;background:#0b141a}figcaption{padding:9px 3px 2px;overflow-wrap:anywhere}</style><header><h1>Crossgrounds · Biblioteca de interfaces</h1><p class="meta">Capturas locais do Studio · <span id="count"></span> imagens · dados simulados identificados na captura. <a href="COBERTURA.md">Cobertura</a> · <a href="ANALISE.md">Análise</a> · <a href="manifest.json">Manifesto</a></p><div class="controls"><button data-group="*" class="active">Todas</button>'''+buttons+'''<input id="search" type="search" placeholder="Buscar tela ou evento" aria-label="Buscar capturas"></div></header><main>'''+body+'''</main><script>let active='*';const cards=[...document.querySelectorAll('figure')];const count=document.querySelector('#count');const search=document.querySelector('#search');function update(){let q=search.value.trim().toLocaleLowerCase('pt-BR'),n=0;for(const card of cards){let show=(active==='*'||card.dataset.group===active)&&card.dataset.name.includes(q);card.hidden=!show;if(show)n++}count.textContent=n}for(const button of document.querySelectorAll('button'))button.addEventListener('click',()=>{active=button.dataset.group;document.querySelector('button.active')?.classList.remove('active');button.classList.add('active');update()});search.addEventListener('input',update);update()</script></html>'''
 (OUT/'index.html').write_text(page,encoding='utf-8')
 from PIL import Image,ImageDraw
 for title,selected in [('menus','0'),('eventos','1'),('restantes','234567')]:
  subset=[p for p in images if group(p.name) in selected]
  columns=4
  width=360
  height=220
  sheet=Image.new('RGB',(columns*width,((len(subset)+columns-1)//columns)*height),(19,32,42))
  draw=ImageDraw.Draw(sheet)
  for index,path in enumerate(subset):
   with Image.open(path) as source:
    thumb=source.convert('RGB')
    thumb.thumbnail((width-8,height-30))
   x=(index%columns)*width+(width-thumb.width)//2
   y=(index//columns)*height
   sheet.paste(thumb,(x,y))
   draw.text(((index%columns)*width+4,y+height-23),path.stem,fill=(225,235,240))
  sheet.save(OUT/f'contact-{title}.jpg',quality=87)
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  data=json.dumps(bundle()).encode();self.send_response(200);self.end_headers();self.wfile.write(data)
 def do_POST(self):
  name=self.path.strip('/')
  if not name or '/'in name or '..'in name:self.send_error(400);return
  OUT.mkdir(parents=True,exist_ok=True);(OUT/(name+'.json')).write_bytes(self.rfile.read(int(self.headers['Content-Length'])));self.send_response(200);self.end_headers();self.wfile.write(b'OK')
 def log_message(self,*args):pass
if __name__=='__main__':
 import sys
 if '--gallery'in sys.argv:gallery()
 else:HTTPServer(('127.0.0.1',8771),H).serve_forever()
