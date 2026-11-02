-- Bounded, versioned composition; colors are free RGB, shapes still require ownership.
local F={MaxLayers=4}
local known={default=true,prestige=true,mastery=true,legend=true,clan=true}
function F.Validate(layers,owned)
 if type(layers)~="table"or #layers<1 or #layers>F.MaxLayers then return nil,"Escolha entre 1 e 4 camadas."end
 local count=0 for key in layers do if type(key)~="number"or key%1~=0 or key<1 or key>#layers then return nil,"Ordem de camadas inválida."end count+=1 end
 if count~=#layers then return nil,"Composição incompleta."end
 local result={}
 for _,layer in layers do
  if type(layer)~="table"or type(layer.frame)~="string"or not known[layer.frame]or owned and owned[layer.frame]~=true then return nil,"Moldura não conquistada."end
  local c=layer.color if type(c)~="table"or #c~=3 then return nil,"Cor RGB inválida."end
  for _,v in c do if type(v)~="number"or v~=v or v%1~=0 or v<0 or v>255 then return nil,"RGB deve usar inteiros de 0 a 255."end end
  for key in c do if not table.find({1,2,3},key)then return nil,"Cor RGB inválida."end end
  table.insert(result,{frame=layer.frame,color={c[1],c[2],c[3]}})
 end return result
end
function F.Set(profile,layers)
 local clean,why=F.Validate(layers,profile.cosmetics.frames)if not clean then return false,why end
 profile.frameLayers=clean profile.identity.frame=clean[1].frame return true
end
return F
