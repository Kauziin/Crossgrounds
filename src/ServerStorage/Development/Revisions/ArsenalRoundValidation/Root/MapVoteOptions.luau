local Options={}
function Options.Pick(catalog,limit,rng)
 rng=rng or Random.new() local pool,seen={},{}
 for _,entry in catalog do
  if not seen[entry.id] and entry.id~="outpost" and string.lower(entry.name or "")~="posto" then seen[entry.id]=true table.insert(pool,entry) end
 end
 for i=#pool,2,-1 do local j=rng:NextInteger(1,i) pool[i],pool[j]=pool[j],pool[i] end
 local out={} for i=1,math.min(limit or 4,#pool) do out[i]=pool[i] end return out
end
return Options
