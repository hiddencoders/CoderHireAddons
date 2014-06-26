ENT.Type = "anim"
ENT.Base = "chem_base"
ENT.PrintName = "Raw Meth"
ENT.Author = "Wolf"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "nChanted: Drugs"


function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"Cooked")
	self:NetworkVar("Bool",1,"OverCooked")
	self:NetworkVar("Bool",2,"Done")
end
