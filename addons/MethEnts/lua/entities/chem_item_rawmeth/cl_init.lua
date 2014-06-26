include("shared.lua")
local ply = LocalPlayer()
print("LOADING CL MODULE...")

function ENT:Initialize()

end

function ENT:Draw()
	self:DrawModel()
	local ply = LocalPlayer()
	
	if ply:EyePos():Distance(self:GetPos()) >= 700 then 
		return 
	end 
	
	local text = "_error"
	
	surface.SetFont("Trebuchet18")
	if self:GetOverCooked() and self:GetDone() then
		text = "OVERCOOKING"
	elseif  self:GetDone() then
		 text = "Done"
	else
		 text = "Uncooked Meth"
	end
	local time = (math.floor((self:GetCooked())) )
	
	local min = 0
	local sec = 0
	
	
	if time > 60 then
		min = math.floor(time / 60)
		sec = time - (min * 60)
	else
		min = 0
		sec = time
	end
	
	if sec < 0 then sec = 0 end
	if min < 0 then min = 0 end
	
	local post = ""
	
	if min == 0 then min = "00" end
	if sec < 10 then post = "0" else post = "" end
	
	local owner = (min..":"..post..sec)
	
	local TextWidth = surface.GetTextSize(text)
	local TextWidth2 = surface.GetTextSize(owner)

	
	local offset = Vector( 0, 0, 60 )
	local ang = ply:EyeAngles()
	local pos = self:GetPos() + offset + ang:Up()
 
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	if ply:EyePos():Distance(self:GetPos()) >= 200 then return end
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
		draw.DrawText( text, "Trebuchet18", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	cam.End3D2D()	
	
	if self:GetOverCooked() then return end
	
	cam.Start3D2D( pos - Vector(0,0,5), Angle( 0, ang.y, 90 ), 0.25 )
		draw.DrawText( owner, "Trebuchet18", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	cam.End3D2D()	
	
end

function ENT:Think()

end
