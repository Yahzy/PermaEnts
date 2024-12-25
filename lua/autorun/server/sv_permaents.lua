--[[
	Functions
]]

function permaents.init()
	local path = "permaents/" .. game.GetMap() .. ".json"
	if not file.IsDir("permaents", "DATA") then file.CreateDir("permaents") end
	if not file.Exists(path, "DATA") then file.Write(path, "[]") end

	local json = file.Read(path, "DATA")
	local results = util.JSONToTable(json or "[]")

	permaents.list = results or {}
end

function permaents.save()
	file.Write("permaents/" .. game.GetMap() .. ".json", util.TableToJSON(permaents.list))
end

function permaents.add(ply, ent)
	if not IsValid(ply) then return end
	if not IsValid(ent) then return end
	if ent:GetNW2Bool("permaents_state", false) then ply:ChatPrint("This entity is already permanent.") return end

	local id = #permaents.list + 1
	permaents.list[id] = {
		class = ent:GetClass(),
		pos = ent:GetPos(),
		ang = ent:GetAngles(),
		model = ent:GetModel(),
		skin = ent:GetSkin(),
		color = ent:GetColor(),
		material = ent:GetMaterial(),
		freeze = IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled() or false
	}

	permaents.save()

	ent:SetNW2Bool("permaents_state", true)
	ent:SetNW2Int("permaents_id", id)

	ply:ChatPrint("This entity is now permanent !")

	local effect = EffectData()
	effect:SetOrigin(ent:GetPos())
	effect:SetMagnitude(2.5)
	effect:SetScale(2)
	effect:SetRadius(3)
	util.Effect("Sparks", effect, true, true)
end

function permaents.remove(ply, ent)
	if not IsValid(ply) then return end

	if not isnumber(ent) and IsValid(ent) and IsEntity(ent) then
		local id = ent:GetNW2Int("permaents_id", 0)
		permaents.list[id] = nil

		ent:SetNW2Bool("permaents_state", nil)
		ent:SetNW2Int("permaents_id", nil)

		permaents.save()
	elseif isnumber(ent) and permaents.list[ent] then
		permaents.list[ent] = nil
		permaents.save()
	end
end

function permaents.cleanup()
	permaents.nextcleanup = permaents.nextcleanup or 0
	if permaents.nextcleanup > CurTime() then return end

	for _, ent in ipairs(ents.GetAll()) do
		if not IsValid(ent) then continue end
		if ent:GetNW2Bool("permaents_state", false) then ent:Remove() end
	end

	timer.Simple(1.5, function() permaents.spawn() end)
	permaents.nextcleanup = CurTime() + 5
end

function permaents.spawn()
	for id, cfg in pairs(permaents.list) do
		local ent = ents.Create(cfg.class)
		if not IsValid(ent) then continue end
		ent:SetPos(cfg.pos)
		ent:SetAngles(cfg.ang)
		ent:SetModel(cfg.model)
		ent:SetSkin(cfg.skin)
		ent:SetColor(cfg.color)
		ent:SetMaterial(cfg.material)
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(cfg.freeze) end

		ent:SetNW2Bool("permaents_state", true)
		ent:SetNW2Int("permaents_id", id)
	end
end

--[[
	Hooks
]]

hook.Add("Initialize", "permaents.init", permaents.init)
hook.Add("InitPostEntity", "permaents.spawn", permaents.spawn)
hook.Add("PostCleanupMap", "permaents.spawn", permaents.spawn)
hook.Add("PhysgunPickup", "permaents.pickup", function(ply, ent)
	if ent:GetNW2Bool("permaents_state", false) then return false end
end)

--[[
	Networks
]]

util.AddNetworkString("permaents.menu")
util.AddNetworkString("permaents.remove")
util.AddNetworkString("permaents.cleanup")

net.Receive("permaents.remove", function(len, ply)
	if not istable(permaents.list) then return end
	if not ply:IsSuperAdmin() then return end

	local id = net.ReadInt(32)
	if not isnumber(id) then return end

	permaents.remove(ply, id)
end)

net.Receive("permaents.cleanup", function(len, ply)
	if not istable(permaents.list) then return end
	if not ply:IsSuperAdmin() then return end

	permaents.cleanup()
end)

--[[
	Commands
]]

concommand.Add("permaents", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end

	net.Start("permaents.menu")
		net.WriteTable(permaents.list)
	net.Send(ply)
end)