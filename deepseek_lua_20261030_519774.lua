pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
end)
if getgenv().meoww_loaded then return end
getgenv().meoww_loaded = true

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local VirtualUser       = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")
local workspace         = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")
local localplayer       = Players.LocalPlayer

getgenv().config = {
    nc = false, flyEnabled = false, flySpeed = 50, doubleJumpEnabled = false,
    fakePositionEnabled = false, desyncEnabled = false,
    evasionEnabled = false, evasionIntensity = 3.0,
    blinkEnabled = false, blinkRadius = 80, blinkRate = 60,
    ghostEnabled = false, ghostDistance = 150,
    glideEnabled = false, glideSpeed = 280, glideAccel = 18,
    VoidEnabled = false, voidX = 1e8, voidY = 1e8, voidZ = 1e8,
    voidSpamEnabled = false, voidSpamInterval = 0.016, voidSpamBurst = 5,
    voidSmooth = false, voidSmoothAlpha = 0.5, voidPattern = "random",
    voidAxisX = true, voidAxisY = true, voidAxisZ = true,
    voidXPos = 2500, voidXNeg = 2500, voidYPos = 1500, voidYNeg = 1500, voidZPos = 2500, voidZNeg = 2500,
    orbit = false, orbitSpeed = 90, orbitDistance = 8, orbitHeight = 0,
    wallbangEnabled = false, rapidFire = false, teleportEnemyEnabled = false,
    sling = false, daggerBypass = false, AntiEnemy = false,
    slingRage = false, antiProj = false, fastReload = false, antiClose = false,
    antiAimEnabled = false, pitchAngle = 0, yawAngle = 0, spinEnabled = false,
    underMapEnabled = false, underMapY = -500,
    riotAbuserEnabled = false, riotAbuserDistance = 300, riotAbuserX = 30,
    riotAbuserY = 8, riotAbuserZ = 30, riotAbuserSpin = 720,
    riotBypassEnabled = false, riotBypassDistance = 3, riotBypassHeight = 0,
    riotBypassUpdate = 0.02, riotBypassPosition = "Front",
    antiAfkEnabled = false, autocollectEnabled = false, autocollectRadius = 60,
    returnHomeEnabled = false, homeReturnDelay = 3.0,
    safeZoneEnabled = false, safeZoneY = -10,
    teleportLoopEnabled = false, teleportLoopDelay = 1.5,
    ragebotEnabled = false,
    ragebotAntiKnife = false,
    ragebotVoidSpam = false,
    ragebotVoidHide = 0.69,
    ragebotVoidAttack = 0.01,
    ragebotSwapOnEmpty = false,
    ragebotPriorityWeapon = "primary",
    ragebotSwapWhen = "ammo reserve",
    ragebotAttackMode = "gun",
    ragebotSafeMethod = "random pos",
    ragebotUndergroundDepth = 10,
    ragebotAutoCrouch = false,
    ragebotFfaSmart = false,
    ragebotFfaLowestHealth = true,
    ragebotFfaClosest = false,
}

local ROOT_FOLDER         = "meowwCL"
local PROFILES_FOLDER     = ROOT_FOLDER .. "/profiles"
local GLOBAL_CFG_FILE     = ROOT_FOLDER .. "/global_config.json"
local ACTIVE_PROFILE_FILE = ROOT_FOLDER .. "/active_profile.txt"

pcall(function()
    if not isfolder(ROOT_FOLDER) then pcall(makefolder, ROOT_FOLDER) end
    if not isfolder(PROFILES_FOLDER) then pcall(makefolder, PROFILES_FOLDER) end
end)

local function safeWrite(p, c) return pcall(writefile, p, c) end
local function safeRead(p) local ok, d = pcall(readfile, p); return ok and d or nil end
local function safeDelete(p) pcall(delfile, p) end
local function jsonEncode(t) local ok, s = pcall(function() return HttpService:JSONEncode(t) end) return ok and s or nil end
local function jsonDecode(s) local ok, t = pcall(function() return HttpService:JSONDecode(s) end) return ok and t or nil end
local function profilePath(n) local s = n:gsub("[^%w%-%_ ]", ""):sub(1, 48); return PROFILES_FOLDER .. "/" .. s .. ".json" end
local function listProfiles()
    local names = {}
    local ok, files = pcall(listfiles, PROFILES_FOLDER)
    if not ok or not files then return names end
    for _, p in ipairs(files) do local n = p:match("([^/\\]+)%.json$"); if n then table.insert(names, n) end end
    table.sort(names); return names
end
local function saveProfile(name)
    name = name:match("^%s*(.-)%s*$")
    if name == "" then return false, "Enter profile name" end
    local t = {}; for k, v in pairs(getgenv().config) do t[k] = v end
    local s = jsonEncode(t); if not s then return false, "JSON encode failed" end
    local ok, err = safeWrite(profilePath(name), s); if not ok then return false, tostring(err) end
    safeWrite(ACTIVE_PROFILE_FILE, name)
    return true, "Saved: " .. name
end
local function loadProfile(name)
    local raw = safeRead(profilePath(name)); if not raw then return false, "Not found" end
    local data = jsonDecode(raw); if not data then return false, "Corrupted" end
    for k, v in pairs(data) do
        if getgenv().config[k] ~= nil and type(getgenv().config[k]) == type(v) then getgenv().config[k] = v end
    end
    safeWrite(ACTIVE_PROFILE_FILE, name)
    return true, "Loaded: " .. name
end
local function deleteProfile(name)
    safeDelete(profilePath(name)); return true, "Deleted: " .. name
end
local function saveGlobalConfig()
    local t = {}; for k, v in pairs(getgenv().config) do t[k] = v end
    local s = jsonEncode(t); if s then safeWrite(GLOBAL_CFG_FILE, s) end
end
local function loadGlobalConfig()
    local raw = safeRead(GLOBAL_CFG_FILE); if not raw then return end
    local data = jsonDecode(raw); if not data then return end
    for k, v in pairs(data) do
        if getgenv().config[k] ~= nil and type(getgenv().config[k]) == type(v) then getgenv().config[k] = v end
    end
end

pcall(loadGlobalConfig)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Window = Library:CreateWindow({ Title = "meowwCL Premium", Center = true, AutoShow = true, Resizable = true, MobileButtonsSide = "Right" })
local function Notify(title, desc) Library:Notify({ Title = title, Description = desc, Time = 3 }) end

getgenv().AllConnections   = {}
getgenv().loopWaypoints    = {}
getgenv().loopIndex        = 1
getgenv().homePosition     = nil
getgenv().safeZoneSavedPos = nil

local config = getgenv().config

-- =====================================================================
-- GAME SERVICE RESOLUTION
-- =====================================================================
local gameServices = { ready = false }

pcall(function()
    local modules = replicatedStorage:WaitForChild("Modules", 10)
    if modules then
        local enumMod = modules:FindFirstChild("EnumLibrary") or modules:WaitForChild("EnumLibrary", 5)
        if enumMod then
            gameServices.module = require(enumMod)
            pcall(function() gameServices.module:WaitForEnumBuilder() end)
        end
    end
end)

pcall(function()
    local ps = localplayer:WaitForChild("PlayerScripts", 10)
    if ps then
        local ctrl = ps:FindFirstChild("Controllers") or ps:WaitForChild("Controllers", 5)
        if ctrl then
            local fc = ctrl:FindFirstChild("FighterController")
            local cc = ctrl:FindFirstChild("ControlsController")
            local cam = ctrl:FindFirstChild("CameraController")
            if fc then gameServices.fighterController = require(fc) end
            if cc then gameServices.controlsController = require(cc) end
            if cam then gameServices.cameraController = require(cam) end
        end
    end
end)

