-- Isolated-copy instrumentation only. Never included in the merge bundle.
local review=Instance.new('BindableFunction') review.Name='PistolArtReview' review.Parent=player.PlayerScripts
review.OnInvoke=function(command,target)
 if command=='open' then show(true,'Loadout')
 elseif command=='close' then show(false)
 elseif command=='focus' then Nav:Focus(target)
 elseif command=='activate' then Nav:Focus(target) Nav:Activate()
 elseif command=='custom' then Nav:Focus(target) Nav:ContextAction('custom') end
 return true
end
