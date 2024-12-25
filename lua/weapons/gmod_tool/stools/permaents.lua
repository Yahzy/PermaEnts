TOOL.Name = "#tool.permaents.name"
TOOL.Desc = "#tool.permaents.desc"
TOOL.Category = "Administration"
TOOL.Author = "Yahzy"

if CLIENT then
	TOOL.Information = {{name = "info", stage = 1}, {name = "left"}, {name = "right"}, {name = "reload"}}

	language.Add("tool.permaents.name", "PermaEnts")
	language.Add("tool.permaents.desc", "Create a permanent object")
	language.Add("tool.permaents.left", "Register in permanent objects")
	language.Add("tool.permaents.right", "UnRegister in permanent objects")
	language.Add("tool.permaents.reload", "Open debug menu")
end

function TOOL:LeftClick(tr)
	if not SERVER then return true end

	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end

	permaents.add(ply, tr.Entity)
	return true
end

function TOOL:RightClick(tr)
	if not SERVER then return true end

	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end

	permaents.remove(ply, tr.Entity)
	return true
end

function TOOL:Reload(tr)
	if CLIENT then RunConsoleCommand("permaents") end
	return false
end

if CLIENT then
	function TOOL:DrawHUD()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		if not ply:IsSuperAdmin() then return end

		for _, ent in ipairs(ents.GetAll()) do
			if not ent:GetNW2Bool("permaents_state", false) then continue end

			local pos = ent:GetPos():ToScreen()
			local x, y = pos.x + 10, pos.y

			draw.SimpleText("⬤", "Trebuchet18", x, y + 15, color_white, 1, 1)
			draw.SimpleText("[" .. ent:GetNW2Int("permaents_id", 0) .. "]", "Trebuchet24", x, y, color_white, 1, 1)
		end
	end
end