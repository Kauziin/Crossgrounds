-- Manual, deterministic module contract runner. Never runs at game startup.
local function fmt(v) return type(v)=="string" and string.format("%q",v) or tostring(v) end
local expect={}
function expect.equal(a,b) if a~=b then error("expected "..fmt(b)..", got "..fmt(a),2) end end
function expect.truthy(v) if not v then error("expected truthy, got "..fmt(v),2) end end
function expect.falsy(v) if v then error("expected falsy, got "..fmt(v),2) end end
function expect.throws(fn) local ok,err=pcall(fn) if ok then error("expected an error",2) end return err end
return function(filter,timeout)
 timeout=timeout or 5
 local totals={run=0,passed=0,failed=0,results={}}
 for _,module in script.Parent.Cases:GetDescendants() do
  if module:IsA("ModuleScript") and (not filter or module.Name:find(filter,1,true)) then
   local function record(name,ok,err)
    totals.run+=1
    if ok then totals.passed+=1 else totals.failed+=1 end
    local item={name=module.Name.." > "..name,passed=ok,error=not ok and tostring(err) or nil}
    table.insert(totals.results,item)
    if ok then print("[PASS] "..item.name) else warn("[FAIL] "..item.name.." | "..tostring(err)) end
   end
   local ok,case=pcall(require,module)
   if not ok or type(case)~="function" then record("load",false,case)
   else
    local t={expect=expect}
    function t.test(name,fn)
     local done,pass,err=false,false,nil
     task.spawn(function() pass,err=pcall(fn) done=true end)
     local waited=0 while not done and waited<timeout do waited+=task.wait() end
     record(name,done and pass,done and err or "TIMEOUT")
    end
    local built,err=pcall(case,t) if not built then record("build",false,err) end
   end
  end
 end
 print(string.format("[SUMMARY] %d run, %d passed, %d failed",totals.run,totals.passed,totals.failed))
 return totals
end
