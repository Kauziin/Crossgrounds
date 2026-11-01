return function(t)
 local Root=game.ReplicatedStorage.Crossgrounds
 local P=require(Root.PistolReloadMotion) local R=require(Root.WeaponReloadMotion)
 local e=t.expect
 local function identity(cf) e.truthy(cf.Position.Magnitude<1e-6) local x,y,z=cf:ToOrientation() e.truthy(math.abs(x)+math.abs(y)+math.abs(z)<1e-5) end
 local function near(a,b) e.truthy(math.abs(a-b)<1e-5) end
 -- Each supported pistol returns exactly to rest at both endpoints.
 t.test('all pistol profiles settle at both endpoints',function()
  for _,id in {'m1911','magnum_357','x16','m19','desert_eagle','renetti','sykov','M1911','Magnum','Glock18','DesertEagle','Luger','Beretta'} do
   e.truthy(P.Profile(id)) for _,time in {0,1} do local s=R.Sample(time,id,true)
    for _,field in {'weapon','magazine','slide','cylinder','toggle'} do identity(s[field]) end
    near(s.hand.Magnitude,0) near(s.visibility.Magazine,0) near(s.visibility.Speedloader,1)
   end
  end
 end)
 -- Partial magazine reloads leave the chambered round and action untouched.
 t.test('partial pistol reload does not rack the slide',function()
  for _,time in {.05,.3,.6,.83,.9} do local s=R.Sample(time,'m19',false) identity(s.slide) identity(s.toggle) end
 end)
 -- Empty reloads retain an open slide before seating and release it afterwards.
 t.test('empty pistol reload releases the slide after insertion',function()
  e.truthy(R.Sample(.4,'m19',true).slide.Position.Z>.15)
  e.truthy(R.Sample(.85,'m19',true).hand.Y>R.Sample(.85,'m19',false).hand.Y)
  identity(R.Sample(1,'m19',true).slide)
 end)
 -- The Luger has a toggle action, not a reciprocating slide.
 t.test('Luger uses its toggle joint',function()
  local s=R.Sample(.85,'Luger',true) e.truthy(s.toggle.Position.Magnitude>.01) identity(s.slide)
  identity(R.Sample(.85,'Luger',false).toggle)
 end)
 -- Revolvers open the cylinder and show a loader only in the insertion phase.
 t.test('revolver loader is confined to the loading phase',function()
  local s=R.Sample(.59,'magnum_357',true) e.truthy(s.cylinder.Position.X<-.2) near(s.visibility.Speedloader,0) identity(s.slide)
  near(R.Sample(.2,'magnum_357',true).visibility.Speedloader,1)
  near(R.Sample(.9,'magnum_357',true).visibility.Speedloader,1)
 end)
 -- Motion is normalized to the actual server duration, including short Arena reloads.
 t.test('controller follows server reload duration',function()
  for _,duration in {.9,1.3,2.8,4} do
   local tool=Instance.new('Tool') tool:SetAttribute('WeaponId','m19') tool:SetAttribute('Reloading',true) tool:SetAttribute('ReloadStartedAt',10) tool:SetAttribute('ReloadDuration',duration) tool:SetAttribute('ReloadWasEmpty',true)
   local actual=R.new():Update(tool,1/60,10+duration*.5) local expected=R.Sample(.5,'m19',true)
   near((actual.hand-expected.hand).Magnitude,0) near((actual.magazine.Position-expected.magazine.Position).Magnitude,0) tool:Destroy()
  end
 end)
 -- A visual cancellation begins at the last pose and eases back without a jump.
 t.test('cancelled reload blends from its current pose',function()
  local tool=Instance.new('Tool') tool:SetAttribute('WeaponId','m19') tool:SetAttribute('Reloading',true) tool:SetAttribute('ReloadStartedAt',10) tool:SetAttribute('ReloadDuration',2)
  local controller=R.new() local before=controller:Update(tool,0,10.8) tool:SetAttribute('Reloading',false)
  local cancelled=controller:Update(tool,0,10.8) near((before.hand-cancelled.hand).Magnitude,0)
  local rest=controller:Update(tool,.14,10.94) identity(rest.weapon) near(rest.hand.Magnitude,0) tool:Destroy()
 end)
 -- The normalized timeline is independent of rendering frame rate.
 t.test('sampling is deterministic across frame rates',function()
  local tool=Instance.new('Tool') tool:SetAttribute('WeaponId','Magnum') tool:SetAttribute('Reloading',true) tool:SetAttribute('ReloadStartedAt',0) tool:SetAttribute('ReloadDuration',2)
  local a=R.new():Update(tool,1/30,1) local b=R.new():Update(tool,1/144,1) near((a.hand-b.hand).Magnitude,0) tool:Destroy()
 end)
 -- Rotations are evaluated about the mechanical pivot rather than the tool origin.
 t.test('part rotation preserves its hinge position',function()
  local pivot=Vector3.new(0,.5,-.5) local cf=R.PartTransform({cylinder=CFrame.Angles(0,0,.6)},'Cylinder',pivot)
  near((cf:PointToWorldSpace(pivot)-pivot).Magnitude,0)
 end)
 -- Numerical samples remain finite and changes near the ends have zero slope.
 t.test('curves remain finite and have soft endpoints',function()
  for _,id in {'m19','Magnum','Luger'} do
   for i=0,200 do local s=R.Sample(i/200,id,true) for _,v in {s.weapon.Position,s.hand} do e.truthy(v.Magnitude==v.Magnitude and v.Magnitude<5) end end
   e.truthy(R.Sample(.00001,id,true).weapon.Position.Magnitude<1e-8)
   e.truthy(R.Sample(.99999,id,true).weapon.Position.Magnitude<1e-8)
  end
 end)
 -- Imported magazine and slide groups exclude the frame-mounted release levers.
 t.test('pistol release levers do not travel with the slide',function()
  local V=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
  local m=assert(V.Build('m19',{})) local magazine=0 local slides=0
  for _,v in m:GetChildren() do if v:IsA('BasePart') then
   if v.Name=='Slide Stop' then e.equal(v:GetAttribute('ReloadGroup'),nil) end
   if v:GetAttribute('ReloadGroup')=='Magazine' then magazine+=1 end if v:GetAttribute('ReloadGroup')=='Slide' then slides+=1 end
  end end e.truthy(magazine>0 and slides>0) m:Destroy()
 end)
 -- The alternate snakeshot prop cannot float next to the idle revolver.
 t.test('revolver keeps one hidden loader and a cylinder pivot',function()
  local m=assert(require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals).Build('magnum_357',{})) local n=0
  for _,v in m:GetChildren() do if v:GetAttribute('ReloadGroup')=='Speedloader' then n+=1 e.equal(v:GetAttribute('ReloadVariant'),'Standard') e.equal(v.Transparency,1) end end
  e.equal(n,7) e.truthy(m.Handle:FindFirstChild('ReloadPivot_Cylinder')) m:Destroy()
 end)
 -- Every catalog item has a static tile; rows need no individual 3D viewport.
 t.test('atlas covers every attachment and removal',function()
  local Art=require(Root.AttachmentArt) e.truthy(Art.Rects.none)
  for id in require(Root.AttachmentCatalog) do e.truthy(Art.Rects[id]) end
  local image=Instance.new('ImageLabel') Art.Apply(image,'foregrips_commando_foregrip') e.equal(image.ImageRectSize,Vector2.new(160,96)) e.truthy(image.Image~='') image:Destroy()
 end)
 -- All rects stay within texture pages that Roblox can serve without resizing.
 t.test('atlas rects fit their uploaded page',function()
  local Art=require(Root.AttachmentArt)
  for _,tile in Art.Rects do e.truthy(tile[1]>=1 and tile[1]<=3) e.truthy(tile[2].X>=0 and tile[2].X+160<=960) e.truthy(tile[2].Y>=0 and tile[2].Y+96<=(tile[1]==3 and 96 or 768)) end
 end)
 -- The requested compact row has art and no second line or 3D scene.
 t.test('accessory rows use compact art without descriptions',function()
  local V=require(game.StarterPlayer.StarterPlayerScripts.ArsenalSelectionView) local signal=Instance.new('BindableEvent') local focus
  local nav={FocusChanged=signal.Event} function nav:Connect() end function nav:SetActions() end function nav:GetFocus() return focus end
  local holder=Instance.new('Frame') local v=V.new(holder,{Navigation=nav,Accessories=true,Category='optic',Categories={'optic'},Entries=function() return {{id='optics_g_i_mini_reflex',name='Reflex',status='Compatível',available=true}} end,Inspect=function()end,Select=function()end})
  v:Layout(1100) local row=v.Root.Catalog.Items.Item_optics_g_i_mini_reflex e.truthy(row.Size.Y.Offset<64) e.falsy(row.Status.Visible) e.truthy(row.AttachmentArt.Image~='')
  for _,o in row:GetDescendants() do e.falsy(o:IsA('ViewportFrame')) end
  v:Destroy() signal:Destroy() holder:Destroy()
 end)
end
