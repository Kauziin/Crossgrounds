from pathlib import Path
import shutil
R=Path(__file__).resolve().parents[2]
T=Path(__file__).resolve().parent
W=T/'work/src'
def save(p,s):
 f=W/p;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s,encoding='utf-8')
def edit(p,pairs):
 s=(R/'src'/p).read_text(encoding='utf-8-sig')
 for a,b in pairs:
  assert a in s,(p,a)
  s=s.replace(a,b,1)
 save(p,s)
edit('ReplicatedStorage/ExperienceSettings.luau',[
 ('local extra={','local extra={\n GraphicsQuality={Label="Qualidade gráfica",Default=2,Choices={1,2,3,4},Labels={[1]="DESEMPENHO",[2]="EQUILIBRADO",[3]="ALTO",[4]="VISUAL"},Category="Graphics"},'),
 ('Settings.Categories=categories','categories.Graphics={"GraphicsQuality"}\nSettings.Categories=categories'),
 ('{"Audio","ÁUDIO"},{"Accessibility"','{"Audio","ÁUDIO"},{"Graphics","GRÁFICOS"},{"Accessibility"')])
edit('StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau',[
 ('{"Interface","Interface"},{"Accessibility"','{"Interface","Interface"},{"Graphics","Gráficos"},{"Accessibility"'),
 ('local keys={Gameplay=','local keys={Graphics=Settings.Categories.Graphics,Gameplay='),
 ('local titles={AdminMaps=','local titles={Graphics="GRÁFICOS",AdminMaps='),
 ('  if id=="Aim" then info(', '  if id=="Graphics" then info("Equilibrado é o padrão. Alto e Visual acrescentam efeitos; Desempenho reduz sombras e pós-processamento. A qualidade global do Roblox continua sob seu controle. Profundidade de campo fica restrita à câmera de fotografia no perfil Visual.") end\n  if id=="Aim" then info(')])
edit('StarterPlayer/StarterPlayerScripts/CombatPresentation.luau',[
 ('local Analog=require(', 'local Intent=require(game.ReplicatedStorage.Crossgrounds.AimAssistIntent)\nlocal windowFocused=true\nlocal Analog=require('),
 ('  touchDelta+=delta','  touchDelta+=delta touchSampleAt=os.clock()'),
 ('UIS.WindowFocusReleased:Connect(function() clearLook() aiming=false firing=false end)', 'UIS.WindowFocusReleased:Connect(function() windowFocused=false clearLook() aiming=false firing=false end)\nUIS.WindowFocused:Connect(function() windowFocused=true clearLook() end)'),
 ('  release() currentTool=nil','  if owned then clearLook() end\n  release() currentTool=nil'),
 ('  currentTool=tool equippedAt=', '  clearLook()\n  currentTool=tool equippedAt='),
 (' if blocked then\n  clearLook()', ' if blocked or not windowFocused then\n  clearLook()'),
 (' local pixels=touchDelta touchDelta=Vector2.zero',' local pixels=os.clock()-touchSampleAt<=Intent.TouchTimeout and touchDelta or Vector2.zero touchDelta=Vector2.zero'),
 (' local lookIntent=input==Enum.PreferredInput.Gamepad and Vector2.new(-movement.X,movement.Y) or touchIntent',' local lookIntent=Intent.Resolve({device=input==Enum.PreferredInput.Gamepad and "gamepad" or input==Enum.PreferredInput.Touch and "touch" or "mouse",focused=windowFocused,blocked=blocked,look=input==Enum.PreferredInput.Gamepad and Vector2.new(-movement.X,movement.Y) or touchIntent,touchOwned=touchLook~=nil,touchAt=touchSampleAt,now=os.clock()})')])
p='ReplicatedStorage/Crossgrounds/AimAssist.luau'
s=(R/'src'/p).read_text(encoding='utf-8-sig')
start=s.index(' local input=context.look or Vector2.zero',s.index('function Assist.Step'))
end=s.index(' local origin=context.origin',start)
block=s[start:end]
helper='function Assist.Friction(state,window,context)\n local dt=context.dt local strength=math.clamp(context.strength or 0,0,1)\n'+block+' return state.friction,trackingRange,escape\nend\n'
s=s[:start]+''' local input=context.look or Vector2.zero
 local magnitude=math.min(1,input.Magnitude)
 local friction,trackingRange,escape=Assist.Friction(state,window,context)
 -- Releasing intent cannot retain tracking velocity or acquisition time.
 if magnitude<=.025 then
  state.target=nil state.anchor=nil state.velocity=Vector2.zero state.age=0
  return friction,Vector2.zero
 end
'''+s[end:]
s=s.replace('function Assist.Step(state,window,context)',helper+'function Assist.Step(state,window,context)',1)
save(p,s)
print('Prepared four existing sources in isolated work/src')
