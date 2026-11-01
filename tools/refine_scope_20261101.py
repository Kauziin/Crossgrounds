from pathlib import Path
import shutil
def edit(name,fn):
 p=Path('src',name+'.luau'); b=Path('artifacts/scope-refinement-2026-11-01/before',name+'.luau'); b.parent.mkdir(parents=True,exist_ok=True)
 if not b.exists(): shutil.copy2(p,b)
 p.write_text(fn(p.read_text(encoding='utf-8')),encoding='utf-8')
edit('ReplicatedStorage/ControlDefinitions',lambda s:s.replace('Controls.Actions={','Controls.Actions={\n ScopeZoomIn={Label="Ampliar mira",Keyboard="Equals",Gamepad="DPadUp"},\n ScopeZoomOut={Label="Reduzir mira",Keyboard="Minus",Gamepad="DPadDown"},').replace('Controls.Order={','Controls.Order={"ScopeZoomIn","ScopeZoomOut",'))
edit('ReplicatedStorage/ControlPolicy',lambda s:s.replace('SniperZoom=combat,','ScopeZoomIn=combat,ScopeZoomOut=combat,SniperZoom=combat,').replace('function Policy.Conflicts(a,b)','function Policy.Conflicts(a,b)\n local zoom={ScopeZoomIn=true,ScopeZoomOut=true}\n if zoom[a] or zoom[b] then return false end'))
edit('StarterPlayer/StarterPlayerScripts/ControlRouter',lambda s:s.replace('(listeners[a].overrides and 1000 or 0)','((listeners[a].overrides or listeners[a].overridePriority) and 1000 or 0)').replace('(listeners[b].overrides and 1000 or 0)','((listeners[b].overrides or listeners[b].overridePriority) and 1000 or 0)'))
def presentation(s):
 start=s.index('Router:Register("SniperZoom",'); end=s.index('zoomButton.Activated:Connect',start)
 s=s[:start]+'''for action,level in {ScopeZoomIn=2,ScopeZoomOut=1} do
 Router:Register(action,function(state)
  if not canZoom() then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then zoomLevel=level end
  return Enum.ContextActionResult.Sink
 end,{scope="combat",enabled=canZoom,overridePriority=true})
end
'''+s[end:]
 s=s.replace('zoomGui.DisplayOrder=15','zoomGui.DisplayOrder=-8')
 s=s.replace('zoomButton.BackgroundTransparency=.2','zoomButton.BackgroundTransparency=1')
 s=s.replace('zoomButton.TextSize=13','zoomButton.TextSize=12')
 s=s.replace('zoomButton.Size=UDim2.fromOffset(240,40)','zoomButton.Size=UDim2.fromOffset(110,30)')
 s=s.replace('zoomButton.AnchorPoint=Vector2.new(.5,0) zoomButton.Position=UDim2.new(.5,0,.65,0)','zoomButton.AnchorPoint=Vector2.new(1,.5) zoomButton.Position=UDim2.new(.12,0,.5,0)')
 s=s.replace('local zoomLevel=1','local zoomLevel=1\nlocal InputIcons=require(script.Parent.InputIcons)\nlocal zoomGlyphs={} ')
 marker='Instance.new("UICorner",zoomButton).CornerRadius=UDim.new(0,8)'
 s=s.replace(marker,marker+'''\nfor i,action in {"ScopeZoomIn","ScopeZoomOut"} do
 local glyph,refresh=InputIcons:Glyph(zoomButton,action,function() return Router:Key(action,InputMode:Get()==Enum.PreferredInput.Gamepad and "Gamepad" or "Keyboard") end,18)
 glyph.Position=UDim2.fromOffset(30+(i-1)*25,30) table.insert(zoomGlyphs,refresh)
end''')
 s=s.replace('zoomButton.Text=(zoomLevel==1 and "4× → ampliar para 8×" or "8× → voltar para 4×").."  ["..Router:Key("SniperZoom",device).."]"','zoomButton.Text=(zoomLevel==1 and "4×" or "8×")\n  local viewport=camera.ViewportSize\n  zoomButton.Position=UDim2.fromOffset(viewport.X*.5-math.min(viewport.X,viewport.Y)*.37-12,viewport.Y*.5)\n  for _,refresh in zoomGlyphs do refresh() end')
 s=s.replace('ads=adsWeight})','ads=adsWeight,sight=sightProfile})')
 s=s.replace(' if sightProfile and renderer then renderer:SetVisible(false) end','')
 return s
edit('StarterPlayer/StarterPlayerScripts/CombatPresentation',presentation)
def renderer(s):
 marker=' for _,entry in self.parts do\n  local transform='
 addition=''' if params.sight then
  local lens=self.Model:FindFirstChild("Lens")
  local entry
  for _,v in self.parts do if v.part==lens then entry=v break end end
  if entry then
   -- Geometry is already normalized to forward -Z. Use the actual ocular bounds.
   local min=Vector3.new(math.huge,math.huge,math.huge) local max=-min
   for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
    local p=entry.rest:PointToWorldSpace(lens.Size*Vector3.new(x,y,z)*.5)
    min=min:Min(p) max=max:Max(p)
   end end end
   local center=(min+max)*.5 local radius=math.min(max.X-min.X,max.Y-min.Y)*.5
   self.camera.FieldOfView=40
   local eyeDistance=radius/(math.tan(math.rad(20))*.72)
   cf=CFrame.new(-center.X,-center.Y,-max.Z-eyeDistance)
  end
 end
'''
 s=s.replace(marker,addition+marker)
 s=s.replace('  entry.part.CFrame=cf*transform*entry.rest','  entry.part.LocalTransparencyModifier=params.sight and entry.part.Name=="Lens" and 1 or 0\n  entry.part.CFrame=cf*transform*entry.rest')
 s=s.replace(' for _,arm in self.arms do\n',' for _,arm in self.arms do\n  arm.part.LocalTransparencyModifier=params.sight and 1 or 0\n')
 return s
edit('StarterPlayer/StarterPlayerScripts/FirstPersonRenderer',renderer)