pcall(function()
    gameServices.useItem = replicatedStorage:FindFirstChild("UseItem", true)
    gameServices.updateState = replicatedStorage:FindFirstChild("UpdateState", true)
    local rem = replicatedStorage:FindFirstChild("Remotes", true)
    if rem then
        local rep = rem:FindFirstChild("Replication")
        if rep then
            local f = rep:FindFirstChild("Fighter")
            if f then gameServices.updateCamera = f:FindFirstChild("UpdateCameraRotation") end
        end
    end
end)

if gameServices.fighterController then
    local t0 = tick()
    while not gameServices.fighterController.LocalFighter and tick() - t0 < 15 do
        task.wait(0.1)
    end
end

gameServices.ready = (
    gameServices.module ~= nil
    and gameServices.fighterController ~= nil
    and gameServices.useItem ~= nil
    and gameServices.updateCamera ~= nil
)

-- =====================================================================
-- DESYNC
-- =====================================================================
local Desync = {}
Desync.__index = Desync

function Desync.new(root)
    local self = setmetatable({
        root = root, id = HttpService:GenerateGUID(false),
        oldPos = root.CFrame, pos = nil,
    }, Desync)
    RunService:BindToRenderStep(self.id, Enum.RenderPriority.First.Value, function() self:Step() end)
    return self
end
function Desync:Step()
    if self.oldPos and self.root.Parent then self.root.CFrame = self.oldPos end
    self.oldPos = nil
end
function Desync:SetServer(cf) self.pos = cf end
function Desync:GetServer() return self.pos or self.root.CFrame end
function Desync:GetClient() return self.oldPos or self.root.CFrame end
function Desync:Beat()
    if self.pos and self.root.Parent then
        if not self.oldPos then self.oldPos = self.root.CFrame end
        self.root.CFrame = self.pos
    end
end
function Desync:Destroy()
    pcall(function() RunService:UnbindFromRenderStep(self.id) end)
    if self.oldPos and self.root.Parent then pcall(function() self.root.CFrame = self.oldPos end) end
    self.oldPos = nil
end

-- =====================================================================
-- GLUE
-- =====================================================================
local Glue = {}
Glue.__index = Glue
function Glue.new() return setmetatable({ glued = {}, bindings = {} }, Glue) end
function Glue:Setup(part)
    if self.glued[part] then self.glued[part].count += 1; return end
    local weld = part:FindFirstChildOfClass("WeldConstraint")
    local real = nil
    if weld then real = weld.Part1; if real then weld.Part1 = nil end; part.Anchored = true end
    self.glued[part] = { count = 1, weld = weld, real = real }
end
function Glue:Release(part)
    local e = self.glued[part]; if not e then return end
    e.count -= 1; if e.count > 0 then return end
    if e.weld and e.real then e.weld.Part1 = e.real; e.real.Anchored = false end
    self.glued[part] = nil
end
function Glue:Connect(part, target)
    pcall(function()
        local id = getthreadidentity()
        setthreadidentity(8)
        sethiddenproperty(part, "PhysicsRepRootPart", target)
        setthreadidentity(id)
    end)
    local prev = self.bindings[part]
    if prev ~= target then
        if prev then self:Release(prev) end
        self:Setup(target); self.bindings[part] = target
    end
    local far = CFrame.new(1e5, 1e5, 1e5)
    target.CFrame = far
    return far
end
function Glue:Free(part)
    local b = self.bindings[part]; if not b then return end
    self.bindings[part] = nil
    self:Release(b)
    pcall(function()
        local id = getthreadidentity()
        setthreadidentity(8)
        sethiddenproperty(part, "PhysicsRepRootPart", nil)
        setthreadidentity(id)
    end)
end
function Glue:Destroy()
    for _, e in pairs(self.glued) do
        if e.weld and e.real then pcall(function() e.weld.Part1 = e.real; e.real.Anchored = false end) end
    end
    table.clear(self.glued); table.clear(self.bindings)
end

-- =====================================================================
-- CAMERA SUPPRESSOR
-- =====================================================================
local Suppressor = {
    active = false, clientCF = nil, serverCF = nil,
    voidActive = false, randomPos = false, oobCF = nil, repositionCF = nil,
    antiKnifeCF = nil, antiKnifeClientCF = nil, suppressed = false,
    refCamera = gameServices.cameraController and gameServices.cameraController.Update or nil,
    cameraHook = nil, renderHook = nil, mainHook = nil,
}
function Suppressor:Refresh()
    if self.antiKnifeCF or self.repositionCF or self.oobCF or self.voidActive or self.randomPos or self.serverCF then
        self:Start()
    else
        self:Stop()
    end
end
function Suppressor:Start()
    if self.active then return end
    self:Stop(); self.active = true
    if gameServices.cameraController then
        self.cameraHook = function(_, ...)
            local fc = gameServices.fighterController
            local ent = fc and fc.LocalFighter and fc.LocalFighter.Entity
            if ent and ent.RootPart and Suppressor.clientCF then ent.RootPart.CFrame = Suppressor.clientCF end
            if self.refCamera then return self.refCamera(gameServices.cameraController, ...) end
        end
        gameServices.cameraController.Update = self.cameraHook
    end
    self.renderHook = RunService.RenderStepped:Connect(function()
        local fc = gameServices.fighterController
        local ent = fc and fc.LocalFighter and fc.LocalFighter.Entity
        if ent and ent.RootPart and Suppressor.clientCF then ent.RootPart.CFrame = Suppressor.clientCF end
    end)
    self.mainHook = RunService.Heartbeat:Connect(function()
        pcall(function()
            local fc = gameServices.fighterController
            local ent = fc and fc.LocalFighter and fc.LocalFighter.Entity
            if not (ent and ent.RootPart) then Suppressor.clientCF = nil; return end
            local id = getthreadidentity()
            if Suppressor.antiKnifeCF then
                Suppressor.clientCF = Suppressor.antiKnifeClientCF or ent.RootPart.CFrame
                setthreadidentity(8); sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil)
                ent.RootPart.CFrame = Suppressor.antiKnifeCF
                setthreadidentity(id)
            elseif Suppressor.repositionCF and not Suppressor.suppressed then
                Suppressor.clientCF = ent.RootPart.CFrame
                setthreadidentity(8); sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil)
                ent.RootPart.CFrame = Suppressor.repositionCF
                setthreadidentity(id)
            elseif Suppressor.oobCF then
                Suppressor.clientCF = ent.RootPart.CFrame
                setthreadidentity(8); sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil)
                ent.RootPart.CFrame = Suppressor.oobCF
                setthreadidentity(id)
            elseif Suppressor.voidActive then
                Suppressor.clientCF = ent.RootPart.CFrame
                setthreadidentity(8); sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil)
                ent.RootPart.CFrame = CFrame.new(math.random(67108864, 134217728), 0, math.random(67108864, 134217728))
                setthreadidentity(id)
            elseif Suppressor.randomPos then
                Suppressor.clientCF = ent.RootPart.CFrame
                local safe = gameServices.GetRandomSafe and gameServices.GetRandomSafe()
                if safe then
                    setthreadidentity(8); sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil)
                    ent.RootPart.CFrame = safe
                    setthreadidentity(id)
                end
            elseif Suppressor.serverCF then
                Suppressor.clientCF = ent.RootPart.CFrame
                setthreadidentity(8); sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil)
                ent.RootPart.CFrame = Suppressor.serverCF
                setthreadidentity(id)
            else
                Suppressor.clientCF = nil
            end
        end)
    end)
