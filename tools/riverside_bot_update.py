from pathlib import Path
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
ROOT=Path(__file__).resolve().parents[1]
FILES={
 'ServerScriptService.Crossgrounds.BotNavigation':'src/ServerScriptService/Crossgrounds/BotNavigation.luau',
 'ServerScriptService.Crossgrounds.CTFBotObjectives':'src/ServerScriptService/Crossgrounds/CTFBotObjectives.luau',
 'StarterPlayer.StarterPlayerScripts.WeaponPose':'src/StarterPlayer/StarterPlayerScripts/WeaponPose.local.luau',
}
def patch():
 p=ROOT/FILES['StarterPlayer.StarterPlayerScripts.WeaponPose']; s=p.read_text(encoding='utf-8-sig')
 s=s.replace('local active={} local pending={} local necks={} local gait=setmetatable({},{__mode="k"})\nworkspace.DescendantRemoving:Connect(function(v) necks[v]=nil end)','local active={} local pending={}')
 start=s.index(' local bots=workspace:FindFirstChild("CTFBots")'); end=s.index(' for tool,r in active do',start)
 s=s[:start]+' -- NPC locomotion belongs to the native Animator; keep weapon handling below.\n'+s[end:]; p.write_text(s,encoding='utf-8')
 p=ROOT/FILES['ServerScriptService.Crossgrounds.BotNavigation']; s=p.read_text(encoding='utf-8-sig').replace('Costs={Water=25}','Costs={Water=math.huge}')
 s=s.replace(' local ground=workspace:Raycast(to+Vector3.new(0,2,0),Vector3.new(0,-10,0),params)\n return not hit and ground~=nil',''' if hit then return false end
 -- Check the full shortcut, including holes and water between supported ends.
 for i=0,math.max(1,math.ceil(delta.Magnitude/3)) do
  local point=from:Lerp(to,i/math.max(1,math.ceil(delta.Magnitude/3)))
  local ground=workspace:Raycast(point+Vector3.new(0,1,0),Vector3.new(0,-7,0),params)
  if not ground or ground.Material==Enum.Material.Water or ground.Normal.Y<.65 then return false end
 end
 return true''')
 s=s.replace('if distance<3.5 then','if Navigation.ReachedWaypoint(root.Position,self.goal) then')
 s=s.replace('  if waypoint.Action==Enum.PathWaypointAction.Jump then h.Jump=true end\n','')
 p.write_text(s,encoding='utf-8')
 p=ROOT/FILES['ServerScriptService.Crossgrounds.CTFBotObjectives']; s=p.read_text(encoding='utf-8-sig')
 start=s.index(' if position.X<-36'); end=s.index('\n return target',start)
 s=s[:start]+''' -- Riverside bridges can move during authoring. Derive a crossing from the
 -- actual deck rather than coordinates from the original map.
 local bridges=arena and arena:FindFirstChild("Bridges")
 if bridges and position.X*target.X<0 and math.abs(position.X-target.X)>70 then
  local decks={} for _,part in bridges:GetDescendants() do
   if part:IsA("BasePart") and part.Name=="Deck" and part.CanCollide then table.insert(decks,part) end
  end
  table.sort(decks,function(a,b)return a.Position.Z<b.Position.Z end)
  local deck=decks[lane<0 and 1 or lane>0 and #decks or math.ceil(#decks/2)]
  if deck then
   local direction=target.X>position.X and 1 or -1
   local edge=deck.Size.X*.5+8
   local approach=Vector3.new(deck.Position.X-direction*edge,deck.Position.Y+deck.Size.Y*.5,deck.Position.Z)
   local exit=Vector3.new(deck.Position.X+direction*edge,approach.Y,deck.Position.Z)
   if (approach.X-position.X)*direction>5 then return approach end
   if (exit.X-position.X)*direction>5 then return exit end
  end
 end''' +s[end:]
 s=s.replace(' if label=="Guarding" then position+=Vector3.new(math.sin(now*.22+self.slot)*6,0,math.cos(now*.22+self.slot)*7) end',' -- Hold a stable defensive post instead of continuously orbiting the flag.')
 p.write_text(s,encoding='utf-8')
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  data=json.dumps({k:(ROOT/v).read_text(encoding='utf-8-sig') for k,v in FILES.items()}).encode(); self.send_response(200); self.end_headers(); self.wfile.write(data)
 def do_POST(self):
  out=ROOT/'artifacts/riverside-bots-2026-11-03'; out.mkdir(parents=True,exist_ok=True)
  data=self.rfile.read(int(self.headers['Content-Length'])); (out/(self.path.strip('/')+'.json')).write_bytes(data); self.send_response(200); self.end_headers(); self.wfile.write(b'OK')
if __name__=='__main__':
 import sys
 if '--patch' in sys.argv: patch()
 else: HTTPServer(('127.0.0.1',8769),Handler).serve_forever()
