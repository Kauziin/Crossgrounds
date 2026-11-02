return function(t)
 local C=require(game.ReplicatedStorage.Crossgrounds.ThemeCatalog)
 local S=require(game.ReplicatedStorage.ExperienceSettings)
 local P=require(game.ReplicatedStorage.Crossgrounds.PreferenceProfile)
 local L=require(game.ReplicatedStorage.Crossgrounds.InterfaceLayout)
 local e=t.expect
 local function close(a,b)e.truthy(math.abs(a-b)<1e-5)end
 -- Presets are a stable, distinct free catalog, not arbitrary custom inputs.
 t.test('the free catalog contains 22 distinct named colors',function()
  e.equal(#C.Presets,22)local names,colors={},{}
  for i,p in C.Presets do e.falsy(names[p.Name])e.falsy(colors[p.Color])names[p.Name]=true colors[p.Color]=true e.truthy(C.CanEdit('ThemePreset',i,false))end
 end)
 -- Custom picker access is gated even when invoked outside its UI.
 t.test('non owners cannot select custom HSV through any protected key',function()
  for key,value in {ThemePreset=0,AccentHue=25,AccentSaturation=.3,AccentValue=.4}do e.falsy(C.CanEdit(key,value,false))e.falsy(C.CanEdit(key,value,nil))end
 end)
 -- The same values are available to a confirmed owner.
 t.test('confirmed owners can select and edit custom HSV',function()
  for key,value in {ThemePreset=0,AccentHue=25,AccentSaturation=.3,AccentValue=.4}do e.truthy(C.CanEdit(key,value,true))end
 end)
 -- Saved custom values do not grant a paid entitlement on their own.
 t.test('saved custom selection falls back without a pass',function()
  e.equal(C.Resolve(0,350,1,1,false),C.Presets[1].Color)
 end)
 -- An owned custom selection respects all three HSV channels.
 t.test('custom HSV resolves to the requested color',function()
  local color=C.Resolve(0,120,.5,.8,true)local h,s,v=color:ToHSV()close(h,1/3)close(s,.5)close(v,.8)
 end)
 -- Every free palette keeps body text and focus readable on its cards.
 t.test('all preset palettes preserve text and focus contrast',function()
  for _,p in C.Presets do for _,hc in {false,true}do local v=C.Palette(p.Color,hc)e.truthy(C.Contrast(v.Text,v.Card)>=7)e.truthy(C.Contrast(v.Accent,v.Card)>=4.5)e.truthy(C.Contrast(v.Focus,v.Card)>=4.5)end end
 end)
 -- A custom black color must not make focus disappear.
 t.test('dark custom colors retain visible focus',function()
  local p=C.Palette(Color3.new())e.equal(p.RawAccent,Color3.new())e.truthy(C.Contrast(p.Focus,p.Card)>=4.5)
 end)
 -- Achromatic choices are neutral rather than an accidental red theme.
 t.test('achromatic custom themes keep neutral surfaces',function()
  local p=C.Palette(Color3.new(.5,.5,.5))close(p.Surface.R,p.Surface.G)close(p.Surface.G,p.Surface.B)
 end)
 -- A warm theme changes the blue surface as well as the bright accent.
 t.test('theme hue reaches dark menu surfaces',function()
  local blue=Color3.fromRGB(13,29,36)local red=C.Tint(blue,Color3.fromRGB(255,100,132))e.truthy(red.R>red.B)e.truthy(red~=blue)
 end)
 -- Health, danger and white art are not generic blue theme roles.
 t.test('semantic health danger and neutral art colors stay unchanged',function()
  for _,color in {Color3.fromRGB(92,213,139),Color3.fromRGB(244,115,121),Color3.new(1,1,1)}do e.equal(C.Tint(color,C.Presets[11].Color),color)end
 end)
 -- Legacy accent preferences retain an equivalent free color without unlocking HSV.
 t.test('legacy hue migrates while preserving other preferences',function()
  local p=P.Migrate({Version=2,ControlBindingVersion=1,Global={AccentHue=120,MenuScale=1.1}})
  e.equal(p.Global.ThemePreset,C.NearestHue(120))e.equal(p.Global.MenuScale,1.1)e.equal(p.Global.AccentHue,120)
 end)
 -- A later persisted theme id is never replaced by the legacy hue.
 t.test('explicit preset survives migration and mode changes',function()
  local p=P.Migrate({Version=2,Global={ThemePreset=8,AccentHue=120}})e.equal(P.Resolve(p,'ThemePreset','arena'),8)e.equal(P.Resolve(p,'ThemePreset','ctf'),8)
 end)
 -- Invalid requests cannot introduce a non-catalog preset or invalid HSV.
 t.test('theme schema rejects invalid preset and non finite channels',function()
  e.equal(S:Sanitize('ThemePreset',23),nil)e.equal(S:Sanitize('ThemePreset',1.5),nil)e.equal(S:Sanitize('AccentHue',0/0),nil)e.equal(S:Sanitize('AccentValue',math.huge),nil)
 end)
 -- The low-height phone layout must show complete controls, not a 34px strip.
 t.test('phone landscape reserves usable remapping content',function()
  local m=L.Settings(726,275,true)e.truthy(m.Compact)e.truthy(m.ContentHeight>=112)e.truthy(m.ContentY+m.ContentHeight<=m.Height)
 end)
 -- Scaling the menu up must still leave an accessible scrolling list.
 t.test('large menu scale retains a full row on short screens',function()
  local m=L.Settings(726/1.3,275/1.3,true)e.truthy(m.Compact)e.truthy(m.ContentHeight>=64)e.truthy(m.Top+m.Height<=275/1.3)
 end)
 -- Desktop pages retain a sidebar, and bindings consume no duplicate category strip.
 t.test('desktop layout keeps substantial content without duplicate tabs',function()
  local m=L.Settings(1280,720,true)e.falsy(m.Compact)e.truthy(m.ContentHeight>=450)e.truthy(m.ContentY+m.ContentHeight<=m.Height)
 end)
end
