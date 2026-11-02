-- Procedural finishes: original geometry/textures, with colors applied per part.
local C={}
C.Items={
 default={name="Original",level=1},
 forest={name="Bosque",level=10,a={67,86,54},b={112,109,73}},
 desert={name="Deserto",level=25,a={179,151,104},b={111,91,64}},
 ocean={name="Oceano",level=40,a={45,108,122},b={37,57,82}},
 gold={name="Ouro",level=55,a={227,185,72},b={142,107,36}},
}
function C.TokenId(weapon,id)return "finish:"..weapon..":"..id end
function C.Parse(value)
 if type(value)~="string"then return end
 local weapon,id=value:match("^finish:([%w_]+):([%w_]+)$")
 if weapon and C.Items[id]and id~="default"then return weapon,id end
end
function C.Allows(profile,weapon,id,mode,level)
 local item=C.Items[id]if not item then return false end
 if id=="default"then return true end
 return profile.permanent[mode]and profile.permanent[mode][C.TokenId(weapon,id)]==true or level>=item.level
end
return C
