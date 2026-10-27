return function(t)
 local B=require(game.ServerScriptService.Crossgrounds.Ballistics)
 local function fixture(fn)
  local c=Instance.new("Model") local head=Instance.new("Part") head.Name="Head" head.CFrame=CFrame.identity head.Parent=c
  local tool=Instance.new("Tool") tool.Parent=c local h=Instance.new("Part") h.Name="Handle" h.CFrame=CFrame.identity h.Parent=tool
  local muzzle=Instance.new("Attachment") muzzle.Name="Muzzle" muzzle.Position=Vector3.new(0,.4,-1) muzzle.Parent=h
  local ok,err=pcall(fn,c,tool,muzzle) c:Destroy() if not ok then error(err,0) end
 end
 local aim=Vector3.new(0,0,-100) local clear=function() return nil end local classify=function() return "block" end
 t.test("bounded first person muzzle origin is accepted",function()
  fixture(function(c,tool) local wanted=Vector3.new(.5,-.3,-3) local o=B.ResolveOrigin(c,tool,aim,wanted,classify,clear) t.expect.truthy((o-wanted).Magnitude<.001) end)
 end)
 t.test("sideways and distant requests fall back to the real barrel",function()
  fixture(function(c,tool,muzzle) for _,requested in {Vector3.new(20,0,0),Vector3.new(0,0,-20),Vector3.new(0/0,0,0)} do local o=B.ResolveOrigin(c,tool,aim,requested,classify,clear) t.expect.truthy((o-muzzle.WorldPosition).Magnitude<.001) end end)
 end)
 t.test("cover between head and barrel blocks a shot",function()
  fixture(function(c,tool) local wall=Instance.new("Part") local hit={Instance=wall,Position=Vector3.new(0,0,-.5)} local _,blocked=B.ResolveOrigin(c,tool,aim,nil,classify,function() return hit end) t.expect.equal(blocked,hit) wall:Destroy() end)
 end)
 t.test("an allied character between head and muzzle is ignored",function()
  fixture(function(c,tool) local ally=Instance.new("Model") local h=Instance.new("Humanoid") h.Parent=ally local part=Instance.new("Part") part.Parent=ally
   local calls=0 local function cast(_,_,params) calls+=1 for _,ignored in params.FilterDescendantsInstances do if ignored==ally then return nil end end return {Instance=part,Position=Vector3.new(0,0,-.2)} end
   local _,blocked=B.ResolveOrigin(c,tool,aim,nil,function() return "ignore" end,cast) t.expect.equal(blocked,nil) t.expect.equal(calls,2) ally:Destroy()
  end)
 end)
end
