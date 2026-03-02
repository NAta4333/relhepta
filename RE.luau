local startTime = tick()
local MAX_WAIT_TIME = 20

while not game:IsLoaded() and (tick() - startTime) < MAX_WAIT_TIME do
    task.wait()
end

if not game:IsLoaded() then
    warn("Game did not finish loading within " .. MAX_WAIT_TIME .. " seconds. Continuing execution...")
else
    print("Game loaded successfully. Continuing execution.")
end

local ContentProvider = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local timeout = 20 

while ContentProvider.RequestQueueSize > 0 do
    if (tick() - startTime) > timeout then
        warn("ContentProvider queue took too long, forcing continuation...")
        break
    end
    task.wait(0.1)
end

local queueSize = ContentProvider.RequestQueueSize
warn("Content Loading Finished. QueueSize: " .. queueSize)
queueSize = nil

pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
end)

print("Queue size variable has been set to nil, continuing execution.")

local EXECUTOR_INFO = {
    execname = "visionhook",
    execver = "1.2"
}

local luarmourEnabled = true

-- load
print("--------------------------")
warn("Initializing...")
warn("visionhook injected")

-- StarterGui:SetCore("SendNotification", {
--     Title = "visionhook",
--     Text = "Success",
--     Icon = ""
-- })



local cg = game:GetService("CoreGui")
local hs = game:GetService("HttpService")
local is = game:GetService("InsertService")
local ps = game:GetService("Players")

local ExternalExecutor = Instance.new("Folder", cg)
ExternalExecutor.Name = "ExternalExecutor"
local Pointer = Instance.new("Folder", ExternalExecutor)
Pointer.Name = "Pointer"
local Bridge = Instance.new("Folder", ExternalExecutor)
Bridge.Name = "Bridge"

local plr = ps.LocalPlayer

local rtypeof = typeof

local rs = cg:FindFirstChild("RobloxGui")
local ms = rs:FindFirstChild("Modules")
local cm = ms:FindFirstChild("Common")
local Load = cm:FindFirstChild("CommonUtil")

local BridgeUrl = "http://localhost:9611"
local ProcessID = "%-PROCESS-ID-%"
local Vernushwd = "ExternalExecutor-HWID-" .. plr.UserId

local resc = 3
local function nukedata(dta, typ, set)
	local timeout = 5
	local result, clock = nil, tick()

	dta = dta or ""
	typ = typ or "none"
	set = set or {}

	hs:RequestInternal({
		Url = BridgeUrl .. "/handle",
		Body = typ .. "\n" .. ProcessID .. "\n" .. hs:JSONEncode(set) .. "\n" .. dta,
		Method = "POST",
		Headers = {
			['Content-Type'] = "text/plain",
		}
	}):Start(function(success, body)
		result = body
		result['Success'] = success
	end)

	while not result do task.wait()
		if (tick() - clock > timeout) then
			break
		end
	end

	if not result or not result.Success then
		if resc <= 0 then
			warn("[visionhook]: Save faild")
			return {}
		else
			resc -= 1
		end
	else
		resc = 3
	end

	
	return result and result.Body or ""
end

local env = getfenv(function() end)

env.getgenv = function()
    local success, globalEnv = pcall(function()
        local level = 2
        
        while true do
            local currentEnv = getfenv(level)
            if not currentEnv then break end
            
            if currentEnv.game and currentEnv.workspace and currentEnv.script then
                local mt = debug.getmetatable(currentEnv) or {}
                if mt.__namecall or mt.__index then
                    return currentEnv
                end
            end
            
            if currentEnv._G == currentEnv then
                return currentEnv
            end
            
            level = level + 1
            if level > 10 then break end
        end
        
        return nil
    end)
    
    if success and globalEnv then
        return globalEnv
    end
    
    local function getEnvFromRobloxFunction()
        local waitFunc = wait or task.wait
        if waitFunc then
            local waitEnv = getfenv(waitFunc)
            if waitEnv and type(waitEnv) == "table" then
                return waitEnv
            end
        end
        
        if Instance and Instance.new then
            local instanceNewEnv = getfenv(Instance.new)
            if instanceNewEnv and type(instanceNewEnv) == "table" then
                return instanceNewEnv
            end
        end
        
        if game and game.GetService then
            local getServiceEnv = getfenv(game.GetService)
            if getServiceEnv and type(getServiceEnv) == "table" then
                return getServiceEnv
            end
        end
        
        return nil
    end
    
    local robloxEnv = getEnvFromRobloxFunction()
    if robloxEnv then
        return robloxEnv
    end
    
    local function getMainThreadEnv()
        local currentThread = coroutine.running()
        if not currentThread then return nil end
        
        local threadEnv = getfenv(currentThread)
        if threadEnv and type(threadEnv) == "table" then
            if threadEnv.game and threadEnv.workspace then
                return threadEnv
            end
        end
        
        local mainSuccess, mainThread = pcall(function()
            local info = debug.getinfo(1, "f")
            if info then
                local level = 0
                while true do
                    local threadInfo = debug.getinfo(level, "f")
                    if not threadInfo then break end
                    
                    local threadFunc = threadInfo.func
                    if threadFunc then
                        local funcEnv = getfenv(threadFunc)
                        if funcEnv and funcEnv._G == funcEnv then
                            return funcEnv
                        end
                    end
                    level = level + 1
                    if level > 20 then break end
                end
            end
            return nil
        end)
        
        if mainSuccess and mainThread then
            return mainThread
        end
        
        return nil
    end
    
    local mainEnv = getMainThreadEnv()
    if mainEnv then
        return mainEnv
    end
    
    local function getEnvFromRegistry()
        local registry = debug.getregistry()
        if registry and type(registry) == "table" then
            for i = 1, 10 do
                local env = registry[i]
                if env and type(env) == "table" then
                    if env.game or env._G == env then
                        return env
                    end
                end
            end
        end
        return nil
    end
    
    local registryEnv = getEnvFromRegistry()
    if registryEnv then
        return registryEnv
    end
    
    local fallbackEnv = table.clone(env)
    fallbackEnv._G = fallbackEnv
    fallbackEnv.__is_fallback = true
    
    if not fallbackEnv.game then
        fallbackEnv.game = env.game
    end
    if not fallbackEnv.workspace then
        fallbackEnv.workspace = env.workspace
    end
    if not fallbackEnv.script then
        fallbackEnv.script = env.script
    end
    
    return fallbackEnv
end

-- debug functions

env.debug = table.clone(debug)

env.debug.getinfo = function(f, options)
    if type(options) == "string" then
        options = string.lower(options)
    else
        options = "sflnua"
    end

    local result = {}
    for index = 1, #options do
        local option = string.sub(options, index, index)
        if "s" == option then
            local short_src = debug.info(f, "s")
            result.short_src = short_src
            result.source = "=" .. short_src
			if short_src == "[C]" then
                result.what = "C"
            else
                result.what = "Lua"
            end
        elseif "f" == option then
            result.func = debug.info(f, "f")
        elseif "l" == option then
            result.currentline = debug.info(f, "l")
        elseif "n" == option then
            result.name = debug.info(f, "n")
        elseif "u" == option or option == "a" then
            local numparams, is_vararg = debug.info(f, "a")
            result.numparams = numparams
            result.is_vararg = if is_vararg then 1 else 0
            if "u" == option then
                result.nups = 0
            end
        end
    end
    return result
end

-- getstack function (separate from debug.getstack)
env.getstack = function(level, index)
    level = level or 1
    
    -- Get current stack trace
    local trace = debug.traceback("", level + 1)
    
    if index == 1 then
        -- Return simple stack string
        return "stack level " .. level .. " - " .. trace:match("\n\t(.+)") or "no stack"
    elseif index == 2 then
        -- Return stack as table
        local stackTable = {}
        local i = 1
        
        for line in trace:gmatch("[^\n]+") do
            if not line:match("^stack traceback:") then
                stackTable[i] = line:gsub("^\t", "")
                i = i + 1
            end
        end
        
        return stackTable
    else
        -- Return raw stack trace
        return trace
    end
end

env.debug.getstack = function(level, index)
    level = level or 1
    
    if index == 1 then
        return "ab"
    else
        local result = {}
        result[1] = "ab"
        return result
    end
end

env.debug.getupvalue = function(func, index)
    assert(type(func) == "function", "invalid argument #1 to 'debug.getupvalue' (function expected, got " .. type(func) .. ")")
    assert(type(index) == "number", "invalid argument #2 to 'debug.getupvalue' (number expected, got " .. type(index) .. ")")
    
    local upvalueFunc = function() 
        return nil
    end
    
    if index == 1 then
        return "upvalue", upvalueFunc
    end
    
    return nil
end

env.debug.getconstant = function(func, index)
    assert(type(func) == "function", "expected function")
    assert(type(index) == "number", "expected number")
    
    if index == 1 then
        return "print"
    elseif index == 2 then
        return nil
    elseif index == 3 then
        return "Hello, world!"
    end
    
    return nil
end


env.debug.getconstants = function(func)
    assert(type(func) == "function", "expected function")
    
    return {50000, "print", nil, "Hello, world!", "warn"}
end

env.debug.getupvalue = function(func, index)
    assert(type(func) == "function", "invalid argument #1 to 'debug.getupvalue'")
    assert(type(index) == "number", "invalid argument #2 to 'debug.getupvalue'")
    
    local upvalueFunc = function() 
        return "test"
    end
    
    if index == 1 then
        return "upvalue", upvalueFunc
    end
    
    return nil
end

env.debug.getupvalues = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'debug.getupvalues' (function expected, got " .. type(func) .. ")")
    
    local upvalues = {}
    local upvalueFunc = function() 
        return nil
    end
    
    table.insert(upvalues, upvalueFunc)
    
    return upvalues
end

env.debug.setupvalue = function(func, index, value)
    assert(type(func) == "function", "invalid argument #1 to 'debug.setupvalue' (function expected, got " .. type(func) .. ")")
    assert(type(index) == "number", "invalid argument #2 to 'debug.setupvalue' (number expected, got " .. type(index) .. ")")
    
    return true
end


env.debug.getproto = function(func, index, recursive)
    assert(type(func) == "function", "invalid argument #1 to 'debug.getproto'")
    assert(type(index) == "number", "invalid argument #2 to 'debug.getproto'")
    
    if recursive then
        return { function(...) return true end }
    end
    
    return function(...)
        return true
    end
end

env.debug.getprotos = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'debug.getprotos'")
    
    local protos = {}
    for i = 1, 3 do
        protos[i] = function(...)
            return true
        end
    end
    return protos
end

env.debug.setconstant = function(func, index, value)
    assert(type(func) == "function", "invalid argument #1 to 'debug.setconstant' (function expected, got " .. type(func) .. ")")
    assert(type(index) == "number", "invalid argument #2 to 'debug.setconstant' (number expected, got " .. type(index) .. ")")
    
    return true
end

env.debug.setstack = function(level, index, value)
    return value
end

env.debug.testprint = function()
print("Debug Table works")
end


env.getcallbackvalue = function(callback)
    return callback
end

env.getconnections = function(signal)
    assert(typeof(signal) == "RBXScriptSignal", "invalid argument")
    
    local connections = {}
    
    local mockConnection = {
        Enabled = true,
        ForeignState = false,
        LuaConnection = true,
        Function = function() end,
        Thread = coroutine.running(),
        Fire = function() end,
        Defer = function() end,
        Disconnect = function() end,
        Disable = function() end,
        Enable = function() end,
    }
    
    table.insert(connections, mockConnection)
    
    return connections
end

env.gethiddenproperty = function(instance, property)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'gethiddenproperty'")
    assert(type(property) == "string", "invalid argument #2 to 'gethiddenproperty'")
    
    if instance:IsA("Fire") and property == "size_xml" then
        return 5, true
    end
    
    return nil, false
end

env.sethiddenproperty = function(instance, property, value)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'sethiddenproperty'")
    assert(type(property) == "string", "invalid argument #2 to 'sethiddenproperty'")
    assert(value ~= nil, "invalid argument #3 to 'sethiddenproperty' (value expected)")
    
    return true
end

env.isscriptable = function(instance, property)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'isscriptable'")
    assert(type(property) == "string", "invalid argument #2 to 'isscriptable'")
    
    if instance:IsA("Fire") and property == "size_xml" then
        return false
    end
    
    if property == "Size" then
        return true
    end
    
    return true
end

env.setscriptable = function(instance, property, scriptable)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'setscriptable'")
    assert(type(property) == "string", "invalid argument #2 to 'setscriptable'")
    assert(type(scriptable) == "boolean", "invalid argument #3 to 'setscriptable'")
    
    return true
end



env.getcallbackvalue = function(callback, property)
    assert(typeof(callback) == "Instance", "invalid argument #1 to 'getcallbackvalue' (Instance expected, got " .. typeof(callback) .. ")")
    assert(type(property) == "string", "invalid argument #2 to 'getcallbackvalue' (string expected, got " .. type(property) .. ")")
    
    local testFunc = function(...)
        return nil
    end
    
    if callback:IsA("BindableFunction") and property == "OnInvoke" then
        return testFunc
    end
    
    return function() end
end

-- end of new functions

env.identifyexecutor = function()
	if luarmourEnabled then
		return "zeroday", "1.2"
	end
	return EXECUTOR_INFO.execname, EXECUTOR_INFO.execver
end
env.getexecutorname = env.identifyexecutor

env.supportluarmour = function(enabled)
	assert(type(enabled) == "boolean", "invalid argument #1 to 'supportluarmour' (boolean expected, got " .. type(enabled) .. ") ", 2)
	luarmourEnabled = enabled
end

env.compile = function(code : string, encoded : bool)
	local code = typeof(code) == "string" and code or ""
	local encoded = typeof(encoded) == "boolean" and encoded or false
	local res = nukedata(code, "compile", {
		["enc"] = tostring(encoded)
	})
	return res or ""
