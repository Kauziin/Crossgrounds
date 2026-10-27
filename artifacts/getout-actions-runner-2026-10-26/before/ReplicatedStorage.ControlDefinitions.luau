local Controls={}
Controls.Order={"AdminSpeedUp","AdminSpeedDown","AdminPreviousMap","AdminNextMap","AdminClean","AdminMode","Sprint","Perspective","SwitchWeapon","ShiftLock","ReloadInteract","Shoulder","Fire","Aim","Jump","Menu","KitMenu","VoteMenu","Leave"}
Controls.Actions={
 AdminSpeedUp={Label="Admin · Aumentar velocidade",Keyboard="Equals",Gamepad="DPadRight",AdminOnly=true},
 AdminSpeedDown={Label="Admin · Diminuir velocidade",Keyboard="Minus",Gamepad="ButtonR3",AdminOnly=true},
 AdminPreviousMap={Label="Admin · Mapa anterior",Keyboard="PageUp",Gamepad="DPadUp",AdminOnly=true},
 AdminNextMap={Label="Admin · Próximo mapa",Keyboard="PageDown",Gamepad="DPadDown",AdminOnly=true},
 AdminClean={Label="Admin · Captura limpa",Keyboard="F7",Gamepad="ButtonY",AdminOnly=true},
 AdminMode={Label="Modo admin · câmera livre",Gamepad="DPadLeft",Keyboard="F6",AdminOnly=true},
 GetOutCrawl={Label="Get Out · rastejar",Gamepad="ButtonL2",Keyboard="C"},
 GetOutAttack={Label="Get Out · martelo",Gamepad="ButtonR2",Keyboard="MouseButton1"},
 GetOutDrop={Label="Get Out · soltar vítima",Gamepad="ButtonR1",Keyboard="X"},
 GetOutCheck={Label="Get Out · confirmar teste",Gamepad="ButtonA",Keyboard="Space"},
 GetOutHacker={Label="Get Out · Hacker",Gamepad="ButtonY",Keyboard="Q"},
 Sprint={Label="Alternar corrida",Gamepad="ButtonL3",Keyboard="LeftControl"},
 Perspective={Label="Trocar câmera",Gamepad="ButtonR3",Keyboard="V"},
 SwitchWeapon={Label="Trocar arma",Gamepad="ButtonY",Keyboard="G"},
 ShiftLock={Label="Alternar Shift Lock",Gamepad="ButtonL1",Keyboard="LeftShift"},
 ReloadInteract={Label="Recarregar / interagir",Gamepad="ButtonX",Keyboard="R"},
 Shoulder={Label="Trocar ombro",Gamepad="ButtonR1",Keyboard="Q"},
 Fire={Label="Atacar",Gamepad="ButtonR2",Keyboard="MouseButton1"},
 Aim={Label="Mirar",Gamepad="ButtonL2",Keyboard="MouseButton2"},
 Jump={Label="Pular",Gamepad="ButtonA",Keyboard="Space"},
 Menu={Label="Configurações",Gamepad="DPadRight",Keyboard="F2"},
 KitMenu={Label="Seleção de kit",Gamepad="DPadUp",Keyboard="K"},
 VoteMenu={Label="Votação",Gamepad="DPadDown",Keyboard="M"},
 Leave={Label="Voltar ao lobby",Gamepad="ButtonB",Keyboard="L"},
}
for _,action in {"GetOutCrawl","GetOutAttack","GetOutDrop","GetOutCheck","GetOutHacker"} do table.insert(Controls.Order,action) end
-- ButtonSelect is reserved for Roblox UI selection; it did not dispatch Jump in Studio.
Controls.GamepadKeys={"ButtonA","ButtonB","ButtonX","ButtonY","ButtonL1","ButtonR1","ButtonL2","ButtonR2","ButtonL3","ButtonR3","DPadLeft","DPadRight","DPadUp","DPadDown"}
function Controls:Attribute(action,device) return "Bind"..action..device end
function Controls:Conflicts(first,second)
 local adminA=self.Actions[first].AdminOnly local adminB=self.Actions[second].AdminOnly
 if adminA or adminB then
  if first=="AdminMode" or second=="AdminMode" then return true end
  return adminA==true and adminB==true
 end
 local a=first:match("^GetOut")~=nil local b=second:match("^GetOut")~=nil
 local shared={Menu=true,Leave=true,ReloadInteract=true,AdminMode=true}
 return a==b or shared[first]==true or shared[second]==true
end
function Controls:IsAllowed(device,name,action)
 if type(name)~="string" then return false end
 if device=="Gamepad" then return table.find(self.GamepadKeys,name)~=nil end
 if name=="MouseButton1" or name=="MouseButton2" or name=="MouseButton3" then return true end
 local ok,key=pcall(function() return Enum.KeyCode[name] end)
 if not ok or not key or key==Enum.KeyCode.Unknown then return false end
 if name:match("^Button") or name:match("^DPad") or name:match("^Thumbstick") then return false end
 if table.find({"Escape","Tab","One","Two","Backquote","Return"},name) then return false end
 return not table.find({"W","A","S","D"},name) or action~=nil and self.Actions[action]~=nil and self.Actions[action].AdminOnly==true
end
function Controls:Input(name)
 if name:match("^MouseButton") then return Enum.UserInputType[name] end
 return Enum.KeyCode[name]
end
return Controls

