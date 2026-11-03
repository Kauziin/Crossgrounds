local Jump={}
function Jump.Duration(mode)
 return mode=="ctf" and 2 or mode=="arena" and 1 or 0
end
function Jump.Ready(mode,last,now)
 return Jump.Duration(mode)==0 or last==nil or now-last>=Jump.Duration(mode)
end
return table.freeze(Jump)
