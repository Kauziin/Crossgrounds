return function(t)
    local Manifest = require(game.ServerScriptService.Crossgrounds.GetOutManifest)
    local Round = require(game.ServerScriptService.Crossgrounds.GetOutRound)

    local function marker(parent, name, id)
        local p = Instance.new("Part")
        p.Name = name
        if id then p:SetAttribute("ObjectiveId", id) end
        p.Parent = parent
        return p
    end

    local function folder(parent, name, count, prefix)
        local f = Instance.new("Folder") f.Name = name f.Parent = parent
        for i = 1, count do marker(f, prefix .. i, prefix .. i) end
        return f
    end

    local function map()
        local m = Instance.new("Model") m.Name = "GetOutContractQA" m:SetAttribute("Sanitized", true)
        local root = Instance.new("Folder") root.Name = "GetOut" root.Parent = m
        root:SetAttribute("Authored", true) root:SetAttribute("SupportedRoutes", "locks")
        marker(root, "BeastSpawn")
        folder(root, "SurvivorSpawns", 3, "survivor")
        folder(root, "Computers", 4, "pc")
        folder(root, "Locks", 4, "lock")
        folder(root, "ExitDoors", 2, "door")
        folder(root, "ExitZones", 2, "door")
        folder(root, "Cranks", 2, "door")
        folder(root, "FreezePods", 2, "pod")
        folder(root, "ContainmentPanels", 2, "panel")
        marker(root, "ContainmentChamber")
        marker(root, "ContainmentLever")
        marker(root, "ContainmentDoor")
        return m, root
    end

    t.test("map needs an authored and complete route manifest", function()
        local m, root = map()
        local data = Manifest.Read(m)
        t.expect.truthy(data and data.routes.locks)
        root.Cranks:GetChildren()[1]:Destroy()
        t.expect.falsy(Manifest.Read(m))
        m:Destroy()
    end)

    t.test("one eligible route is selected", function()
        local m = map()
        local data = Manifest.Read(m)
        local route = Manifest.Choose(data, Random.new(7), { locks = true })
        t.expect.equal(route, "locks")
        t.expect.falsy(Manifest.Choose(data, Random.new(7), { vault_code = true }))
        m:Destroy()
    end)

    t.test("four unique PCs release locks and each door needs a crank", function()
        local m = map()
        local data = Manifest.Read(m)
        local beast, a, b = Instance.new("Folder"), Instance.new("Folder"), Instance.new("Folder")
        local round = Round.new(1, "test", "locks", data.routes.locks, beast, { a, b }, 100)
        t.expect.falsy(round:Crank(a, "door1"))
        for i = 1, 4 do t.expect.truthy(round:CompleteComputer(a, "pc" .. i)) end
        t.expect.falsy(round:CompleteComputer(a, "pc1"))
        t.expect.truthy(round.exitReady)
        t.expect.falsy(round:Escape(a, "door1"))
        t.expect.truthy(round:Crank(a, "door1"))
        t.expect.truthy(round:Escape(a, "door1"))
        t.expect.equal(round.status[a], "escaped")
        t.expect.falsy(round:Escape(b, "door2"))
        t.expect.truthy(round:Advance(1000))
        t.expect.equal(round.status[a], "escaped")
        t.expect.equal(round.status[b], "eliminated_at_timeout")
        m:Destroy() beast:Destroy() a:Destroy() b:Destroy()
    end)

    t.test("enraged starts at 600 seconds; containment preserves individual results", function()
        local m = map()
        local data = Manifest.Read(m)
        local beast, a, b = Instance.new("Folder"), Instance.new("Folder"), Instance.new("Folder")
        local round = Round.new(2, "test", "locks", data.routes.locks, beast, { a, b }, 100)
        t.expect.falsy(round:Contain(true))
        t.expect.falsy(round:Advance(699))
        t.expect.truthy(round:Advance(700))
        t.expect.equal(round.phase, "enraged")
        t.expect.truthy(round:Capture(a))
        t.expect.truthy(round:Contain(true))
        t.expect.equal(round.status[a], "captured")
        t.expect.equal(round.status[b], "beast_contained")
        m:Destroy() beast:Destroy() a:Destroy() b:Destroy()
    end)

    t.test("prototype Hacker reverses one PC but never closes an opened door", function()
        local m = map()
        local data = Manifest.Read(m)
        local beast, a = Instance.new("Folder"), Instance.new("Folder")
        local round = Round.new(4, "test", "locks", data.routes.locks, beast, { a }, 0)
        for i = 1, 4 do round:CompleteComputer(a, "pc" .. i) end
        local ok, id = round:RollbackLastComputer()
        t.expect.truthy(ok) t.expect.equal(id, "pc4")
        t.expect.equal(round:CompletedComputerCount(), 3)
        t.expect.falsy(round.exitReady)
        round:CompleteComputer(a, "pc4")
        round:Crank(a, "door1")
        t.expect.falsy(round:RollbackLastComputer())
        m:Destroy() beast:Destroy() a:Destroy()
    end)

    t.test("vault rejects early guesses and locks out wrong codes for 30 seconds", function()
        local m, root = map()
        root:SetAttribute("SupportedRoutes", "vault_code")
        root.Cranks:Destroy() root.Locks:Destroy()
        marker(root, "VaultDial")
        for _, p in root.Computers:GetChildren() do
            local i = tonumber(p.Name:match("%d+$"))
            p:SetAttribute("DigitSlot", i) p:SetAttribute("Digit", i)
        end
        local data = Manifest.Read(m)
        local beast, a = Instance.new("Folder"), Instance.new("Folder")
        local round = Round.new(3, "test", "vault_code", data.routes.vault_code, beast, { a }, 0)
        t.expect.falsy(round:TryVault(a, "1234", 1))
        for i = 1, 4 do round:CompleteComputer(a, "pc" .. i) end
        t.expect.equal(round.vaultCode, "1234")
        local ok, reason = round:TryVault(a, "9999", 5)
        t.expect.falsy(ok) t.expect.equal(reason, "wrong_code")
        t.expect.falsy(round:TryVault(a, "1234", 34))
        t.expect.truthy(round:TryVault(a, "1234", 35))
        m:Destroy() beast:Destroy() a:Destroy()
    end)
end
