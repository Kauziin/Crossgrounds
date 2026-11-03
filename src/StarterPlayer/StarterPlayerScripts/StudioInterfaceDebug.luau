-- Studio-only UI laboratory. Attributes are local and restored on Reset.
local Debug={}if not game:GetService("RunService"):IsStudio()then return Debug end
local Run=game:GetService("RunService")local p=game.Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local scenarios=require(game.ReplicatedStorage.Crossgrounds.StudioInterfaceScenarios)
local saved={}local clone local hidden={}local captureConnection local fixture local overrides={}
local function set(key,value)if saved[key]==nil then saved[key]={p:GetAttribute(key)}end p:SetAttribute(key,value)end
function Debug.Open(id)
 if id=="Progress"then set("ProgressionMenuOpen",true)else Nav:OpenMenu(id)end
end
function Debug.Clear()
 if captureConnection then captureConnection:Disconnect()captureConnection=nil end
 if clone then clone:Destroy()clone=nil end
 for gui,value in hidden do if gui.Parent then gui.Enabled=value end end hidden={}
end
function Debug.Reset()
 for _,entry in overrides do entry.object[entry.key]=entry.value end overrides={}
 if fixture then fixture:Destroy()fixture=nil end
 local board=p.PlayerGui:FindFirstChild("StudioUIStandings")if board then board:Fire(false)end
 Debug.Clear()for key,box in saved do p:SetAttribute(key,box[1])end saved={}
 p:SetAttribute("StudioInterfaceScenario",nil)Nav:OpenMenu("Resume")