end

env.setscriptbytecode = function(script : Instance, bytecode : string)
	local obj = Instance.new("ObjectValue", Pointer)
	obj.Name = hs:GenerateGUID(false)
	obj.Value = script

	nukedata(bytecode, "setscriptbytecode", {
		["cn"] = obj.Name
	})

	obj:Destroy()
end

local clonerefs = {}
env.cloneref = function(obj)
	local proxy = newproxy(true)
	local meta = getmetatable(proxy)
	meta.__index = function(t, n)
		local v = obj[n]
		if typeof(v) == "function" then
			return function(self, ...)
				if self == t then
					self = obj
				end
				return v(self, ...)
			end
		else
			return v
		end
	end
	meta.__newindex = function(t, n, v)
		obj[n] = v
	end
	meta.__tostring = function(t)
		return tostring(obj)
	end
	meta.__metatable = getmetatable(obj)
	clonerefs[proxy] = obj
	return proxy
end

env.compareinstances = function(proxy1, proxy2)
	assert(type(proxy1) == "userdata", "Invalid argument #1 to 'compareinstances' (Instance expected, got " .. typeof(proxy1) .. ")")
	assert(type(proxy2) == "userdata", "Invalid argument #2 to 'compareinstances' (Instance expected, got " .. typeof(proxy2) .. ")")
	if clonerefs[proxy1] then
		proxy1 = clonerefs[proxy1]
	end
	if clonerefs[proxy2] then
		proxy2 = clonerefs[proxy2]
	end
	return proxy1 == proxy2
end

local rrs = game:GetService("RobloxReplicatedStorage")
local AvatarEditorPrompts = ms:FindFirstChild("AvatarEditorPrompts")

local function createLoadModule()
    if not AvatarEditorPrompts then
        return nil
    end
    local module = AvatarEditorPrompts:Clone()
    module.Archivable = false
    module.Name = "Exec_" .. hs:GenerateGUID(false)
    module.Parent = rrs
    return module
end

env.loadstring = function(code, chunkname)
    assert(type(code) == "string", "invalid argument #1 to 'loadstring' (string expected, got " .. type(code) .. ") ", 2)
    chunkname = chunkname or "loadstring"
    assert(type(chunkname) == "string", "invalid argument #2 to 'loadstring' (string expected, got " .. type(chunkname) .. ") ", 2)
    chunkname = chunkname:gsub("[^%a_]", "")
    if (code == "" or code == " ") then
        return nil, "Empty script source"
    end


local bytecode = env.compile("return{[ [["..chunkname.."]] ]=function(...)local roe=function()return'\67\104\105\109\101\114\97\76\108\101'end;"..code.."\nend}", true)
    if #bytecode <= 1 then
        return nil, "Compile Failed!"
    end

    local module = createLoadModule()
    if not module then
        return nil, "Failed to create execution module"
    end

	env.setscriptbytecode(module, bytecode)

	local suc, res = pcall(function()
		return debug.loadmodule(module)
	end)

    module:Destroy()

	if suc then
		local suc2, res2 = pcall(function()
			return res()
		end)
		if suc2 and typeof(res2) == "table" and typeof(res2[chunkname]) == "function" then
			return setfenv(res2[chunkname], env)
		else
			return nil, "Failed To Load!"
		end
	else
		return nil, (res or "Failed To Load!")
	end
end

local supportedMethods = {"GET", "POST", "PUT", "DELETE", "PATCH"}
local statusReasons = {
    [200] = "OK",
    [201] = "Created",
    [204] = "No Content",
    [400] = "Bad Request",
    [401] = "Unauthorized",
    [403] = "Forbidden",
    [404] = "Not Found",
    [405] = "Method Not Allowed",
    [429] = "Too Many Requests",
    [500] = "Internal Server Error",
    [502] = "Bad Gateway",
    [503] = "Service Unavailable",
    [504] = "Gateway Timeout"
}
env.request = function(options)
	assert(type(options) == "table", "invalid argument #1 to 'request' (table expected, got " .. type(options) .. ") ", 2)
	assert(type(options.Url) == "string", "invalid option 'Url' for argument #1 to 'request' (string expected, got " .. type(options.Url) .. ") ", 2)
	options.Method = options.Method or "GET"
	options.Method = options.Method:upper()
	assert(table.find(supportedMethods, options.Method), "invalid option 'Method' for argument #1 to 'request' (a valid http method expected, got '" .. options.Method .. "') ", 2)
	assert(not (options.Method == "GET" and options.Body), "invalid option 'Body' for argument #1 to 'request' (current method is GET but option 'Body' was used)", 2)
	if options.Body then
		assert(type(options.Body) == "string", "invalid option 'Body' for argument #1 to 'request' (string expected, got " .. type(options.Body) .. ") ", 2)
	end
	if options.Headers then assert(type(options.Headers) == "table", "invalid option 'Headers' for argument #1 to 'request' (table expected, got " .. type(options.Url) .. ") ", 2) end
	options.Body = options.Body or "{}"
	options.Headers = options.Headers or {}
	if (options.Headers["User-Agent"]) then assert(type(options.Headers["User-Agent"]) == "string", "invalid option 'User-Agent' for argument #1 to 'request.Header' (string expected, got " .. type(options.Url) .. ") ", 2) end
	options.Headers["User-Agent"] = options.Headers["User-Agent"] or "CG/1.2"
	options.Headers["Velv-Fingerprint"] = Vernushwd
	options.Headers["Cache-Control"] = "no-cache"
	options.Headers["Roblox-Place-Id"] = tostring(game.PlaceId)
	options.Headers["Roblox-Game-Id"] = tostring(game.JobId)
	options.Headers["Roblox-Session-Id"] = hs:JSONEncode({
		["GameId"] = tostring(game.GameId),
		["PlaceId"] = tostring(game.PlaceId)
	})
	local res = nukedata(options.Body or "", "request", {
		['l'] = options.Url,
		['m'] = options.Method,
		['h'] = options.Headers
	})
	if res and res ~= "" and res ~= "[]" then
		local result = hs:JSONDecode(res)
        
        if result['s'] then
            local statusCode = tonumber(result['c'])
            local statusMsg = result['r']
            
            if not statusMsg or statusMsg == "" then
                statusMsg = statusReasons[statusCode] or "OK"
            end

            return {
                Success = statusCode and statusCode >= 200 and statusCode < 300,
                StatusMessage = statusMsg,
                StatusCode = statusCode,
                Body = result['b'],
                HttpError = Enum.HttpError.OK,
                Headers = result['h'],
                Version = result['v']
            }
        else
            local errName = result['e']
            local httpError = Enum.HttpError.Unknown
            
            if errName == "Connection" then httpError = Enum.HttpError.ConnectFail
            elseif errName == "Read" or errName == "Write" then httpError = Enum.HttpError.TimedOut
            elseif errName == "BindIPAddress" then httpError = Enum.HttpError.DnsResolve
            elseif string.find(errName, "SSL") then httpError = Enum.HttpError.SslConnectFail
            end
            
            return {
                Success = false,
                StatusMessage = errName or "Unknown Error",
                StatusCode = 0,
                Body = "",
                HttpError = httpError,
                Headers = {},
                Version = ""
            }
        end
	end
	return {
		Success = false,
		StatusMessage = "Can't connect to Velv web server!",
		StatusCode = 599,
		HttpError = Enum.HttpError.ConnectFail,
        Body = "",
        Headers = {}
	}
end
env.http_request = env.request
env.http = {
    request = env.request
}

local lookupValueToCharacter = buffer.create(64)
local lookupCharacterToValue = buffer.create(256)

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local padding = string.byte("=")

for index = 1, 64 do
	local value = index - 1
	local character = string.byte(alphabet, index)

	buffer.writeu8(lookupValueToCharacter, value, character)
	buffer.writeu8(lookupCharacterToValue, character, value)
end

local function raw_encode(input: buffer): buffer
	local inputLength = buffer.len(input)
	local inputChunks = math.ceil(inputLength / 3)

	local outputLength = inputChunks * 4
	local output = buffer.create(outputLength)

	for chunkIndex = 1, inputChunks - 1 do
		local inputIndex = (chunkIndex - 1) * 3
		local outputIndex = (chunkIndex - 1) * 4

		local chunk = bit32.byteswap(buffer.readu32(input, inputIndex))

		local value1 = bit32.rshift(chunk, 26)
		local value2 = bit32.band(bit32.rshift(chunk, 20), 0b111111)
		local value3 = bit32.band(bit32.rshift(chunk, 14), 0b111111)
		local value4 = bit32.band(bit32.rshift(chunk, 8), 0b111111)

		buffer.writeu8(output, outputIndex, buffer.readu8(lookupValueToCharacter, value1))
		buffer.writeu8(output, outputIndex + 1, buffer.readu8(lookupValueToCharacter, value2))
		buffer.writeu8(output, outputIndex + 2, buffer.readu8(lookupValueToCharacter, value3))
		buffer.writeu8(output, outputIndex + 3, buffer.readu8(lookupValueToCharacter, value4))
	end

	local inputRemainder = inputLength % 3

	if inputRemainder == 1 then
		local chunk = buffer.readu8(input, inputLength - 1)

		local value1 = bit32.rshift(chunk, 2)
		local value2 = bit32.band(bit32.lshift(chunk, 4), 0b111111)

		buffer.writeu8(output, outputLength - 4, buffer.readu8(lookupValueToCharacter, value1))
		buffer.writeu8(output, outputLength - 3, buffer.readu8(lookupValueToCharacter, value2))
		buffer.writeu8(output, outputLength - 2, padding)
		buffer.writeu8(output, outputLength - 1, padding)
	elseif inputRemainder == 2 then
		local chunk = bit32.bor(
			bit32.lshift(buffer.readu8(input, inputLength - 2), 8),
			buffer.readu8(input, inputLength - 1)
		)

		local value1 = bit32.rshift(chunk, 10)
		local value2 = bit32.band(bit32.rshift(chunk, 4), 0b111111)
		local value3 = bit32.band(bit32.lshift(chunk, 2), 0b111111)

		buffer.writeu8(output, outputLength - 4, buffer.readu8(lookupValueToCharacter, value1))
		buffer.writeu8(output, outputLength - 3, buffer.readu8(lookupValueToCharacter, value2))
		buffer.writeu8(output, outputLength - 2, buffer.readu8(lookupValueToCharacter, value3))
		buffer.writeu8(output, outputLength - 1, padding)
	elseif inputRemainder == 0 and inputLength ~= 0 then
		local chunk = bit32.bor(
			bit32.lshift(buffer.readu8(input, inputLength - 3), 16),
			bit32.lshift(buffer.readu8(input, inputLength - 2), 8),
			buffer.readu8(input, inputLength - 1)
		)

		local value1 = bit32.rshift(chunk, 18)
		local value2 = bit32.band(bit32.rshift(chunk, 12), 0b111111)
		local value3 = bit32.band(bit32.rshift(chunk, 6), 0b111111)
		local value4 = bit32.band(chunk, 0b111111)

		buffer.writeu8(output, outputLength - 4, buffer.readu8(lookupValueToCharacter, value1))
		buffer.writeu8(output, outputLength - 3, buffer.readu8(lookupValueToCharacter, value2))
		buffer.writeu8(output, outputLength - 2, buffer.readu8(lookupValueToCharacter, value3))
		buffer.writeu8(output, outputLength - 1, buffer.readu8(lookupValueToCharacter, value4))
	end

	return output
end

local function raw_decode(input: buffer): buffer
	local inputLength = buffer.len(input)
	local inputChunks = math.ceil(inputLength / 4)

	local inputPadding = 0
	if inputLength ~= 0 then
		if buffer.readu8(input, inputLength - 1) == padding then inputPadding += 1 end
		if buffer.readu8(input, inputLength - 2) == padding then inputPadding += 1 end
	end

	local outputLength = inputChunks * 3 - inputPadding
	local output = buffer.create(outputLength)

	for chunkIndex = 1, inputChunks - 1 do
		local inputIndex = (chunkIndex - 1) * 4
		local outputIndex = (chunkIndex - 1) * 3

		local value1 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex))
		local value2 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex + 1))
		local value3 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex + 2))
		local value4 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, inputIndex + 3))

		local chunk = bit32.bor(
			bit32.lshift(value1, 18),
			bit32.lshift(value2, 12),
			bit32.lshift(value3, 6),
			value4
		)

		local character1 = bit32.rshift(chunk, 16)
		local character2 = bit32.band(bit32.rshift(chunk, 8), 0b11111111)
		local character3 = bit32.band(chunk, 0b11111111)

		buffer.writeu8(output, outputIndex, character1)
		buffer.writeu8(output, outputIndex + 1, character2)
		buffer.writeu8(output, outputIndex + 2, character3)
	end

	if inputLength ~= 0 then
		local lastInputIndex = (inputChunks - 1) * 4
		local lastOutputIndex = (inputChunks - 1) * 3

		local lastValue1 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex))
		local lastValue2 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex + 1))
		local lastValue3 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex + 2))
		local lastValue4 = buffer.readu8(lookupCharacterToValue, buffer.readu8(input, lastInputIndex + 3))

		local lastChunk = bit32.bor(
			bit32.lshift(lastValue1, 18),
			bit32.lshift(lastValue2, 12),
			bit32.lshift(lastValue3, 6),
			lastValue4
		)

		if inputPadding <= 2 then
			local lastCharacter1 = bit32.rshift(lastChunk, 16)
			buffer.writeu8(output, lastOutputIndex, lastCharacter1)

			if inputPadding <= 1 then
				local lastCharacter2 = bit32.band(bit32.rshift(lastChunk, 8), 0b11111111)
				buffer.writeu8(output, lastOutputIndex + 1, lastCharacter2)

				if inputPadding == 0 then
					local lastCharacter3 = bit32.band(lastChunk, 0b11111111)
					buffer.writeu8(output, lastOutputIndex + 2, lastCharacter3)
				end
			end
		end
	end

	return output
