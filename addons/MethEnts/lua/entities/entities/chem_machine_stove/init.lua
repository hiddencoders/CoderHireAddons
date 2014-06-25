AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()	
	self:PreInit()
	self:SetModel(self.WorldModelData)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self.avoidamount = self.AvoidAmount or true
	self.healths = self.MaxHealth or 100
	self.UseMessage = self.message or "An object."
	self.HeatLevel = 9999
	self.TID = math.random(1, 9999)
	
	self.Voltage = 0
	self.Heat = 23
	self.Speed = self.engineSpeed or 1
	
	self.MaxVoltage = self.engineLimit or 1200
	self.Storage = 0
	
	self.healths = self.MaxHealth or 100
	self.cooking = self.TimeRequirement or 300
	
	self.ID = self.ID or 6666
	
	self:SetUpDefault("Timers")
	
	self.MaterialType = "Item"
	self.CraftName = self.CraftName or "Meth"
	self:UpdateCables()
end

function ENT:PreInit()
	self.WorldModelData = "models/props_vehicles/generatortrailer01.mdl" // How it should look like
	self.CraftName = "Uncooked Meth" // Name
	self.MaxHealth = 110 // Health. If its below 0, it'll explode, just like when overcooked, just with less damage
	self.ID = 14

end

function ENT:Explode( data )
	if not self.exploding then
		self.exploding = true
		local explode = ents.Create( "env_explosion" ) 
		local s = "ambient/explosions/explode_" .. ( math.floor( math.random( 1, 9)) ) .. ".wav"
		local a = self:GetPos() --self.StoredPos
		local luck = math.random(1,5)
		local exp = "20"
		if luck == 1 then exp = "40" elseif luck == 2 then exp = "80" elseif luck == 3 then exp = "120" elseif luck == 4 then exp = "160" elseif luck == 5 then exp = "200" end
		self.Ownerply = self:GetOwner()
		local expval = tonumber(exp) + ( ( data / luck ) / 100)
		explode:SetOwner( self.Ownerply ) 
		explode:Spawn() 
		explode:SetPos( self:GetPos() )
		explode:SetKeyValue( "iMagnitude", exp ) 
		explode:Fire( "Explode", 0, 0 )
		explode:EmitSound( s, 200, 100 ) 
		self:Remove()
	end
end

function ENT:OnTakeDamage(dmg)
	local dmgmult = self.W or 1
	self.healths = self.healths * dmgmult
	self.healths = self.healths - dmg:GetDamage()
	if (self.healths <= 0) then
		self.HasStoredPos = false
		self:Explode( 100 )
	end
end

function ENT:StartTouch(ent)
	if ent:IsValid() then
		if ent.ID == 13 then
			ent:StartWorking()
		end
	end
end

function ENT:EndTouch(ent)
	if ent:IsValid() then
		if ent.ID == 13 then
			ent:StopWorking()
		end
	end
end


function ENT:Think()

end

function ENT:Use(activator,caller)
	if IsValid(activator) and activator:IsPlayer() then
		activator:ChatPrint("A stove. You might cook ingredients here.")
	end
end