end
function Debug.Run(id)
 Debug.Reset()local chosen for _,s in scenarios do if s.id==id then chosen=s break end end assert(chosen,"Cenário desconhecido")
 set("CrossgroundsMode",chosen.mode)set("LobbyMenuDismissed",true)
 for _,key in {"InMatch","InArena","ArenaPlaying","ExperienceMenuOpen","ProgressionMenuOpen","CareerMenuOpen","SocialMenuOpen","ClanMenuOpen","LobbyMusicMenuOpen","ClientLoading","CrossgroundsTransition"}do set(key,false)end
 for key,value in chosen.attributes do set(key,key=="ArenaRespawnAt"and workspace:GetServerTimeNow()+7 or value)end
 if id=="loading"then set("SceneLoading",true)end
 p:SetAttribute("StudioInterfaceScenario",id)
 task.wait(.15)local ok,err=game.ReplicatedStorage.Crossgrounds:WaitForChild("StudioInterfaceDebug"):InvokeServer(id)
 if id=="clan-fixture"or id=="party-fixture"then
  local bridge=require(script.Parent[id=="clan-fixture"and"ClanBridge"or"PartyBridge"])
  for _,key in {"Get","Send"}do table.insert(overrides,{object=bridge,key=key,value=bridge[key]})end
  local stats={XP=12500,Wins=12,Kills=140,BotKills=25,Captures=8,Deaths=70}
  local clan={id="studio_fixture",tag="TEST",name="Clã de teste",role="leader",level=3,xp=12500,capacity=20,emblem="star",current=stats,earned=stats,members={{userId=p.UserId,name=p.DisplayName,role="leader",epoch=1,contributionXP=8500},{userId=0,name="Integrante de teste",role="member",epoch=1,contributionXP=4000}}}
  local data=id=="clan-fixture"and{clan=clan,invites={{clanId="test_invite",tag="DEMO",name="Clã convidante"}},sessionOnly=true}or{group={id="studio_fixture",leader=p.UserId,members={{userId=p.UserId,name=p.DisplayName,mode="hub"},{userId=0,name="Amigo de teste",mode="hub"}}}}
  bridge.Get=function()return data end
  bridge.Send=function(_,action)
   if action=="get"then return true,data elseif action=="view"then return true,clan elseif action=="leaderboard"then return true,{label="Ranking · simulação",message="Dados sintéticos",sessionOnly=true,rows={{id=clan.id,rank=1,tag=clan.tag,name=clan.name,score=12500,level=3,members=2}}}end
   bridge.Status="Simulação: operação não enviada."return false,bridge.Status
  end
  Nav:OpenMenu(id=="clan-fixture"and"Clan"or"Social")
 elseif id=="hub"then Nav:OpenMenu("Hub")
 elseif id=="weapon-hud"then
  fixture=Instance.new("Tool")fixture.Name="M4A1 · simulação UI"fixture.RequiresHandle=false fixture:SetAttribute("WeaponId","m4a1")fixture:SetAttribute("WeaponKind","Gun")fixture:SetAttribute("Ammo",23)fixture:SetAttribute("ReserveAmmo",300)fixture.Parent=p.Character
 elseif id=="optical-scope"or id=="optical-reflex"then
  fixture=Instance.new("Folder")fixture.Name="StudioOpticalFixture"fixture.Parent=p.PlayerGui
  local sight=require(script.Parent.OpticalSight).new(p)local viewport=workspace.CurrentCamera.ViewportSize
  sight:Update({reticle=id=="optical-reflex"and"RedDot"or"MilDot"},viewport,viewport*.5,1,nil,true)
  sight.gui.Name="StudioOpticalScope"sight.reticle.Name="StudioOpticalReticle"sight.gui.Parent=fixture sight.reticle.Parent=fixture
 elseif id=="damage"then p.PlayerGui:WaitForChild("StudioUIDamage"):Fire(90,300)
 elseif id:find("standings",1,true)then task.wait(.1)p.PlayerGui:WaitForChild("StudioUIStandings"):Fire(true)
 elseif id=="dialog"then local dialog=require(script.Parent.MenuDialog).new({Navigation=Nav,Title="Confirmação · simulação",Message="Exemplo do diálogo real, sem executar uma alteração.",Actions={{Name="Confirm",Text="Confirmar",Callback=function()end},{Name="Cancel",Text="Cancelar"}}})fixture=dialog.Root:FindFirstAncestorOfClass("ScreenGui")
 elseif id=="interaction"then
  local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")if root then
   fixture=Instance.new("Part")fixture.Name="StudioUIInteractionFixture"fixture.Anchored=true fixture.CanCollide=false fixture.Transparency=1 fixture.CFrame=root.CFrame*CFrame.new(0,0,-3)fixture.Parent=workspace
   local prompt=Instance.new("ProximityPrompt")prompt.ActionText="Interagir"prompt.ObjectText="Objeto de teste"prompt.MaxActivationDistance=10 prompt.HoldDuration=2 prompt.RequiresLineOfSight=false prompt.Parent=fixture
  end
 end
 return ok,err
