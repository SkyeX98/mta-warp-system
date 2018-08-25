--[[
 maybe migration to oop orientation? :-)
]]

local warps=nil

-- functions
local function loadTheWarps()
	warps={}
	local xml=xmlLoadFile("warpy.xml")
	if not xml then return end -- zabezpieczenie przed "brakiem pliku"/nieznalezieniem pliku
	local xmlNode=xmlNodeGetChildren(xml)

	for i, node in pairs(xmlNode) do
		warps[i]={
			name=tostring(xmlNodeGetAttribute(node, "name")),
			x=xmlNodeGetAttribute(node, "x"),
			y=xmlNodeGetAttribute(node, "y"),
			z=xmlNodeGetAttribute(node, "z"),
			dim=xmlNodeGetAttribute(node, "dim"),
			int=xmlNodeGetAttribute(node, "int"),
		}
	end
	outputDebugString("[WARPS]: Loaded " .. #warps .. " warps.")
	xmlUnloadFile(xml)
end

-- events
addEventHandler("onResourceStart", resourceRoot, loadTheWarps)
addEventHandler("onResourceStop", resourceRoot, function()
	warps=nil
end)

-- commands
addCommandHandler("warp", function(plr, cmd, arg)
	if not arg or arg ~= "lista" then return end

	if not warps then
		outputChatBox("Lista warpów jest pusta.")
	end

	local tmpWarps={}
	for i,v in pairs(warps) do
		tmpWarps[i]=v.name
	end
	tmpWarps=table.concat(tmpWarps, " ")
	outputChatBox(tmpWarps, plr)
end)

addCommandHandler("warp", function(plr, cmd, warpName)
	if not warps then 
		outputChatBox("Wystapil blad, prosimy sprobowac pozniej.", plr)
		return
	end

	if not warpName then
		outputChatBox("Blad! Podany warp nie istnieje. Wpisz /lista-warpow, aby sprawdzic liste wszystkich warpow.", plr)
		return
	end

	local foundedWarp=0
	for i,v in pairs(warps) do
		if v.name==warpName then
			foundedWarp=i
			break
		end
	end

	if foundedWarp~=0 then
		local curWarp=warps[foundedWarp]
		outputChatBox(("Teleportowanie do %s."):format(curWarp.name))
		fadeCamera(plr, false)

		setTimer(function(plr, v)
			setElementPosition(plr, v.x, v.y, v.z)
			setElementDimension(plr, v.dim)
			setElementInterior(plr, v.int)
			fadeCamera(plr, true)
		end, 2500, 1, plr, curWarp)
	else
		outputChatBox("Nie znaleziono teleportu. Aby sprawdzić listę wszystkich warpów wpisz /warp lista", plr)
	end
end)

addCommandHandler("warp", function(plr, cmd, arg)
		if not arg or arg ~= "reoald" then return end
	--[[
	Dla korzystajacych z uprawnien ACL i wbudowanego mechanizmu kont.

	local accountName=getAccountName(getPlayerAccount(plr)) or "none"
	if not isObjectInACLGroup("user." .. accountName, aclGetGroup("Admin")) then
		-- outputChatBox("Brak uprawnien.")
		return
	end
	]]

	warps=nil
	loadTheWarps()
	outputChatBox("Pomyślnie przeładowano warpy (obecnie: ".. #warps .. ")", plr)
end)

addCommandHandler("warp", function(plr, cmd, warpName, arg)
		if not arg or arg ~= "add" then return end
	--[[
	Dla korzystajacych z uprawnien ACL i wbudowanego mechanizmu kont.

	local accountName=getAccountName(getPlayerAccount(plr)) or "none"
	if not isObjectInACLGroup("user." .. accountName, aclGetGroup("Admin")) then
		-- outputChatBox("Brak uprawnien.")
		return
	end
	]]

	if not warpName then
		outputChatBox("Błąd, nie została podana nazwa warpu.", plr)
		return
	end

	local x,y,z=getElementPosition(plr)
	local int,dim=getElementInterior(plr), getElementDimension(plr)

	local xml=xmlLoadFile("warpy.xml")
	if not xml then return end

	--[[
		@todo: wpisywanie do pliku
	]]
	xmlSaveFile(xml)
	xmlUnloadFile(xml)

	warps=nil
	loadTheWarps()
	outputChatBox("Stworzono warp, o nazwie " .. warpName .. ".", plr)
end)