end
function Suppressor:Stop()
    self.active = false
    self.serverCF = nil; self.voidActive = false; self.randomPos = false
    self.oobCF = nil; self.repositionCF = nil; self.antiKnifeCF = nil
    local fc = gameServices.fighterController
    local ent = fc and fc.LocalFighter and fc.LocalFighter.Entity
    if self.clientCF and ent and ent.RootPart then ent.RootPart.CFrame = self.clientCF end
    pcall(function()
        local id = getthreadidentity()
        setthreadidentity(8)
        if ent and ent.RootPart then sethiddenproperty(ent.RootPart, "PhysicsRepRootPart", nil) end
        setthreadidentity(id)
    end)
    self.clientCF = nil
    if self.mainHook then self.mainHook:Disconnect(); self.mainHook = nil end
    if self.renderHook then self.renderHook:Disconnect(); self.renderHook = nil end
    if self.cameraHook and gameServices.cameraController and gameServices.cameraController.Update == self.cameraHook and self.refCamera then
        gameServices.cameraController.Update = self.refCamera
    end
    self.cameraHook = nil
end

-- =====================================================================
-- SAFE POSITION & OOB HELPER
-- =====================================================================
local safeParams = RaycastParams.new()
safeParams.IgnoreWater = true
safeParams.FilterType = Enum.RaycastFilterType.Exclude

function gameServices.GetRandomSafe()
    local fc = gameServices.fighterController
    local ent = fc and fc.LocalFighter and fc.LocalFighter.Entity
    local root = ent and ent.RootPart
    if not root then return nil end
    safeParams.FilterDescendantsInstances = { localplayer.Character }
    local base = root.Position
    for _ = 1, 20 do
        local ang = math.random() * math.pi * 2
        local r = math.random(35, 100)
        local start = base + Vector3.new(math.cos(ang) * r, 50, math.sin(ang) * r)
        local hit = workspace:Raycast(start, Vector3.new(0, -100, 0), safeParams)
        if hit and hit.Instance then
            local dest = hit.Position + Vector3.new(0, 5, 0)
            if not gameServices.IsWithinTaggedParts("OutOfBoundsPart", dest)
                and not gameServices.IsWithinTaggedParts("Barrier", dest) then
                return CFrame.new(dest)
            end
        end
    end
    return nil
end

function gameServices.IsWithinTaggedParts(tag, pos)
    for _, p in collectionService:GetTagged(tag) do
        if p:IsA("BasePart") then
            local lp = p.CFrame:PointToObjectSpace(pos)
            local h = p.Size * 0.5
            if math.abs(lp.X) <= h.X and math.abs(lp.Y) <= h.Y and math.abs(lp.Z) <= h.Z then
                return true
            end
        end
    end
    return false
end

local OobHelper = { Part = nil, Environment = nil, Offset = nil, Next = 0, Origin = nil }
function OobHelper:Env()
    local fc = gameServices.fighterController
    return localplayer:GetAttribute("EnvironmentID") or (fc and fc.LocalFighter and fc.LocalFighter:Get("EnvironmentID"))
end
function OobHelper:Valid(p)
    if not p or not p:IsA("BasePart") or not p:IsDescendantOf(workspace) then return false end
    if not collectionService:HasTag(p, "OutOfBoundsPart") then return false end
    return p:GetAttribute("KillDelay") == 0
end
function OobHelper:Dest(part, origin, off)
    local lp = part.CFrame:PointToObjectSpace(origin)
    local h = part.Size * 0.5
    local xB = math.max(h.X - 2, 0)
    local zB = math.max(h.Z - 1, 0)
    return part.CFrame * CFrame.new(math.clamp(lp.X, -xB, xB), -h.Y + off, math.clamp(lp.Z, -zB, zB))
end
function OobHelper:Find(origin, off)
    local env = self:Env(); local now = os.clock()
    if self.Environment ~= env or self.Offset ~= off then
        self.Part = nil; self.Environment = env; self.Offset = off; self.Next = 0
    end
    if now < self.Next and self.Origin and (origin - self.Origin).Magnitude < 12 then
        if self.Part and self:Valid(self.Part) then return self.Part end
        return nil
    end
    local best, bestD = nil, math.huge
    for _, p in collectionService:GetTagged("OutOfBoundsPart") do
        if self:Valid(p) then
            local eid = p:GetAttribute("EnvironmentID")
            if env == nil or eid == nil or eid == env then
                local d = (self:Dest(p, origin, off).Position - origin).Magnitude
                if d < bestD then bestD = d; best = p end
            end
        end
    end
    self.Part = best; self.Origin = origin; self.Next = now + 0.25
    return self.Part
end
function OobHelper:GetCFrame(cf, off)
    off = math.clamp(tonumber(off) or -5, -10, 10)
    local part = self:Find(cf.Position, off)
    if not part then return nil end
    local d = self:Dest(part, cf.Position, off)
    return cf + d.Position - cf.Position
end

function gameServices.GetUnderground(desync)
    if not desync then return nil end
    local client = desync:GetClient()
    local pos = client.Position
    local depth = math.clamp(config.ragebotUndergroundDepth, 5, 14)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    params.RespectCanCollide = true
    params.FilterDescendantsInstances = { localplayer.Character, workspace.CurrentCamera }
    local hit = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -512, 0), params)
    if not hit then return nil end
    local targetY = math.max(hit.Position.Y - depth, workspace.FallenPartsDestroyHeight + 10)
    if targetY > hit.Position.Y - 5 then return nil end
    return client + Vector3.new(0, targetY - pos.Y, 0)
end

-- =====================================================================
-- ANTI-KNIFE
-- =====================================================================
local AntiKnife = {
    Ping = 0.1, Next = 0, ReleaseAt = 0, Observed = {}, Threats = {},
    Dirs = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1),
        Vector3.new(0,0,-1), Vector3.new(0.707,0,0.707), Vector3.new(-0.707,0,0.707),
        Vector3.new(0.707,0,-0.707), Vector3.new(-0.707,0,-0.707),
    },
}
function AntiKnife:Reset()
    self.Root = nil; self.Position = nil; self.ReleaseAt = 0
    table.clear(self.Observed); table.clear(self.Threats)
    Suppressor.antiKnifeCF = nil; Suppressor:Refresh()
end
function AntiKnife:IsKnife(item)
    if not item then return false end
    local info = item.Info
    if item.Name == "Knife" or (info and info.HeavyAttackReach and info.CriticalDamage) then return true end
    if type(item.Get) == "function" then
        local ok, r = pcall(item.Get, item, "ItemName")
        return ok and r == "Knife"
    end
    return false
end
function AntiKnife:IsNear(t, pos, vel, buf)
    local rp = t.Position - pos
    local rv = t.Velocity - vel
    local d2 = rv:Dot(rv)
    local c = d2 > 0.01 and math.clamp(-rp:Dot(rv) / d2, 0, buf) or 0
    return (rp + rv * c).Magnitude <= t.Reach + 8 + t.Dash
end
function AntiKnife:Clearance(pos, buf)
    local best, bp = math.huge, nil
    for _, t in self.Threats do
        local rp = t.Position - pos
        local v2 = t.Velocity:Dot(t.Velocity)
        local c = v2 > 1 and math.clamp(-rp:Dot(t.Velocity) / v2, 0, buf) or 0
        local d = (rp + t.Velocity * c).Magnitude - t.Reach - 8 - t.Dash
        if d < best then best = d; bp = t.Position end
    end
    return best, bp
end
function AntiKnife:GetRetreat(center, buf)
    local safe = gameServices.GetRandomSafe()
    if safe then
        local c = self:Clearance(safe.Position, buf)
        if c >= 16 then return safe end
    end
    local reach = 48
    for _, t in self.Threats do
        reach = math.max(reach, math.min(t.Reach + t.Dash + t.Velocity.Magnitude * buf + 24, 160))
    end
    local best, bp = -math.huge, nil
    for _, d in self.Dirs do
        local cand = center + d * reach + Vector3.new(0, math.max(8, reach * 0.4), 0)
        local c = self:Clearance(cand, buf)
        if c > best then best = c; bp = cand end
    end
    if not bp then return CFrame.new(center) end
    local _, esc = self:Clearance(bp, buf)
    if esc and (esc - bp).Magnitude > 1 then return CFrame.lookAt(bp, esc) end
    return CFrame.new(bp)
