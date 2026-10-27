local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Bridge=require(script.Parent:WaitForChild("HubBridge"))
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local player=game.Players.LocalPlayer
local remotes=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("GetOutRemotes",15)
if not remotes then return end -- Get Out is not installed in a hub-only Place.
local event=remotes:WaitForChild("State")
local ability=remotes:WaitForChild("UseAbility")
local current

local gui=Instance.new("ScreenGui") gui.Name="GetOutHUD" gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true gui.DisplayOrder=16 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame") panel.Name="Status" panel.AnchorPoint=Vector2.new(.5,0)
panel.Position=UDim2.new(.5,0,0,24) panel.Size=UDim2.new(1,-24,0,126)
panel.BackgroundColor3=Color3.fromRGB(18,27,37) panel.BackgroundTransparency=.15 panel.Parent=gui
local constraint=Instance.new("UISizeConstraint") constraint.MaxSize=Vector2.new(430,126) constraint.Parent=panel
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=panel
local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(112,137,153) stroke.Thickness=1 stroke.Parent=panel
local function label(name,y,height,size,color)
 local value=Instance.new("TextLabel") value.Name=name value.Position=UDim2.fromOffset(14,y)
 value.Size=UDim2.new(1,-28,0,height) value.BackgroundTransparency=1 value.TextXAlignment=Enum.TextXAlignment.Left
 value.TextColor3=color or Color3.fromRGB(233,241,247) value.Font=Enum.Font.GothamMedium
 value.TextSize=size value.TextWrapped=true value.Parent=panel return value
end
local title=label("Title",8,30,20)
local objective=label("Objective",42,36,14)
local note=label("Note",82,34,13,Color3.fromRGB(190,205,217))
local abilityButton=Instance.new("TextButton") abilityButton.Name="BeastAbility" abilityButton.AnchorPoint=Vector2.new(1,1)
abilityButton.Position=UDim2.new(1,-28,1,-88) abilityButton.Size=UDim2.fromOffset(190,56)
abilityButton.BackgroundColor3=Color3.fromRGB(45,89,107) abilityButton.TextColor3=Color3.fromRGB(245,250,253)
abilityButton.Font=Enum.Font.GothamBold abilityButton.TextSize=15 abilityButton.TextWrapped=true abilityButton.Visible=false
abilityButton.Parent=gui
local buttonCorner=Instance.new("UICorner") buttonCorner.CornerRadius=UDim.new(0,9) buttonCorner.Parent=abilityButton

local function fmt(seconds)
 seconds=math.max(0,math.ceil(seconds or 0))
 return string.format("%02d:%02d",math.floor(seconds/60),seconds%60)
end
local function useHacker()
 if not Scope:IsGetOut() or not current or current.role~="beast" or not current.roundId
  or (current.abilityReadyIn or 0)>0 or current.state=="results"or Router:IsBlocked()then return end
 ability:FireServer(current.roundId)
end
abilityButton.Activated:Connect(useHacker)
Router:Register("GetOutHacker",function(state)
 if state==Enum.UserInputState.Begin then useHacker() end
 return Enum.ContextActionResult.Sink
end,{scope="get_out"})

local function render()
 gui.Enabled=Scope:IsGetOut()
 if not gui.Enabled then return end
 local data=current
 if not data then title.Text="GET OUT" objective.Text="Preparando partida..." note.Text="" abilityButton.Visible=false return end
 local role=data.role=="beast" and "BESTA" or data.role=="survivor" and "SOBREVIVENTE" or "AGUARDANDO"
 local phase=data.state=="enraged" and "FÚRIA" or data.state=="playing" and "FUGA" or string.upper(data.state or "AGUARDANDO")
 title.Text=role.."  ·  "..phase.."  ·  "..fmt(data.remaining)
 if data.state=="results" then
  local translations={escaped="Você escapou",captured="Você foi capturado",beast_contained="Besta contida",eliminated_at_timeout="Eliminado ao fim do tempo"}
  objective.Text=translations[data.result] or (data.ending=="technical_beast_departure" and "Partida encerrada por desconexão" or "Rodada encerrada")
  note.Text="Nova rodada em "..fmt(data.remaining)
 elseif data.state=="playing" or data.state=="enraged" then
  if data.role=="beast" then
   objective.Text="Capture os sobreviventes antes que escapem."
   note.Text=(current.abilityActiveIn or 0)>0 and"Runner ativo · +150% de velocidade · salto bloqueado"or"Runner · impulso de 3 segundos · use Q ou Y"
  elseif data.role=="survivor" then
   objective.Text="Travas · PCs hackeados: "..tostring(data.computers or 0).." / 4"
   note.Text=data.podRemaining and ("Preso no pod · "..fmt(data.podRemaining))
    or (data.computers or 0)>=4 and "Gire uma manivela e atravesse a saída."
    or (data.alliesInPods or 0)>0 and "Um aliado precisa de resgate." or "Encontre os computadores e evite a Besta."
  else objective.Text="Rodada em curso" note.Text="Você entra na próxima rodada." end
  if data.result=="escaped" then objective.Text="Você escapou" note.Text="Aguardando os demais sobreviventes."
  elseif data.result=="captured" then objective.Text="Você foi capturado" note.Text="Aguarde o resultado da rodada." end
  local g=data.gameplay or {}
  if g.victim=="Downed" then note.Text="Derrubado · aguarde recuperação ou a Besta prender a corda."
  elseif g.victim=="Dragged" then note.Text="Você está sendo arrastado."
  elseif g.victim=="Captured" then note.Text="Aguarde resgate · "..math.floor((g.freeze or 0)*100).."% congelado"..(g.freezePaused and " · PAUSADO" or "")
  elseif g.dragging then note.Text="Transportando "..g.dragging.." · leve à cápsula."
  elseif g.hack then note.Text="Hack compartilhado · "..math.floor(g.hack.progress*100).."% · confirme quando ficar verde." end
 else
  objective.Text=data.message or (data.state=="waiting" and "Aguardando pelo menos 2 jogadores." or "Preparando o mapa.")
  note.Text="Protótipo Clássico · regras de teste"
 end
 abilityButton.Visible=data.role=="beast" and (data.state=="playing" or data.state=="enraged")
 if abilityButton.Visible then
  local ready=(data.abilityReadyIn or 0)<=0
  abilityButton.Active=ready abilityButton.BackgroundColor3=ready and Color3.fromRGB(45,109,118) or Color3.fromRGB(68,75,81)
  abilityButton.Text=(data.abilityActiveIn or 0)>0 and("RUNNER ATIVO · "..fmt(data.abilityActiveIn))or ready and("RUNNER · "..Router:Key("GetOutHacker","Keyboard").." / "..Router:Key("GetOutHacker","Gamepad"))or"RUNNER · "..fmt(data.abilityReadyIn)
 end
end
event.OnClientEvent:Connect(function(data)
 if type(data)=="table" and data.id=="get_out" then current=data render() end
end)
Bridge.Changed:Connect(function()
 local state=Bridge:Get()
 if state and state.mode=="get_out" and state.session then current=state.session end
 render()
end)
Scope.Changed:Connect(render)
render()