end
function Debug.Inventory()
 local out={}for i,b in Cascade.CaptureInstances or {}do local panes={}for id,pane in b.Panes do table.insert(panes,{id=id,items=#pane.List:GetChildren()})end table.sort(panes,function(a,b)return a.id<b.id end)table.insert(out,{index=i,gui=b.Backdrop.Parent.Name,panes=panes})end return out
end
function Debug.Tree(name)
 local out={}local root=p.PlayerGui:FindFirstChild(name)or p.PlayerGui
 for _,n in root:GetDescendants()do if n:IsA("GuiButton")then local path=n:GetFullName():split(".PlayerGui.")[2]table.insert(out,{path=path,text=n:IsA("TextButton")and n.Text or "",visible=n.Visible})end end return out
end
function Debug.Activate(path,action)
 local n=p.PlayerGui for _,seg in path:split(".")do n=n:FindFirstChild(seg)assert(n,"Objeto ausente: "..seg)end
 return Nav:DebugActivate(n,action)
end
function Debug.Pane(index,stack)
 local b=Cascade.CaptureInstances[index]assert(b,"Cascade ausente")b.Backdrop.Parent.Enabled=true b:SetOpen(true)b:Push(stack)
end
function Debug.Snapshot(name)
 Debug.Clear()local names=type(name)=="table"and name or {name}local gui=p.PlayerGui:FindFirstChild(names[1],true)assert(gui,"Tela ausente: "..names[1])
 clone=gui:Clone()clone.Name="InterfaceLibrarySnapshot"clone.Enabled=true clone.DisplayOrder=500 clone.Parent=p.PlayerGui
 for i=2,#names do local other=p.PlayerGui:FindFirstChild(names[i],true)if other then for _,child in other:GetChildren()do child:Clone().Parent=clone end end end
 local badge=Instance.new("TextLabel")badge.Name="CaptureProvenance"badge.AnchorPoint=Vector2.new(1,1)badge.Position=UDim2.new(1,-8,1,-5)badge.Size=UDim2.fromOffset(460,20)badge.BackgroundColor3=Color3.fromRGB(0,0,0)badge.BackgroundTransparency=.3 badge.TextColor3=Color3.new(1,1,1)badge.TextSize=10 badge.Text="STUDIO · "..(p:GetAttribute("StudioInterfaceScenario")or"navegação").." · dados de teste quando indicados"badge.ZIndex=100 badge.Parent=clone
 captureConnection=Run.PreRender:Connect(function()for _,g in p.PlayerGui:GetChildren()do if g:IsA("ScreenGui")and g~=clone then if hidden[g]==nil then hidden[g]=g.Enabled end g.Enabled=false end end end)
 return true
end
function Debug.Init()
 local bridge=Instance.new("BindableFunction")bridge.Name="StudioInterfaceDebug"bridge.Parent=p.PlayerGui
 bridge.OnInvoke=function(action,a,b)
  if action=="run"then return Debug.Run(a)elseif action=="reset"then Debug.Reset()elseif action=="clear"then Debug.Clear()elseif action=="open"then Debug.Open(a)elseif action=="inventory"then return Debug.Inventory()elseif action=="tree"then return Debug.Tree(a)elseif action=="pane"then Debug.Pane(a,b)elseif action=="activate"then return Debug.Activate(a,b)elseif action=="snapshot"then return Debug.Snapshot(a)end return true
 end
 local gui=Instance.new("ScreenGui")gui.Name="StudioInterfaceLaboratory"gui.ResetOnSpawn=false gui.DisplayOrder=300 gui.Enabled=false gui.Parent=p.PlayerGui
 local list=Instance.new("ScrollingFrame")list.Size=UDim2.new(0,350,1,-60)list.Position=UDim2.fromOffset(20,30)list.BackgroundColor3=Color3.fromRGB(12,20,30)list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new()list.Parent=gui
 local layout=Instance.new("UIListLayout",list)layout.Padding=UDim.new(0,4)
 local function button(title,fn)local b=Instance.new("TextButton")b.Size=UDim2.new(1,-10,0,32)b.Text=title b.TextColor3=Color3.new(1,1,1)b.BackgroundColor3=Color3.fromRGB(25,50,65)b.Parent=list b.Activated:Connect(fn)end
 button("LABORATÓRIO DE UI · F8 fechar",function()gui.Enabled=false end)
 button("Restaurar contexto",Debug.Reset)
 for _,id in {"Hub","Main","Settings","Loadout","Progress","Career","Social","Clan","Playlist","MobileHUD"}do button("Tela · "..id,function()gui.Enabled=false Debug.Open(id)end)end
 for _,s in scenarios do button(s.id,function()gui.Enabled=false local ok,err=Debug.Run(s.id)if not ok then warn("UI Debug: "..tostring(err))end end)end
 game:GetService("UserInputService").InputBegan:Connect(function(input,processed)if not processed and input.KeyCode==Enum.KeyCode.F8 then Debug.Clear()gui.Enabled=not gui.Enabled end end)
end
return Debug
