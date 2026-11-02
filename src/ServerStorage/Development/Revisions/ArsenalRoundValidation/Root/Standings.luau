local Standings={}
function Standings.Sort(rows)
 table.sort(rows,function(a,b)
  if a.score~=b.score then return a.score>b.score end
  if a.kills~=b.kills then return a.kills>b.kills end
  if a.deaths~=b.deaths then return a.deaths<b.deaths end
  return a.userId<b.userId
 end)
 for i,row in rows do row.rank=i row.medal=({"gold","silver","bronze"})[i] or "standard" end
 return rows
end
return Standings