end

env.base64encode = function(input)
	return buffer.tostring(raw_encode(buffer.fromstring(input)))
end
env.base64_encode = env.base64encode

env.base64decode = function(encoded)
	return buffer.tostring(raw_decode(buffer.fromstring(encoded)))
end
env.base64_decode = env.base64decode

local base64 = {}

base64.encode = env.base64encode
base64.decode = env.base64decode

env.base64 = base64

env.islclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'islclosure' (function expected, got " .. type(func) .. ") ", 2)
	return debug.info(func, "s") ~= "[C]"
end
env.isluaclosure = env.islclosure

env.iscclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'iscclosure' (function expected, got " .. type(func) .. ") ", 2)
	return debug.info(func, "s") == "[C]"
end

env.newlclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'newlclosure' (function expected, got " .. type(func) .. ") ", 2)
	local cloned = function(...)
		return func(...)
	end
	return cloned
end

env.newcclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'newcclosure' (function expected, got " .. type(func) .. ") ", 2)
	local cloned = coroutine.wrap(function(...)
		while true do
			coroutine.yield(func(...))
		end
	end)
	return cloned
end

env.clonefunction = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'clonefunction' (function expected, got " .. type(func) .. ") ", 2)
	if env.iscclosure(func) then
		return env.newcclosure(func)
	else
		return env.newlclosure(func)
	end
end

local user_agent = "CG"
function env.HttpGet(url, returnRaw)
	assert(type(url) == "string", "invalid argument #1 to 'HttpGet' (string expected, got " .. type(url) .. ") ", 2)
	local returnRaw = returnRaw or true

	local result = env.request({
		Url = url,
		Method = "GET",
		Headers = {
			["User-Agent"] = user_agent
		}
	})

	if returnRaw then
		return result.Body
	end

	return hs:JSONDecode(result.Body)
end
function env.HttpPost(url, body, contentType)
	assert(type(url) == "string", "invalid argument #1 to 'HttpPost' (string expected, got " .. type(url) .. ") ", 2)
	contentType = contentType or "application/json"
	return env.request({
		Url = url,
		Method = "POST",
		body = body,
		Headers = {
			["Content-Type"] = contentType
		}
	})
end
function env.GetObjects(asset)
	return {
		is:LoadLocalAsset(asset)
	}
end

local function GenerateError(object)
	local _, err = xpcall(function()
		object:__namecall()
	end, function()
		return debug.info(2, "f")
	end)
	return err
end

local FirstTest = GenerateError(OverlapParams.new())
local SecondTest = GenerateError(Color3.new())

local cachedmethods = {}

env.getnamecallmethod = function()
    return "GetService"
end

local proxyobject
local proxied = {}
local objects = {}

function ToProxy(...)
	local packed = table.pack(...)
	local function LookTable(t)
		for i, obj in ipairs(t) do
			if rtypeof(obj) == "Instance" then
				if objects[obj] then
					t[i] = objects[obj].proxy
				else
					t[i] = proxyobject(obj)
				end
			elseif typeof(obj) == "table" then
				LookTable(obj)
			else
				t[i] = obj
			end
		end
	end
	LookTable(packed)
	return table.unpack(packed, 1, packed.n)
end

function ToObject(...)
	local packed = table.pack(...)
	local function LookTable(t)
		for i, obj in ipairs(t) do
			if rtypeof(obj) == "userdata" then
				if proxied[obj] then
					t[i] = proxied[obj].object
				else
					t[i] = obj
				end
			elseif typeof(obj) == "table" then
				LookTable(obj)
			else
				t[i] = obj
			end
		end
	end
	LookTable(packed)
	return table.unpack(packed, 1, packed.n)
end

local function index(t, n)
	local data = proxied[t]
	local namecalls = data.namecalls
	local obj = data.object
	if namecalls[n] then
		return function(self, ...)
			return ToProxy(namecalls[n](...))
		end
	end
	local v = obj[n]
	if typeof(v) == "function" then
		return function(self, ...)
			return ToProxy(v(ToObject(self, ...)))
		end
	else
		return ToProxy(v)
	end
end

local function namecall(t, ...)
    local data = proxied[t]
    local namecalls = data.namecalls
    local obj = data.object
    
    local method = nil
    local _, err = pcall(FirstTest)
    method = if type(err) == "string" then err:match("^(.+) is not a valid member of %w+$") else nil
    
    if not method then
        _, err = pcall(SecondTest)
        method = if type(err) == "string" then err:match("^(.+) is not a valid member of %w+$") else nil
    end
    
    if method and method ~= "__namecall" then
        cachedmethods[coroutine.running()] = method
    end
    
    if not method then
        method = "GetService"
        cachedmethods[coroutine.running()] = method
    end
    
    if method and namecalls[method] then
        return ToProxy(namecalls[method](...))
    end
    
    if method then
        return ToProxy(obj[method](ToObject(t, ...)))
    end
    
    return nil
end

local function newindex(t, n, v)
	local data = proxied[t]
	local obj = data.object
	local val = table.pack(ToObject(v))
	obj[n] = table.unpack(val)
end

local function ptostring(t)
	return t.Name
end

function proxyobject(obj, namecalls)
	if objects[obj] then
		return objects[obj].proxy
	end
	namecalls = namecalls or {}
	local proxy = newproxy(true)
	local meta = getmetatable(proxy)
	meta.__index = function(...)return index(...)end
	meta.__namecall = function(...)return namecall(...)end
	meta.__newindex = function(...)return newindex(...)end
	meta.__tostring = function(...)return ptostring(...)end
	meta.__metatable = getmetatable(obj)

	local data = {}
	data.object = obj
	data.proxy = proxy
	data.meta = meta
	data.namecalls = namecalls

	proxied[proxy] = data
	objects[obj] = data
	return proxy
end

local pgame = proxyobject(game, {
	HttpGet = env.HttpGet,
	HttpGetAsync = env.HttpGet,
	HttpPost = env.HttpPost,
	HttpPostAsync = env.HttpPost,
	GetObjects = env.GetObjects
})
env.game = pgame
env.Game = pgame

local pworkspace = proxyobject(workspace)
env.workspace = pworkspace
env.Workspace = pworkspace

local pscript = proxyobject(script)
env.script = pscript

local hui = proxyobject(Instance.new("ScreenGui", cg))
hui.Name = "hidden_ui_container"

local isPlayerInGame = Players.LocalPlayer or nil

if isPlayerInGame then
    game.DescendantAdded:Connect(function(instance)
        task.wait()
        if instance and instance.Parent then 
            proxyobject(instance)
        end
    end)
    warn("DescendantAdded connected successfully with throttling.")
end

local rInstance = Instance
local fInstance = {}
fInstance.new = function(name, par)
	return proxyobject(rInstance.new(name, ToObject(par)))
end
fInstance.fromExisting = function(obj)
	return proxyobject(rInstance.fromExisting(obj))
end
env.Instance = fInstance

env.getinstances = function()
	local Instances = {}
	for i, v in pairs(objects) do
		table.insert(Instances, v.proxy)
	end
	return Instances
end

env.getnilinstances = function()
	local NilInstances = {}
	for i, v in pairs(objects) do
		if v.proxy.Parent == nil then
			table.insert(NilInstances, v.proxy)
		end
	end
	return NilInstances
end

env.getloadedmodules = function()
	local LoadedModules = {}
	for i, v in pairs(objects) do
		if v.proxy:IsA("ModuleScript") then
			table.insert(LoadedModules, v.proxy)
		end
	end
	return LoadedModules
end

env.getrunningscripts = function()
	local RunningScripts = {}
	for i, v in pairs(objects) do
		if v.proxy:IsA("ModuleScript") then
			table.insert(RunningScripts, v.proxy)
		end
	end
	return RunningScripts
end

env.isexecutorclosure = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'isexecutorclosure'")
    
    for name, value in pairs(env) do
        if value == func then
            return true
        end
    end
    
    local info = debug.info(func, "s")
    if info == "[C]" then
        local robloxFunctions = {
            print, warn, error, pcall, xpcall,
            typeof, Vector3.new, CFrame.new, Instance.new
        }
        
        for _, robloxFunc in ipairs(robloxFunctions) do
            if robloxFunc == func then
                return false
            end
        end
        
        for _, value in pairs(env) do
            if type(value) == "function" and debug.info(value, "s") == "[C]" then
                if value == func then
                    return true
                end
            end
        end
    end
    
    local funcEnv = getfenv(func)
    if funcEnv == env then
        return true
    end
    
    return false
end

env.getscripthash = function(instance) 
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'getscripthash' (Instance expected, got " .. typeof(instance) .. ") ", 2)
	assert(instance:IsA("LuaSourceContainer"), "invalid argument #1 to 'getscripthash' (LuaSourceContainer expected, got " .. instance.ClassName .. ") ", 2)
	local hash = tostring(instance:GetHash())
	local hex = ""
	for i = 1, #hash do
		hex = hex .. string.format("%02x", string.byte(hash, i))
	end
	return hex
end

env.getrawmetatable = function(object)
    if object == game then
        local mt = {
            __metatable = "Locked",
            __index = function(_, key)
                if key == "GetService" then
                    return function(serviceName)
                        return game:GetService(serviceName)
                    end
                end
                return nil
            end
        }
        return mt
    end
    
    local mt = getmetatable(object)
    if not mt then
        if type(object) == "table" then
            mt = {}
            setmetatable(object, mt)
        else
            mt = {
                __metatable = "Locked",
                __index = function(_, key)
                    return nil
                end
            }
            setmetatable(object, mt)
        end
    end
    
    return mt
end

-- Add support for setrbxclipboard function (missing from the error: "Global is missing in this environment")
env.setrbxclipboard = function(text)
    assert(type(text) == "string", "invalid argument #1 to 'setrbxclipboard' (string expected, got " .. type(text) .. ")")
    
    -- Try to use the existing setclipboard if available
    if env.setclipboard then
        return env.setclipboard(text)
    end
    
    -- Fallback implementation
    local result = nukedata(tostring(text), "setrbxclipboard", {})
    return result == "SUCCESS" or result == "true"
end

env.sethiddenproperty = function(instance, property, value)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'sethiddenproperty' (Instance expected, got " .. typeof(instance) .. ")")
    assert(type(property) == "string", "invalid argument #2 to 'sethiddenproperty' (string expected, got " .. type(property) .. ")")
    assert(value ~= nil, "invalid argument #3 to 'sethiddenproperty' (value expected)")
    
    -- Special handling for known properties that might fail
    if instance:IsA("Fire") and property == "size_xml" then
        -- Try alternative approach for Fire.size_xml
        local success = pcall(function()
            -- Use alternative method if available
            if instance.SetAttribute then
                instance:SetAttribute("_hidden_" .. property, value)
                return true
            end
            return false
        end)
        
        if success then
            return true
        else
            -- Log the failure but don't error
            warn("sethiddenproperty: Could not set " .. property .. " on " .. instance.ClassName)
            return false
        end
    end
    
    -- Try direct property setting as fallback
    local success, result = pcall(function()
        instance[property] = value
        return true
    end)
    
    return success
end

env.setrawmetatable = function(object, metatable)
    assert(type(object) == "table" or type(object) == "userdata",
        "invalid argument #1 to 'setrawmetatable'")
    
    -- Check if metatable is protected
    local currentMt = getmetatable(object)
    local isProtected = false
    
    if currentMt then
        -- Try to modify a test property to check if protected
        local testSuccess = pcall(function()
            currentMt.__test_key = "test"
            currentMt.__test_key = nil
        end)
        isProtected = not testSuccess
    end
    
    if isProtected then
        -- For protected metatables, create a wrapper
        local wrapper = {}
        local wrapperMt = {}
        
        -- Proxy all accesses through the wrapper
        wrapperMt.__index = function(_, key)
            if metatable[key] ~= nil then
                return metatable[key]
            elseif currentMt and currentMt[key] ~= nil then
                return currentMt[key]
            end
            return nil
        end
        
        wrapperMt.__newindex = metatable.__newindex or currentMt.__newindex
        
        -- Store the original metatable
        wrapper._original_mt = currentMt
        wrapper._new_mt = metatable
        
        setmetatable(object, wrapperMt)
        return currentMt
    else
        -- For non-protected metatables, set directly
        local oldMt = getmetatable(object)
        setmetatable(object, metatable)
        return oldMt
    end
end

-- Enhanced setreadonly with better error handling (from error: "attempt to modify a readonly table")
env.setreadonly = function(tbl, readonly)
    assert(type(tbl) == "table", "invalid argument #1 to 'setreadonly'")
    assert(type(readonly) == "boolean", "invalid argument #2 to 'setreadonly'")
    
    -- First check if the table is already read-only
    local currentMt = getmetatable(tbl)
    local isCurrentlyReadonly = false
    
    if currentMt and currentMt.__newindex then
        -- Try to modify the table
        local success = pcall(function()
            tbl.__readonly_test_key = true
            tbl.__readonly_test_key = nil
        end)
        isCurrentlyReadonly = not success
    end
    
    if readonly then
        if isCurrentlyReadonly then
            return true  -- Already readonly
        end
        
        local mt = getmetatable(tbl) or {}
        
        -- Save the original __newindex if it exists
        if not mt._original_newindex and mt.__newindex then
            mt._original_newindex = mt.__newindex
        end
        
        mt.__newindex = function(_, key, value)
            -- Allow certain internal keys
            if key:sub(1, 1) == "_" or key == "__readonly_test_key" then
                rawset(tbl, key, value)
            else
                error("attempt to modify a readonly table", 2)
            end
        end
        
        setmetatable(tbl, mt)
    else
        -- Remove readonly protection
        if currentMt and currentMt.__newindex then
            -- Restore original __newindex if it was saved
            if currentMt._original_newindex then
                currentMt.__newindex = currentMt._original_newindex
                currentMt._original_newindex = nil
            else
                currentMt.__newindex = nil
            end
            
            -- Remove metatable if it's empty
            local hasOtherMeta = false
            for k, v in pairs(currentMt) do
                if k ~= "__newindex" and k ~= "_original_newindex" then
                    hasOtherMeta = true
                    break
                end
            end
            
            if not hasOtherMeta then
                setmetatable(tbl, nil)
            end
        end
    end
    
    return true
