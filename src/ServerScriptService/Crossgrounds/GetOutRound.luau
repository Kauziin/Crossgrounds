--!strict
-- Server-owned Classic round state. Calls to these methods must come from validated world interactions.
local Rules = require(game.ReplicatedStorage.Crossgrounds.GetOutRules)
local Round = {}
Round.__index = Round

function Round.new(roundId, mapId, routeId, routeData, beast, survivors, startedAt)
    assert(typeof(roundId) == "number" and typeof(mapId) == "string")
    assert(Rules.RouteNames[routeId] and routeData and beast and #survivors > 0)
    local status = {}
    for _, player in survivors do
        assert(player ~= beast and not status[player], "Participantes inválidos")
        status[player] = "active"
    end
    return setmetatable({
        id = roundId, mapId = mapId, routeId = routeId, routeData = routeData,
        beast = beast, status = status, phase = "active", startedAt = startedAt,
        completedPCs = {}, computerOrder = {}, openedDoors = {}, solvedPanels = {},
        revealedDigits = {}, vaultCode = nil, vaultBlockedUntil = 0,
        collected = {}, delivered = {}, assembled = false, plantedAt = nil,
        exitReady = false, ending = nil,
    }, Round)
end

function Round:IsActive(player)
    return (self.phase == "active" or self.phase == "enraged") and self.status[player] == "active"
end

function Round:Finish(reason)
    if self.phase == "results" then return false end
    self.phase = "results"
    self.ending = reason
    return true
end

function Round:CheckResolved()
    for _, result in self.status do if result == "active" then return false end end
    return self:Finish("all_survivors_resolved")
end

function Round:Advance(now)
    if self.phase == "results" then return false end
    local elapsed = now - self.startedAt
    if elapsed >= Rules.TotalSeconds then
        for player, result in self.status do
            if result == "active" then self.status[player] = "eliminated_at_timeout" end
        end
        self:Finish("timeout")
        return true
    end
    local changed = false
    if elapsed >= Rules.BaseSeconds and self.phase == "active" then self.phase = "enraged" changed = true end
    if self.routeId == "demolition" and self.plantedAt and not self.exitReady
        and now - self.plantedAt >= Rules.DemolitionFuseSeconds then
        self.exitReady = true
        changed = true
    end
    return changed
end

function Round:CompleteComputer(player, id)
    if not self:IsActive(player) or (self.routeId ~= "locks" and self.routeId ~= "vault_code")
        or not self.routeData.computers[id] or self.completedPCs[id] then return false end
    self.completedPCs[id] = true
    table.insert(self.computerOrder, id)
    if self.routeId == "locks" then
        if self:CompletedComputerCount() == 4 then self.exitReady = true end
    else
        local marker = self.routeData.computers[id]
        local slot, digit = marker:GetAttribute("DigitSlot"), marker:GetAttribute("Digit")
        self.revealedDigits[slot] = digit
        if self:CompletedComputerCount() == 4 then
            local code = ""
            for i = 1, 4 do code ..= tostring(self.revealedDigits[i]) end
            self.vaultCode = code
        end
    end
    return true
end

function Round:RollbackLastComputer()
    -- Prototype Hacker behavior: one completed PC, never after an exit has opened.
    if self.phase == "results" or (self.routeId ~= "locks" and self.routeId ~= "vault_code")
        or next(self.openedDoors) or self.exitReady and self.routeId == "vault_code" then return false end
    local id = table.remove(self.computerOrder)
    if not id then return false end
    self.completedPCs[id] = nil
    self.exitReady = false
    if self.routeId == "vault_code" then
        local slot = self.routeData.computers[id]:GetAttribute("DigitSlot")
        self.revealedDigits[slot] = nil
        self.vaultCode = nil
    end
    return true, id
end

function Round:CompletedComputerCount()
    local n = 0
    for _ in self.completedPCs do n += 1 end
    return n
end

function Round:Crank(player, doorId)
    if not self:IsActive(player) or self.routeId ~= "locks" or not self.exitReady
        or not self.routeData.cranks[doorId] or self.openedDoors[doorId] then return false end
    self.openedDoors[doorId] = true
    return true
end

function Round:TryVault(player, code, now)
    if not self:IsActive(player) or self.routeId ~= "vault_code" or not self.vaultCode
        or typeof(code) ~= "string" or not code:match("^%d%d%d%d$")
        or now < self.vaultBlockedUntil or self.exitReady then return false end
    if code ~= self.vaultCode then
        self.vaultBlockedUntil = now + Rules.VaultLockoutSeconds
        return false, "wrong_code"
    end
    self.exitReady = true
    return true
end

function Round:CompletePanel(player, panelId)
    -- Puzzle proof must be checked by a separate server controller before calling this.
    if not self:IsActive(player) or self.routeId ~= "laser_shutdown"
        or not self.routeData.panels[panelId] or self.solvedPanels[panelId] then return false end
    self.solvedPanels[panelId] = true
    local n = 0
    for _ in self.solvedPanels do n += 1 end
    if n == 4 then self.exitReady = true end
    return true
end

function Round:Collect(player, itemId)
    if not self:IsActive(player) or (self.routeId ~= "thermal_tool" and self.routeId ~= "demolition")
        or not self.routeData.items[itemId] or self.collected[itemId] then return false end
    self.collected[itemId] = player
    return true
end

function Round:Deliver(player, itemId)
    if not self:IsActive(player) or self.collected[itemId] ~= player or self.delivered[itemId] then return false end
    self.delivered[itemId] = true
    return true
end

function Round:Assemble(player, carriersPresent)
    if not self:IsActive(player) or self.assembled or not carriersPresent
        or (self.routeId ~= "thermal_tool" and self.routeId ~= "demolition") then return false end
    for id in self.routeData.items do if not self.delivered[id] then return false end end
    self.assembled = true
    return true
end

function Round:OpenSealedDoor(player, now, hasAssembledItem)
    if not self:IsActive(player) or not self.assembled or not hasAssembledItem or self.exitReady then return false end
    if self.routeId == "thermal_tool" then self.exitReady = true return true end
    if self.routeId == "demolition" and not self.plantedAt then self.plantedAt = now return true end
    return false
end

function Round:CanCross(doorId)
    if not self.routeData.zones[doorId] then return false end
    if self.routeId == "locks" then return self.openedDoors[doorId] == true end
    return self.exitReady
end

function Round:Escape(player, doorId)
    if not self:IsActive(player) or not self:CanCross(doorId) then return false end
    self.status[player] = "escaped"
    self:CheckResolved()
    return true
end

function Round:Capture(player)
    if not self:IsActive(player) then return false end
    self.status[player] = "captured"
    self:CheckResolved()
    return true
end

function Round:Contain(beastInChamber)
    -- The room and trigger are pending design. Only a validated server controller may call this.
    if self.phase ~= "enraged" or beastInChamber ~= true then return false end
    for player, result in self.status do
        if result == "active" then self.status[player] = "beast_contained" end
    end
    self:Finish("beast_contained")
    return true
end

function Round:Disconnect(player)
    if player == self.beast then return self:Finish("technical_beast_departure") end
    if self.status[player] == "active" then self.status[player] = "disconnected" self:CheckResolved() return true end
    return false
end

function Round:Snapshot(player, now)
    local results = {}
    for member, value in self.status do
        local key = member:IsA("Player") and tostring(member.UserId) or tostring(member)
        results[key] = value
    end
    local snapshot = {
        roundId = self.id, mapId = self.mapId, routeId = self.routeId, phase = self.phase,
        remaining = math.max(0, Rules.TotalSeconds - (now - self.startedAt)),
        result = self.status[player], results = results,
        computers = self:CompletedComputerCount(), exitReady = self.exitReady,
        ending = self.ending,
    }
    if self.routeId == "vault_code" then
        snapshot.digits = table.clone(self.revealedDigits)
        snapshot.vaultBlockedFor = math.max(0, self.vaultBlockedUntil - now)
    end
    return snapshot
end

return Round
