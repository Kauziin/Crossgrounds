return function(t)
 local A=require(game.ServerScriptService.Crossgrounds.PremiumFeatureAccess)
 local testers=require(game.ReplicatedStorage.Crossgrounds.TesterConfiguration)
 t.test("owner and registered testers have paid feature access",function()
  t.expect.truthy(A.IsPrivileged(1248190494))
  for _,id in testers.UserIds do t.expect.truthy(A.Allows({UserId=id},"CustomColor")) end
 end)
 t.test("client role claims do not grant server entitlements",function()
  t.expect.falsy(A.Allows({UserId=123456789,GetAttribute=function()return true end},"CustomColor"))
 end)
end