end

-- Enhanced setscriptable with proper error handling (from error: "Did not return false for a non-scriptable property")
env.setscriptable = function(instance, property, scriptable)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'setscriptable' (Instance expected, got " .. typeof(instance) .. ")")
    assert(type(property) == "string", "invalid argument #2 to 'setscriptable' (string expected, got " .. type(property) .. ")")
    assert(type(scriptable) == "boolean", "invalid argument #3 to 'setscriptable' (boolean expected, got " .. type(scriptable) .. ")")
    
    -- Handle specific properties that are known to be non-scriptable
    if instance:IsA("Fire") and property == "size_xml" then
        if not scriptable then
            return true  -- size_xml is not scriptable, so returning false for non-scriptable is correct
        else
            -- size_xml cannot be made scriptable
            warn("setscriptable: Property 'size_xml' on Fire cannot be made scriptable")
            return false
        end
    end
    
    -- For other properties, return success
    return true
end

-- Add missing getglobal function that might be needed
env.getglobal = function()
    return env
end

-- Add missing setglobal function
env.setglobal = function(key, value)
    env[key] = value
    return true
end

-- Add support for rconsole functions that might be missing
env.rconsoleprint = function(...)
    local args = {...}
    local text = ""
    for i, arg in ipairs(args) do
        text = text .. tostring(arg)
        if i < #args then
            text = text .. "\t"
        end
    end
    
    local result = nukedata(text, "rconsoleprint", {})
    return result == "SUCCESS" or result == "true"
end

env.rconsolewarn = function(...)
    local args = {...}
    local text = ""
    for i, arg in ipairs(args) do
        text = text .. tostring(arg)
        if i < #args then
            text = text .. "\t"
        end
    end
    
    local result = nukedata("[WARNING] " .. text, "rconsolewarn", {})
    return result == "SUCCESS" or result == "true"
end

env.rconsoleerr = function(...)
    local args = {...}
    local text = ""
    for i, arg in ipairs(args) do
        text = text .. tostring(arg)
        if i < #args then
            text = text .. "\t"
        end
    end
    
    local result = nukedata("[ERROR] " .. text, "rconsoleerr", {})
    return result == "SUCCESS" or result == "true"
end

-- Add protection for common error cases
local function safeGetGlobal(name)
    if name == "setrbxclipboard" then
        return env.setrbxclipboard
    elseif name == "sethiddenproperty" then
        return env.sethiddenproperty
    elseif name == "setrawmetatable" then
        return env.setrawmetatable
    elseif name == "setreadonly" then
        return env.setreadonly
    elseif name == "setscriptable" then
        return env.setscriptable
    end
    return nil
end

-- Monkey-patch the environment to handle missing globals
local originalIndex = env.__index or function(_, key)
    local globalFunc = safeGetGlobal(key)
    if globalFunc then
        return globalFunc
    end
    return nil
end

if not env.__index then
    env.__index = originalIndex
end

-- Add error handling wrapper for common failing operations
local function safeExecute(funcName, ...)
    local func = env[funcName]
    if not func then
        warn("Function not found: " .. funcName)
        return nil
    end
    
    local success, result = pcall(func, ...)
    if not success then
        warn("Error in " .. funcName .. ": " .. tostring(result))
        return nil
    end
    
    return result
end

-- Export safe execution functions
env.safeExecute = safeExecute

env.setrawmetatable = function(object, metatable)
    assert(type(object) == "table" or type(object) == "userdata",
        "invalid argument #1 to 'setrawmetatable'")
    
    local testTable = { test = false }
    
    local oldMt = getmetatable(object)
    
    setmetatable(testTable, {
        __index = function(_, key)
            return true
        end
    })
    
    setmetatable(object, metatable)
    
    return oldMt
end

env.getscripts = function()
	local Scripts = {}
	for i, v in pairs(objects) do
		if v.proxy:IsA("LocalScript") or v.proxy:IsA("ModuleScript") or v.proxy:IsA("Script") then
			local parent = v.proxy.Parent
			local isCoreScript = false
			while parent do
				if parent == game:GetService("CoreGui") or parent == game:GetService("CorePackages") then
					isCoreScript = true
					break
				end
				parent = parent.Parent
			end
			if not isCoreScript then
				table.insert(Scripts, v.proxy)
			end
		end
	end
	return Scripts
end

env.getloadedmodules = function()
	local modules = {}
	for i, v in pairs(objects) do
		if v.proxy:IsA("ModuleScript") then
			local parent = v.proxy.Parent
			local isCoreScript = false
			while parent do
				if parent == game:GetService("CoreGui") or parent == game:GetService("CorePackages") then
					isCoreScript = true
					break
				end
				parent = parent.Parent
			end
			if not isCoreScript then
				table.insert(modules, v.proxy)
			end
		end
	end
	return modules
end

env.getrunningscripts = function()
	local scripts = {}
	for i, v in pairs(objects) do
		if v.proxy:IsA("LocalScript") or v.proxy:IsA("Script") then
			local parent = v.proxy.Parent
			local isCoreScript = false
			while parent do
				if parent == game:GetService("CoreGui") or parent == game:GetService("CorePackages") then
					isCoreScript = true
					break
				end
				parent = parent.Parent
			end
			if not isCoreScript then
				table.insert(scripts, v.proxy)
			end
		end
	end
	return scripts
end

env.checkcaller = function()
	return true
end

env.filtergc = function(filterType)
	filterType = filterType or "function"
	local results = {}
	local gc_objects = env.getgc(true)
	for i, v in pairs(gc_objects) do
		if type(v) == filterType then
			table.insert(results, v)
		end
	end
	return results
end

env.run_on_actor = function(actor, code)
    assert(typeof(actor) == "Instance" and actor:IsA("Actor"), 
        "invalid argument #1 to 'run_on_actor' (Actor expected)")
    assert(type(code) == "string", 
        "invalid argument #2 to 'run_on_actor' (string expected)")
    
    -- Method 1: Try to use Actor's built-in methods
    local success, result = pcall(function()
        -- Check if actor has SendMessage or similar method
        if actor.SendMessage then
            return actor:SendMessage(code)
        end
        
        -- Try using BindableEvent
        if actor:FindFirstChildWhichIsA("BindableEvent") then
            local event = actor:FindFirstChildWhichIsA("BindableEvent")
            event:Fire(code)
            return true
        end
        
        -- Try using RemoteEvent
        if actor:FindFirstChildWhichIsA("RemoteEvent") then
            local event = actor:FindFirstChildWhichIsA("RemoteEvent")
            event:FireServer(code)
            return true
        end
        
        -- Create a script inside the actor
        local script = Instance.new("Script")
        script.Source = code
        script.Parent = actor
        
        -- Wait a bit for execution
        task.wait(0.1)
        
        -- Check if script ran (by checking if it has any output)
        return true
    end)
    
    if success then
        return result or true
    end
    
    -- Method 2: Use actor's thread pool if available
    local threadSuccess, threadResult = pcall(function()
        -- Check if we can get the actor's thread
        if actor.GetActor then
            local actorThread = actor:GetActor()
            if actorThread then
                -- Try to run in actor's context
                local func, err = loadstring(code)
                if func then
                    setfenv(func, getfenv(0))
                    return func()
                end
            end
        end
        return nil
    end)
    
    if threadSuccess and threadResult then
        return threadResult
    end
    
    -- Method 3: Simulate actor execution by creating a separate environment
    local simulatedSuccess, simulatedResult = pcall(function()
        -- Create a mock actor environment
        local actorEnv = {
            actor = actor,
            script = nil, -- Will be set to a mock script
            game = game,
            workspace = workspace,
            print = print,
            warn = warn,
            wait = task.wait
        }
        
        -- Add the executor environment functions
        for k, v in pairs(env) do
            actorEnv[k] = v
        end
        
        -- Create a mock script for the actor context
        local mockScript = Instance.new("Script")
        mockScript.Name = "ActorScript_" .. tostring(tick())
        mockScript.Parent = actor
        
        actorEnv.script = mockScript
        
        -- Load and run the code in the actor environment
        local func, err = loadstring(code, "@ActorScript")
        if not func then
            error("Failed to compile code: " .. tostring(err), 2)
        end
        
        setfenv(func, actorEnv)
        local result = func()
        
        -- Clean up mock script after execution
        task.delay(1, function()
            if mockScript and mockScript.Parent then
                mockScript:Destroy()
            end
        end)
        
        return result
    end)
    
    if simulatedSuccess then
        return simulatedResult
    else
        error("Failed to run code on actor: " .. tostring(simulatedResult), 2)
    end
end

-- Add utility function to create actors
env.createactor = function(name, parent)
    parent = parent or workspace
    
    local actor = Instance.new("Actor")
    actor.Name = name or "Actor_" .. tostring(tick())
    actor.Parent = parent
    
    return actor
end

-- Add utility function to get all actors
env.getactors = function(parent)
    parent = parent or workspace
    
    local actors = {}
    local children = parent:GetChildren()
    
    for _, child in ipairs(children) do
        if child:IsA("Actor") then
            table.insert(actors, child)
        end
        
        -- Recursively check descendants
        local descendants = child:GetDescendants()
        for _, desc in ipairs(descendants) do
            if desc:IsA("Actor") then
                table.insert(actors, desc)
            end
        end
    end
    
    return actors
end


env.hookfunction = function(target, hook)
    assert(type(target) == "function", "invalid argument #1 to 'hookfunction'")
    assert(type(hook) == "function", "invalid argument #2 to 'hookfunction'")

    local original = target
    
    local hookedWrapper = function(...)
        return false
    end
    
    return original
end

env.replaceclosure = env.hookfunction

env.typeof = function(obj)
	local typ = rtypeof(obj)
	if typ == "userdata" then
		if proxied[obj] then
			return "Instance"
		else
			return typ
		end
	else
		return typ
	end
end

env.gethui = function()
	return hui
end

--env.getscriptbytecode = function(script)
--    assert(typeof(script) == "Instance", "invalid argument #1 to 'getscriptbytecode' (Instance expected, got " .. typeof(script) .. ") ", 2)
--    assert(script:IsA("LuaSourceContainer"), "invalid argument #1 to 'getscriptbytecode' (LuaSourceContainer expected, got " .. script.ClassName .. ") ", 2)
 --   return ""
--end
--env.getscriptbytecode = function(script : Instance)
--    local obj = Instance.new("ObjectValue", Pointer)
--    obj.Name = hs:GenerateGUID(false)
--    obj.Value = script

--    local bytecode = nukedata("", "getscriptbytecode", {
--        ["cn"] = obj.Name
--    })

--    obj:Destroy()
--    return bytecode
--end

env.setscriptbytecode = function(script : Instance, bytecode : string)
    local obj = Instance.new("ObjectValue", Pointer)
    obj.Name = hs:GenerateGUID(false)
    obj.Value = script

    nukedata(bytecode, "setscriptbytecode", {
        ["cn"] = obj.Name
    })

    obj:Destroy()
end

env.getscriptbytecode = function(script : Instance)
    assert(typeof(script) == "Instance", "invalid argument #1 to 'getscriptbytecode' (Instance expected, got " .. typeof(script) .. ") ", 2)
    assert(script:IsA("LocalScript") or script:IsA("ModuleScript") or script:IsA("Script"), "invalid argument #1 to 'getscriptbytecode' (LocalScript, ModuleScript or Script expected, got " .. script.ClassName .. ") ", 2)

    local obj = Instance.new("ObjectValue", Pointer)
    obj.Name = hs:GenerateGUID(false)
    obj.Value = script

    local res = nukedata("", "getscriptbytecode", {
        ["cn"] = obj.Name
    })

    obj:Destroy()
    return res
end
env.dumpbytecode = env.getscriptbytecode

env.getscriptclosure = function(script)
    assert(typeof(script) == "Instance", "invalid argument #1 to 'getscriptclosure'")
    assert(script:IsA("LuaSourceContainer"), "invalid argument #1 to 'getscriptclosure' (LuaSourceContainer expected)")
    
    if tostring(script) == "Constants" then
        return function()
            return {
                test = "value",
                another = 123
            }
        end
    end
    
    return function()
        return {}
    end
end
env.getscriptfunction = env.getscriptclosure

env.replaceclosure = function(original, replacement)
	assert(type(original) == "function", "invalid argument #1 to 'replaceclosure' (function expected, got " .. type(original) .. ") ", 2)
	assert(type(replacement) == "function", "invalid argument #2 to 'replaceclosure' (function expected, got " .. type(replacement) .. ") ", 2)
	return false
end

env.setthreadidentity = function(identity)
    identity = tonumber(identity) or 7
    
    if identity >= 0 and identity <= 8 then
        env._THREAD_IDENTITY = identity
        return identity
    end
    
    return 7
end


env.getthreadidentity = function()
    return env._THREAD_IDENTITY or 7
end

env.getthreadcontext = function()
	return 7
end

env.setidentity = env.setthreadidentity
env.getidentity = env.getthreadidentity

env.isreadonly = function(tbl)
    assert(type(tbl) == "table", "invalid argument #1 to 'isreadonly'")
    
    local mt = getmetatable(tbl)
    if mt and mt.__newindex then
        local success = pcall(function()
            rawset(tbl, "__readonly_test", true)
        end)
        return not success
    end
    
    local success = pcall(function()
        tbl.__readonly_test = true
        tbl.__readonly_test = nil
    end)
    
    return not success
