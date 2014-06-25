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
	
	self.money = math.random(MinCash, MaxCash)
	self.OCT = math.random(MinOverCookTime, MaxOverCookTime)
	
	
	self.MaterialType = "Item"
	self.CraftName = self.CraftName or "Meth"
	self:UpdateCables()
end

function ENT:PreInit()
	self.WorldModelData = "models/props_vehicles/generatortrailer01.mdl" // How it should look like
	self.CraftName = "Uncooked Meth" // Name
	self.MaxHealth = 110 // Health. If its below 0, it'll explode, just like when overcooked, just with less damage
	self.ID = 13
	self.AvoidAmount = true
	
	
	self.MaxCash = 3000
	self.MinCash = 1000
	
	self.TimeRequirement = 300
	
	self.MinOverCookTime = 120
	self.MaxOverCookTime = 300
	
	self.OverCookBonus = 0.01
	// How its counted?
	// The cash it would normally drop will be multiplied with that number, and then it would add to itself. EXAMPLE:
	
	// Money the meth would drop: 2000$
	// OverCookBonus: 0.01
	
	// If the meth is 10 seconds overcooked:
	//		2000$ + 10 x (0.01 * 2000$) =
	//		2000$	+	10x	(20$) =
	//		2000$ + 200$ = 2200$ !!
end

function ENT:OverHeat()
	self.ohing = true
	self.OverHeatColor = Color(255, 100, 100, 255)
	self:SetColor( self.OverHeatColor )
	if self.cooking < - 10 then
		self:SetOverCooked( true )
	end
	self:SetDone( true )
end

function ENT:StopOverHeat()
	if self.ohing == false then return end
	self.ohing = false
	self.DefaultColor = Color(255, 255, 255, 255)
	self:SetColor( self.DefaultColor )
end

function ENT:StartWorking()
	timer.Create("meth_cook_"..self.TID,1, 420, function() 
		self:TriggerWork() 
	end) 
end

function ENT:StopWorking()
	timer.Destroy("meth_cook_"..self.TID)
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
		for k, v in pairs(ents.FindInSphere(self:GetPos(),200))
			if v:IsValid() then v:Ignite() timer.Simple(5, function()
				if v:IsValid() then v:Extinguish() end)
			end
		end
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


function ENT:Think()
	self:SetCooked(self.cooked)
	if (self.cooking < 0 ) and !self.ohing then 
		self:OverHeat()
	end
end

function ENT:TriggerWork()
	if self:IsValid() then
		self.cooking = self.cooking - 1
		if self.cooking < 0 then
			self:OverHeat()
			if self.cooking + self.OCT >= 1 then
				self:Explode( 1000 )
			end
		end
	end
end

function ENT:OnRemove()
	self:StopWorking()
end

function ENT:DropCash(ply)
	if self.cooked < 0 then
		local addcash = 0
		local def = self.money or 100
		local div = self.OverCookBonus or 0.01
		local sec = (0 - self.cooked ) or 0
		local mul = div * sec
		local fin = def * mul
		local addcash = math.floor(fin + def)
		DarkRPCreateMoneyBag(self:GetPos() + Vector(15,0,0), addcash)
		ply:ChatPrint("You have sold the meth for $"..addcash.." !")
	else
		DarkRPCreateMoneyBag(self:GetPos() + Vector(15,0,0), self.money)
		ply:ChatPrint("You have sold the meth for $"..self.money.." !")
	end
	self:Remove()
end

function ENT:Use(activator,caller)
	if IsValid(activator) and activator:IsPlayer() then
		if self.Ready then
			self:DropCash(activator)
		else
			activator:ChatPrint("This is a not yet done barrel of meth. Cook it for "..self.cooked.." seconds to get money!")
			activator:ChatPrint("Or cook it for longer to gather more money. However, if you overcook it, it might explode!")
		end
	end
end