end
function AntiKnife:GetCFrame(target, root, dt)
    if not config.ragebotAntiKnife then
        if self.Root then self:Reset() end
        return nil
    end
    if self.Root ~= root then self:Reset(); self.Root = root end
    local now = tick()
    if self.Next <= now then
        self.Next = now + 0.5
        local ok, p = pcall(localplayer.GetNetworkPing, localplayer)
        if ok and type(p) == "number" and p == p then self.Ping = math.clamp(p, 0, 0.5) end
    end
    local buf = math.clamp(self.Ping * 2 + math.max(dt or 0.016, 0.016) * 2 + 0.15, 0.25, 1.25)
    local client = (target and target.desync and target.desync:GetClient()) or root.CFrame
    local server = (target and target.desync and target.desync:GetServer()) or client
    local threat = false
    table.clear(self.Threats)
    local fc = gameServices.fighterController
    if fc and fc.Objects then
        for _, obj in pairs(fc.Objects) do
            local obs = self.Observed[obj]
            if obj.Player and obj.Player ~= localplayer and obj.Player.Character then
                local item = obj.EquippedItem
                local isK = self:IsKnife(item)
                if not isK and (not obs or now >= obs.Expires) then
                    self.Observed[obj] = nil
                else
                    local ent = obj.Entity
                    local model = ent and ent.Model or obj.Player.Character
                    local rp = ent and ent.RootPart or model and model:FindFirstChild("HumanoidRootPart")
                    local hum = model and model:FindFirstChildOfClass("Humanoid")
                    if not rp or not rp.Parent or not hum or hum.Health <= 0 then
                        self.Observed[obj] = nil
                    else
                        if not obs then
                            obs = { Reach = 7, Dash = 0, Expires = 0 }
                            self.Observed[obj] = obs
                        end
                        if isK then
                            local info = item.Info or {}
                            obs.Reach = math.clamp(math.max(tonumber(info.AttackReach) or 6, tonumber(info.HeavyAttackReach) or 7), 7, 30)
                            obs.Expires = now + math.clamp(tonumber(info.HeavyAttackCooldown) or 1.25, 0.5, 3) + buf
                            local ok, dash = pcall(item.Get, item, "DashOnAim")
                            obs.Dash = ok and dash == true and 25 or 0
                        end
                        local p = rp.Position
                        local v = rp.AssemblyLinearVelocity
                        if v.Magnitude > 200 then v = v.Unit * 200 end
                        obs.Position = p; obs.Velocity = v; obs.Seen = now
                        table.insert(self.Threats, obs)
                        if self:IsNear(obs, client.Position, root.AssemblyLinearVelocity, buf)
                            or self:IsNear(obs, server.Position, Vector3.zero, buf) then
                            threat = true
                        end
                    end
                end
            end
        end
    end
    for k, v in pairs(self.Observed) do if v.Seen ~= now then self.Observed[k] = nil end end
    if threat then
        self.ReleaseAt = now + buf
        if not self.Position or self:Clearance(self.Position.Position, buf) < 12 then
            self.Position = self:GetRetreat(client.Position, buf)
        end
    elseif self.ReleaseAt <= now then
        self.Position = nil
    end
    return self.Position
end

-- =====================================================================
-- RAGEBOT CLASS
-- =====================================================================
local Ragebot = {
    active = false, desync = nil, glue = nil,
    reloadAnims = { "EmptyReload", "EmptyReloadStart", "EmptyReloadSegment", "EmptyReloadFinish", "Reload" },
    timer = tick(), lastFire = 0, wasReloading = false, glued = nil,
    safeMethod = nil, safePosition = nil, currentTarget = nil,
    previousTarget = nil, targetEnv = nil,
    voidPhase = nil, voidEnds = 0, voidCF = nil,
    hitboxWindow = -1, attackCooldown = -1, healingActive = false,
    pendingSlot = nil, pendingAt = 0,
}

function Ragebot:MatchActive()
    local fc = gameServices.fighterController
    if not fc then return false end
    local lf = fc.LocalFighter
    local char = localplayer.Character
    if not lf or not char or lf:Get("IsInDuel") ~= true or not lf:IsActive() then return false end
    local eid = localplayer:GetAttribute("EnvironmentID") or lf:Get("EnvironmentID")
    if eid == nil then return false end
    local cEid = char:GetAttribute("EnvironmentID")
    if cEid ~= nil and cEid ~= eid then return false end
    return true
end

function Ragebot:IsEnemy(player, fighter)
    if not player or player == localplayer or not fighter then return false end
    if not self:MatchActive() then return false end
    local lf = gameServices.fighterController.LocalFighter
    if lf:Get("IsInDuel") ~= true or fighter:Get("IsInDuel") ~= true then return false end
    local eid = localplayer:GetAttribute("EnvironmentID") or lf:Get("EnvironmentID")
    local fEid = player:GetAttribute("EnvironmentID") or fighter:Get("EnvironmentID")
    if not eid or fEid ~= eid then return false end
    local cEid = player.Character and player.Character:GetAttribute("EnvironmentID")
    if cEid ~= nil and cEid ~= eid then return false end
    local tid = localplayer:GetAttribute("TeamID") or lf:Get("TeamID")
    local ftid = player:GetAttribute("TeamID") or fighter:Get("TeamID")
    return lf:Get("TeamkillEnabled") == true or tid == nil or ftid == nil or ftid ~= tid
end

function Ragebot:IsKatanaDeflecting(item)
    if item and item.Name == "Katana" then
        local now = tick()
        return item._attack_cooldown > now and item._deflect_cooldown > now and item._deflect_hash % 2 == 1
    end
    return false
end

function Ragebot:IsFfa()
    local lf = gameServices.fighterController.LocalFighter
    return lf ~= nil and lf:Get("TeamkillEnabled") == true
end

function Ragebot:GetEnemies()
    local out = {}
    local fc = gameServices.fighterController
    if not fc.Objects then return out end
    for _, f in pairs(fc.Objects) do
        local player = f.Player
        local ent = f.Entity
        local model = ent and ent.Model
        if model and self:IsEnemy(player, f) then
            local hh = model:FindFirstChild("HitboxHead")
            local rp = model:FindFirstChild("HumanoidRootPart")
            if hh and rp then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local data = ent and ent.Data
                table.insert(out, {
                    player = player, model = model, hitboxHead = hh, rootPart = rp,
                    fighter = f,
                    alive = hum and hum.Health > 0 or false,
                    health = hum and hum.Health or math.huge,
                    invincible = data and data.IsInvincible == true or false,
                })
            end
        end
    end
    return out
end

function Ragebot:ResetTarget()
    self.currentTarget = nil; self.previousTarget = nil; self.targetEnv = nil
end

function Ragebot:GetTarget()
    local lf = gameServices.fighterController.LocalFighter
    local eid = localplayer:GetAttribute("EnvironmentID") or (lf and lf:Get("EnvironmentID"))
    local smart = config.ragebotFfaSmart and self:IsFfa()
        and (config.ragebotFfaLowestHealth or config.ragebotFfaClosest)
    if self.targetEnv ~= eid then self:ResetTarget(); self.targetEnv = eid end
    local list = {}
    local hrp = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
    for _, e in self:GetEnemies() do
        if e.alive and not e.invincible and not self:IsKatanaDeflecting(e.fighter and e.fighter.EquippedItem) then
            e.distance = hrp and (e.rootPart.Position - hrp.Position).Magnitude or math.huge
            table.insert(list, e)
        end
    end
    table.sort(list, function(a, b)
        if smart then
            if config.ragebotFfaLowestHealth and a.health ~= b.health then return a.health < b.health end
            if config.ragebotFfaClosest and a.distance ~= b.distance then return a.distance < b.distance end
        end
        return a.player.UserId < b.player.UserId
    end)
    if self.currentTarget then
        for _, e in list do if e.player == self.currentTarget then return e end end
        self.previousTarget = self.currentTarget
        self.currentTarget = nil
    end
    local chosen
    if smart then chosen = list[1]
    else
        for _, e in list do if e.player ~= self.previousTarget then chosen = e; break end end
    end
    chosen = chosen or list[1]
    if chosen then self.currentTarget = chosen.player end
    return chosen
