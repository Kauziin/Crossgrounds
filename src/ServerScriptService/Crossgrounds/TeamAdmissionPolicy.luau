local Policy={}
function Policy.Plan(players,sameTeam,teams,counts,capacity)
 if #teams==0 or #players==0 then return nil,"Não há equipes disponíveis." end
 local occupied={} for _,team in teams do occupied[team]=counts[team] or 0 end
 local plan={}
 if sameTeam then
  local chosen
  for _,team in teams do if occupied[team]+#players<=capacity and (not chosen or occupied[team]<occupied[chosen]) then chosen=team end end
  if not chosen then return nil,"Não há vagas na mesma equipe para o grupo. Remova integrantes ou permita dividir os times." end
  for _,p in players do plan[p]=chosen end
 else
  for _,p in players do
   local chosen
   for _,team in teams do if occupied[team]<capacity and (not chosen or occupied[team]<occupied[chosen]) then chosen=team end end
   if not chosen then return nil,"Não há vagas para todos os integrantes nesta partida." end
   plan[p]=chosen occupied[chosen]+=1
  end
 end
 return plan
end
function Policy.PlanBlocks(blocks,teams,capacity)
 local occupied,plan={},{}
 for _,team in teams do occupied[team]=0 end
 local function place(index)
  if index>#blocks then return true end
  local block=blocks[index] local tried={}
  for _,team in teams do
   local count=occupied[team]
   if not tried[count] and count+#block<=capacity then
    tried[count]=true occupied[team]+= #block
    for _,p in block do plan[p]=team end
    if place(index+1) then return true end
    occupied[team]=count for _,p in block do plan[p]=nil end
   end
  end
  return false
 end
 if place(1) then return plan end
 return nil,"Não é possível manter os grupos inteiros nestas equipes."
end
return Policy
