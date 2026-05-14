local vfxHandler = {}

function vfxHandler.play(vfx: Instance, destroyAfter: boolean)
	local largestEmitterDuration = 0
	
	local vfxElements = vfx:GetDescendants()
	table.insert(vfxElements, vfx)
	
	for index, emitter: ParticleEmitter in vfxElements do
		if not emitter:IsA("ParticleEmitter") then continue end
		local emitCount = emitter:GetAttribute("EmitCount") or 10
		local emitDuration = emitter:GetAttribute("EmitDuration") or 0
		local emitDelay = emitter:GetAttribute("EmitDelay") or 0

		largestEmitterDuration = math.max(largestEmitterDuration, emitDuration)
		largestEmitterDuration = math.max(largestEmitterDuration, emitter.Lifetime.Max)

		task.delay(emitDelay, function()
			if emitCount > 0 then
				emitter:Emit(emitCount)
			end
			if emitDuration > 0 then
				emitter.Enabled = true
				task.delay(emitDuration, function()
					emitter.Enabled = false
				end)
			end
		end)
	end

	largestEmitterDuration = math.min(largestEmitterDuration + 1, 30)

	if destroyAfter then
		task.delay(largestEmitterDuration + 3, function()
			vfx:Destroy()
		end)
	end

	return largestEmitterDuration
end

function vfxHandler.playAtPos(vfx, pos)
	local newVFX = vfx:Clone()

	if pcall(function() if newVFX.PivotTo then return true end end) then
		newVFX:PivotTo(CFrame.new(pos))
	elseif pcall(function() if newVFX.CFrame then return true end end) then
		newVFX.CFrame = CFrame.new(pos)
	else
		newVFX.Position = pos
	end

	newVFX.Parent = workspace

	local largestEmitterDuration = 4

	task.delay(0.05, function()
		largestEmitterDuration = vfxHandler.play(newVFX, true)
	end)

	return newVFX, largestEmitterDuration
end

function vfxHandler.playOnParent(vfx, parent)
	local newVFX = vfx:Clone()
	newVFX.Parent = parent

	local largestEmitterDuration = 4

	task.delay(0.05, function()
		largestEmitterDuration = vfxHandler.play(newVFX, true)
	end)

	return newVFX, largestEmitterDuration
end

return vfxHandler
