if (not LPH_OBFUSCATED) then
    LPH_ENCNUM = function(toEncrypt, ...)
        assert(type(toEncrypt) == "number" and #{...} == 0, "LPH_ENCNUM only accepts a single constant double or integer as an argument.")
        return toEncrypt
    end
    LPH_NUMENC = LPH_ENCNUM

    LPH_ENCSTR = function(toEncrypt, ...)
        assert(type(toEncrypt) == "string" and #{...} == 0, "LPH_ENCSTR only accepts a single constant string as an argument.")
        return toEncrypt
    end
    LPH_STRENC = LPH_ENCSTR

    LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
        assert(type(toEncrypt) == "function" and type(encKey) == "string" and #{...} == 0, "LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")
        return toEncrypt
    end
    LPH_FUNCENC = LPH_ENCFUNC

    LPH_JIT = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
        return f
    end
    LPH_JIT_MAX = LPH_JIT

    LPH_NO_VIRTUALIZE = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
        return f
    end

    LPH_NO_UPVALUES = function(f, ...)
        assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
        return f
    end

    LPH_CRASH = function(...)
        assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
    end
end

local LPH_Protected = LPH_JIT(function()
    local LPH_Players = game:GetService("Players")
    local LPH_RunService = game:GetService("RunService")
    local LPH_ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local LPH_LocalPlayer = LPH_Players.LocalPlayer
    
    local CONFIG = {
        SAFE_MODE = true,
        DELAY_BETWEEN_SCANS = 0.1,
        MAX_DEPTH = 30,
        IGNORE_TABLES = {
            "_G",
            "game",
            "workspace",
            "script",
        }
    }
    
    local processed = setmetatable({}, {__mode = "k"})
    local isRunning = false
    local scanConnection = nil
    
    local safeGetUpvalues = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function(func)
        local success, upvalues = pcall(getupvalues, func)
        if success then
            return upvalues or {}
        end
        return {}
    end))
    
    local safePairs = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function(tbl)
        local success, result = pcall(function()
            local keys = {}
            for k, _ in pairs(tbl) do
                table.insert(keys, k)
            end
            return keys
        end)
        
        if success and type(result) == "table" then
            local i = 0
            return function()
                i = i + 1
                local key = result[i]
                if key ~= nil then
                    return key, tbl[key]
                end
            end
        end
        
        return function() end
    end))
    
    local function isCyclic(obj)
        return processed[obj] == true
    end
    
    local hookRemoteEvent = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function(remote)
        if not remote or not remote:IsA("RemoteEvent") then
            return false
        end
        
        local success, oldFire = pcall(function()
            local hooked = LPH_ENCFUNC(function(self, ...)
                local args = {...}
                local shouldBlock = false
                
                for i, arg in ipairs(args) do
                    if type(arg) == "string" then
                        local lowerArg = string.lower(arg)
                        if lowerArg == "x-15" or lowerArg == "x-16" or 
                           lowerArg:find("ban") or lowerArg:find("kick") then
                            shouldBlock = true
                            break
                        end
                    end
                end
                
                if shouldBlock then
                    return nil
                end
                
                return oldFire(self, ...)
            end, "hook", "hook")
            
            oldFire = hookfunction(remote.FireServer, hooked)
            return true
        end)
        
        return success
    end))
    
    local deepScan
    deepScan = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function(obj, depth)
        if not isRunning then return end
        if depth == nil then depth = 0 end
        if depth > CONFIG.MAX_DEPTH then return end
        
        if obj == nil or processed[obj] then return end
        
        local objType = typeof(obj)
        
        if objType == "number" and obj ~= obj then
            return
        end
        
        processed[obj] = true
        
        if objType == "Instance" and obj:IsA("RemoteEvent") then
            if not obj:IsDescendantOf(LPH_ReplicatedStorage) then
                hookRemoteEvent(obj)
            end
            return
        end
        
        if objType == "function" then
            if isexecutorclosure and isexecutorclosure(obj) then
                return
            end
            
            local upvalues = safeGetUpvalues(obj)
            for i, upval in ipairs(upvalues) do
                if upval ~= obj then
                    pcall(deepScan, upval, depth + 1)
                end
            end
            return
        end
        
        if objType == "table" then
            local shouldSkip = false
            for _, skipName in ipairs(CONFIG.IGNORE_TABLES) do
                if rawget(_G, skipName) == obj then
                    shouldSkip = true
                    break
                end
            end
            
            if shouldSkip then return end
            
            for key, value in safePairs(obj) do
                if value ~= obj and not isCyclic(value) then
                    pcall(deepScan, value, depth + 1)
                end
            end
            return
        end
    end))
    
    local function safeCollect()
        pcall(collectgarbage, "collect")
        task.wait(0.05)
        pcall(collectgarbage, "collect")
    end
    
    local throttledScan = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function(obj, depth)
        if not isRunning then return end
        pcall(deepScan, obj, depth or 0)
    end))
    
    local startBypass = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function()
        if isRunning then return end
        isRunning = true
        
        task.wait(1)
        
        local gcList = {}
        local success, result = pcall(getgc, true)
        if success and type(result) == "table" then
            gcList = result
        end
        
        local processed_count = 0
        
        for i, obj in ipairs(gcList) do
            if not isRunning then break end
            
            pcall(function()
                local objType = typeof(obj)
                if objType == "function" or objType == "table" then
                    throttledScan(obj, 0)
                    processed_count = processed_count + 1
                    
                    if processed_count % 50 == 0 then
                        safeCollect()
                        task.wait(CONFIG.DELAY_BETWEEN_SCANS)
                    end
                end
            end)
        end
        
        if scanConnection then
            scanConnection:Disconnect()
        end
        
        scanConnection = LPH_RunService.Heartbeat:Connect(function()
            if not isRunning then
                if scanConnection then
                    scanConnection:Disconnect()
                    scanConnection = nil
                end
                return
            end
            
            if CONFIG.SAFE_MODE and math.random(1, 100) == 1 then
                pcall(function()
                    local success, newGc = pcall(getgc, true)
                    if success and type(newGc) == "table" then
                        local scanCount = 0
                        for _, obj in ipairs(newGc) do
                            if not processed[obj] then
                                throttledScan(obj, 0)
                                scanCount = scanCount + 1
                                if scanCount > 10 then break end
                            end
                        end
                    end
                end)
            end
        end)
    end))
    
    local antiDetection = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function()
        if LPH_OBFUSCATED then return end
        
        local oldPrint = print
        print = function(...)
            local args = {...}
            local shouldBlock = false
            for i, arg in ipairs(args) do
                if type(arg) == "string" then
                    local lowerArg = string.lower(arg)
                    if lowerArg:find("executor") or 
                       lowerArg:find("bypass") or
                       lowerArg:find("inject") then
                        shouldBlock = true
                        break
                    end
                end
            end
            if not shouldBlock then
                oldPrint(...)
            end
        end
        
        local oldWarn = warn
        warn = function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                if type(arg) == "string" then
                    local lowerArg = string.lower(arg)
                    if lowerArg:find("executor") or 
                       lowerArg:find("bypass") then
                        return
                    end
                end
            end
            oldWarn(...)
        end
    end))
    
    local safeEnvironment = LPH_NO_VIRTUALIZE(LPH_NO_UPVALUES(function()
        local env = getfenv and getfenv(2) or getrenv()
        if env then
            local success, mt = pcall(getrawmetatable, env)
            if success and mt then
                local success2, oldIndex = pcall(function()
                    return mt.__index
                end)
                if success2 and oldIndex then
                    pcall(function()
                        mt.__index = function(t, k)
                            local value = oldIndex(t, k)
                            if value == nil then
                                return nil
                            end
                            return value
                        end
                    end)
                end
            end
        end
    end))
    
    antiDetection()
    safeEnvironment()
    pcall(startBypass)
    
    task.delay(600, function()
        if CONFIG.SAFE_MODE then
            safeCollect()
        end
    end)
end)

LPH_JIT_MAX(LPH_Protected)()
print("work")