end

function Ragebot:IsAbove(fighter)
    local item = fighter and fighter.EquippedItem
    if not item then return nil end
    local ok, res = pcall(function()
        if item.Name == "Katana" then
            local x = math.deg(fighter:GetCameraRotation().X)
            if x > 22 and x < 91 then return false end
            return true
        end
        for _, it in pairs(fighter.Items) do
            if it.Name == "Riot Shield" then
                local x = math.deg(fighter:GetCameraRotation().X)
                if (x > 315 and x < 360) or (x > 0 and x < 91) then return true end
                return false
            end
        end
        return nil
    end)
    return ok and res or nil
end

function Ragebot:TargetHasKnife(fighter)
    if not fighter or not fighter.EquippedItem then return false end
    local ok, r = pcall(function() return fighter.EquippedItem.Name == "Knife" end)
    return ok and r == true
end

function Ragebot:RepositionCFrame()
    if not self.desync then return nil end
    return OobHelper:GetCFrame(self.desync:GetClient(), -5)
end

function Ragebot:ClearSafe()
    self.safeMethod = nil; self.safePosition = nil
end

function Ragebot:SetSafe(method)
    self:ReleaseGlue()
    if not self.desync then return end
    if config.ragebotVoidSpam and self.voidPhase == "hide" then
        local cf = self.voidCF or CFrame.new(math.random(67108864, 134217728), 0, math.random(67108864, 134217728))
        self.safeMethod = "void spam"; self.safePosition = cf
        self.desync:SetServer(cf); return
    end
    local rep = self:RepositionCFrame()
    if rep then self.safeMethod = "reposition"; self.safePosition = rep; self.desync:SetServer(rep); return end
    if method == "underground" then
        local ug = gameServices.GetUnderground(self.desync)
        if ug then self.safeMethod = "underground"; self.safePosition = ug; self.desync:SetServer(ug); return end
    end
    if method == "random pos" then
        local safe = gameServices.GetRandomSafe()
        if safe then self.safeMethod = "random pos"; self.safePosition = safe; self.desync:SetServer(safe); return end
    end
    self.safeMethod = "void"; self.safePosition = nil
    self.desync:SetServer(CFrame.new(math.random(67108864, 134217728), 0, math.random(67108864, 134217728)))
end

function Ragebot:ReleaseGlue()
    if self.glued then self.glue:Free(self.glued); self.glued = nil end
end

function Ragebot:ResetVoidSpam()
    self.voidPhase = nil; self.voidEnds = 0; self.voidCF = nil
end

function Ragebot:UpdateVoidSpam(now)
    if not config.ragebotVoidSpam then self:ResetVoidSpam(); return false end
    if not self.voidPhase then
        self.voidPhase = "hide"
        self.voidEnds = now + math.clamp(config.ragebotVoidHide, 0.05, 5)
        self.voidCF = CFrame.new(math.random(67108864, 134217728), 0, math.random(67108864, 134217728))
    elseif now >= self.voidEnds then
        if self.voidPhase == "hide" then
            self.voidPhase = "attack"
            self.voidEnds = now + math.clamp(config.ragebotVoidAttack, 0.01, 2)
        else
            self.voidPhase = "hide"
            self.voidEnds = now + math.clamp(config.ragebotVoidHide, 0.05, 5)
            self.voidCF = CFrame.new(math.random(67108864, 134217728), 0, math.random(67108864, 134217728))
        end
    end
    return self.voidPhase == "hide"
end

function Ragebot:IsReloading(fighter)
    local item = (fighter or gameServices.fighterController.LocalFighter).EquippedItem
    if not item or not item.ViewModel then return false end
    for _, a in ipairs(self.reloadAnims) do
        if item.ViewModel:IsAnimationPlaying(a) then return true end
    end
    return false
end

function Ragebot:GetAmmo(item)
    if not item then return 0, 0 end
    return item:Get("Ammo") or 0, item:Get("AmmoReserve") or 0
end

function Ragebot:ItemBySlot(fighter, slot)
    for _, it in pairs(fighter.Items) do
        if it and (it:Get("ItemIndex") or (it.Data and it.Data.ItemIndex)) == slot then return it end
    end
    return nil
end

function Ragebot:DesiredSlot(fighter)
    local pri = config.ragebotPriorityWeapon == "secondary" and 2 or 1
    local other = pri == 1 and 2 or 1
    local a = self:ItemBySlot(fighter, pri)
    local b = self:ItemBySlot(fighter, other)
    local aA, aR = self:GetAmmo(a)
    local bA, bR = self:GetAmmo(b)
    if aA <= 0 and aR <= 0 and bA <= 0 and bR <= 0 then return 3 end
    if aA > 0 or aR > 0 then
        if aA <= 0 and config.ragebotSwapWhen ~= "ammo reserve" and bA > 0 then return other end
        return pri
    end
    if bA > 0 or bR > 0 then return other end
    return pri
end

function Ragebot:Equip(fighter, slot)
    local now = os.clock()
    if self.pendingSlot == slot and now - self.pendingAt < 0.35 then return end
    self.pendingSlot = slot; self.pendingAt = now
    fighter:EquipItem(slot)
end

function Ragebot:Reload(item)
    if not item or not item.ViewModel or item.ViewModel:IsAnimationPlaying("Reload") then return end
    local id = getthreadidentity()
    setthreadidentity(2)
    pcall(item.Input, item, "StartReloading")
    setthreadidentity(id)
end

function Ragebot:FireGun(target, item, objectId, above)
    local lf = gameServices.fighterController.LocalFighter
    local ent = lf and lf.Entity
    local root = self.desync and self.desync:GetServer() or (ent and ent.RootPart and ent.RootPart.CFrame)
    if not root or not gameServices.module then return end
    local _, ry, rz = root:ToOrientation()
    local pitch = above and -math.pi/2 or math.pi/2
    local camRot = {
        [utf8.char(0)] = -9e37, [utf8.char(1)] = 0, [utf8.char(2)] = 0,
        [utf8.char(3)] = pitch, [utf8.char(4)] = ry, [utf8.char(5)] = rz,
    }
    local args = {
        [utf8.char(0)] = camRot,
        [utf8.char(1)] = target.hitboxHead,
        [utf8.char(2)] = target.hitboxHead,
        [utf8.char(3)] = { [utf8.char(0)] = 0, [utf8.char(1)] = 1, [utf8.char(2)] = 0,
                           [utf8.char(3)] = 0, [utf8.char(4)] = 0, [utf8.char(5)] = 0 },
    }
    if config.ragebotAutoCrouch and gameServices.updateState then
        pcall(function() gameServices.updateState:FireServer(gameServices.module:ToEnum("IsCrouching"), true, nil) end)
    end
    gameServices.useItem:FireServer(objectId, gameServices.module:ToEnum("StartShooting"),
        { [utf8.char(1)] = args, [utf8.char(2)] = true }, nil)
end

