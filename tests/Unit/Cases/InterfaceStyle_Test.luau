return function(t)
 local Policy=require(game.ReplicatedStorage.Crossgrounds.InterfaceStylePolicy)
 local Settings=require(game.ReplicatedStorage.ExperienceSettings)
 local Profile=require(game.ReplicatedStorage.Crossgrounds.PreferenceProfile)
 t.test('old profiles keep the original presentation',function()
  local p=Profile.Migrate({Version=2,Global={ThemePreset=4,MenuScale=1.1}})
  t.expect.equal(Profile.Resolve(p,'InterfaceStyle','ctf'),0)
  t.expect.equal(Profile.Resolve(p,'ThemePreset','ctf'),4)
  t.expect.equal(Profile.Resolve(p,'MenuScale','ctf'),1.1)
 end)
 t.test('style persists once globally without modifying the palette',function()
  local p=Profile.New()
  Profile.Set(p,'Global','ThemePreset',7)
  t.expect.truthy(Profile.Set(p,'Global','InterfaceStyle',2))
  local restored=Profile.Migrate(p)
  for _,mode in {'hub','ctf','arena'}do t.expect.equal(Profile.Resolve(restored,'InterfaceStyle',mode),2)end
  t.expect.equal(Profile.Resolve(restored,'ThemePreset','ctf'),7)
 end)
 t.test('invalid style and scoped overrides are rejected',function()
  for _,value in {-1,3,1.5,0/0,math.huge,'Completo'}do t.expect.equal(Settings:Sanitize('InterfaceStyle',value),nil)end
  t.expect.falsy(Profile.Set(Profile.New(),'Mode:arena','InterfaceStyle',1))
  t.expect.falsy(Profile.Set(Profile.New(),'Device:Touch','InterfaceStyle',1))
 end)
 t.test('unrecognized presentation IDs use the original style',function()
  for _,v in {'invalid',3,-1,0/0}do t.expect.equal(Policy.Resolve(v),0)end
  t.expect.equal(Policy.Resolve(nil),0)
 end)
 t.test('technical screens receive more useful space in both new styles',function()
  local old=Policy.Metrics(0,true)
  for _,id in {1,2}do local m=Policy.Metrics(id,true)t.expect.truthy(m.Width>old.Width)t.expect.truthy(m.Height>old.Height)end
 end)
 t.test('wide attachment screens reserve almost half their area for the weapon',function()
  for _,width in {900,1280,1700}do
   local layout=Policy.Arsenal(width,true,2)
   t.expect.equal(layout.Side,0)
   t.expect.truthy(layout.Right>=width*.47)
   t.expect.truthy(width-layout.Right-12>=300)
  end
 end)
 t.test('narrow screens stack previews instead of squeezing columns',function()
  for _,width in {320,480,720}do
   local layout=Policy.Arsenal(width,true,1)
   t.expect.equal(layout.Right,0)
  end
 end)
end
