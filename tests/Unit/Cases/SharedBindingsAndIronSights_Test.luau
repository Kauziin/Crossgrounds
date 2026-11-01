return function(t)
 local P=require(game.ReplicatedStorage.ControlPolicy)
 local D=require(game.ReplicatedStorage.ControlDefinitions)
 local Profile=require(game.ReplicatedStorage.Crossgrounds.PreferenceProfile)
 local Iron=require(game.ReplicatedStorage.Crossgrounds.IronSightVisibility)
 t.test('rebinding a used button preserves every other action',function()
  local bindings={} for action,data in D.Actions do bindings[action]=data.Gamepad end
  local plan=P.Plan(D,bindings,'ReloadInteract','Gamepad','ButtonY')
  t.expect.equal(plan.ReloadInteract,'ButtonY') t.expect.equal(plan.SwitchWeapon,'ButtonY')
  for action,key in bindings do if action~='ReloadInteract' then t.expect.equal(plan[action],key) end end
 end)
 t.test('normalization preserves duplicates and fixes only invalid inputs',function()
  local bindings={} for action in D.Actions do bindings[action]='ButtonY' end
  bindings.Jump='ButtonSelect'
  local plan=P.Normalize(D,bindings,'Gamepad')
  t.expect.equal(plan.SwitchWeapon,'ButtonY') t.expect.equal(plan.ReloadInteract,'ButtonY') t.expect.equal(plan.Jump,'ButtonA')
 end)
 t.test('Y is restored once without overriding future custom bindings',function()
  local old=Profile.New() old.ControlBindingVersion=nil old.Devices.Gamepad.BindSwitchWeaponGamepad='ButtonR3'
  local migrated=Profile.Migrate(old) t.expect.equal(migrated.Devices.Gamepad.BindSwitchWeaponGamepad,'ButtonY')
  migrated.Devices.Gamepad.BindSwitchWeaponGamepad='ButtonR3'
  t.expect.equal(Profile.Migrate(migrated).Devices.Gamepad.BindSwitchWeaponGamepad,'ButtonR3')
 end)
 t.test('shared Y uses combat/admin context and is inactive in menus',function()
  local actions={'SwitchWeapon','AdminClean','GetOutHacker'}
  t.expect.equal(P.Resolve(actions,{mode='ctf',inMatch=true,alive=true}),'SwitchWeapon')
  t.expect.equal(P.Resolve(actions,{mode='ctf',admin=true,authorized=true,alive=true}),'AdminClean')
  t.expect.equal(P.Resolve(actions,{mode='ctf',modal=true,alive=true}),nil)
 end)
 t.test('native sights are hidden and restored without hiding optics or rails',function()
  local m=Instance.new('Model')
  for _,name in {'FrontSightBase','Rear Sight (Now with ROBLOX O Logo in it)','Iron Sights','Sight Rail','Accessory_optic_Front Sight'} do
   local p=Instance.new('Part') p.Name=name p.Transparency=.2 p.Parent=m
   if name:find('Accessory',1,true) then p:SetAttribute('VisualAttachmentId','optic') end
   p:SetAttribute('IronSightPart',Iron.IsSourcePart(p,m))
  end
  Iron.Apply(m,true)
  t.expect.equal(m.FrontSightBase.Transparency,1) t.expect.equal(m['Iron Sights'].Transparency,1)
  t.expect.truthy(math.abs(m['Sight Rail'].Transparency-.2)<.0001) t.expect.truthy(math.abs(m['Accessory_optic_Front Sight'].Transparency-.2)<.0001)
  Iron.Apply(m,false) t.expect.truthy(math.abs(m.FrontSightBase.Transparency-.2)<.0001) m:Destroy()
 end)
end