function Ragebot:FireMelee(target, item, objectId, above)
    if not gameServices.module then return end
    local lf = gameServices.fighterController.LocalFighter
    local ent = lf and lf.Entity
    local root = self.desync and self.desync:GetServer() or (ent and ent.RootPart and ent.RootPart.CFrame)
    if not root then return end
    local _, ry, rz = root:ToOrientation()
    local pitch = above and -math.pi/2 or math.pi/2
    local camRot = { [utf8.char(0)] = -9e37, [utf8.char(1)] = 0, [utf8.char(2)] = 0,
                     [utf8.char(3)] = pitch, [utf8.char(4)] = ry, [utf8.char(5)] = rz }
    local args = {
        [utf8.char(0)] = camRot,
        [utf8.char(1)] = target.hitboxHead,
        [utf8.char(2)] = target.hitboxHead,
        [utf8.char(3)] = { [utf8.char(0)] = 0, [utf8.char(1)] = 1, [utf8.char(2)] = 0,
                           [utf8.char(3)] = 0, [utf8.char(4)] = 0, [utf8.char(5)] = 0 },
    }
    local now = os.clock()
    if now < self.hitboxWindow and item.Name == "Knife" then
        if config.ragebotAutoCrouch and gameServices.updateState then
            pcall(function() gameServices.updateState:FireServer(gameServices.module:ToEnum("IsCrouching"), true, nil) end)
        end
        gameServices.useItem:FireServer(objectId, gameServices.module:ToEnum("StartAiming"),
            { [utf8.char(1)] = args, [utf8.char(2)] = gameServices.module:ToEnum("HeavyAttack1") }, nil)
        return
    end
    if now < self.attackCooldown then return end
    if item.Name == "Knife" then
        self.hitboxWindow = now + 0.625
        self.attackCooldown = now + 1.25
        if config.ragebotAutoCrouch and gameServices.updateState then
            pcall(function() gameServices.updateState:FireServer(gameServices.module:ToEnum("IsCrouching"), true, nil) end)
        end
        gameServices.useItem:FireServer(objectId, gameServices.module:ToEnum("StartAiming"),
            { [utf8.char(1)] = args, [utf8.char(2)] = gameServices.module:ToEnum("HeavyAttack1") }, nil)
    else
        if config.ragebotAutoCrouch and gameServices.updateState then
            pcall(function() gameServices.updateState:FireServer(gameServices.module:ToEnum("IsCrouching"), true, nil) end)
        end
        gameServices.useItem:FireServer(objectId, gameServices.module:ToEnum("StartShooting"),
            { [utf8.char(1)] = args }, nil)
    end
end

function Ragebot:Sync()
    AntiKnife:Reset(); self:ClearSafe()
    if self.desync then self.desync:Destroy(); self.desync = nil end
    self.hitboxWindow = -1; self.attackCooldown = -1
    Suppressor:Stop()
end

function Ragebot:Stop()
    self.active = false
    if self.connection then self.connection:Disconnect(); self.connection = nil end
    self:ReleaseGlue(); self:Sync(); self:ResetTarget()
    if self.glue then self.glue:Destroy() end
    Suppressor:Stop()
    getgenv().RagebotStatus = "idle"
end

