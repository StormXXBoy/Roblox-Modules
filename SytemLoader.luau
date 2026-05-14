local RUNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local isClient = RUNS:IsClient()

export type context = "server" | "client" | "shared"
export type system = {
	[context]: {
		[string]: any
	}
}

local loader = {}

loader.systems = {} :: {[string]: system}

function loader.isServerModule(module: ModuleScript)
	return module.Name:find("Server") ~= nil
end

function loader.isClientModule(module: ModuleScript)
	return module.Name:find("Client") ~= nil
end

function loader.isSharedModule(module: ModuleScript)
	return module.Name:find("Shared") ~= nil
end

function loader.getModuleContext(module: ModuleScript): context
	local isServer = loader.isServerModule(module)
	local isClient = loader.isClientModule(module)
	local isShared = loader.isSharedModule(module)
	
	if isServer then
		return "server"
	elseif isClient then
		return "client"
	elseif isShared then
		return "shared"
	end
	
	return nil
end

function loader.context(): context
	if isClient then
		return "client"
	else
		return "server"
	end
end

--[[
Call this once in order to load all the modules.
]]
function loader.start()
	local moduleMoveToSSS = {}
	for _, system in script:GetChildren() do
		local newSystem = {}
		for _, module in system:GetChildren() do
			if module:IsA("ModuleScript") then
				local moduleContext = loader.getModuleContext(module)
				if moduleContext then
					if moduleContext == "server" and isClient then
						module:Destroy()
						continue
					end
					
					if not newSystem[moduleContext] then
						newSystem[moduleContext] = {}
					end
					newSystem[moduleContext][module.Name] = require(module)
					
					if moduleContext == "server" and not isClient then
						table.insert(moduleMoveToSSS, module)
					end
				end
			end
		end
		loader.systems[system.Name] = newSystem
	end
	
	for _, module in moduleMoveToSSS do
		module.Parent = SSS
	end
end

--[[
Call this to call a function from a module.
]]
function loader.load(start: string, async: boolean)
	local loaderContext = loader.context()
	
	local modulesToLoad = 0
	local modulesLoaded = 0
	
	for name, system in loader.systems do
		local systemContext = system[loaderContext]
		if systemContext then
			for moduleName, module in systemContext do
				if module[start] and type(module[start]) == "function" then
					modulesToLoad += 1
					local success, err = pcall(task.spawn, function()
						module[start]()
						modulesLoaded += 1
					end)
					if not success then
						warn("Error while loading module " .. moduleName .. ": " .. err)
						modulesToLoad -= 1
					end
				end
			end
		end
	end
	
	if not async then return end
	repeat task.wait() until modulesLoaded >= modulesToLoad
end

return loader
