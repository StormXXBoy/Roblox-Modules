local cubeFX = {}

export type cubeFXoptions = {
	sizeRange: NumberRange,
	spreadRange: NumberRange,
	partsRange: NumberRange,
	velocityRange: NumberRange,
	
	createCube: ()->(Part),
}

local rand = Random.new()
local function getRandomNumber(range: NumberRange)
	return rand:NextNumber(range.Min, range.Max)
end

function cubeFX.new(options: cubeFXoptions)
	local self = setmetatable({}, {__index = cubeFX})
	
	self.cache = {}
	
	local options = options or {}
	self.options = options
	self.options.sizeRange = options.sizeRange or NumberRange.new(1, 1)
	self.options.spreadRange = options.spreadRange or NumberRange.new(0, 0)
	self.options.partsRange = options.partsRange or NumberRange.new(1, 1)
	self.options.velocityRange = options.velocityRange or NumberRange.new(0, 0)
	
	self.options.createCube = options.createCube or function()
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Anchored = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		return part
	end
	
	return self
end

function cubeFX:getCube()
	if #self.cache > 0 then
		return table.remove(self.cache)
	else
		local part = self.options.createCube()
		part.Size = Vector3.one * getRandomNumber(self.options.sizeRange)
		return part
	end
end

function cubeFX:emit(pos: Vector3, dir: Vector3, color: Color3 | ()->(Color3), material: Enum.Material)
	dir = dir or Vector3.new(0, 0, 0)
	if typeof(color) == "function" then
		color = color()
	end
	
	for i = 1, math.round(getRandomNumber(self.options.partsRange)) do
		local part: Part = self:getCube()
		part.CFrame = CFrame.lookAt(pos, pos + dir)
		part.Color = color or part.Color
		part.Material = material or part.Material
		
		local randomDir = Vector3.new(rand:NextNumber(-0.5, 0.5), rand:NextNumber(), rand:NextNumber(-0.5, 0.5))
		local direction = (dir + randomDir*getRandomNumber(self.options.spreadRange)).Unit
		part.AssemblyLinearVelocity = direction * getRandomNumber(self.options.velocityRange)
		
		part.AssemblyAngularVelocity = Vector3.new(rand:NextNumber(), rand:NextNumber(), rand:NextNumber()) * getRandomNumber(self.options.velocityRange)
		
		part.Parent = workspace.Terrain
		
		task.delay(1, function()
			table.insert(self.cache, part)
			
			part.Parent = nil
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end)
	end
end

function cubeFX:Destroy()
	for _, part in self.cache do
		part:Destroy()
	end

	table.clear(self.cache)
	self.cache = nil
	self.options = nil
	setmetatable(self, nil)
	self = nil
end

return cubeFX 
