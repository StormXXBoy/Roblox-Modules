local sfxHandler = {}

function sfxHandler.play(sfx: Sound)
	if not sfx then warn("SFX doesn't exist.") return end
	local newSFX = sfx:Clone()
	newSFX.Parent = sfx.Parent
	newSFX:Play()
	newSFX.Ended:Once(function()
		newSFX:Destroy()
	end)
	
	return newSFX
end

function sfxHandler.playAtPos(sfx: Sound, pos: Vector3)
	local newSFX = sfx:Clone()
	
	local newAttachment = Instance.new("Attachment")
	newAttachment.Parent = workspace.Terrain
	newAttachment.WorldPosition = pos
	newSFX.Parent = newAttachment
	
	newSFX:Play()
	newSFX.Ended:Once(function()
		newSFX:Destroy()
		newAttachment:Destroy()
	end)
	
	return newSFX, newAttachment
end

function sfxHandler.playOnParent(sfx: Sound, parent: Instance)
	local newSFX = sfx:Clone()
	newSFX.Parent = parent
	newSFX:Play()
	newSFX.Ended:Once(function()
		newSFX:Destroy()
	end)
	
	return newSFX
end

return sfxHandler
