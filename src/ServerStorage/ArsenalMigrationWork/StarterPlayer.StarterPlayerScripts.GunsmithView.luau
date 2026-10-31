local View={}
local Root=game.ReplicatedStorage.Crossgrounds local Catalog=require(Root.WeaponCatalog) local Attachments=require(Root.AttachmentCatalog)
local Config=require(Root.WeaponVisualConfiguration) local Stats=require(Root.WeaponStats)
local Http=game:GetService("HttpService") local UIS=game:GetService("UserInputService")
local function copy(v) return Http:JSONDecode(Http:JSONEncode(v)) end
function View.new(parent,options)
 local player,nav=options.Player,options.Navigation local remote=Root.Remotes:WaitForChild("ArsenalCommand")
 local connections={} local alive=true local generation=0 local page="loadouts" local index=1 local slot="primary" local candidate="m4a1" local selectedSlot
 local draft=Config.Default(1) local attachments={} local yaw=.8 local pitch=.1 local zoom=1 local dragging local model
 local root=Instance.new("Frame") root.Name="Gunsmith" root.BackgroundTransparency=1 root.Size=UDim2.new(1,-8,0,660) root.Parent=parent
 local self={Root=root} local buttons={} local render
 local function hook(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
 local function label(name,p,size)
  local t=Instance.new("TextLabel") t.Name=name t.BackgroundTransparency=1 t.TextColor3=Color3.fromRGB(230,242,248) t.TextSize=size or 14 t.Font=Enum.Font.GothamMedium t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=p return t
 end
 local title=label("Title",root,20) title.Size=UDim2.new(1,0,0,32)
 local notice=label("Notice",root,12) notice.Position=UDim2.fromOffset(0,34) notice.Size=UDim2.new(1,0,0,42) notice.Text="Acessórios são somente visuais. Valores atuais são provisórios; seleções entram no próximo nascimento."
 local list=Instance.new("ScrollingFrame") list.Name="CascadeOptions" list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=4 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=root
 local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,6) layout.Parent=list
 local preview=Instance.new("ViewportFrame") preview.Name="WeaponPreview" preview.BackgroundColor3=Color3.fromRGB(15,23,31) preview.BackgroundTransparency=.15 preview.Ambient=Color3.fromRGB(175,185,200) preview.LightColor=Color3.fromRGB(255,245,228) preview.LightDirection=Vector3.new(-1,-2,-2) preview.Active=true preview.Parent=root
 local camera=Instance.new("Camera") camera.FieldOfView=35 camera.Parent=preview preview.CurrentCamera=camera
 local world=Instance.new("WorldModel") world.Parent=preview
 local details=label("Statistics",root,13)
 local rotate=Instance.new("TextButton") rotate.Name="RotatePreview" rotate.Text="Girar prévia · analógico direito / arrastar" rotate.TextSize=12 rotate.Font=Enum.Font.GothamMedium rotate.TextColor3=Color3.new(1,1,1) rotate.BackgroundColor3=Color3.fromRGB(33,51,65) rotate.Parent=root
 nav:Connect(rotate,function() nav:Focus(rotate) end)
 local function positionCamera()
  if not model then return end local cf,size=model:GetBoundingBox()
  local aspect=math.max(.25,preview.AbsoluteSize.X/math.max(1,preview.AbsoluteSize.Y))
  local distance=math.max(size.Y,size.X/aspect,size.Z)*1.9*zoom
  local direction=CFrame.fromEulerAnglesYXZ(pitch,yaw,0).LookVector
  camera.CFrame=CFrame.lookAt(cf.Position-direction*math.max(1,distance),cf.Position)
 end
 local function state() local ok,s=pcall(Http.JSONDecode,Http,player:GetAttribute("CTFArsenalState") or "") return ok and s or {} end
 local function request(command,payload,fn)
  task.spawn(function() local ok,success,message=pcall(remote.InvokeServer,remote,command,payload) if not alive then return end if not ok or not success then notice.Text=ok and tostring(message) or "Não foi possível completar a solicitação." elseif fn then fn(message) else notice.Text=tostring(message) end end)
 end
 local function showModel(id,configuration)
  generation+=1 local token=generation
  local w=Catalog.Get(id) local stats=Stats.Get(id).baseStats
  details.Text=(w and (w.name.." · "..w.category.."\n"..w.status) or "Variante · somente prévia").."\nDano: "..tostring(stats.damage or "desconhecido").." | Alcance: "..(stats.range and stats.range.." studs" or "desconhecido").."\nPrecisão: "..(stats.spreadDegrees and stats.spreadDegrees.."° de dispersão atual" or "desconhecida").."\nControle: não catalogado | Mobilidade: regra atual preservada\nCadência: "..(stats.rpm and math.floor(stats.rpm+.5).." RPM" or "desconhecida").."\nCapacidade: "..tostring(stats.capacity or "?").." | Recarga: "..(stats.reloadSeconds and stats.reloadSeconds.." s" or "?").."\nAcessórios: nenhum bônus funcional."
  request("preview",{weaponId=id,attachments=configuration or {}},function()
   if token~=generation then return end local cache=player.PlayerGui:WaitForChild("ArsenalPreviewCache",5) local asset=cache and cache:WaitForChild("Current",5)
   if not alive or token~=generation or not asset then return end world:ClearAllChildren() model=asset:Clone() model.Parent=world positionCamera()
  end)
 end
 local function action(text,fn)
  local b=Instance.new("TextButton") b.Name="Option"..(#buttons+1) b.Text=text b.TextWrapped=true b.Size=UDim2.new(1,-8,0,44) b.BackgroundColor3=Color3.fromRGB(25,42,55) b.TextColor3=Color3.fromRGB(230,244,250) b.TextSize=14 b.Font=Enum.Font.GothamMedium b.AutoButtonColor=true b.Parent=list nav:Connect(b,fn) table.insert(buttons,b) return b
 end
 local function clear() for _,b in buttons do b:Destroy() end buttons={} list.CanvasPosition=Vector2.zero end
 local function open(nextPage) page=nextPage render() if buttons[1] then nav:Focus(buttons[1]) end end
 function self:Back() if page=="loadouts" then return false end if page=="attachments" then open("weapon") elseif page=="weapon" or page=="weapons" then open("preset") else open("loadouts") end return true end
 function self:Cycle(step) index=(index-1+step)%5+1 draft=copy(state().presets and state().presets[index] or Config.Default(index)) open("preset") end
 render=function()
  clear() title.Text="CTF → Armamentos → Loadouts"..(page~="loadouts" and " → "..draft.name or "")
  if page~="loadouts" then action("‹ Voltar",function() self:Back() end) end
  if page=="loadouts" then
   for n=1,5 do local preset=state().presets and state().presets[n] or Config.Default(n) action(preset.name,function() index=n draft=copy(preset) showModel(draft.primaryWeaponId,draft.primaryAttachments) open("preset") end) end
  elseif page=="preset" then
   local name=Instance.new("TextBox") name.Name="PresetName" name.Size=UDim2.new(1,-8,0,40) name.BackgroundColor3=Color3.fromRGB(24,36,48) name.TextColor3=Color3.new(1,1,1) name.Text=draft.name name.ClearTextOnFocus=false name.Parent=list table.insert(buttons,name) hook(name.FocusLost,function() draft.name=name.Text end)
   for _,key in {"primary","secondary"} do local w=Catalog.Get(draft[key.."WeaponId"]) action((key=="primary" and "Primária: " or "Secundária: ")..w.name,function() slot=key open("weapons") end) end
   action("Aplicar no próximo nascimento",function() request("save",{index=index,loadout=draft}) end)
   action("Cancelar alterações",function() draft=copy(state().presets and state().presets[index] or Config.Default(index)) showModel(draft.primaryWeaponId,draft.primaryAttachments) open("preset") end)
   action("Restaurar padrão",function() draft=Config.Default(index) showModel(draft.primaryWeaponId,{}) open("preset") end)
  elseif page=="weapons" then
   for _,w in Catalog.List(slot) do action(w.name..(w.combatId and "" or " · somente prévia"),function() candidate=w.id attachments=copy(draft[slot.."WeaponId"]==w.id and draft[slot.."Attachments"] or {}) showModel(candidate,attachments) open("weapon") end) end
  elseif page=="weapon" then
   local w=Catalog.Get(candidate)
   if w.combatId then action("Escolher "..w.name,function() draft[slot.."WeaponId"]=candidate draft[slot.."Attachments"]=copy(attachments) open("preset") end) end
   for _,key in w.slots do action("Personalizar: "..key..(attachments[key] and " · equipado" or ""),function() selectedSlot=key open("attachments") end) end
   action("Restaurar visual padrão",function() attachments={} showModel(candidate,attachments) end)
   action("Salvar preset visual",function() request("visual",{name=draft.name.."/"..slot,weaponId=candidate,attachments=attachments}) end)
   for name,v in state().visualPresets or {} do if v.weaponId==candidate then action("Carregar visual: "..name,function() attachments=copy(v.attachments) showModel(candidate,attachments) end) end end
   for id,v in Catalog.Variants do if v.family==candidate then action("Variante: "..v.name.." · prévia",function() showModel(id,{}) end) end end
  elseif page=="attachments" then
   action("Sem acessório",function() attachments[selectedSlot]=nil showModel(candidate,attachments) open("weapon") end)
   local sorted={} for _,a in Attachments do if a.slot==selectedSlot then table.insert(sorted,a) end end table.sort(sorted,function(a,b)return a.name<b.name end)
   for _,a in sorted do local available=a.status=="Available" and table.find(a.compatible or {},candidate) local status=attachments[selectedSlot]==a.id and "Equipado" or available and "Disponível" or a.status=="PreviewOnly" and "Montagem não verificada" or "Incompatível"
    action(a.name.." · "..status,function() if available then attachments[selectedSlot]=a.id showModel(candidate,attachments) open("weapon") else notice.Text="Este acessório ainda não possui montagem verificada para esta arma." end end)
   end
  end
 end
 local function reflow()
  local small=parent.AbsoluteSize.X<620 local width=math.max(220,parent.AbsoluteSize.X-8)
  root.Size=UDim2.new(1,-8,0,small and 850 or 660)
  list.Position=UDim2.fromOffset(0,small and 520 or 82) list.Size=small and UDim2.new(1,0,0,320) or UDim2.new(.42,-8,0,560)
  preview.Position=small and UDim2.fromOffset(0,82) or UDim2.new(.43,0,0,82) preview.Size=small and UDim2.new(1,0,0,220) or UDim2.new(.57,0,0,310)
  rotate.Position=small and UDim2.fromOffset(0,308) or UDim2.new(.43,0,0,398) rotate.Size=small and UDim2.new(1,0,0,34) or UDim2.new(.57,0,0,34)
  details.Position=small and UDim2.fromOffset(0,350) or UDim2.new(.43,0,0,440) details.Size=small and UDim2.new(1,0,0,164) or UDim2.new(.57,0,0,205) positionCamera()
 end
 hook(parent:GetPropertyChangedSignal("AbsoluteSize"),reflow)
 hook(preview.InputBegan,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=input end end)
 hook(UIS.InputEnded,function(input) if dragging==input then dragging=nil end end)
 hook(UIS.InputChanged,function(input) if dragging and (input==dragging or input.UserInputType==Enum.UserInputType.MouseMovement) then yaw-=input.Delta.X*.008 pitch=math.clamp(pitch-input.Delta.Y*.008,-.9,.9) positionCamera() end end)
 hook(preview.InputChanged,function(input) if input.UserInputType==Enum.UserInputType.MouseWheel then zoom=math.clamp(zoom-input.Position.Z*.1,.6,2.5) positionCamera() end end)
 hook(game:GetService("RunService").RenderStepped,function(dt) if nav:GetFocus()==rotate and UIS.GamepadEnabled then for _,input in UIS:GetGamepadState(Enum.UserInputType.Gamepad1) do if input.KeyCode==Enum.KeyCode.Thumbstick2 and input.Position.Magnitude>.15 then yaw-=input.Position.X*dt*2 pitch=math.clamp(pitch+input.Position.Y*dt,-.9,.9) positionCamera() end end end end)
 function self:DefaultFocus() return buttons[1] end
 function self:Destroy() alive=false for _,c in connections do c:Disconnect() end root:Destroy() end
 render() reflow() showModel("m4a1",{}) return self
end
return View