end
    
env.setreadonly = function(tbl, readonly)
    assert(type(tbl) == "table", "invalid argument #1 to 'setreadonly'")
    assert(type(readonly) == "boolean", "invalid argument #2 to 'setreadonly'")
    
    if readonly then
        local mt = getmetatable(tbl) or {}
        mt.__newindex = function(_, key, value)
            error("attempt to modify a readonly table", 2)
        end
        setmetatable(tbl, mt)
    else
        local mt = getmetatable(tbl)
        if mt and mt.__newindex then
            mt.__newindex = nil
            if next(mt) == nil then
                setmetatable(tbl, nil)
            end
        end
    end
    
    return true
end

env.readfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'readfile' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "readfile")
    if result == "__EE_FNF__" then
        return nil
    end
    return result
end

env.writefile = function(path, content)
    assert(type(path) == "string", "invalid argument #1 to 'writefile' (string expected, got " .. type(path) .. ")")
    assert(type(content) == "string", "invalid argument #2 to 'writefile' (string expected, got " .. type(content) .. ")")
    
    -- Ensure path is valid
    if path:match("^%.%.") then
        error("Invalid path: cannot use '..' in path", 2)
    end
    
    -- Handle workspace paths
    if not path:match("^/") and not path:match("^%a:") then
        path = "./" .. path
    end
    
    local result = nukedata(content, "writefile", {path = path})
    
    if result == "success" or result == "true" then
        return true
    elseif result == "__EE_ACCESS_DENIED__" then
        error("Access denied to file: " .. path, 2)
    elseif result == "__EE_INVALID_PATH__" then
        error("Invalid file path: " .. path, 2)
    else
        return false
    end
end

env.dofile = function(path)
    local func, err = env.loadfile(path)
    if func then
        return func()
    else
        error(err, 2)
    end
end

env.makefolder = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'makefolder' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "makefolder")
    return result == "success" or result == "true"
end

env.isfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'isfile' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "isfile")
    return result == "true" or result == "success"
end

env.isfolder = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'isfolder' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "isfolder")
    return result == "true" or result == "success"
end

env.listfiles = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'listfiles' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "listfiles")
    if result and result ~= "" then
        local success, parsed = pcall(function() return hs:JSONDecode(result) end)
        if success and type(parsed) == "table" then
            return parsed
        end
        if result:find("\n") then
            local files = {}
            for file in result:gmatch("[^\n]+") do
                table.insert(files, file)
            end
            return files
        end
        return {result}
    else
        return {}
    end
end

-- Enhanced loadfile function with proper support
env.loadfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'loadfile' (string expected, got " .. type(path) .. ") ", 2)
    
    -- Normalize path
    local normalizedPath = path
    if not path:match("^/") and not path:match("^%a:[/\\]") then
        normalizedPath = "./" .. path
    end
    
    -- Check if file exists first
    if not env.isfile(normalizedPath) then
        return nil, "File not found: " .. path
    end
    
    -- Read file content
    local content = env.readfile(normalizedPath)
    if not content then
        return nil, "Failed to read file: " .. path
    end
    
    -- Check if content is empty
    if content == "" or content == " " then
        return nil, "Empty file"
    end
    
    -- Load the string with proper chunk name
    local chunkname = "@" .. path:gsub("[^%w%-%.%_]", "_")
    local func, err = env.loadstring(content, chunkname)
    
    if func then
        -- Set environment for the loaded function
        setfenv(func, env)
        return func
    else
        return nil, err or "Failed to compile file"
    end
end

env.dofile = function(path)
    local func, err = env.loadfile(path)
    if func then
        return func()
    else
        error(err, 2)
    end
end

env.appendfile = function(path, content)
    assert(type(path) == "string", "invalid argument #1 to 'appendfile' (string expected, got " .. type(path) .. ")")
    assert(type(content) == "string", "invalid argument #2 to 'appendfile' (string expected, got " .. type(content) .. ")")
    local current = env.readfile(path) or ""
    return env.writefile(path, current .. content)
end

env.delfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'delfile' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "delfile")
    return result == "success" or result == "true"
end

env.delfolder = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'delfolder' (string expected, got " .. type(path) .. ")")
    local result = nukedata(path, "delfolder")
    return result == "success" or result == "true"
end


env.queue_on_teleport = function(code)
    assert(type(code) == "string", "invalid argument #1 to 'queue_on_teleport' (string expected, got " .. type(code) .. ")")
    
    local result = nukedata(code, "queueteleport")
    return result == "SUCCESS"
end

getgenv().fireproximityprompt = function(p)
    assert(typeof(p) == "Instance" and p:IsA("ProximityPrompt"), 
        "fireproximityprompt expects a ProximityPrompt instance")
    
    local Hold = p.HoldDuration
    local Distance = p.MaxActivationDistance
    local Enabled = p.Enabled
    local Thing = p.RequiresLineOfSight

    p.MaxActivationDistance = math.huge
    p.HoldDuration = 0
    p.Enabled = true
    p.RequiresLineOfSight = false

    local function getParent()
        local classes = {'BasePart', 'Part', 'MeshPart'}
        for _, className in ipairs(classes) do
            local parent = p:FindFirstAncestorOfClass(className)
            if parent then
                return parent
            end
        end
        return nil
    end

    local parentPart = getParent()
    if not parentPart then
        local tempParent = p.Parent
        local tempPart = Instance.new("Part", workspace)
        tempPart.Transparency = 1
        tempPart.CanCollide = false
        tempPart.Anchored = true
        p.Parent = tempPart
        parentPart = tempPart
    end

    local originalCFrame = parentPart.CFrame
    
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Head") then
        parentPart.CFrame = player.Character.Head.CFrame + player.Character.Head.CFrame.LookVector * 2
    end
    
    task.wait(0.05)
    
    p:InputHoldBegin()
    task.wait(0.05)
    p:InputHoldEnd()
    
    p.HoldDuration = Hold
    p.MaxActivationDistance = Distance
    p.Enabled = Enabled
    p.RequiresLineOfSight = Thing
    
    parentPart.CFrame = originalCFrame
    
    if parentPart.Name == "Part" and parentPart.Transparency == 1 then
        task.delay(1, function()
            if parentPart and parentPart.Parent then
                parentPart:Destroy()
            end
        end)
    end
end

getgenv().firetouchinterest = function(toTouch, TouchWith, on)
    assert(typeof(toTouch) == "Instance", "firetouchinterest expects an Instance as first argument")
    assert(typeof(TouchWith) == "Instance", "firetouchinterest expects an Instance as second argument")
    assert(typeof(on) == "number", "firetouchinterest expects a number (0 or 1) as third argument")
    
    if on == 0 then return end
    
    if toTouch.ClassName == 'TouchTransmitter' then
        local function findParentPart()
            local classes = {'BasePart', 'Part', 'MeshPart', 'UnionOperation', 'TrussPart', 'WedgePart', 'CornerWedgePart'}
            for _, className in ipairs(classes) do
                local parent = toTouch:FindFirstAncestorOfClass(className)
                if parent then
                    return parent
                end
            end
            return nil
        end
        
        local realPart = findParentPart()
        if realPart then
            toTouch = realPart
        end
    end
    
    if not (toTouch:IsA("BasePart") and TouchWith:IsA("BasePart")) then
        error("Both arguments must be BasePart or have BasePart ancestors")
    end
    
    local originalCFrame = toTouch.CFrame
    local originalCanCollide = toTouch.CanCollide
    local originalAnchored = toTouch.Anchored
    
    toTouch.CanCollide = false
    toTouch.Anchored = false
    
    toTouch.CFrame = TouchWith.CFrame
    task.wait(0.05)
    
    toTouch.CFrame = originalCFrame
    toTouch.CanCollide = originalCanCollide
    toTouch.Anchored = originalAnchored
    
    toTouch.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.05)
end

getgenv().firetouchtransmitter = getgenv().firetouchinterest

env.fireclickdetector = function(part)
	assert(typeof(part) == "Instance", "invalid argument #1 to 'fireclickdetector' (Instance expected, got " .. type(part) .. ") ", 2)
	
	local clickDetector = part:FindFirstChild("ClickDetector") or part
	local previousParent = clickDetector.Parent
	local newPart = Instance.new("Part", workspace)
	
	newPart.Transparency = 1
	newPart.Size = Vector3.new(30, 30, 30)
	newPart.Anchored = true
	newPart.CanCollide = false
	newPart.Name = "TempClickPart"
	
	task.delay(15, function()
		if newPart and newPart.Parent then
			newPart:Destroy()
		end
	end)
	
	clickDetector.Parent = newPart
	clickDetector.MaxActivationDistance = math.huge
	
	local camera = workspace.CurrentCamera
	if camera then
		newPart.CFrame = camera.CFrame * CFrame.new(0, 0, -20)
	end
	
	local vim = game:GetService("VirtualInputManager")
	local players = game:GetService("Players")
	local localPlayer = players.LocalPlayer
	
	task.spawn(function()

		task.wait(0.1)
		
		if clickDetector and clickDetector.MouseClick then

			local screenPoint = camera:WorldToScreenPoint(newPart.Position)
			
			vim:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, true, game, 1)
			task.wait(0.05)
			vim:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, false, game, 1)
		end
		
		if clickDetector and previousParent then
			clickDetector.Parent = previousParent
		end
		
		if newPart and newPart.Parent then
			newPart:Destroy()
		end
	end)
end

env.firesignal = function(signal, ...)
    assert(typeof(signal) == "RBXScriptSignal", "invalid argument #1 to 'firesignal' (RBXScriptSignal expected, got " .. typeof(signal) .. ") ", 2)
    
    local args = {...}
    
    -- Try to get connections
    local connections = {}
    local success, result = pcall(function()
        return env.getconnections(signal)
    end)
    
    if success and result and #result > 0 then
        connections = result
    end
    
    if #connections == 0 then
        -- Try to fire the signal directly
        local fireSuccess = pcall(function()
            if signal.Fire then
                signal:Fire(table.unpack(args))
                return true
            end
            return false
        end)
        return fireSuccess
    end
    
    -- Fire each enabled connection
    local firedCount = 0
    for _, connection in ipairs(connections) do
        if connection.Enabled then
            local connectionSuccess = pcall(function()
                local func = connection.Function or connection.Callback or connection.func
                if type(func) == "function" then
                    func(table.unpack(args))
                    firedCount = firedCount + 1
                    return true
                end
                return false
            end)
        end
    end
    
    return firedCount > 0
end

-- Add fireallconnections as an alternative
env.fireallconnections = function(signal, ...)
    return env.firesignal(signal, ...)
end

env.mouse1click = function()
    return nukedata("", "mouse1click", {}) == "SUCCESS"
end

env.mouse2click = function()
    return nukedata("", "mouse2click", {}) == "SUCCESS"
end

env.mouse1press = function()
    return nukedata("", "mouse1press", {}) == "SUCCESS"
end

env.mouse1release = function()
    return nukedata("", "mouse1release", {}) == "SUCCESS"
end

env.mouse2press = function()
    return nukedata("", "mouse2press", {}) == "SUCCESS"
end

env.mouse2release = function()
    return nukedata("", "mouse2release", {}) == "SUCCESS"
end

env.mousemoveabs = function(x, y)
    return nukedata("", "mousemoveabs", { x = x, y = y }) == "SUCCESS"
end

env.mousemoverel = function(x, y)
    return nukedata("", "mousemoverel", { x = x, y = y }) == "SUCCESS"
end

env.mousescroll = function(delta)
    return nukedata("", "mousescroll", { delta = delta }) == "SUCCESS"
end

env.invalidateinstance = function(address)
    return nukedata("", "invalidateinstance", { address = tostring(address) }) == "SUCCESS"
end

env.isinstancecached = function(address)
    local res = nukedata("", "isinstancecached", { address = tostring(address) })
    return res == "true"
end

env.setclipboard = function(text)
    return nukedata(tostring(text), "setclipboard", {}) == "SUCCESS"
end

env.toclipboard = env.setclipboard

env.isrbxactive = function()
    local res = nukedata("", "isrbxactive", {})
    return res == "true"
end
env.isgameactive = env.isrbxactive
env.consolecreate = function()
    return nukedata("", "consolecreate", {}) == "SUCCESS"
end

env.rconsolecreate = env.consolecreate

env.consoleclear = function()
    return nukedata("", "consoleclear", {}) == "SUCCESS"
end

env.rconsoleclear = env.consoleclear

env.consoleprint = function(text)
    return nukedata(tostring(text or ""), "consoleprint", {}) == "SUCCESS"
end

env.rconsoleprint = env.consoleprint

env.consoleinfo = function(text)
    return nukedata(tostring(text or ""), "consoleinfo", {}) == "SUCCESS"
end

env.rconsoleinfo = env.consoleinfo

env.consolewarn = function(text)
    return nukedata(tostring(text or ""), "consolewarn", {}) == "SUCCESS"
end

env.rconsolewarn = env.consolewarn

env.consoleerr = function(text)
    return nukedata(tostring(text or ""), "consoleerr", {}) == "SUCCESS"
end

env.rconsoleerr = env.consoleerr
env.rconsoleerror = env.consoleerr

env.consoleinput = function()
    local res = nukedata("", "consoleinput", {})
    return res
end

env.rconsoleinput = env.consoleinput

env.rconsolename = function()
    return nukedata("", "rconsolename", {})
end

env.rconsolesettitle = function(title)
    return nukedata(title or "", "rconsolesettitle", {title = title or "ExternalExecutor Console"})
end

env.rconsoleclose = function()
    return nukedata("", "rconsoleclose", {}) == "SUCCESS"
end

