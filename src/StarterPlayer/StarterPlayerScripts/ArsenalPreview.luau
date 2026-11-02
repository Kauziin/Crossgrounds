-- Keeps one displayed weapon for a weapon ID; only changed slots are cloned.
local Preview={}
Preview.__index=Preview
local Iron=require(game.ReplicatedStorage.Crossgrounds.IronSightVisibility)
local function safe(model)
	for _,v in model:GetDescendants() do
		if v:IsA('LuaSourceContainer') or v:IsA('Sound') or v:IsA('ParticleEmitter')
			or v:IsA('Trail') or v:IsA('Beam') or v:IsA('Light') then v:Destroy()
		elseif v:IsA('BasePart') then
			v.Anchored=true v.CanCollide=false v.CanQuery=false v.CanTouch=false v.Massless=true
		end
	end
end
function Preview.new(world)
	return setmetatable({world=world,bases={},order={},native=setmetatable({},{__mode='k'})},Preview)
end
function Preview:HasBase(id) return self.bases[id]~=nil end
function Preview:Capture(asset,id)
	-- Clone the base only on a weapon change/cache miss, not for every combination.
	if not self.bases[id] then
		local base=Instance.new('Model') base.Name=id
		for _,v in asset:GetChildren() do if not v:GetAttribute('VisualAttachmentId') then v:Clone().Parent=base end end
		base.PrimaryPart=base:FindFirstChild('Handle') safe(base) self.bases[id]=base table.insert(self.order,id)
		if #self.order>4 then local old=table.remove(self.order,1) self.bases[old]:Destroy() self.bases[old]=nil end
	end
	local snapshot=Instance.new('Model') snapshot.Name='AttachmentSnapshot'
	local native={}
	for _,v in asset:GetChildren() do
		if v:GetAttribute('VisualAttachmentId') or v.Name=='Handle' then v:Clone().Parent=snapshot
		elseif v:IsA('BasePart') then native[v:GetAttribute('VisualPartKey') or v.Name]=v.Transparency end
	end
	self.native[snapshot]=native safe(snapshot)
	return snapshot
end
function Preview:Show(asset,id,configuration)
	local clean=table.clone(configuration or {})
	local previous=self.configuration or {}
	if not self.model or self.id~=id then
		if self.model then self.model:Destroy() end
		self.model=assert(self.bases[id],'Preview base missing'):Clone() safe(self.model) self.model.Parent=self.world
		previous={}
	end
	do
		local changed={}
		for slot,value in previous do if clean[slot]~=value then changed[slot]=true end end
		for slot,value in clean do if previous[slot]~=value then changed[slot]=true end end
		if changed.barrel then changed.muzzle=true end
		for _,v in self.model:GetChildren() do if changed[v:GetAttribute('VisualAttachmentSlot')] then v:Destroy() end end
		for _,v in asset:GetChildren() do
			if changed[v:GetAttribute('VisualAttachmentSlot')] then v:Clone().Parent=self.model end
		end
		-- Barrel changes also move the shot/muzzle mounts.
		local handle=self.model:FindFirstChild('Handle') local source=asset:FindFirstChild('Handle')
		if handle and source then
			for _,a in source:GetChildren() do if a:IsA('Attachment') then
				local old=handle:FindFirstChild(a.Name) if old then old.CFrame=a.CFrame else a:Clone().Parent=handle end
			end end
		end
		safe(self.model)
		-- AX-50's native scope and all native iron sights mirror the server template.
		local native=self.native[asset] or {}
		for _,v in self.model:GetChildren() do
			if v:IsA('BasePart') and not v:GetAttribute('VisualAttachmentId') then
				local transparency=native[v:GetAttribute('VisualPartKey') or v.Name]
				if transparency~=nil then v.Transparency=transparency end
			end
		end
		Iron.Apply(self.model,clean.optic~=nil)
	end
	self.configuration=clean self.id=id
	return self.model
end
function Preview:Destroy()
	if self.model then self.model:Destroy() end self.model=nil
	for _,base in self.bases do base:Destroy() end table.clear(self.bases)
end
return Preview
