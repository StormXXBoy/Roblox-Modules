local RUNS = game:GetService("RunService")
local isClient = RUNS:IsClient()

local simpleNet = {}

function simpleNet.randomString()
	local randomSting = ""
	for i = 1, 10 do
		randomSting = randomSting .. string.char(math.random(30, 90))
	end
	return randomSting
end

simpleNet.connections = {} :: {{["name"]: string, ["func"]: (any)->(any) | (Player, any)->(any)}}

simpleNet.events = {} :: {RemoteEvent}
local function addRemote(remote)
	if remote:IsA("RemoteEvent") then
		table.insert(simpleNet.events, remote)
		if isClient then
			remote.OnClientEvent:Connect(function(event, ...)
				for _, connection in simpleNet.connections do
					if connection.name == event then
						connection.func(...)
					end
				end
			end)
		else
			remote.OnServerEvent:Connect(function(client, event, ...)
				for _, connection in simpleNet.connections do
					if connection.name == event then
						connection.func(client, ...)
					end
				end
			end)
		end
	end
end
script.ChildAdded:Connect(addRemote)
for _, remote in script:GetChildren() do
	addRemote(remote)
end
if not isClient then
	for i=1, 100 do
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = simpleNet.randomString()
		remoteEvent.Parent = script
	end
end

if isClient then
	function simpleNet.fireToServer(event: string, ...)
		simpleNet.events[math.random(1, #simpleNet.events)]:FireServer(event, ...)
	end
	
	function simpleNet.listenAsClient(event: string, func: (any)->(any))
		local connection = {
			name = event,
			func = func
		}
		table.insert(simpleNet.connections, connection)
	end
else
	function simpleNet.fireToClient(event: string, client: Player, ...)
		simpleNet.events[math.random(1, #simpleNet.events)]:FireClient(client, event, ...)
	end
	
	function simpleNet.fireToClients(event: string, clients: {Player}, ...)
		for _, client in clients do
			simpleNet.fireToClient(event, client, ...)
		end
	end

	function simpleNet.fireToAllClients(event: string, ...)
		for _, client in game.Players:GetPlayers() do
			simpleNet.fireToClient(event, client, ...)
		end
	end
	
	function simpleNet.listenAsServer(event: string, func: (Player, any)->(any))
		local connection = {
			name = event,
			func = func
		}
		table.insert(simpleNet.connections, connection)
		
		return function()
			table.remove(simpleNet.connections, table.find(simpleNet.connections, connection))
		end
	end
end

return simpleNet