function Ragebot:Start()
    if self.active then return end
    if not gameServices.ready then
        Notify("Ragebot", "Game services not ready (need Elisium/Rivals).")
        config.ragebotEnabled = false
        return
    end
    self.active = true
    self.glue = Glue.new()
    self.timer = tick()
    self:ResetTarget()
    getgenv().RagebotStatus = "starting"

    self.connection = RunService.Heartbeat:Connect(function(dt)
        if self.desync then self.desync:Step() end
        local ok, err = pcall(function()
            if not config.ragebotEnabled then
                self:ResetVoidSpam(); self:ReleaseGlue(); self:Sync(); self:ResetTarget()
                getgenv().RagebotStatus = "idle"
                return
            end
            if not self:MatchActive() then
                self:ResetVoidSpam(); self:ReleaseGlue(); self:Sync(); self:ResetTarget()
                getgenv().RagebotStatus = "lobby"
                return
            end
            local char = localplayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then
                self:ResetVoidSpam(); self:ReleaseGlue(); self:Sync()
                getgenv().RagebotStatus = "dead"
                return
            end
            if self.rootPart ~= hrp then
                self:ReleaseGlue(); self:Sync()
                self.rootPart = hrp
                self.desync = Desync.new(hrp)
            end
            local now = os.clock()
            local hiding = self:UpdateVoidSpam(now)
            local target = self:GetTarget()

            if target then
                local retreat = AntiKnife:GetCFrame(target, hrp, dt)
                if retreat then
                    self:ReleaseGlue(); self:ClearSafe()
                    self.desync:SetServer(retreat)
                    Suppressor.antiKnifeCF = retreat
                    Suppressor.antiKnifeClientCF = self.desync:GetClient()
                    Suppressor:Refresh()
                    getgenv().RagebotStatus = "anti-knife"
                    return
                else
                    Suppressor.antiKnifeCF = nil
                    Suppressor:Refresh()
                end
            end

            if not target then
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "no target"
                return
            end

            local lf = gameServices.fighterController.LocalFighter
            local equipped = lf and lf.EquippedItem
            if not lf or not lf:IsActive() then
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "no weapon"
                return
            end

            if equipped and self:IsKatanaDeflecting(equipped) then
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "deflecting"
                return
            end

            if hum.Health < 60 and not self.healingActive then
                local medkit
                for _, it in pairs(lf.Items) do
                    if it:Get("ItemIndex") == 4 and (it.Name == "Medkit" or it:Get("ItemName") == "Medkit") then
                        medkit = it; break
                    end
                end
                if medkit and tick() > (medkit._use_cooldown or 0) and not medkit._is_using then
                    self.healingActive = true
                end
            end
            if self.healingActive then
                local medkit
                for _, it in pairs(lf.Items) do
                    if it:Get("ItemIndex") == 4 and (it.Name == "Medkit" or it:Get("ItemName") == "Medkit") then
                        medkit = it; break
                    end
                end
                if not medkit or hum.Health > 60 then
                    self.healingActive = false
                else
                    self:SetSafe(config.ragebotSafeMethod)
                    if lf.EquippedItem ~= medkit then lf:EquipItem(4) end
                    if lf.EquippedItem == medkit and tick() > (medkit._use_cooldown or 0) and not medkit._is_using then
                        local id = getthreadidentity(); setthreadidentity(2)
                        pcall(medkit.Input, medkit, "StartShooting")
                        setthreadidentity(id)
                    end
                    getgenv().RagebotStatus = "healing"
                    return
                end
            end

            local mode = config.ragebotAttackMode
            local index = equipped:Get("ItemIndex") or -1
            if mode == "melee" then
                if index ~= 3 then
                    self:SetSafe(config.ragebotSafeMethod)
                    lf:EquipItem(3)
                    getgenv().RagebotStatus = "swapping"
                    return
                end
            else
                local desired = config.ragebotSwapOnEmpty and self:DesiredSlot(lf)
                    or (config.ragebotPriorityWeapon == "secondary" and 2 or 1)
                if index ~= desired then
                    self:SetSafe(config.ragebotSafeMethod)
                    self:Equip(lf, desired)
                    getgenv().RagebotStatus = "swapping"
                    return
                end
                if desired == 3 then mode = "melee" end
            end

            if self:IsReloading(lf) then
                self.wasReloading = true
                self.timer = tick() + 0.3
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "reloading"
                return
            end
            if self.wasReloading then
                self.wasReloading = false
                self.timer = tick() + 0.3
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "waiting"
                return
            end
            local ammo, reserve = self:GetAmmo(equipped)
            if mode == "gun" and ammo <= 0 and reserve > 0 then
                self:Reload(equipped); self.wasReloading = true
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "reloading"
                return
            end
            if mode == "gun" and ammo <= 0 then
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "out of ammo"
                return
            end
            if tick() < self.timer then
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "waiting"
                return
            end
            if hiding then
                self:SetSafe(config.ragebotSafeMethod)
                getgenv().RagebotStatus = "void hiding"
                return
            end

            local above = self:IsAbove(target.fighter) == true
            local rep = OobHelper:GetCFrame(self.desync:GetClient(), -5)
            local serverCF
            if rep then
                self:ReleaseGlue()
                serverCF = rep
            else
                local conn = self.glue:Connect(hrp, target.hitboxHead)
                self.glued = hrp
                local offset = above and Vector3.new(0, -0.7, 0.05) or Vector3.new(0, -3.85, 0.05)
                if mode == "melee" and equipped.Name == "Knife" and now < (self.knifeAbove or 0) then
                    serverCF = conn * CFrame.new(0, 5, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                elseif self:TargetHasKnife(target.fighter) then
                    serverCF = conn * CFrame.new(0, 5, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                elseif above then
                    serverCF = conn + offset
                else
                    serverCF = CFrame.new(conn.Position + offset, target.hitboxHead.Position)
                end
            end
            self:ClearSafe()
            self.desync:SetServer(serverCF)

            if not (os.clock() - self.lastFire < 0.001) then
                self.lastFire = os.clock()
                local objectId = equipped:Get("ObjectID")
                if not objectId then return end
                local name = target.player and target.player.Name or "enemy"
                if mode == "melee" or (equipped.Info and equipped.Info.Type == "Melee") then
                    getgenv().RagebotStatus = "hitting " .. name
                    self:FireMelee(target, equipped, objectId, above)
                else
                    getgenv().RagebotStatus = "killing " .. name
                    self:FireGun(target, equipped, objectId, above)
                end
            end
        end)
        if not ok then
            warn("[Ragebot] " .. tostring(err))
            pcall(function() self:ReleaseGlue() end)
        end
        if self.desync then pcall(function() self.desync:Beat() end) end
    end)
end

-- =====================================================================
-- MEOWWCL MOVEMENT & UTILITY FUNCTIONS
-- =====================================================================
local function getHrp()
    return localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
end
local function getClosest()
    local closest, minD = nil, math.huge
    local hrp = getHrp()
    if not hrp then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localplayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < minD then minD = d; closest = p end
                end
            end
        end
    end
    return closest
end
local function safeTeleport(pos)
    local hrp = getHrp()
    if not hrp then return end
    local x, y, z = pos.X, pos.Y, pos.Z
    y = math.clamp(y, 2, hrp.Position.Y + 800)
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = { localplayer.Character }
    local hit = workspace:Raycast(Vector3.new(x, y + 60, z), Vector3.new(0, -220, 0), p)
    if hit then y = math.max(hit.Position.Y + 3, 2) end
    hrp.CFrame = CFrame.new(x, y, z)
end

-- Safe __namecall hook for Dagger Bypass
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and config.daggerBypass and method == "FireServer" then
        local ok, n = pcall(function() return self.Name:lower() end)
        if ok and n then
            if n:find("dagger") or n:find("knife") or n:find("throw") or n:find("blade") then
                local args = { ... }
                local argStr = ""
                for _, v in ipairs(args) do
                    if type(v) == "string" then
                        argStr = argStr .. v .. " "
                    end
                end
                argStr = argStr:lower()
                if not (argStr:find(localplayer.Name:lower()) or argStr:find("owner")) then
                    return
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

UserInputService.JumpRequest:Connect(function()
    if config.doubleJumpEnabled then
        local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local flyConn
getgenv().startFly = function()
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.Heartbeat:Connect(function(dt)
        local hrp = getHrp()
        if not hrp or not config.flyEnabled then return end
        local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
        local cam = workspace.CurrentCamera
        local mv = Vector3.zero
        if hum and hum.MoveDirection.Magnitude > 0 then
            local flat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            mv = flat.Magnitude > 0.001 and
                Vector3.new(hum.MoveDirection.X, cam.CFrame.LookVector.Y * hum.MoveDirection:Dot(flat.Unit), hum.MoveDirection.Z)
                or Vector3.new(hum.MoveDirection.X, cam.CFrame.LookVector.Y, hum.MoveDirection.Z)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0, 1, 0) end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if mv.Magnitude > 0 then hrp.CFrame = hrp.CFrame + mv.Unit * (config.flySpeed * dt) end
    end)
end
getgenv().stopFly = function()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local hrp = getHrp()
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end
    local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

getgenv().startWallbang = function()
    RunService:BindToRenderStep("WbAim", Enum.RenderPriority.Camera.Value + 1, function()
        if not config.wallbangEnabled then return end
        local cl = getClosest(); local hrp = getHrp()
        local char = localplayer.Character
        if cl and cl.Character and cl.Character:FindFirstChild("Head") and hrp and char then
            local head = cl.Character.Head
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, head.Position)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end
    end)
end
getgenv().stopWallbang = function() RunService:UnbindFromRenderStep("WbAim") end

local rapidFireConn
getgenv().startRapidFire = function()
    if rapidFireConn then rapidFireConn:Disconnect() end
    rapidFireConn = RunService.Heartbeat:Connect(function()
        if not config.rapidFire then return end
        local tool = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end)
end
getgenv().stopRapidFire = function() if rapidFireConn then rapidFireConn:Disconnect(); rapidFireConn = nil end end

local tpConn
getgenv().startTp = function()
    if tpConn then tpConn:Disconnect() end
    tpConn = RunService.Heartbeat:Connect(function()
        if not config.teleportEnemyEnabled then return end
        local t = getClosest()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and getHrp() then
            getHrp().CFrame = CFrame.new(t.Character.HumanoidRootPart.Position + Vector3.new(0, 3.5, 0))
        end
    end)
end
getgenv().stopTp = function() if tpConn then tpConn:Disconnect(); tpConn = nil end end

local antiAfkConn
getgenv().startAntiAfk = function()
    if antiAfkConn then antiAfkConn:Disconnect() end
    antiAfkConn = localplayer.Idled:Connect(function()
        if not config.antiAfkEnabled then return end
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end
getgenv().stopAntiAfk = function() if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end end

table.insert(getgenv().AllConnections, RunService.Stepped:Connect(function()
    if config.nc and localplayer.Character then
        for _, p in ipairs(localplayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))
table.insert(getgenv().AllConnections, RunService.Heartbeat:Connect(function()
    local hrp = getHrp()
    if not hrp then return end
    if config.antiAimEnabled then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(config.pitchAngle), math.rad(config.yawAngle), 0)
    end
    if config.spinEnabled then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        hrp.AssemblyLinearVelocity = Vector3.new(math.random(-200, 200), 250, math.random(-200, 200)) * 45
    end
end))

-- Placeholders for unused toggles
for _, f in ipairs({"startFakePosition","stopFakePosition","startDesync","stopDesync","startVoid","stopVoid",
                    "startVoidSpam","stopVoidSpam","startOrbit","stopOrbit","startEvasion","stopEvasion",
                    "startBlink","stopBlink","startGhost","stopGhost","startGlide","stopGlide",
                    "startRiotAbuser","stopRiotAbuser","startRiotBypass","stopRiotBypass",
                    "startSlingRage","stopSlingRage","startAntiProj","stopAntiProj",
                    "startAntiClose","stopAntiClose","startFastReload","stopFastReload",
                    "startAutocollect","stopAutocollect","startReturnHome","stopReturnHome",
                    "startSafeZone","stopSafeZone","startTeleportLoop","stopTeleportLoop",
                    "startUnderMap","stopUnderMap"}) do
    getgenv()[f] = function() end
end

-- =====================================================================
-- UI
-- =====================================================================
local function Tgl(box, id, txt, desc, cb)
    box:AddToggle(id, { Text = txt, Default = false, Callback = function(v) if v then Notify(txt, desc) end cb(v) end })
end

local MainTab     = Window:AddTab("Main")
local CombatTab   = Window:AddTab("Combat")
local MovementTab = Window:AddTab("Movement")
local RagebotTab  = Window:AddTab("Ragebot")
local MiscTab     = Window:AddTab("Utilities")
local SettingsTab = Window:AddTab("Settings")

local MoveBox = MainTab:AddLeftGroupbox("Movement")
Tgl(MoveBox, "FlyMode", "Fly", "Camera-directed flight", function(v) config.flyEnabled = v if v then startFly() else stopFly() end end)
MoveBox:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 50, Min = 1, Max = 2000, Rounding = 0, Callback = function(v) config.flySpeed = v end })
Tgl(MoveBox, "Noclip", "Noclip", "Walk through walls", function(v) config.nc = v end)
Tgl(MoveBox, "DoubleJump", "Double Jump", "Infinite mid-air jumps", function(v) config.doubleJumpEnabled = v end)

