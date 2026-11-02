local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.IdentityCatalog)
local Frames=require(game.ReplicatedStorage.Crossgrounds.ProfileFramePolicy)
local Identity=require(script.Parent.PlayerIdentityView)
local Theme=require(script.Parent.MenuTheme)
local Nav=require(script.Parent.MenuNavigation)
local Editor={}
function Editor.Attach(browser,options)
 browser:AddPane("Frames","COMPOR MOLDURA")browser:AddPane("FrameLayer","EDITAR CAMADA")
 local info=browser:Info("Frames","Summary","Até quatro camadas, da interna para a externa. Cores livres; modelos precisam ser conquistados. A prévia só é salva ao confirmar.",90)
 local holder=browser:Info("Frames","Preview","",140)holder.Text=""local preview=Identity.new(holder)
 local detail=browser:Info("FrameLayer","Summary","",55)
 local rows={}local draft={}local selected=1 local render
 local function paint()
  local state=options.Get()if not state then return end local public=P.Public(state,game.Players.LocalPlayer.UserId,game.Players.LocalPlayer.DisplayName)public.frameLayers=draft preview:Render(public)
 end
 local function box(name,placeholder)
  local b=Instance.new("TextBox")b.Name=name b.Text=""b.PlaceholderText=placeholder b.ClearTextOnFocus=false b.Size=UDim2.new(1,-4,0,44)b.Font=Enum.Font.GothamMedium b.TextSize=15 b.TextColor3=Theme.Colors.Text b.Parent=browser.Panes.FrameLayer.List Theme.Surface(b)Nav:Register(b,function()b:CaptureFocus()end)return b
 end
 local hex=box("Hex","#RRGGBB — qualquer cor")
 local function layerPaint()
  local layer=draft[selected]if not layer then return end
  hex.Text=string.format("#%02X%02X%02X",table.unpack(layer.color))
  detail.Text="Camada "..selected.." · "..Catalog.frames[layer.frame].name.."\nCor livre RGB, sem custo."paint()
 end
 local function applyHex()
  local value=hex.Text:gsub("#",""):gsub("%s","")
  if #value~=6 or not value:match("^%x+$")then detail.Text="Use seis dígitos: #RRGGBB."return false end
  local layer=draft[selected]if not layer then return false end
  layer.color={tonumber(value:sub(1,2),16),tonumber(value:sub(3,4),16),tonumber(value:sub(5,6),16)}layerPaint()return true
 end
 hex.FocusLost:Connect(applyHex)
 browser:Button("FrameLayer","ApplyColor","Aplicar cor da prévia",applyHex)
 for component,name in {"Vermelho","Verde","Azul"}do
  local button
  local function adjust(step)local layer=draft[selected]if layer then layer.color[component]=math.clamp(layer.color[component]+step,0,255)layerPaint()end end
  button=browser:Button("FrameLayer","RGB"..component,name.." · − / +",function()adjust(1)end)
  Nav:Register(button,function()adjust(1)end,function(step)adjust(step)end)
 end
 local function move(step)
  local destination=selected+step if destination<1 or destination>#draft then return end
  draft[selected],draft[destination]=draft[destination],draft[selected]selected=destination layerPaint()render()
 end
 browser:Button("FrameLayer","Inner","Mover para dentro",function()move(-1)end)
 browser:Button("FrameLayer","Outer","Mover para fora",function()move(1)end)
 browser:Button("FrameLayer","Remove","Remover camada",function()
  if #draft<=1 then detail.Text="Mantenha pelo menos uma camada."return end
  table.remove(draft,selected)selected=math.min(selected,#draft)render()browser:Push({"RootPane","Identity","Frames"})
 end)
 for _,id in {"default","prestige","mastery","legend","clan"}do
  browser:Button("FrameLayer","Shape_"..id,"Modelo · "..Catalog.frames[id].name,function()
   local state=options.Get()if not state or not state.cosmetics.frames[id]then detail.Text="Modelo ainda não conquistado."return end
   draft[selected].frame=id layerPaint()
  end)
 end
 render=function()
  for _,b in rows do b:Destroy()end table.clear(rows)
  for i,layer in draft do
   table.insert(rows,browser:Button("Frames","Layer"..i,i.." · "..Catalog.frames[layer.frame].name.." · "..string.format("#%02X%02X%02X",table.unpack(layer.color)),function()selected=i layerPaint()browser:Push({"RootPane","Frames","FrameLayer"})end))
  end paint()
 end
 browser:Button("Frames","Add","Adicionar camada",function()
  if #draft>=Frames.MaxLayers then info.Text="Limite de quatro camadas por moldura."return end
  table.insert(draft,{frame="default",color={255,255,255}})render()
 end)
 browser:Button("Frames","Save","Salvar composição",function()
  local ok=options.Save(draft)if ok then options.Refresh()info.Text="Composição salva. Cores e camadas permanecem após prestígio."else info.Text="Não foi possível salvar. Sua prévia foi preservada."end
 end)
 browser:Button("Frames","Reset","Restaurar prévia salva",function()
  local state=options.Get()if not state then return end
  local id=state.identity.frame draft=P.Copy(state.frameLayers or{{frame=id,color=Catalog.frames[id].color}})render()
 end)
 browser:Button("Identity","Frames","Moldura por camadas e cores  ›",function()
  local state=options.Get()if not state then return end
  local id=state.identity.frame draft=P.Copy(state.frameLayers or{{frame=id,color=Catalog.frames[id].color}})selected=1 render()browser:Push({"RootPane","Identity","Frames"})
 end)
end
return Editor
