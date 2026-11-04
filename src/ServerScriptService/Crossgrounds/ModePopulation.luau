local Players = game:GetService("Players")
local MemoryStore = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

local Population = {}
local modes = { "arena", "ctf", "duels", "get_out" }

local function emptyCounts()
    local counts = {}
    for _, mode in modes do counts[mode] = 0 end
    return counts
end

function Population.start(context)
    if RunService:IsStudio() or game.JobId == "" then return end

    local servers = MemoryStore:GetHashMap("CrossgroundsModePopulationServers_v1")
    local shared = MemoryStore:GetHashMap("CrossgroundsModePopulationSummary_v1")
    local job = game.JobId
    local closing = false
    local writing = false

    game:BindToClose(function()
        closing = true
        while writing do task.wait() end
        pcall(servers.RemoveAsync, servers, job)
    end)

    task.spawn(function()
        while not closing do
            local counts = emptyCounts()
            for _, player in Players:GetPlayers() do
                local mode = context:GetMode(player)
                if counts[mode] ~= nil and not player:GetAttribute("CTFPracticeRange") then
                    counts[mode] += 1
                end
            end
            writing = true
            pcall(servers.SetAsync, servers, job, counts, 95)
            writing = false
            task.wait(25 + math.random() * 5)
        end
    end)

    local function refreshSummary()
        local summary = shared:GetAsync("counts")
        if summary and os.time() - summary.updatedAt < 40 then return summary end

        -- One server scans the live entries per refresh window.
        local lease = shared:UpdateAsync("scan", function(current)
            if current then return nil end
            return job
        end, 40)
        if lease ~= job then return summary end

        local started = os.time()
        local totals = emptyCounts()
        local seen = {}
        local pages = servers:ListItemsAsync(100)
        while true do
            for _, entry in pages:GetCurrentPage() do
                if not seen[entry.key] then
                    seen[entry.key] = true
                    for _, mode in modes do
                        totals[mode] += entry.value[mode] or 0
                    end
                end
            end
            if pages.IsFinished then break end
            if closing or os.time() - started >= 35 then return summary end
            pages:AdvanceToNextPageAsync()
        end
        if closing or os.time() - started >= 35 then return summary end

        summary = { counts = totals, updatedAt = os.time() }
        shared:SetAsync("counts", summary, 100)
        return summary
    end

    task.spawn(function()
        local lastSummary
        while not closing do
            local hasLobbyPlayer = false
            for _, player in Players:GetPlayers() do
                if context:GetMode(player) == "hub" then
                    hasLobbyPlayer = true
                    break
                end
            end
            if hasLobbyPlayer then
                local ok, summary = pcall(refreshSummary)
                if ok and summary then lastSummary = summary end
            end
            for _, mode in modes do
                local value = lastSummary and os.time() - lastSummary.updatedAt < 100 and lastSummary.counts[mode] or nil
                workspace:SetAttribute("CrossgroundsGlobalPlayers_" .. mode, value)
            end
            task.wait(15 + math.random() * 5)
        end
    end)
end

return Population
