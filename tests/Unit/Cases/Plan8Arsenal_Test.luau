return function(t)
 local Root=game.ReplicatedStorage.Crossgrounds
 local Catalog=require(Root.WeaponCatalog) local A=require(Root.AttachmentCatalog)
 local Compat=require(Root.AttachmentCompatibility) local Config=require(Root.WeaponVisualConfiguration)
 local Stats=require(Root.WeaponStats) local Kits=require(game.ReplicatedStorage.KitDefinitions)
 local Visual=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
 local Hold=require(Root.WeaponHold)
 local e=t.expect
 local function near(a,b) e.truthy(math.abs(a-b)<1e-6) end
 local function fixture()
  return {id='fixture',platform='AR',slots={'optic'},mountPoints={optic='TopRail'}},
   {id='fixtureOptic',slot='optic',status='Available',auditStatus='Verified',mountType='TopRail',compatibilityMode='SpecificWeapon',compatibleWeapons={'fixture'}}
 end
 -- Explicit blocks win over an otherwise allowed weapon/platform/mount.
 t.test('explicit block takes precedence',function() local w,a=fixture() a.blockedWeapons={'fixture'} e.falsy(Compat.Check(w,a)) end)
 -- Unknown imported geometry cannot be equipped by declaring the right slot.
 t.test('pending audit is closed',function() local w,a=fixture() a.pendingAudit=true e.falsy(Compat.Check(w,a)) end)
 -- Universal rails still need per-weapon geometric verification.
 t.test('universal requires verified fit',function() local w,a=fixture() a.compatibilityMode='Universal' e.falsy(Compat.Check(w,a)) a.verifiedMountWeapons={'fixture'} e.truthy(Compat.Check(w,a)) end)
 -- Platform support also requires the actual mount, not merely a category.
 t.test('platform and mount both apply',function() local w,a=fixture() a.compatibilityMode='SpecificPlatform' a.compatiblePlatforms={'AR'} e.truthy(Compat.Check(w,a)) w.mountPoints.optic='Other' e.falsy(Compat.Check(w,a)) end)
 -- Catalog changes invalidate the bounded per-weapon/slot compatibility view.
 t.test('slot cache follows explicit invalidation',function()
  local w,a=fixture() a.name='Fixture' local catalog={fixture=a}
  local before=Compat.ForSlot(w,catalog,'optic') e.truthy(before[1].available)
  a.pendingAudit=true Compat.Invalidate()
  e.falsy(Compat.ForSlot(w,catalog,'optic')[1].available)
 end)
 -- Six independent verified slots are legal; no global five-item budget.
 t.test('six independent slots validate without a global ceiling',function()
  local id='__plan8_fixture' local w={id=id,combatId='Rifle',slots={},mountPoints={}}
  local config={} Catalog.Weapons[id]=w
  for i=1,6 do local slot='fixture'..i local a=id..i w.slots[i]=slot w.mountPoints[slot]=slot config[slot]=a A[a]={id=a,slot=slot,status='Available',auditStatus='Verified',mountType=slot,compatibilityMode='SpecificWeapon',compatibleWeapons={id}} end
  local ok,err=pcall(function() e.truthy(Config.Validate(id,config,true)) end)
  Catalog.Weapons[id]=nil for i=1,6 do A[id..i]=nil end if not ok then error(err) end
 end)
 -- Client-supplied multiplier tables and unknown slots never enter server stats.
 t.test('forged values and foreign attachments are rejected',function()
  e.falsy(Config.Validate('m4a1',{optic={Damage=999}},true))
  e.falsy(Config.Validate('m1911',{optic='optics_g_i_mini_reflex'},true))
  e.falsy(Config.Validate('m4a1',{Damage='optics_g_i_mini_reflex'},true))
 end)
 -- Queries must not grow the AUG slot list.
 t.test('catalog reads are idempotent',function()
  local before=#Catalog.Get('aug').slots for _=1,500 do Catalog.Get('aug') end e.equal(#Catalog.Get('aug').slots,before)
  local count=0 for _,slot in Catalog.Get('aug').slots do if slot=='fireControl' then count+=1 end end e.equal(count,1)
 end)
 -- Functional attachment values derive from the shared base without modifying it.
 t.test('commando applies once and preserves base',function()
  local base=Kits.Weapons[Catalog.Get('m4a1').combatId] local spread=base.Spread
  local data=Stats.Resolve('m4a1',{underbarrel='foregrips_commando_foregrip'})
  near(data.Spread,spread*.6) e.equal(base.Spread,spread)
 end)
 -- Optional recoil fields are skipped; a valid weapon without them still resolves.
 t.test('optional recoil fields may be absent',function()
  local id='__plan8_norecoil' Catalog.Weapons[id]={id=id,combatId=id,slots={'underbarrel'},mountPoints={underbarrel='LowerRail'}}
  Kits.Weapons[id]={Kind='Gun',Damage=10,Cooldown=.2,Magazine=5,Reserve=20,ReloadTime=1,Range=30,Spread=2}
  local attachment=A.foregrips_commando_foregrip local old=attachment.compatibleWeapons attachment.compatibleWeapons={id}
  local ok,err=pcall(function() local data=Stats.Resolve(id,{underbarrel=attachment.id}) near(data.Spread,1.2) e.equal(data.VisualRecoil,nil) end)
  attachment.compatibleWeapons=old Kits.Weapons[id]=nil Catalog.Weapons[id]=nil if not ok then error(err) end
 end)
 -- All public available combinations construct sanitized physical mounts.
 t.test('every verified pair builds without imported code',function()
  for _,a in A do if a.status=='Available' then for _,id in a.compatibleWeapons do
   e.truthy(Compat.Check(Catalog.Get(id),a))
   local model=assert(Visual.Build(id,{[a.slot]=a.id}))
   for _,v in model:GetDescendants() do e.falsy(v:IsA('LuaSourceContainer') or v:IsA('Sound') or v:IsA('RemoteEvent')) end
   model:Destroy()
  end end end
 end)
 -- Pistols need a support hand near the grip, never the rifle fore-end.
 t.test('all seven imported pistols use a compact support grip',function()
  for _,id in {'m1911','magnum_357','x16','m19','desert_eagle','renetti','sykov'} do
   local model=assert(Visual.Build(id,{}))
   e.truthy((model.Handle.SupportGrip.Position-model.Handle.RightHandGrip.Position).Magnitude<.4)
   e.truthy(model.Handle.Muzzle.Position.Z<-.5) e.truthy(model.Handle.Muzzle.Position.Z>-2.5)
   model:Destroy()
  end
 end)
 -- Arena cosmetics, legacy pistol and MW pistols share the same posture classification.
 t.test('pistol classification excludes rifles and blasters',function()
  for _,id in {'ArenaPistol','Pistol','m1911','magnum_357','x16','m19','desert_eagle','renetti','sykov'} do
   local tool=Instance.new('Tool') tool:SetAttribute('WeaponId',id) tool:SetAttribute('WeaponKind','Gun') e.truthy(Hold.IsPistol(tool)) near(Hold.Mount(tool).Z,-.7) tool:Destroy()
  end
  for _,id in {'m4a1','Blaster','AutoBlaster','Sword'} do local tool=Instance.new('Tool') tool:SetAttribute('WeaponId',id) e.falsy(Hold.IsPistol(tool)) tool:Destroy() end
 end)
 -- Reconfiguring the same gun preserves its model and native mesh instances.
 t.test('preview updates only changed slots and cleans up',function()
  local Preview=require(game.StarterPlayer.StarterPlayerScripts.ArsenalPreview)
  local world=Instance.new('WorldModel') local preview=Preview.new(world)
  local base=assert(Visual.Build('m4a1',{})) local optic=assert(Visual.Build('m4a1',{optic='optics_g_i_mini_reflex'}))
  local a=preview:Capture(base,'m4a1') local b=preview:Capture(optic,'m4a1')
  local model=preview:Show(a,'m4a1',{}) local native=model:FindFirstChild('Handle')
  e.equal(preview:Show(b,'m4a1',{optic='optics_g_i_mini_reflex'}),model) e.equal(model.Handle,native)
  e.equal(preview:Show(a,'m4a1',{}),model)
  for _,v in model:GetChildren() do e.falsy(v:GetAttribute('VisualAttachmentId')) end
  preview:Destroy() e.equal(#world:GetChildren(),0) a:Destroy() b:Destroy() base:Destroy() optic:Destroy() world:Destroy()
 end)
 -- Refreshing authoritative data must preserve row identity, focus and scroll.
 t.test('attachment list preserves context and separates right panels',function()
  local View=require(game.StarterPlayer.StarterPlayerScripts.ArsenalSelectionView)
  local signal=Instance.new('BindableEvent') local selected=0 local inspected=0 local focus
  local nav={FocusChanged=signal.Event,callbacks={}}
  function nav:Connect(b,fn) self.callbacks[b]=fn end function nav:SetActions() end
  function nav:GetFocus() return focus end function nav:Focus(b) focus=b signal:Fire(b) end
  local parent=Instance.new('Frame') local player=Instance.new('Folder') player:SetAttribute('SettingFontScale',1.35)
  local equipped=false
  local view=View.new(parent,{Player=player,Navigation=nav,Accessories=true,WeaponName='Fixture',Category='optic',Categories={'optic','muzzle'},
   Entries=function() return {{id='none',name='Sem acessório',status='Disponível',available=true},{id='fixture',name='Fixture',status=equipped and 'Equipado' or 'Compatível',available=true,equipped=equipped}} end,
   Inspect=function() inspected+=1 end,Select=function() selected+=1 end,Tools={{'Restaurar acessórios','',function()end},{'Salvar visual','',function()end}},ChangeWeapon=function()end})
  view:Layout(1100) local root=view.Root local row=root.Catalog.Items.Item_fixture nav:Focus(row)
  e.equal(selected,0) root.Catalog.Items.AutomaticCanvasSize=Enum.AutomaticSize.None root.Catalog.Items.CanvasSize=UDim2.fromOffset(0,5000) root.Catalog.Items.CanvasPosition=Vector2.new(0,25) equipped=true view:Refresh()
  e.equal(root.Catalog.Items.Item_fixture,row) e.equal(nav:GetFocus(),row) e.equal(root.Catalog.Items.CanvasPosition.Y,25)
  e.falsy(root.Categories.Visible) e.truthy(root.WeaponPanel.Position.X.Offset>root.Catalog.Position.X.Offset)
  e.truthy(root.StatisticsPanel.Position.Y.Offset>=root.WeaponPanel.Position.Y.Offset+root.WeaponPanel.Size.Y.Offset)
  nav.callbacks[row]() e.equal(selected,1)
  view:Layout(500) e.truthy(root.WeaponPanel.Position.Y.Offset>=root.Catalog.Position.Y.Offset+root.Catalog.Size.Y.Offset)
  view:Cycle(1) e.equal(selected,1) e.truthy(inspected>0)
  view:Destroy() e.equal(#parent:GetChildren(),0) signal:Destroy() player:Destroy() parent:Destroy()
 end)
end
