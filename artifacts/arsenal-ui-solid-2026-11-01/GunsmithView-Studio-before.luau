local View={}
local slotNames={optic="Mira",muzzle="Boca",barrel="Cano",underbarrel="Acoplamento",magazine="Carregador",stock="Coronha",laser="Laser",fireControl="Disparo"}
local Root=game.ReplicatedStorage.Crossgrounds local Catalog=require(Root.WeaponCatalog) local Attachments=require(Root.AttachmentCatalog)
local Config=require(Root.WeaponVisualConfiguration) local Stats=require(Root.WeaponStats)
local Http=game:GetService("HttpService") local UIS=game:GetService("UserInputService")
local PreviewStyle=require(script.Parent.ArsenalPreviewStyle)
local function copy(v) return Http:JSONDecode(Http:JSONEncode(v)) end
function View.new(parent,options)
 local player,nav=options.Player,options.Navigation local remote=Root.Remotes:WaitForChild("ArsenalCommand")
 local connections={} local alive=true local generation=0 local page="loadouts" local index=1 local slot="primary" local candidate="m4a1" local selectedSlot
 local draft=Config.Default(1) local attachments={} local yaw=-1.4 local pitch=.1 local zoom=1 local dragging local model
 local root=Instance.new("Frame") root.Name="Gunsmith" root.BackgroundTransparency=1 root.Size=UDim2.new(1,-8,0,660) root.Parent=parent
 local self={Root=root} local buttons={} local render,reflow local overview local inspect local selectionView local accessoryPreview=false
 local modelCache={} local cacheOrder={} local cacheFolder=Instance.new('Folder') local displayedKey
 local function hook(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
 local function label(name,p,size)
  local t=Instance.new("TextLabel") t.Name=name t.BackgroundTransparency=1 t.TextColor3=Color3.fromRGB(230,242,248) t.TextSize=size or 14 t.Font=Enum.Font.GothamMedium t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=p return t
 end
 local title=label("Title",root,20) title.Size=UDim2.new(1,0,0,32)
 local notice=label("Notice",root,12) notice.Position=UDim2.fromOffset(0,34) notice.Size=UDim2.new(1,0,0,42) notice.Text="Commando: −40% dispersão, −15% recuo lateral. Silenciador: som abafado. Valores atuais são provisórios; seleções entram no próximo nascimento."
local function updateNotice()
 notice.Text=player:GetAttribute("CTFPracticeRange")==true and "No Practice Range, presets e kits são equipados imediatamente." or "Commando: −40% dispersão, −15% recuo lateral. Silenciador: som abafado. Valores atuais são provisórios; seleções entram no próximo nascimento."
end
updateNotice()
table.insert(connections,player:GetAttributeChangedSignal("CTFPracticeRange"):Connect(updateNotice))
 local list=Instance.new("ScrollingFrame") list.Name="CascadeOptions" list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=4 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=root
 local layout=Instance.new("UIListLayout") layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Padding=UDim.new(0,6) layout.Parent=list
 local preview=Instance.new("ViewportFrame") preview.Name="WeaponPreview" preview.BackgroundColor3=Color3.fromRGB(15,23,31) preview.BackgroundTransparency=.15 preview.Ambient=Color3.fromRGB(175,185,200) preview.LightColor=Color3.fromRGB(255,245,228) preview.LightDirection=Vector3.new(-1,-2,-2) preview.Active=true preview.Parent=root
 local camera=Instance.new("Camera") camera.FieldOfView=35 camera.Parent=preview preview.CurrentCamera=camera
 PreviewStyle.Attach(preview)
 local world=Instance.new("WorldModel") world.Parent=preview
 local details=label("Statistics",root,13)
 local rotate=Instance.new("TextButton") rotate.Name="RotatePreview" rotate.Text="Girar prévia · analógico direito / arrastar" rotate.TextSize=12 rotate.Font=Enum.Font.GothamMedium rotate.TextColor3=Color3.new(1,1,1) rotate.BackgroundColor3=Color3.fromRGB(33,51,65) rotate.Parent=root
 nav:Connect(rotate,function() nav:Focus(rotate) end)
 rotate:SetAttribute("ConsumesRightStick",true)
 local function positionCamera()
  if not model then return end local cf,size=model:GetBoundingBox()
  local aspect=math.max(.25,preview.AbsoluteSize.X/math.max(1,preview.AbsoluteSize.Y))
  local direction=-CFrame.fromEulerAnglesYXZ(pitch,yaw,0).LookVector
  local basis=CFrame.lookAt(Vector3.zero,-direction) local tangent=math.tan(math.rad(camera.FieldOfView*.5)) local distance=0
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
   local p=basis:VectorToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)-cf.Position)
   distance=math.max(distance,math.abs(p.X)/(tangent*aspect)+p.Z,math.abs(p.Y)/tangent+p.Z)
  end end end
  camera.CFrame=CFrame.lookAt(cf.Position+direction*math.max(.5,distance*1.12*zoom),cf.Position)
  PreviewStyle.Aim(preview,camera)
 end
 local function state() local ok,s=pcall(Http.JSONDecode,Http,player:GetAttribute("CTFArsenalState") or "") return ok and s or {} end
 local requestQueue={} local processing=false local lastRequest=0
 local function request(command,payload,fn,valid)
  table.insert(requestQueue,{command,payload,fn,valid})
  if processing then return end processing=true
  task.spawn(function()
   while alive and #requestQueue>0 do
    local item=table.remove(requestQueue,1)
    if not item[4] or item[4]() then
     task.wait(math.max(0,.16-(os.clock()-lastRequest)))
     if not alive then break end
     if not item[4] or item[4]() then
      lastRequest=os.clock() local ok,success,message=pcall(remote.InvokeServer,remote,item[1],item[2])
      if not alive then break end
      if not ok or not success then notice.Text=ok and tostring(message) or "Não foi possível completar a solicitação." elseif item[3] then item[3](message) else notice.Text=tostring(message) end
     end
    end
   end
   processing=false
  end)
 end
 local function showModel(id,configuration)
  generation+=1 local token=generation
  if page=='attachments' and not accessoryPreview then return end
  local w = Catalog.Get(id)
  local stats = Stats.Get(id, configuration).effectiveGameplayStats
  details.Text=(w and (w.name.." · "..w.category.."\n"..w.status) or "Variante · somente prévia").."\nDano: "..tostring(stats.damage or "desconhecido").." | Alcance: "..(stats.range and stats.range.." studs" or "desconhecido").."\nPrecisão: "..(stats.spreadDegrees and stats.spreadDegrees.."° de dispersão atual" or "desconhecida").."\nControle: não catalogado | Mobilidade: regra atual preservada\nCadência: "..(stats.rpm and math.floor(stats.rpm+.5).." RPM" or "desconhecida").."\nCapacidade: "..tostring(stats.capacity or "?").." | Recarga: "..(stats.reloadSeconds and stats.reloadSeconds.." s" or "?").."\nEstatísticas efetivas com os acessórios equipados."
  local compare=Stats.Compare(draft[slot.."WeaponId"],id)
  local combat=w and w.combatId and require(game.ReplicatedStorage.KitDefinitions).Weapons[w.combatId]
  local burst=combat and require(Root.BurstFire).Config(combat,configuration and configuration.fireControl=="aug_burst_conversion")
  if burst then details.Text..="\nDisparo: rajada de "..burst.count.." tiros por acionamento." end
  if compare.damage and draft[slot.."WeaponId"]~=id then details.Text..="\nComparação base · dano atual "..compare.damage.current.." → "..compare.damage.candidate.." (acessórios não entram no cálculo)." end
  local parts={id} for key,value in configuration or {} do table.insert(parts,key..'='..value) end table.sort(parts) local cacheKey=table.concat(parts,'|')
  if displayedKey==cacheKey and model and model.Parent==world then return end
  local function display(asset)
   if model then model.Parent=cacheFolder end
   model=asset model.Parent=world displayedKey=cacheKey positionCamera()
  end
  if modelCache[cacheKey] then display(modelCache[cacheKey]) return end
  task.delay(.12,function()
  if not alive or token~=generation then return end
  request("preview",{weaponId=id,attachments=configuration or {}},function(assetName)
   if token~=generation then return end local cache=player.PlayerGui:WaitForChild("ArsenalPreviewCache",5) local asset=cache and cache:WaitForChild(assetName,5)
   if not alive or token~=generation or not asset then return end
   local clone=asset:Clone() modelCache[cacheKey]=clone table.insert(cacheOrder,cacheKey) display(clone)
   while #cacheOrder>4 do local old=table.remove(cacheOrder,1) local value=modelCache[old] modelCache[old]=nil if value then value:Destroy() end end
  end,function() return alive and token==generation end)
  end)
 end
 local function action(text,fn)
  local b=Instance.new("TextButton") b.Name="Option"..(#buttons+1) b:SetAttribute("CascadeDecoration",page=="loadouts") b.LayoutOrder=#buttons+1 b.Text=text b.TextWrapped=true b.Size=UDim2.new(1,-8,0,44) b.BackgroundColor3=Color3.fromRGB(25,42,55) b.TextColor3=Color3.fromRGB(230,244,250) b.TextSize=14 b.Font=Enum.Font.GothamMedium b.AutoButtonColor=true b.Parent=list nav:Connect(b,fn) table.insert(buttons,b) return b
 end
 local function clear() if selectionView then selectionView:Destroy() selectionView=nil end for _,b in buttons do b:Destroy() end buttons={} list.CanvasPosition=Vector2.zero end
 local function open(nextPage) if nextPage=='attachments' and page~='attachments' then accessoryPreview=false end page=nextPage render() if reflow then reflow() end local target=selectionView and selectionView:DefaultFocus() or buttons[1] if target then nav:Focus(target) end end
 local function applyDraft(successText)
  request("save",{index=index,loadout=copy(draft)},function(message)
   notice.Text=successText or message or "Loadout atualizado."
    open("loadouts")
  end)
 end
 overview=require(script.Parent.CTFClassOverview).new(root,{
  Navigation=nav,Catalog=Catalog,Stats=Stats,Attachments=Attachments,PracticeRange=function() return player:GetAttribute("CTFPracticeRange")==true end,
  Inspect=function(n) inspect(n) end,
		Select = function(key)
			slot = key
			candidate = draft[key.."WeaponId"]
			open("weapons")
		end,

		Edit = function(key)
			slot = key
			candidate = draft[key.."WeaponId"]
			attachments = copy(draft[key.."Attachments"] or {})
			selectedSlot = nil
			open("attachments")
		end,
  Preview=function(id,configuration,callback,valid)
   local library=Root:FindFirstChild("LoadoutPreviews") local existing=library and library:FindFirstChild(id)
   if existing then callback(existing) return end
   request("preview",{weaponId=id,attachments=configuration or {}},function(assetName)
    if not valid() then return end local cache=player.PlayerGui:FindFirstChild("ArsenalPreviewCache") local asset=cache and cache:WaitForChild(assetName,3)
    if asset and valid() then callback(asset) end
   end,valid)
  end,
 })
 inspect=function(n)
  index=n draft=copy(state().presets and state().presets[n] or Config.Default(n))
  showModel(draft.primaryWeaponId,draft.primaryAttachments) overview:Inspect(n,draft) overview:RefreshState(state())
 end
	function self:Back()
		if page == "loadouts" then
			return false
		end

		open("loadouts")
		return true
	end

	function self:Cycle(step)
		index = (index - 1 + step) % 5 + 1
		draft = copy(
			state().presets and state().presets[index]
				or Config.Default(index)
		)
		if page ~= "loadouts" then
			open("loadouts")
		else
			inspect(index)
		end
	end
 render=function()
  clear() overview.Root.Visible=page=="loadouts" title.Text=page=="loadouts" and "CRIAR CLASSE" or "ARMAMENTOS / "..draft.name
  title.Font=Enum.Font.GothamBold title.TextSize=page=="loadouts" and 27 or 20
  notice.Position=UDim2.fromOffset(0,34) notice.Size=UDim2.new(1,0,0,page=="loadouts" and 24 or 42)
  list.Visible=true
  if page=='weapons' or page=='attachments' then
   local accessories=page~='weapons' list.Visible=false
   local w=Catalog.Get(candidate) selectedSlot=selectedSlot or w.slots[1] or 'optic'
   local categories={} local seen={}
   if accessories then for _,key in w.slots do table.insert(categories,key) seen[key]=true end for _,key in {'optic','muzzle','underbarrel','magazine','stock','laser'} do if not seen[key] then table.insert(categories,key) end end
   else for _,entry in Catalog.List(slot) do if not seen[entry.category] then seen[entry.category]=true table.insert(categories,entry.category) end end table.sort(categories) end
   local category=accessories and selectedSlot or (Catalog.Get(draft[slot..'WeaponId']).category)
   local tools={}
   if accessories then
    table.insert(tools,{'Restaurar acessórios','Configuração padrão',function() attachments={} draft[slot.."Attachments"]={} showModel(candidate,attachments) applyDraft("Acessórios removidos.") end})
    table.insert(tools,{'Salvar visual','Preset visual existente',function() request('visual',{name=draft.name..'/'..slot,weaponId=candidate,attachments=attachments}) end})
    for name,visual in state().visualPresets or {} do if visual.weaponId==candidate then table.insert(tools,{'Carregar '..name,'Preset visual salvo',function() attachments=copy(visual.attachments) draft[slot.."Attachments"]=copy(attachments) showModel(candidate,attachments) applyDraft("Visual carregado.") end}) end end
   end
   title.Text=accessories and 'ACESSÓRIOS' or 'ESCOLHA DE ARMAS'
   selectionView=require(script.Parent.ArsenalSelectionView).new(root,{
    Player=player,Navigation=nav,Accessories=accessories,Categories=categories,Category=category,WeaponName=w.name,Tools=tools,PreviewEnabled=accessoryPreview,
    LayoutChanged=function() if reflow then reflow() end end,
    PreviewChanged=function(on) accessoryPreview=on if on then showModel(candidate,attachments) else generation+=1 end if reflow then reflow() end end,
    Entries=function(key)
     local entries={}
    if not accessories then for _,entry in Catalog.List(slot) do if entry.category==key then table.insert(entries,{id=entry.id,name=entry.name,status=entry.combatId and 'Clique para equipar' or 'Somente prévia',description=entry.category..'\n'..(entry.combatId and (player:GetAttribute("CTFPracticeRange")==true and 'Clique para equipar imediatamente no Practice Range.' or 'Clique para equipar no próximo nascimento.') or 'Modelo de catálogo; indisponível para equipar.')}) end end
     else
      selectedSlot=key table.insert(entries,{id='none',name='Sem acessório',status=not attachments[key] and 'Equipado na edição' or 'Disponível',description='Usar a configuração padrão deste slot.'})
        for _,a in Attachments do if a.slot==key then local compatible=a.status=='Available' and table.find(a.compatible or {},candidate) table.insert(entries,{id=a.id,name=a.name,status=attachments[key]==a.id and 'Equipado na edição' or compatible and 'Disponível' or 'Incompatível / somente prévia',description=compatible and (key=='fireControl' and 'Conversão funcional do modo de disparo.' or a.visualOnly==false and (a.description or 'Acessório com bônus funcionais.') or 'Acessório visual compatível. Não adiciona bônus aos atributos da arma.') or 'Montagem não verificada para esta arma.',available=compatible}) end end
     end
     table.sort(entries,function(a,b) if a.id=='none' then return b.id~='none' elseif b.id=='none' then return false end return a.name<b.name end) return entries
    end,
    Inspect=function(entry) if not accessories then showModel(entry.id,{}) end end,
    Select=function(entry)
      if not accessories then
       local chosen=Catalog.Get(entry.id)
       if not chosen.combatId then notice.Text='Esta arma está disponível apenas para prévia.' return end
       draft[slot..'WeaponId']=entry.id draft[slot..'Attachments']={} candidate=entry.id attachments={}
       showModel(entry.id,{}) applyDraft(chosen.name..' equipado.')
      elseif entry.id=='none' or entry.available then
       attachments[selectedSlot]=entry.id~='none' and entry.id or nil
       draft[slot..'Attachments']=copy(attachments)
       showModel(candidate,attachments) applyDraft(entry.id=='none' and 'Acessório removido.' or entry.name..' equipado.')
      else notice.Text='Montagem incompatível ou não verificada.' end
    end,
    Custom=function(entry) if not accessories then local chosen=Catalog.Get(entry.id) if not chosen or not chosen.combatId then notice.Text='Esta arma está disponível apenas para prévia.' return end draft[slot..'WeaponId']=entry.id draft[slot..'Attachments']={} candidate=entry.id attachments={} showModel(entry.id,{}) applyDraft(chosen.name..' equipado.') end end,
    ChangeWeapon=accessories and function() open('weapons') end or nil,
    Apply=nil,
   })
   if accessories then showModel(candidate,attachments) end
   return
  end
  if page~="loadouts" then action("‹ Voltar",function() self:Back() end) end
  if page=="loadouts" then
   for n=1,5 do
    local preset=state().presets and state().presets[n] or Config.Default(n)
    local b=action(preset.name,function() request("save",{index=n,loadout=copy(state().presets and state().presets[n] or preset)}) end)
    overview:StyleRow(b,n,preset)
				nav:SetActions(b, {
					custom = function()
						index = n
						draft = copy(
							state().presets and state().presets[n] or preset
						)

						local field = Instance.new("TextBox")
						field.Name = "RenameInline"
						field.Position = UDim2.fromOffset(6, 20)
						field.Size = UDim2.new(1, -12, 0, 36)
						field.BackgroundColor3 = Color3.fromRGB(20, 42, 52)
						field.TextColor3 = Color3.new(1, 1, 1)
						field.Font = Enum.Font.GothamMedium
						field.TextSize = 15
						field.Text = draft.name
						field.ClearTextOnFocus = false
						field.Parent = b

						field:CaptureFocus()

						field.FocusLost:Once(function()
							local name = field.Text:match("^%s*(.-)%s*$")
							field:Destroy()

							if name ~= "" and name ~= draft.name then
								draft.name = name
								applyDraft("Loadout renomeado.")
							end
						end)
					end,
				})
   end
   action("Corpo a corpo · catálogo de prévias",function() open("melee") end)
   action("Acessórios e itens auxiliares · prévias",function() open("auxiliary") end)
   action("Variantes e conjuntos de peças · prévias",function() open("variants") end)
   inspect(index)
  elseif page=="melee" then
   for _,w in Catalog.List("melee") do action(w.name.." · somente prévia",function() showModel(w.id,{}) end) end
  elseif page=="auxiliary" then
   local sorted={} for _,a in Attachments do table.insert(sorted,a) end table.sort(sorted,function(a,b)return a.name<b.name end)
   for _,a in sorted do action(a.name.." · "..a.status,function() showModel(a.id,{}) end) end
  elseif page=="variants" then
   local sorted={} for _,v in Catalog.Variants do table.insert(sorted,v) end table.sort(sorted,function(a,b)return a.name<b.name end)
   for _,v in sorted do action(v.name.." · somente prévia",function() showModel(v.id,{}) end) end
  end end
	reflow=function()
  local factor=1 local ancestor=parent
  while ancestor do local scale=ancestor:FindFirstChildOfClass("UIScale") if scale then factor*=scale.Scale end ancestor=ancestor.Parent end
  local small=parent.AbsoluteSize.X/factor<620 local height=math.max(170,parent.AbsoluteSize.Y/factor)
  if selectionView then
   local total=selectionView:Layout(math.max(310,parent.AbsoluteSize.X/factor-8)) root.Size=UDim2.new(1,-8,0,total)
   preview.Visible=selectionView:PreviewVisible() preview.Position=selectionView.PreviewPosition preview.Size=selectionView.PreviewSize preview.ZIndex=3 preview.BackgroundTransparency=1 rotate.Visible=false details.Visible=false positionCamera() return
  end
  if page=="loadouts" then
   preview.Visible=true
   local width=math.max(310,parent.AbsoluteSize.X/factor-8)
   local left,x,center,total,offset=overview:Layout(width)
   root.Size=UDim2.new(1,-8,0,total)
   list.Position=UDim2.fromOffset(0,62) list.Size=UDim2.fromOffset(left,offset>0 and 194 or 492)
   preview.Position=UDim2.fromOffset(x+center*.23,72+offset) preview.Size=UDim2.fromOffset(center*.75,143)
   preview.ZIndex=3 rotate.ZIndex=3 preview.BackgroundTransparency=1 rotate.Position=UDim2.fromOffset(x+center-182,69+offset) rotate.Size=UDim2.fromOffset(76,28) rotate.TextSize=10 rotate.Text="Girar prévia" rotate.Visible=center>=410
   details.Visible=false positionCamera() return
  end
  preview.Visible=true preview.BackgroundTransparency=.15 preview.ZIndex=1 rotate.ZIndex=1 rotate.Visible=true rotate.Text="Girar prévia · analógico direito / arrastar"
  local previewHeight=small and 150 or math.clamp(height-82,90,280)
  local statHeight=(page=="attachments") and 180 or 0 details.Visible=statHeight>0
  local listY=small and 82+previewHeight+42 or 82 local listHeight=small and 180 or math.max(90,height-82)
  root.Size=UDim2.new(1,-8,0,math.max(listY+listHeight,82+previewHeight+42)+statHeight+8)
  list.Position=UDim2.fromOffset(0,listY) list.Size=small and UDim2.new(1,0,0,listHeight) or UDim2.new(.42,-8,0,listHeight)
  preview.Position=small and UDim2.fromOffset(0,82) or UDim2.new(.43,0,0,82) preview.Size=small and UDim2.new(1,0,0,previewHeight) or UDim2.new(.57,0,0,previewHeight)
  rotate.Position=small and UDim2.fromOffset(0,82+previewHeight+6) or UDim2.new(.43,0,0,82+previewHeight+6) rotate.Size=small and UDim2.new(1,0,0,30) or UDim2.new(.57,0,0,30)
  details.Position=UDim2.fromOffset(0,math.max(listY+listHeight,82+previewHeight+42)+4) details.Size=UDim2.new(1,0,0,statHeight)
  positionCamera()
 end
 hook(parent:GetPropertyChangedSignal("AbsoluteSize"),reflow)
 hook(preview.InputBegan,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=input end end)
 hook(UIS.InputEnded,function(input) if dragging==input then dragging=nil end end)
 hook(UIS.InputChanged,function(input) if dragging and (input==dragging or input.UserInputType==Enum.UserInputType.MouseMovement) then yaw-=input.Delta.X*.008 pitch=math.clamp(pitch-input.Delta.Y*.008,-.9,.9) positionCamera() end end)
 hook(preview.InputChanged,function(input) if input.UserInputType==Enum.UserInputType.MouseWheel then zoom=math.clamp(zoom-input.Position.Z*.1,.6,2.5) positionCamera() end end)
 local pinchZoom=1
 hook(UIS.TouchPinch,function(points,scale,_,state)
  local point=points[1] if not point or not root.Visible or not root:IsDescendantOf(player.PlayerGui) then return end
  local pos,size=preview.AbsolutePosition,preview.AbsoluteSize
  if point.X<pos.X or point.Y<pos.Y or point.X>pos.X+size.X or point.Y>pos.Y+size.Y then return end
  if state==Enum.UserInputState.Begin then pinchZoom=zoom elseif state==Enum.UserInputState.Change then zoom=math.clamp(pinchZoom/math.max(.01,scale),.6,2.5) positionCamera() end
 end)
 hook(game:GetService("RunService").RenderStepped,function(dt) if nav:GetFocus()==rotate and UIS.GamepadEnabled then for _,input in UIS:GetGamepadState(Enum.UserInputType.Gamepad1) do if input.KeyCode==Enum.KeyCode.Thumbstick2 and input.Position.Magnitude>.15 then yaw-=input.Position.X*dt*2 pitch=math.clamp(pitch+input.Position.Y*dt,-.9,.9) positionCamera() end end end end)
 function self:DefaultFocus() return selectionView and selectionView:DefaultFocus() or buttons[1] end
 function self:Destroy() alive=false for _,c in connections do c:Disconnect() end root:Destroy() end
 hook(player:GetAttributeChangedSignal("CTFArsenalState"),function() if page=="loadouts" then overview:RefreshState(state()) end end)
 root.Destroying:Connect(function() alive=false generation+=1 cacheFolder:Destroy() table.clear(modelCache) for _,c in connections do c:Disconnect() end end)
 render() reflow() return self
end
return View