local CombatBox = MainTab:AddRightGroupbox("Combat")
Tgl(CombatBox, "Wallbang", "Wallbang Aim", "Lock + auto-shoot", function(v) config.wallbangEnabled = v if v then startWallbang() else stopWallbang() end end)
Tgl(CombatBox, "RapidFire", "Rapid Fire", "Spams tool activation", function(v) config.rapidFire = v if v then startRapidFire() else stopRapidFire() end end)
Tgl(CombatBox, "TpEnemy", "Teleport to Enemy", "TP on top of enemy", function(v) config.teleportEnemyEnabled = v if v then startTp() else stopTp() end end)
Tgl(CombatBox, "DaggerBypass", "Dagger Bypass", "Blocks incoming daggers", function(v) config.daggerBypass = v end)

local AntiBox = CombatTab:AddLeftGroupbox("Anti-Aim")
Tgl(AntiBox, "AntiAim", "Anti Aim", "Alters orientation", function(v) config.antiAimEnabled = v end)
AntiBox:AddSlider("PitchShift", { Text = "Pitch Shift", Default = 0, Min = -180, Max = 180, Rounding = 0, Callback = function(v) config.pitchAngle = v end })
AntiBox:AddSlider("YawShift", { Text = "Yaw Shift", Default = 0, Min = -180, Max = 180, Rounding = 0, Callback = function(v) config.yawAngle = v end })
Tgl(AntiBox, "SpinBypass", "Spin Bypass", "Spins rapidly", function(v) config.spinEnabled = v end)

local RageMain = RagebotTab:AddLeftGroupbox("Ragebot")
Tgl(RageMain, "RagebotEnabled", "Enable Ragebot", "Desync + glue aimbot", function(v)
    config.ragebotEnabled = v
    if v then Ragebot:Start() else Ragebot:Stop() end
end)

RageMain:AddDropdown("RagebotAttackMode", { Text = "Attack Mode", Default = "gun", Values = { "gun", "melee" }, Callback = function(v) config.ragebotAttackMode = v end })
RageMain:AddDropdown("RagebotSafeMethod", { Text = "Safe Method", Default = "random pos", Values = { "void", "random pos", "underground" }, Callback = function(v) config.ragebotSafeMethod = v; Ragebot:ClearSafe() end })
RageMain:AddSlider("RagebotUndergroundDepth", { Text = "Underground Depth", Default = 10, Min = 5, Max = 14, Rounding = 0, Callback = function(v) config.ragebotUndergroundDepth = v end })
local statusLabel = RageMain:AddLabel("Status: idle")

task.spawn(function()
    while task.wait(0.25) do
        if statusLabel then
            pcall(function() statusLabel:SetText("Status: " .. tostring(getgenv().RagebotStatus or "idle")) end)
        end
    end
end)

local RageCombat = RagebotTab:AddLeftGroupbox("Weapon Cycling")
Tgl(RageCombat, "RageSwapOnEmpty", "Swap On Empty", "Cycle on ammo low", function(v) config.ragebotSwapOnEmpty = v end)
RageCombat:AddDropdown("RagePriorityWeapon", { Text = "Priority", Default = "primary", Values = { "primary", "secondary" }, Callback = function(v) config.ragebotPriorityWeapon = v end })
RageCombat:AddDropdown("RageSwapWhen", { Text = "Swap When", Default = "ammo reserve", Values = { "ammo", "ammo reserve" }, Callback = function(v) config.ragebotSwapWhen = v end })
Tgl(RageCombat, "RageAutoCrouch", "Auto Crouch", "Crouch on every shot", function(v) config.ragebotAutoCrouch = v end)

local RageAnti = RagebotTab:AddRightGroupbox("Anti-Knife")
Tgl(RageAnti, "RageAntiKnife", "Anti Knife", "Retreat from knife threats", function(v) config.ragebotAntiKnife = v; if not v then AntiKnife:Reset() end end)

local RageVoid = RagebotTab:AddRightGroupbox("Void Spam")
Tgl(RageVoid, "RageVoidSpam", "Void Spam", "Alternate hide/attack", function(v) config.ragebotVoidSpam = v; if not v then Ragebot:ResetVoidSpam() end end)
RageVoid:AddSlider("RageVoidHide", { Text = "Hide Seconds", Default = 69, Min = 5, Max = 500, Rounding = 0, Callback = function(v) config.ragebotVoidHide = v / 100 end })
RageVoid:AddSlider("RageVoidAttack", { Text = "Attack Seconds", Default = 1, Min = 1, Max = 200, Rounding = 0, Callback = function(v) config.ragebotVoidAttack = v / 100 end })

local RageFfa = RagebotTab:AddRightGroupbox("FFA Targeting")
Tgl(RageFfa, "RageFfaSmart", "Smart Targeting", "Enable FFA priority", function(v) config.ragebotFfaSmart = v end)
RageFfa:AddToggle("RageFfaLow", { Text = "Lowest Health", Default = true, Callback = function(v) config.ragebotFfaLowestHealth = v end })
RageFfa:AddToggle("RageFfaClose", { Text = "Closest Proximity", Default = false, Callback = function(v) config.ragebotFfaClosest = v end })

local AutoBox = MiscTab:AddLeftGroupbox("Automation")
Tgl(AutoBox, "AntiAfk", "Anti AFK", "Prevents idle disconnect", function(v) config.antiAfkEnabled = v if v then startAntiAfk() else stopAntiAfk() end end)

local CfgBox = SettingsTab:AddLeftGroupbox("Config")
local profileInput = "Main"
CfgBox:AddInput("ProfileNameInput", { Text = "Profile", Default = "Main", Finished = false, Callback = function(v) profileInput = v end })
CfgBox:AddButton("Save Profile", function() local s, m = saveProfile(profileInput); Notify("Config", m) end)
CfgBox:AddButton("Load Profile", function() local s, m = loadProfile(profileInput); Notify("Config", m) end)
CfgBox:AddButton("Delete Profile", function() local s, m = deleteProfile(profileInput); Notify("Config", m) end)
CfgBox:AddButton("Save to File", function() saveGlobalConfig(); Notify("Config", "Saved") end)

local SysBox = SettingsTab:AddRightGroupbox("System")
SysBox:AddButton("Unload", function()
    getgenv().meoww_loaded = false
    pcall(function() Ragebot:Stop() end)
    Suppressor:Stop()
    for _, c in ipairs(getgenv().AllConnections) do pcall(function() c:Disconnect() end) end
    pcall(function() Library:Unload() end)
end)

task.spawn(function()
    while task.wait(60) do
        if getgenv().meoww_loaded then pcall(saveGlobalConfig) end
    end
end)

Notify("meowwCL Premium", gameServices.ready and "Loaded. Ragebot ready." or "Loaded. Ragebot unavailable (needs Elisium/Rivals).")