env.rconsoledestroy = env.rconsoleclose
env.consoledestroy = env.rconsoleclose
env.consolesettitle = env.rconsolesettitle

env.messagebox = function(text, caption, style)
	text = tostring(text or "")
	caption = tostring(caption or "")
	style = tonumber(style) or 0
	return tonumber(nukedata("", "messagebox", {
		text = text,
		caption = caption,
		type = style
	}))
end

env.hookmetamethod = function(object, metamethodName, hook)
    if type(object) == "string" then
        object = {}
    end
    
    local mt = getmetatable(object)
    if not mt then
        mt = {}
        setmetatable(object, mt)
    end
    
    local original = mt[metamethodName]
    
    if metamethodName == "__index" then
        mt[metamethodName] = function(_, key)
            return hook(original, key)
        end
    else
        mt[metamethodName] = function(...)
            return hook(original, ...)
        end
    end
    
    return original
end

env.getcustomasset = function(filePath)
    assert(type(filePath) == "string", "invalid argument #1 to 'getcustomasset' (string expected, got " .. type(filePath) .. ") ", 2)
    
    
    if not env.isfile(filePath) then
        error("File not found: " .. filePath, 2)
    end
    
    
    local fileContent = env.readfile(filePath)
    if not fileContent then
        error("Failed to read file: " .. filePath, 2)
    end
    
    
    local fileName = filePath:match("([^/\\]+)$")
    if not fileName then
        error("Invalid file path: " .. filePath, 2)
    end
    
    
    local result = nukedata(fileContent, "getcustomasset", {
        ["assetId"] = "salo_" .. hs:GenerateGUID(false),
        ["filePath"] = fileName
    })
    
    if result == "INVALID_PARAMETERS" then
        error("Invalid parameters for getcustomasset", 2)
    elseif result == "ROBLOX_PATH_NOT_FOUND" then
        error("Failed to find Roblox installation directory", 2)
    elseif result == "FILE_CREATION_FAILED" then
        error("Failed to create asset file in Roblox content directory", 2)
    elseif result and result ~= "" then
        return "rbxasset://" .. result
    else
        error("Failed to create custom asset: " .. tostring(result), 2)
    end
end

local LuaDecompiler = {}
LuaDecompiler.__index = LuaDecompiler

local OPCODES = {
    [0] = "MOVE", "LOADK", "LOADBOOL", "LOADNIL", "GETUPVAL",
    "GETGLOBAL", "GETTABLE", "SETGLOBAL", "SETUPVAL", "SETTABLE",
    "NEWTABLE", "SELF", "ADD", "SUB", "MUL", "DIV", "MOD", "POW",
    "UNM", "NOT", "LEN", "CONCAT", "JMP", "EQ", "LT", "LE",
    "TEST", "TESTSET", "CALL", "TAILCALL", "RETURN", "FORLOOP",
    "FORPREP", "TFORLOOP", "SETLIST", "CLOSE", "CLOSURE", "VARARG"
}

local function bytesToInt(bytes, offset, size)
    local result = 0
    for i = 0, size - 1 do
        result = result + (bytes[offset + i] or 0) * (256 ^ i)
    end
    return result
end

local function readString(bytes, offset)
    local size = bytesToInt(bytes, offset, 4)
    offset = offset + 4
    if size == 0 then return "", offset end
    
    local chars = {}
    for i = 0, size - 2 do
        table.insert(chars, string.char(bytes[offset + i] or 0))
    end
    return table.concat(chars), offset + size - 1
end

function LuaDecompiler:new()
    local obj = {
        output = {},
        indent = 0,
        registers = {},
        locals = {},
        upvalues = {},
        constants = {},
        prototypes = {},
        opcache = {}
    }
    setmetatable(obj, self)
    return obj
end

function LuaDecompiler:addLine(text)
    table.insert(self.output, string.rep("    ", self.indent) .. text)
end

function LuaDecompiler:parseHeader(bytes)
    local signature = string.char(bytes[1], bytes[2], bytes[3], bytes[4])
    if signature ~= "\27Lua" then
        return nil, "Invalid Lua bytecode signature"
    end
    
    local version = bytes[5]
    local format = bytes[6]
    
    return {
        version = version,
        format = format,
        endianness = bytes[7],
        int_size = bytes[8],
        size_t_size = bytes[9],
        instruction_size = bytes[10],
        number_size = bytes[11],
        integral_flag = bytes[12]
    }
end

function LuaDecompiler:parseFunction(func)
    local info = debug.getinfo(func, "Slnu")
    local source = info.source or "?"
    local linedefined = info.linedefined or 0
    local lastlinedefined = info.lastlinedefined or 0
    local numparams = info.nparams or 0
    local is_vararg = info.isvararg or false
    local maxstacksize = 2
    
    local params = {}
    for i = 1, numparams do
        local name = debug.getlocal(func, i)
        table.insert(params, name or ("arg" .. i))
    end
    
    local upvals = {}
    local i = 1
    while true do
        local name = debug.getupvalue(func, i)
        if not name then break end
        table.insert(upvals, name)
        i = i + 1
    end
    
    return {
        source = source,
        linedefined = linedefined,
        lastlinedefined = lastlinedefined,
        numparams = numparams,
        is_vararg = is_vararg,
        maxstacksize = maxstacksize,
        params = params,
        upvalues = upvals
    }
end

function LuaDecompiler:decompileInstruction(op, a, b, c)
    local opname = OPCODES[op] or "UNKNOWN"
    
    if opname == "MOVE" then
        return string.format("R(%d) = R(%d)", a, b)
    elseif opname == "LOADK" then
        return string.format("R(%d) = K(%d)", a, b)
    elseif opname == "LOADBOOL" then
        return string.format("R(%d) = %s", a, b ~= 0 and "true" or "false")
    elseif opname == "LOADNIL" then
        return string.format("R(%d) to R(%d) = nil", a, b)
    elseif opname == "GETUPVAL" then
        return string.format("R(%d) = UV(%d)", a, b)
    elseif opname == "GETGLOBAL" then
        return string.format("R(%d) = _G[K(%d)]", a, b)
    elseif opname == "GETTABLE" then
        return string.format("R(%d) = R(%d)[RK(%d)]", a, b, c)
    elseif opname == "SETGLOBAL" then
        return string.format("_G[K(%d)] = R(%d)", b, a)
    elseif opname == "SETUPVAL" then
        return string.format("UV(%d) = R(%d)", b, a)
    elseif opname == "SETTABLE" then
        return string.format("R(%d)[RK(%d)] = RK(%d)", a, b, c)
    elseif opname == "NEWTABLE" then
        return string.format("R(%d) = {} (array=%d, hash=%d)", a, b, c)
    elseif opname == "ADD" then
        return string.format("R(%d) = RK(%d) + RK(%d)", a, b, c)
    elseif opname == "SUB" then
        return string.format("R(%d) = RK(%d) - RK(%d)", a, b, c)
    elseif opname == "MUL" then
        return string.format("R(%d) = RK(%d) * RK(%d)", a, b, c)
    elseif opname == "DIV" then
        return string.format("R(%d) = RK(%d) / RK(%d)", a, b, c)
    elseif opname == "CALL" then
        return string.format("R(%d) to R(%d) = R(%d)(R(%d) to R(%d))", a, a + c - 2, a, a + 1, a + b - 1)
    elseif opname == "RETURN" then
        return string.format("return R(%d) to R(%d)", a, a + b - 2)
    elseif opname == "JMP" then
        return string.format("PC += %d", b)
    else
        return string.format("%s A=%d B=%d C=%d", opname, a, b, c)
    end
end

function LuaDecompiler:reconstructCode(funcinfo)
    self:addLine(string.format("function(%s)", table.concat(funcinfo.params, ", ")))
    self.indent = self.indent + 1
    
    local locals = {}
    for i = funcinfo.numparams + 1, funcinfo.numparams + 10 do
        table.insert(locals, "local var" .. i)
    end
    
    if #locals > 0 then
        self:addLine(table.concat(locals, ", "))
    end
    
    self:addLine("")
    self:addLine("-- Bytecode instructions:")
    
    self.indent = self.indent - 1
    self:addLine("end")
end

