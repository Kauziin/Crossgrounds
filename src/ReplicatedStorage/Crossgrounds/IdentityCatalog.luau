local C={}
C.rankStyles={classic={name="Clássico",glyph="✧",color={249,201,83}},astral={name="Astral",glyph="✦",color={190,151,255}},solar={name="Solar",glyph="★",color={255,151,86}}}
C.cards={
 default={name="Primeiros passos",a={12,37,49},b={32,113,126}},
 hunter={name="Na linha de frente",a={43,20,18},b={155,66,38}},
 objective={name="Pelo objetivo",a={14,38,29},b={41,130,83}},
 prestige={name="Novo começo",a={33,24,54},b={112,72,160}},
 mastery={name="Maestria",a={42,32,12},b={185,143,39}},
 legend={name="Lenda",a={42,14,32},b={167,43,110}},
}
C.frames={default={name="Essencial",color={112,166,180}},prestige={name="Prestígio",color={170,126,231}},mastery={name="Maestria",color={249,201,83}},legend={name="Lenda",color={255,115,187}}}
C.emblems={default={name="Recruta",glyph="◆"},prestige={name="Renascido",glyph="✦"},mastery={name="Mestre",glyph="✧"},legend={name="Lenda",glyph="★"}}
C.titles={default={name="Recruta"},hunter={name="Linha de frente"},objective={name="Pelo objetivo"},prestige={name="Renascido"},mastery={name="Mestre"},legend={name="Lenda"}}
C.cards.clan={name="Companheiros",a={18,44,40},b={51,138,110}}
C.frames.clan={name="Companheiros",color={105,224,178}}
C.titles.clan={name="Pilar do clã"}
for id,frame in C.frames do frame.roundness=({default=.12,prestige=0,mastery=.04,legend=.15,clan=0})[id]end
function C.Grant(p)
 local function grant(id,all)
  p.cosmetics.cards[id]=true p.cosmetics.titles[id]=true
  if all then p.cosmetics.frames[id]=true p.cosmetics.emblems[id]=true end
 end
 if (p.stats.Kills or 0)>=100 then grant("hunter") end
 if (p.stats.Captures or 0)>=10 then grant("objective") end
 if p.prestige>=1 then grant("prestige",true) end
 if p.phase=="mastery" or p.phase=="legend" then grant("mastery",true) end
 if p.phase=="legend" then grant("legend",true) end
end
return C
