AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/gibs/wood_gib01e.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self.healths = 75
	self.MaxHealth = self.healths
	self.W = 1
	self.Priority = math.random(1, 3000)
	self.ID = 0
	self.UseMessage = "Base entity for nChanted Chemistry"
	
	self.HeatLevel = 3000
	self.EU = 0
	
	self.MaterialType = "Base"
	self.CraftName = "Base Entity"
end

function ENT:GetEU()
	if self.IsFuel then
		local eutemp = self.EU * self.W
		local eusec = self.MaxHealth / self.healths
		local eufin = eutemp / eusec
			if eufin < 0 then
				eufin = 0
			end
		
		return eufin
		
	else
		return 0
	end
end

function ENT:HasEU()
	if self.EU then
		return true
	else
		return false
	end
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
	local entid = self.ClassName --or "chem_base"
    local ent = ents.Create( entid )
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
    ent:Spawn()
    ent:Activate()
	self.Ownerply = ply
    return ent
end

function ENT:OnTakeDamage(dmg)
	local dmgmult = self.W or 1
	self.healths = self.healths * dmgmult
	self.healths = self.healths - dmg:GetDamage()
	if (self.healths <= 0) then
		self:Remove()
	end
end

function ENT:Think()
	--self.Amount = self.Amount or 0
	if not self.avoidamount then
		if self.W <= 0 then
			self:Remove()
		else
			self.IsColliding = false
		end
	end
end

function ENT:StartTouch(ent)
	if self.W then
		if not ent.IsColliding then
			self.IsColliding = true
			if ent.ID == self.ID then
				local a = self.Priority or 5
				local b = ent.Priority or 10
				if a <= b then
					ent.W = ent.W + self.W
					self:Remove()
				else
					self.W = self.W + ent.W
					ent:Remove()
				end
			end
		end
	end
end

function ENT:Use(activator,caller)
	if IsValid(activator) and activator:IsPlayer() then
		--if nChanted.Chem.ShowName then
			--activator:PrintMessage( HUD_PRINTTALK, "An " self.PrintName() " :")
		--end
		activator:PrintMessage( HUD_PRINTTALK, self.UseMessage )
		if not self.avoidamount then
			activator:PrintMessage( HUD_PRINTTALK, "Weight: ".. self.W .."kg " )
		end
	end
end