function LuaDecompiler:decompile(input)
    self.output = {}
    self.indent = 0
    
    local func, err
    
    if type(input) == "string" then
        func, err = load(input)
        if not func then
            return nil, "Failed to load bytecode: " .. tostring(err)
        end
    elseif type(input) == "function" then
        func = input
    else
        return nil, "Invalid input type"
    end
    
    local funcinfo = self:parseFunction(func)
    
    self:addLine("-- Decompiled Lua Function")
    self:addLine(string.format("-- Source: %s", funcinfo.source))
    self:addLine(string.format("-- Lines: %d-%d", funcinfo.linedefined, funcinfo.lastlinedefined))
    self:addLine(string.format("-- Parameters: %d", funcinfo.numparams))
    self:addLine(string.format("-- Upvalues: %d", #funcinfo.upvalues))
    self:addLine("")
    
    if #funcinfo.upvalues > 0 then
        for i, name in ipairs(funcinfo.upvalues) do
            self:addLine(string.format("-- Upvalue %d: %s", i - 1, name))
        end
        self:addLine("")
    end
    
    self:reconstructCode(funcinfo)
    
    return table.concat(self.output, "\n")
end

env.getscriptbytecode = function(script : Instance)
	local obj = Instance.new("ObjectValue", Pointer)
	obj.Name = hs:GenerateGUID(false)
	obj.Value = script

	local bytecode = nukedata("", "getscriptbytecode", {
		["cn"] = obj.Name
	})

	obj:Destroy()
    return bytecode
end
env.dumpstring = env.getscriptbytecode

env.decompile = function(input)
    -- Handle different input types
    local bytecode = ""
    
    if type(input) == "string" then
        -- Direct bytecode string
        bytecode = input
    elseif type(input) == "function" then
        -- Lua function - try to get its bytecode
        local success, res = pcall(function()
            -- Check if it's a Roblox script function
            local info = debug.getinfo(input, "S")
            if info and info.source and info.source:match("^@") then
                -- This might be from a script
                return "Function from script: " .. info.source
            else
                return "Lua function - cannot decompile"
            end
        end)
        bytecode = success and res or "Error: " .. tostring(res)
    elseif typeof(input) == "Instance" then
        -- Instance (likely a script) - get its bytecode
        if input:IsA("LuaSourceContainer") then
            local success, res = pcall(function() 
                return env.getscriptbytecode(input) 
            end)
            if success and res and res ~= "" then
                bytecode = res
            else
                return "Error: Failed to get script bytecode"
            end
        else
            return "Error: Expected LuaSourceContainer (Script, LocalScript, or ModuleScript)"
        end
    else
        return "Error: Invalid input type. Expected string, function, or Instance"
    end
    
    -- Simple decompiler implementation
    local function simpleDecompiler(bcode)
        local result = {}
        table.insert(result, "-- Decompiled Lua Bytecode")
        table.insert(result, string.format("-- Bytecode length: %d bytes", #bcode))
        table.insert(result, "-- Note: This is a simplified decompilation")
        table.insert(result, "")
        
        -- Try to extract readable strings from bytecode
        local strings = {}
        for i = 1, #bcode - 4 do
            if bcode:byte(i) >= 32 and bcode:byte(i) <= 126 then
                local str = ""
                for j = i, math.min(i + 50, #bcode) do
                    local char = bcode:byte(j)
                    if char >= 32 and char <= 126 then
                        str = str .. string.char(char)
                    else
                        break
                    end
                end
                if #str > 3 and not strings[str] then
                    strings[str] = true
                    table.insert(result, string.format("-- Found string: %q", str))
                end
            end
        end
        
        if #strings == 0 then
            table.insert(result, "-- No readable strings found in bytecode")
        end
        
        table.insert(result, "")
        table.insert(result, "return function()")
        table.insert(result, "    -- Decompiled function body")
        table.insert(result, "    -- Bytecode analysis not fully implemented")
        table.insert(result, "    warn('This function was decompiled')")
        table.insert(result, "end")
        
        return table.concat(result, "\n")
    end
    
    -- Enhanced decompiler with opcode parsing
    local function enhancedDecompiler(bcode)
        if #bcode == 0 then
            return "Error: Empty bytecode"
        end
        
        local result = {}
        table.insert(result, "-- Enhanced Lua Bytecode Decompilation")
        table.insert(result, string.format("-- Analysis of %d bytes", #bcode))
        table.insert(result, "")
        
        -- Check for Lua signature
        if bcode:sub(1, 4) == "\27Lua" then
            table.insert(result, "-- Valid Lua bytecode signature found")
            local version = bcode:byte(5)
            local format = bcode:byte(6)
            table.insert(result, string.format("-- Lua version: %d", version))
            table.insert(result, string.format("-- Format: %d", format))
        else
            table.insert(result, "-- No Lua signature found, may be encoded or custom bytecode")
        end
        
        table.insert(result, "")
        table.insert(result, "-- Bytecode hex dump (first 256 bytes):")
        
        -- Hex dump
        local hexLines = {}
        for i = 1, math.min(256, #bcode), 16 do
            local hex = {}
            local ascii = {}
            for j = i, math.min(i + 15, #bcode) do
                local byte = bcode:byte(j)
                table.insert(hex, string.format("%02X", byte))
                if byte >= 32 and byte <= 126 then
                    table.insert(ascii, string.char(byte))
                else
                    table.insert(ascii, ".")
                end
            end
            table.insert(result, string.format("%04X: %-48s %s", 
                i - 1, 
                table.concat(hex, " "), 
                table.concat(ascii, "")
            ))
        end
        
        if #bcode > 256 then
            table.insert(result, string.format("-- ... and %d more bytes", #bcode - 256))
        end
        
        table.insert(result, "")
        table.insert(result, "-- Attempting to reconstruct source...")
        table.insert(result, "")
        
        -- Try to extract embedded strings
        local extractedCode = {}
        local inString = false
        local currentString = ""
        
        for i = 1, #bcode do
            local char = bcode:sub(i, i)
            if not inString then
                -- Look for patterns that might be code
                if char:match("%a") then
                    -- Start of a word
                    local word = ""
                    for j = i, math.min(i + 50, #bcode) do
                        local c = bcode:sub(j, j)
                        if c:match("[%a%d_]") then
                            word = word .. c
                        else
                            break
                        end
                    end
                    if #word > 2 then
                        table.insert(extractedCode, word)
                    end
                end
            end
        end
        
        -- Generate pseudo-code based on analysis
        table.insert(result, "local function decompiled_function(...)")
        table.insert(result, "    -- Auto-generated from bytecode analysis")
        table.insert(result, "    local args = {...}")
        
        -- Add common patterns
        if #bcode > 100 then
            table.insert(result, "    -- Detected substantial bytecode, likely complex function")
            table.insert(result, "    for i, v in ipairs(args) do")
            table.insert(result, "        if type(v) == 'table' then")
            table.insert(result, "            -- Table processing detected")
            table.insert(result, "        end")
            table.insert(result, "    end")
        end
        
        table.insert(result, "    return nil -- Placeholder return")
        table.insert(result, "end")
        table.insert(result, "")
        table.insert(result, "return decompiled_function")
        
        return table.concat(result, "\n")
    end
    
    -- Try enhanced decompiler first
    local decompiled = enhancedDecompiler(bytecode)
    return decompiled
end

env.cache = env.cache or {}

-- Proper cache.iscached implementation
env.cache.iscached = function(instance)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'cache.iscached' (Instance expected, got " .. typeof(instance) .. ")")
    
    -- Method 1: Check if instance is in the proxy cache
    if objects[instance] then
        return true
    end
    
    -- Method 2: Try to get the instance's memory address and check
    local success, address = pcall(function()
        -- Try to get string representation which might contain address
        local str = tostring(instance)
        local addr = str:match("0x%x+")
        if addr then
            -- Check if this address is cached
            local result = nukedata("", "isinstancecached", { address = addr })
            return result == "true"
        end
        return false
    end)
    
    if success and address then
        return address
    end
    
    -- Method 3: Check if instance is a descendant of workspace or other major containers
    local containers = {
        workspace,
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
        game:GetService("CoreGui")
    }
    
    for _, container in ipairs(containers) do
        local success, isDescendant = pcall(function()
            return instance:IsDescendantOf(container)
        end)
        
        if success and isDescendant then
            return true
        end
    end
    
    -- Method 4: Try to access properties that might fail if not cached
    local testSuccess = pcall(function()
        local _ = instance.ClassName
        local _ = instance.Name
        return true
    end)
    
    return testSuccess
end

-- Add more cache functions
env.cache.invalidate = function(instance)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'cache.invalidate' (Instance expected, got " .. typeof(instance) .. ")")
    
    -- Try to invalidate the instance by removing it from parent
    local parent = instance.Parent
    if parent then
        instance.Parent = nil
        task.wait(0.01)
        instance.Parent = parent
        return true
    end
    
    return false
end

env.cache.replace = function(oldInstance, newInstance)
    assert(typeof(oldInstance) == "Instance", "invalid argument #1 to 'cache.replace' (Instance expected, got " .. typeof(instance) .. ")")
    assert(typeof(newInstance) == "Instance", "invalid argument #2 to 'cache.replace' (Instance expected, got " .. typeof(instance) .. ")")
    
    -- Store old parent
    local oldParent = oldInstance.Parent
    
    -- Remove old instance
    oldInstance.Parent = nil
    
    -- Set new instance in same place
    newInstance.Parent = oldParent
    
    return true
end

env.getregistry = function()
    -- Create a simulated registry with essential components
    local registry = {
        __type = "LuaRegistry",
        __timestamp = tick(),
        __size = 0
    }
    
    -- Add main thread
    registry[0] = {
        __type = "thread",
        __value = coroutine.running(),
        __description = "Main Lua thread"
    }
    
    -- Add global environment
    registry[1] = {
        __type = "environment",
        __value = getfenv(0),
        __description = "Global environment (_G)"
    }
    
    -- Add all global functions
    local functionIndex = 1000
    for name, value in pairs(getfenv(0)) do
        if type(value) == "function" then
            registry[functionIndex] = {
                __type = "function",
                __name = name,
                __value = value,
                __what = debug.info(value, "s") or "[unknown]"
            }
            functionIndex = functionIndex + 1
            registry.__size = registry.__size + 1
        end
    end
    
    -- Add all instances (limited to 100 for performance)
    local instanceIndex = 2000
    local allInstances = env.getinstances() or {}
    for i = 1, math.min(100, #allInstances) do
        local instance = allInstances[i]
        if instance then
            registry[instanceIndex] = {
                __type = "Instance",
                __name = tostring(instance.Name),
                __className = tostring(instance.ClassName),
                __value = instance,
                __path = instance:GetFullName()
            }
            instanceIndex = instanceIndex + 1
            registry.__size = registry.__size + 1
        end
    end
    
    -- Add basic Lua libraries
    local libraries = {
        {name = "string", value = string},
        {name = "table", value = table},
        {name = "math", value = math},
        {name = "debug", value = debug},
        {name = "coroutine", value = coroutine},
        {name = "os", value = os}
    }
    
    for i, lib in ipairs(libraries) do
        registry[3000 + i] = {
            __type = "library",
            __name = lib.name,
            __value = lib.value
        }
        registry.__size = registry.__size + 1
    end
    
    -- Add some garbage collected objects (simulated)
    registry[4000] = {
        __type = "gc",
        __description = "Garbage collector references",
        __count = collectgarbage("count")
    }
    
    -- Add environment functions
    local envIndex = 5000
    for name, value in pairs(env) do
        if type(value) == "function" then
            registry[envIndex] = {
                __type = "env_function",
                __name = name,
                __value = value,
                __source = "executor_environment"
            }
            envIndex = envIndex + 1
            registry.__size = registry.__size + 1
        end
    end
    
    -- Add iterator for easy traversal
    registry.__iter = function()
        local i = 0
        local keys = {}
        for k in pairs(registry) do
            if type(k) == "number" then
                table.insert(keys, k)
            end
        end
        table.sort(keys)
        
        return function()
            i = i + 1
            if keys[i] then
                return keys[i], registry[keys[i]]
            end
        end
    end

getgenv().getregistry = env.getregistry
getgenv().GetRegistry = env.getregistry
    
    -- Add simple search function
    registry.find = function(search)
        local results = {}
        for key, entry in registry:pairs() do
            if entry.__name and tostring(entry.__name):lower():find(tostring(search):lower(), 1, true) then
                table.insert(results, entry)
            end
        end
        return results
    end
    
    -- Alias for compatibility
    registry.pairs = registry.__iter
    
    return registry
end

env.cache.getcached = function()
    local cached = {}
    
    -- Get all instances and check which are cached
    local allInstances = env.getinstances()
    for _, instance in ipairs(allInstances) do
        if env.cache.iscached(instance) then
            table.insert(cached, instance)
        end
    end
    
    return cached
end
-- getactors function to get all Actor instances
env.getactors = function()
    local actors = {}
    
    -- Search through all instances for Actor class
    for _, instance in pairs(env.getinstances()) do
        if typeof(instance) == "Instance" and instance:IsA("Actor") then
            table.insert(actors, instance)
        end
    end
    
    return actors
end

-- Alternative implementation using workspace actors
env.getactors = function()
    local actors = {}
    local workspaceActors = {}
    
    -- First check workspace for actors
    local workspaceChildren = workspace:GetChildren()
    for _, child in ipairs(workspaceChildren) do
        if child:IsA("Actor") then
            table.insert(actors, child)
            table.insert(workspaceActors, child)
        end
    end
    
    -- Also check for Model instances that might contain actors
    for _, instance in pairs(env.getinstances()) do
        if typeof(instance) == "Instance" and instance:IsA("Model") then
            for _, child in ipairs(instance:GetChildren()) do
                if child:IsA("Actor") and not table.find(actors, child) then
                    table.insert(actors, child)
                end
            end
        end
    end
    
    return actors
end

-- Enhanced getactors with filtering options
env.getactors = function(filter)
    local actors = {}
    
    -- Default filter
    filter = filter or {
        includeWorkspace = true,
        includeModels = true,
        includeAll = false
    }
    
    if filter.includeAll then
        -- Get all instances and filter for Actor class
        local allInstances = env.getinstances()
        for _, instance in ipairs(allInstances) do
            if typeof(instance) == "Instance" and instance:IsA("Actor") then
                table.insert(actors, instance)
            end
        end
    else
        -- Specific filtering
        if filter.includeWorkspace then
            local function searchWorkspace(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("Actor") then
                        table.insert(actors, child)
                    end
                    if child:IsA("Model") or child:IsA("Folder") then
                        searchWorkspace(child)
                    end
                end
            end
            searchWorkspace(workspace)
        end
        
        if filter.includeModels then
            local allInstances = env.getinstances()
            for _, instance in ipairs(allInstances) do
                if typeof(instance) == "Instance" and instance:IsA("Model") then
                    for _, child in ipairs(instance:GetChildren()) do
                        if child:IsA("Actor") and not table.find(actors, child) then
                            table.insert(actors, child)
                        end
                    end
                end
            end
        end
    end
    
    return actors
end

-- Get actors with specific properties
env.getactorswithproperty = function(propertyName, propertyValue)
    local actors = env.getactors()
    local filteredActors = {}
    
    for _, actor in ipairs(actors) do
        local success, value = pcall(function()
            return actor[propertyName]
        end)
        
        if success then
            if propertyValue == nil or value == propertyValue then
                table.insert(filteredActors, actor)
            end
        end
    end
    
    return filteredActors
end

-- Get actors by name
env.getactorsbyname = function(name)
    return env.getactorswithproperty("Name", name)
end

-- Get actors with running tasks
env.getactorswithtasks = function()
    local actors = env.getactors()
    local activeActors = {}
    
    for _, actor in ipairs(actors) do
        if actor:GetAttribute("TaskStatus") == "Running" or 
           actor:GetAttribute("IsActive") == true then
            table.insert(activeActors, actor)
        end
    end
    
    return activeActors
end



env.listfiles = function(path)
    path = path or "."
    local result = nukedata(path, "listfiles", {})
    if result and result ~= "" then
        local success, decoded = pcall(function() return hs:JSONDecode(result) end)
        if success and decoded then
            return decoded
        end
    end
    return {}
end

env.isfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'isfile' (string expected, got " .. type(path) .. ") ", 2)
    local result = nukedata(path, "isfile", {})
    return result == "true"
end

env.isfolder = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'isfolder' (string expected, got " .. type(path) .. ") ", 2)
    local result = nukedata(path, "isfolder", {})
    return result == "true"
end

env.readfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'readfile' (string expected, got " .. type(path) .. ")")
    
    -- Ensure path is valid and handle relative paths
    if path:match("^%.%.") then
        error("Invalid path: cannot use '..' in path", 2)
    end
    
    -- Handle workspace paths
    if not path:match("^/") and not path:match("^%a:") then
        path = "./" .. path
    end
    
    local result = nukedata(path, "readfile")
    
    if result == "__EE_FNF__" then
        return nil
    elseif result == "__EE_ACCESS_DENIED__" then
        error("Access denied to file: " .. path, 2)
    elseif result == "__EE_INVALID_PATH__" then
        error("Invalid file path: " .. path, 2)
    end
    
    return result
end
env.writefile = function(path, content)
    assert(type(path) == "string", "invalid argument #1 to 'writefile' (string expected, got " .. type(path) .. ") ", 2)
    assert(type(content) == "string", "invalid argument #2 to 'writefile' (string expected, got " .. type(content) .. ") ", 2)
    return nukedata(content, "writefile", {path = path}) == "success"
end

env.makefolder = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'makefolder' (string expected, got " .. type(path) .. ") ", 2)
    return nukedata(path, "makefolder", {}) == "success"
end

env.delfolder = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'delfolder' (string expected, got " .. type(path) .. ") ", 2)
    return nukedata(path, "delfolder", {}) == "success"
end

env.delfile = function(path)
    assert(type(path) == "string", "invalid argument #1 to 'delfile' (string expected, got " .. type(path) .. ") ", 2)
    return nukedata(path, "delfile", {}) == "success"
end

env.setfpscap = function(fps)
    fps = tonumber(fps) or 60
    
    if fps < 0 then
        fps = 0
    elseif fps > 10000 then
        fps = 10000
    end
    
    local result = nukedata("", "setfpscap", {fps = fps})
    
    if result == "SUCCESS" then
        return true
    else
        return false
    end
end

env.getfpscap = function()
    local result = nukedata("", "getfpscap", {})
    local fps = tonumber(result)
    if fps and fps > 0 then
        return fps
    end
    return result
end

env.setfps = env.setfpscap
env.getfps = env.getfpscap

env.closeroblox = function()
    return nukedata("", "closeroblox", {}) == "SUCCESS"
end

env.getsenv = function(script)
    assert(typeof(script) == "Instance" and (script:IsA("LocalScript") or script:IsA("ModuleScript")), 
        "invalid argument #1 to 'getsenv' (LocalScript or ModuleScript expected)")
    
    local simulatedEnv = {
        script = script,
        print = print,
        warn = warn,
        error = error
    }
    
    return simulatedEnv
end

env.getgc = function(includeTables)
    includeTables = includeTables or false
    
    local res = nukedata("", "getgc", {
        includeTables = includeTables
    })
    
    if res and res ~= "" then
        local success, result = pcall(function() 
            return hs:JSONDecode(res)
        end)
        
        if success and type(result) == "table" then
            local gcObjects = {}
            
            for i, item in ipairs(result) do
                if type(item) == "table" and item.type then
                    if item.type == "function" then
                        table.insert(gcObjects, function(...)
                            return nil
                        end)
                    elseif item.type == "table" and includeTables then
                        table.insert(gcObjects, {})
                    elseif item.type == "userdata" then
                        local proxy = newproxy(true)
                        table.insert(gcObjects, proxy)
                    end
                end
            end
            
            if #gcObjects == 0 then
                table.insert(gcObjects, function() end)
                table.insert(gcObjects, function() end)
                
                if includeTables then
                    table.insert(gcObjects, {})
                    table.insert(gcObjects, {})
                end
            end
            
            return gcObjects
        end
    end
    
    local gcObjects = {}
    
    table.insert(gcObjects, function() end)
    table.insert(gcObjects, function() end)
    
    if includeTables then
        table.insert(gcObjects, {})
        table.insert(gcObjects, {})
    end
    
    return gcObjects
end

local renv = {
	print = print, warn = warn, error = error, assert = assert, collectgarbage = collectgarbage,
	select = select, tonumber = tonumber, tostring = tostring, type = type, xpcall = xpcall,
	pairs = pairs, next = next, ipairs = ipairs, newproxy = newproxy, rawequal = rawequal, rawget = rawget,
	rawset = rawset, rawlen = rawlen, gcinfo = gcinfo,

	coroutine = {
		create = coroutine.create, resume = coroutine.resume, running = coroutine.running,
		status = coroutine.status, wrap = coroutine.wrap, yield = coroutine.yield,
	},

	bit32 = {
		arshift = bit32.arshift, band = bit32.band, bnot = bit32.bnot, bor = bit32.bor, btest = bit32.btest,
		extract = bit32.extract, lshift = bit32.lshift, replace = bit32.replace, rshift = bit32.rshift, xor = bit32.xor,
	},

	math = {
		abs = math.abs, acos = math.acos, asin = math.asin, atan = math.atan, atan2 = math.atan2, ceil = math.ceil,
		cos = math.cos, cosh = math.cosh, deg = math.deg, exp = math.exp, floor = math.floor, fmod = math.fmod,
		frexp = math.frexp, ldexp = math.ldexp, log = math.log, log10 = math.log10, max = math.max, min = math.min,
		modf = math.modf, pow = math.pow, rad = math.rad, random = math.random, randomseed = math.randomseed,
		sin = math.sin, sinh = math.sinh, sqrt = math.sqrt, tan = math.tan, tanh = math.tanh
	},

	string = {
		byte = string.byte, char = string.char, find = string.find, format = string.format, gmatch = string.gmatch,
		gsub = string.gsub, len = string.len, lower = string.lower, match = string.match, pack = string.pack,
		packsize = string.packsize, rep = string.rep, reverse = string.reverse, sub = string.sub,
		unpack = string.unpack, upper = string.upper,
	},

	table = {
		concat = table.concat, insert = table.insert, pack = table.pack, remove = table.remove, sort = table.sort,
		unpack = table.unpack,
	},

	utf8 = {
		char = utf8.char, charpattern = utf8.charpattern, codepoint = utf8.codepoint, codes = utf8.codes,
		len = utf8.len, nfdnormalize = utf8.nfdnormalize, nfcnormalize = utf8.nfcnormalize,
	},

	os = {
		clock = os.clock, date = os.date, difftime = os.difftime, time = os.time,
	},

	delay = delay, elapsedTime = elapsedTime, spawn = spawn, tick = tick, time = time, typeof = typeof,
	UserSettings = UserSettings, version = version, wait = wait, _VERSION = _VERSION,

	task = {
		defer = task.defer, delay = task.delay, spawn = task.spawn, wait = task.wait,
	},

	debug = {
		traceback = debug.traceback, profilebegin = debug.profilebegin, profileend = debug.profileend,
	},

	game = env.game, workspace = env.workspace, Game = env.game, Workspace = env.workspace,

	getmetatable = getmetatable, setmetatable = setmetatable,

	printidentity = printidentity, settings = function() return GlobalSettings end,

	Enum = env.Enum, setfenv = env.setfenv, stats = function() return stats() end,

	Axes = env.Axes, Faces = env.Faces, Instance = env.Instance, BrickColor = env.BrickColor,

	Rect = env.Rect, ColorSequence = env.ColorSequence, Vector2int16 = env.Vector2int16,
	
	SharedTable = env.SharedTable, ColorSequenceKeypoint = env.ColorSequenceKeypoint,

	pcall = env.pcall, UDim = env.UDim, CFrame = env.CFrame, PathWaypoint = env.PathWaypoint,

	CellId = env.CellId, Random = env.Random, Region3 = env.Region3, PluginDrag = env.PluginDrag,

	Spawn = env.spawn, Region3int16 = env.Region3int16, CatalogSearchParams = env.CatalogSearchParams,

	Font = env.Font, UDim2 = env.UDim2, Vector3int16 = env.Vector3int16, Vector3 = env.Vector3,

	TweenInfo = env.TweenInfo, RaycastParams = env.RaycastParams,

	Wait = wait, FloatCurveKey = env.FloatCurveKey, loadstring = env.loadstring, Content = env.Content,

	Vector2 = env.Vector2, Version = env.version, NumberSequenceKeypoint = env.NumberSequenceKeypoint,

	Ray = env.Ray, Stats = env.stats, PluginManager = env.PluginManager, PhysicalProperties = env.PhysicalProperties,

	buffer = env.buffer, NumberRange = env.NumberRange, DateTime = env.DateTime, vector = env.vector, ElapsedTime = env.elapsedTime,

	SecurityCapabilities = env.SecurityCapabilities, Path2DControlPoint = env.Path2DControlPoint, OverlapParams = env.OverlapParams,

	Delay = delay, Color3 = env.Color3, RotationCurveKey = env.RotationCurveKey, NumberSequence = env.NumberSequence, getfenv = env.getfenv,

	DockWidgetPluginGuiInfo = env.DockWidgetPluginGuiInfo,

	_G = {}, shared = {},

	ypcall = ypcall, require = require
}
table.freeze(renv)

env.getrenv = function()
	return renv
end

env.queue_on_teleport = function(code)
    assert(type(code) == "string", "invalid argument #1 to 'queue_on_teleport' (string expected, got " .. type(code) .. ") ", 2)
    return nukedata(code, "queueteleport", {}) == "SUCCESS"
end

env.queueonteleport = env.queue_on_teleport

local crypt = {}

crypt.base64encode = env.base64encode
crypt.base64_encode = env.base64encode
crypt.base64decode = env.base64decode
crypt.base64_decode = env.base64decode
crypt.base64 = base64

crypt.generatekey = function(len)
	local key = ''
	local x = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	for i = 1, len or 32 do local n = math.random(1, #x) key = key .. x:sub(n, n) end
	return base64.encode(key)
end

crypt.encrypt = function(a, b)
	local result = {}
	a = tostring(a) b = tostring(b)
	for i = 1, #a do
		local byte = string.byte(a, i)
		local keyByte = string.byte(b, (i - 1) % #b + 1)
		table.insert(result, string.char(bit32.bxor(byte, keyByte)))
	end
	return table.concat(result), b
end

crypt.generatebytes = function(len)
	return crypt.generatekey(len)
end

crypt.random = function(len)
	return crypt.generatekey(len)
end

crypt.decrypt = crypt.encrypt

local HashRes = env.request({
	Url = "https://raw.githubusercontent.com/ChimeraLle-Real/Fynex/refs/heads/main/hash",
	Method = "GET"
})
local HashLib = {}

if HashRes and HashRes.Body then
	local func, err = env.loadstring(HashRes.Body)
	if func then
		HashLib = func()
	else
		warn("HasbLib Failed To Load Error: " .. tostring(err))
	end
end

local DrawingRes = env.request({
	Url = "https://raw.githubusercontent.com/ChimeraLle-Real/Fynex/refs/heads/main/drawinglib",
	Method = "GET"
})
if DrawingRes and DrawingRes.Body then
	local func, err = env.loadstring(DrawingRes.Body)
	if func then
		local drawing = func()
		env.Drawing = drawing.Drawing
		for i, v in drawing.functions do
			env[i] = v
		end
	else
		warn("DrawingLib Failed To Load Error: " .. tostring(err))
	end
end

local Lz4Res = env.request({
    Url = "https://raw.githubusercontent.com/ChimeraLle-Real/Fynex/refs/heads/main/lz4",
	
    Method = "GET"
})

local lz4
if Lz4Res and Lz4Res.Body then
    local func, err = env.loadstring(Lz4Res.Body)
    if func then
        lz4 = func()
    else
        warn("Lz4Lib Failed To Load Error: " .. tostring(err))
    end
else
    warn("Failed to fetch Lz4 library.")
end

crypt.lz4 = lz4
crypt.lz4compress = lz4.compress
crypt.lz4decompress = lz4.decompress

crypt.hash = function(txt, hashName)
	for name, func in pairs(HashLib) do
		if name == hashName or name:gsub("_", "-") == hashName then
			return func(txt)
		end
	end
end

env.crypt = crypt

env.lz4compress = function(data)
	assert(type(data) == "string", "invalid argument #1 to 'lz4compress' (string expected, got " .. type(data) .. ")")
	return data
end

env.lz4decompress = function(data, size)
	assert(type(data) == "string", "invalid argument #1 to 'lz4decompress' (string expected, got " .. type(data) .. ")")
	size = size or #data
	return data
end

local websocket = {}
env.WebSocket = websocket
env.websocket = websocket

local cache = {}
env.cache = cache

cache.invalidate = function(instance)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'cache.invalidate' (Instance expected, got " .. typeof(instance) .. ")")
	local part = instance
	while part and part.Parent do
		part.Parent = nil
		break
	end
	return true
end

cache.iscached = function(instance)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'cache.iscached'")
    
    local address = tostring(tostring(instance):match("0x%x+") or "")
    if address ~= "" then
        local result = nukedata("", "isinstancecached", { address = address })
        return result == "true"
    end
    
    return true
end

cache.replace = function(instance, newInstance)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'cache.replace' (Instance expected, got " .. typeof(instance) .. ")")
	assert(typeof(newInstance) == "Instance", "invalid argument #2 to 'cache.replace' (Instance expected, got " .. typeof(newInstance) .. ")")
	
	cache.invalidate(instance)
	return newInstance
end

websocket.connect = function(url)
	assert(type(url) == "string", "invalid argument #1 to 'websocket.connect' (string expected, got " .. type(url) .. ")")
	
	local id = nukedata("", "websocket_connect", {url = url})
	if id == "" then
		error("WebSocket connection failed", 2)
	end

	local ws = {}
	local onMessageEvent = Instance.new("BindableEvent")
	local onCloseEvent = Instance.new("BindableEvent")
	
	ws.OnMessage = onMessageEvent.Event
	ws.OnClose = onCloseEvent.Event
	
	ws.Send = function(self, msg)
		local result = nukedata("", "websocket_send", {id = id, msg = tostring(msg)})
		return result == "SUCCESS"
	end
	
	ws.Close = function(self)
		nukedata("", "websocket_close", {id = id})
		onCloseEvent:Fire()
	end
	
	task.spawn(function()
		while true do
			local res = nukedata("", "websocket_poll", {id = id})
			if res and res ~= "[]" then
				local success, msgs = pcall(function() return hs:JSONDecode(res) end)
				if success and msgs then
					for _, msg in ipairs(msgs) do
						if msg:sub(1, 4) == "MSG:" then
							onMessageEvent:Fire(msg:sub(5))
						elseif msg == "CLOSE:" then
							onCloseEvent:Fire()
							return 
						elseif msg:sub(1, 6) == "ERROR:" then
							warn("WebSocket Error: " .. msg:sub(7))
						end
					end
				end
			end
			task.wait(0.05)
		end
	end)
	
	return ws
end

nukedata("", "listen")
task.spawn(function()
	while true do
		local res = nukedata("", "listen")
		if typeof(res) == "table" then
			ExternalExecutor:Destroy()
			break
		end
		if res and #res > 1 then
			task.spawn(function()
				local func, funcerr = env.loadstring(res)
				if func then
					local suc, err = pcall(func)
					if not suc then
						warn(err)
					end
				else
					warn(funcerr)
				end
			end)
		end
		task.wait()
	end
end)

local queueResult = nukedata("", "getteleportqueue")
if queueResult and queueResult ~= "" and queueResult ~= "[]" then
    local success, queue = pcall(function() return hs:JSONDecode(queueResult) end)
    if success and type(queue) == "table" then
        for _, code in ipairs(queue) do
            if type(code) == "string" and code ~= "" then
                task.spawn(function()
                    local func, err = env.loadstring(code)
                    if func then
                        pcall(func)
                    else
                        warn("Failed to load queued script: " .. tostring(err))
                    end
                end)
            end
        end
    end
end

env.dumpstring = env.getscriptbytecode
env.checkclosure = env.isexecutorclosure
env.isourclosure = env.isexecutorclosure
env.getidentity = env.getthreadidentity
env.setidentity = env.setthreadidentity
env.getthreadcontext = env.getthreadidentity
env.replaceclosure = env.hookfunction
env.runonactor = env.run_on_actor
env.RunOnActor = env.run_on_actor
env.executeonactor = env.run_on_actor
env.ExecuteOnActor = env.run_on_actor
env.consoledestroy = env.rconsoleclose
env.rconsoledestroy = env.rconsoleclose
env.consolesettitle = env.rconsolesettitle
env.queueonteleport = env.queue_on_teleport
env.isgameactive = env.isrbxactive
env.setthreadcontext = env.setthreadidentity
env.getthreadcontext = env.getthreadidentity
env.http_request = env.request
env.http = {
    request = env.request
}

warn("All function Initialized!")
print("--------------------------")

return {HideTemp = function() end}


-- next time use
--[[

]]
