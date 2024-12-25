--[[
	Variables
]]

local frame
local sw, sh = ScrW(), ScrH()
local rw, rh = sw / 1920, sh / 1080

--[[
    Functions
]]

function permaents.menu(tbl)
	if IsValid(frame) then frame:Remove() end

	frame = vgui.Create("DFrame")
	frame:SetSize(rw*384, rh*256)
	frame:Center()
	frame:SetTitle("PermaEnts Debug")
	frame:MakePopup()

	local scroll = frame:Add("DScrollPanel")
	scroll:Dock(FILL)
	scroll:DockMargin(rw*10, rh*10, rw*10, rh*5)

	local bottom = frame:Add("DButton")
	bottom:Dock(BOTTOM)
	bottom:DockMargin(rw*10, rh*5, rw*10, rh*10)
	bottom:SetText("CleanUp All")
	bottom:SetTall(rh*32)
	bottom.DoClick = function()
		net.Start("permaents.cleanup")
		net.SendToServer()
	end

	if not istable(tbl) then
		scroll.Paint = function(_, w, h)
			draw.SimpleText("There is no permanent entity", "DermaLarge", w/2, h/2, color_white, 1, 1)
		end
		return
	end

	for id, ent in pairs(tbl) do
		local button = scroll:Add("DButton")
		button:Dock(TOP)
		button:DockMargin(0, 0, 0, rh*4)
		button:SetTall(rh*32)
		button:SetText("[" .. id .. "] " .. ent.class)
		button.DoClick = function()
			net.Start("permaents.remove")
				net.WriteInt(id, 32)
			net.SendToServer()

			button:Remove()
		end
	end
end

--[[
    Networks
]]

net.Receive("permaents.menu", function()
	permaents.menu(net.ReadTable())
end)