loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-AR/main/UI"))();

game:GetService("CoreGui").ArgonGui.MainFrame.Visible = false

R = game.Workspace.Remote

Running = nil

local Script = nil
if _G.Commands == nil then
	_G.Commands = {}
	meta = getrawmetatable(game)
	nc = meta.__namecall
	make_writeable(meta)

	meta.__namecall = newcclosure(function(rc, ...)
		args = {...}
		if Running == nil and tostring(rc) == "RenderSteppedAfterCamera" and getnamecallmethod() == "Fire" then
			Running = true
			Script = getfenv(2).script
			spawn(function()
				while wait() do
					if Script.Parent == nil then
						break
					end
					if #_G.Commands > 0 then
						for i = 1, #_G.Commands do
							_G.Commands[i][1](unpack(_G.Commands[i][2]))
							--{Command, {Args}}
						end
						_G.Commands = {}
					end
				end
			end)
		end

		return nc(rc, unpack(args))
	end)

	spawn(function()
		while wait() do
			if Running ~= nil and Script.Parent == nil then
				Running = nil
			end
		end
	end)
end

G = getrenv()["_G"]
function fireserver(re, ...)
	if G[re] then
		table.insert(_G.Commands, {G[re], {...}})
	end
end

getgenv().fireserver = fireserver


LPlr = game.Players.LocalPlayer
function SetupHumanoidWatch()
	repeat
		wait()
	until LPlr.Character ~= nil and LPlr.Character:FindFirstChild("HumanoidRootPart")
	local DidTryKick = false
	LPlr.Character.HumanoidRootPart.ChildAdded:connect(function(Ch)
		if tostring(Ch) == "IsBuildingMaterial" and LPlr.Character.HumanoidRootPart.IsBuildingMaterial.Value ~= "poop" then
			R.Detonate:FireServer(Ch)
			local TempPlrTab = game.Players:GetPlayers()
			DidTryKick =  true
			pcall(function()
				repeat
					fireserver("ChangeParent", Ch)
					wait()
				until Ch.Parent == nil
			end)
			print("Someone attempted to kick you!")
			spawn(function()
				for i = 1, 30 do
					for a = 1, #TempPlrTab do
						if not game.Players:FindFirstChild(tostring(TempPlrTab[a])) and tostring(TempPlrTab[a]) ~= "nil" then
							print("Possible Kicker: "..tostring(TempPlrTab[a]))
							table.remove(TempPlrTab, a)
						else if LPlr.Character.HumanoidRootPart.IsBuildingMaterial.Value == "poop" then
								print("dark was here")
							end
						end
					end
					wait(0.1)
				end
				DidTryKick = false
			end)
		end
	end)
	local LastPos = LPlr.Character.HumanoidRootPart.Position
	LPlr.Character.HumanoidRootPart:GetPropertyChangedSignal("Position"):connect(function()
		wait(0.1)
		if LPlr.Character == nil or not LPlr.Character:FindFirstChild("HumanoidRootPart") then
			return
		end
		if (LPlr.Character.HumanoidRootPart.Position - LastPos).Magnitude > 100 and DidTryKick == true then
			DidTryKick = false
			LPlr.Character:MoveTo(LastPos)
		else
			LastPos = LPlr.Character.HumanoidRootPart.Position
		end
	end)
end

LPlr.CharacterAdded:connect(SetupHumanoidWatch)
spawn(function()
	SetupHumanoidWatch()
end)

local crashers = getconnections(game.Players.LocalPlayer.ChildAdded)
for i, v in pairs(crashers)do
	v:Disable()
end

eplr = game.Players.LocalPlayer
----------------------------------------------------------------------------
if _G.Parts == nil then
	_G.Parts = {}
	game.Workspace.ChildAdded:connect(function(Ch)
		wait(5)
		if game.Players:FindFirstChild(tostring(Ch)) then
			local Tor = Ch.Torso
			local Part = Instance.new("Part", Tor)
			Part.Size = Vector3.new(4, 5, 2)
			Part.Transparency = 1
			Part.CanCollide = false
			local Weld = Instance.new("Weld", Tor)
			Weld.Part0 = Tor
			Weld.Part1 = Part
			Weld.C0 = CFrame.new(0, -0.5, 0)
			table.insert(_G.Parts, Part)
		end
	end)
	for i, v in pairs(game.Players:GetPlayers()) do
		if v.Character ~= nil then 
			local Tor = v.Character.Torso
			local Part = Instance.new("Part", Tor)
			Part.Size = Vector3.new(4, 5, 2)
			Part.Transparency = 1
			Part.CanCollide = false
			local Weld = Instance.new("Weld", Tor)
			Weld.Part0 = Tor
			Weld.Part1 = Part
			Weld.C0 = CFrame.new(0, -0.5, 0)
			table.insert(_G.Parts, Part)
		end
	end
end
if _G.TouchParts == nil then
	_G.TouchParts = {}
	spawn(function()
		while wait(0.1) do
			for b = 1, #_G.Parts do
				for i, v in pairs(_G.TouchParts) do
					-- v = {"Kill"} or v = {"Teleport", Position}
					if i ~= nil and _G.Parts[b] ~= nil and (i.Position - _G.Parts[b].Position).magnitude <= GetBiggestSize(i)/2 then
						if v[1] == "Kill" then
							KillPlayer(_G.Parts[b])
						elseif v[1] == "Teleport" then
							TeleportPlayer(_G.Parts[b], v[2])
						end
						break
					end
				end
			end
		end
	end)
end

R = game.Workspace.Remote
Mats = game.Lighting.Materials
SpecialBypass = true
if not debug == nil or not debug.getupvalues then
	SpecialBypass = false
	function KillPlayer(Part)
		Plr = GetPlayer(Part)
		if Plr ~= nil and Plr:FindFirstChild("Humanoid") and Plr:FindFirstChild("HumanoidRootPart") then
			local H = Plr.HumanoidRootPart
			Position = H.Position
			R.AddClothing:FireServer("IsBuildingMaterial", H, "", "", "")
			repeat
				wait()
			until H:FindFirstChild("IsBuildingMaterial")
			R.ReplicatePart:FireServer(H, CFrame.new(Position.X, -10000, Position.Z))
		end
	end
elseif SpecialBypass == true then
	Serial = nil
	GetKey = nil
	local metaCall = getrawmetatable(getrenv().shared)
	for i, v in pairs(debug.getupvalues(metaCall.__index)) do
		if i == 3 then
			for a, b in pairs(debug.getupvalues(v)) do
				if a == 6 then
					Serial = b
				elseif a == 7 then
					GetKey = b
				end
			end
		end
	end
	function fireserver(Re, ...)
		Re = R[tostring(Re)]
		Re:FireServer(Serial({...}, GetKey()))
	end
	function MoveItem(Item, Par)
		fireserver("GrabItem", Par, game.Players, Item)
	end
	function KillPlayer(Part)
		Plr = GetPlayer(Part)
		if Plr ~= nil and Plr:FindFirstChild("Humanoid") then
			fireserver("GrabItem", Plr.HumanoidRootPart, game.Players, Plr.Head)
		end
	end
	function FillChest(Chest, ItemList)
		LootDrops = game.Lighting.LootDrops
		Storage = Chest.Head.storage
		if not game.Lighting:FindFirstChild("PatientZero") then return end
		SacrificeItem = game.Lighting.PatientZero
		SacPar = SacrificeItem.Parent
		MoveItem(SacrificeItem, Mats)
		Count()
		local AcceptedItems = 0
		for i = 1, #ItemList do
			if LootDrops:FindFirstChild(ItemList[i]) and LootDrops[ItemList[i]]:FindFirstChild("ObjectID") then
				ItemList[i] = {LootDrops[ItemList[i]].ObjectID, LootDrops[ItemList[i]]}
				MoveItem(ItemList[i][1], SacrificeItem)
				AcceptedItems = AcceptedItems + 1
				Count()
			end
		end
		repeat
			wait()
		until SacrificeItem.Parent == Mats and #SacrificeItem:GetChildren() >= AcceptedItems
		pcall(function() R["PlaceMaterial"]:FireServer(tostring(SacrificeItem), Vector3.new(0, 0, 0)) end)
		Count()
		repeat
			wait()
		until game.Workspace:FindFirstChild(tostring(SacrificeItem))
		MoveItem(SacrificeItem, SacPar)
		Count()
		for i = 1, #ItemList do
			if ItemList[i][1] ~= nil then
				MoveItem(ItemList[i][1], ItemList[i][2])
				Count()
			end
		end
		local ItemHolder = game.Workspace:FindFirstChild(tostring(SacrificeItem))
		local Amount = 0
		for i, v in pairs(ItemHolder:GetChildren()) do
			if v.Name == "ObjectID" then
				Amount = Amount + 1
				MoveItem(v, Storage["slot"..tostring(Amount)])
				Count()
			end
		end
		wait()
		for i, v in pairs(game.Workspace:GetChildren()) do 
			if v.Name == tostring(SacrificeItem) then
				MoveItem(v, game.ReplicatedStorage.DefaultChatSystemChatEvents.OnUnmuted)
				Count()
			end
		end
	end
end

function TeleportPlayer(Part, Position)
	Plr = GetPlayer(Part)
	if Plr ~= nil and Plr:FindFirstChild("Humanoid") and Plr:FindFirstChild("HumanoidRootPart") then
		local H = Plr.HumanoidRootPart
		R.AddClothing:FireServer("IsBuildingMaterial", H, "", "", "")
		repeat
			wait()
		until H:FindFirstChild("IsBuildingMaterial")
		R.ReplicatePart:FireServer(H, CFrame.new(Position.X, Position.Y, Position.Z))
	end
end

function GetPlayer(T)
	if T == nil or T.Parent == nil then
		return nil
	end
	repeat
		T = T.Parent
	until T == nil or T.Parent == nil or T:FindFirstChild("Head") and T:FindFirstChild("HumanoidRootPart")
	return T
end

function GetBiggestSize(Part)
	local Side = Part.Size.X
	if Part.Size.Y > Side then
		Side = Part.Size.Y
	end
	if Part.Size.Z > Side then
		Side = Part.Size.Z
	end
	if Side/2 < 4 then
		Side = 8
	end
	return Side
end

function HandleSpecial(Item, Tab, Pos)
	if SpecialBypass == false and not (Tab[1] == "Teleport" or Tab[1] == "Kill") then
		return
	end
	if Tab[1] == "Kill" or Tab[1] == "Teleport" then
		local ItemsTab = {}
		if Item:IsA("BasePart") then
			table.insert(ItemsTab, Item)
		elseif Item:IsA("Model") then
			for i, v in pairs(Item:GetChildren()) do
				if v:IsA("BasePart") then
					table.insert(ItemsTab, v)
				end
			end
		end
		for i = 1, #ItemsTab do
			if Tab[1] == "Kill" then
				_G.TouchParts[ItemsTab[i]] = {"Kill"}
			elseif Tab[1] == "Teleport" then
				_G.TouchParts[ItemsTab[i]] = {"Teleport", Pos+Tab[2]}
			end
		end
	elseif Tab[1] == "Fill" then
		FillChest(Item, Tab[2])
	end
end

function PlaceItem(Item, Pos, Val)
	pcall(function() R["PlaceMaterial"]:FireServer(tostring(Item), Pos-Mats[tostring(Item)].Head.Position, false, Val) end)
end
Times = 0
MaxTimes = 1000
function Count()
	Times = Times + 1
	if Times > MaxTimes then
		wait(1)
		Times = 0
	end
end

function SpawnParts(Item, Amount, Val)
	PlrPos = game.Players.LocalPlayer.Character.Head.Position
	for i = 1, Amount do
		PlaceItem(Item, PlrPos+Vector3.new(0, 10, 0), Val)
		Count()
	end
end

function CountParts(TheWS, Item, Val)
	local Amount = 0
	local Parts = {}
	for i, v in pairs(game.Workspace:GetChildren()) do
		if TheWS[v] ~= true and v:FindFirstChild("IsBuildingMaterial") and (v:IsA("BasePart") and v.Size == Mats[Item].Head.Size or Val == true and v:FindFirstChild("Head") and v.Name == Item) then
			Amount = Amount + 1
			table.insert(Parts, v)
		end
	end
	return {Amount, Parts}
end

function MoveParts(Items, ItemTab, Spot)
	local Broken = false
	for i = 1, #Items do
		if ItemTab[i] == nil then
			Broken = true
			if Items[i]:FindFirstChild("Head") then
				R.ReplicateModel:FireServer(Items[i], CFrame.new(100000, -100, 1000))
			else
				R.ReplicatePart:FireServer(Items[i], CFrame.new(100000, -100, 1000))
			end
		elseif ItemTab[i] ~= nil and ItemTab[i][3] ~= nil then
			HandleSpecial(Items[i], ItemTab[i][3], Spot)
		end
		if not Items[i]:FindFirstChild("Head") and Broken ~= true then
			local Pos = (ItemTab[i][2]+Spot+ItemTab[i][1])
			R.ReplicatePart:FireServer(Items[i], Pos)
		elseif Broken ~= true then
			local Pos = (ItemTab[i][2]+ItemTab[i][1]+Spot)
			R.ReplicateModel:FireServer(Items[i], Pos)
		end
		Count()
	end
end

function SpawnBase(Tab, Spot)
	for i = 1, #Tab do
		local Item = Tab[i]["Item"]
		local Amount = Tab[i]["Amount"]
		local Whole = Tab[i]["Whole"]
		local WS = {}
		for i, v in pairs(game.Workspace:GetChildren()) do
			WS[v] = true
		end
		SpawnParts(Item, Amount, not Whole)
		repeat
			wait()
		until (Whole == false and CountParts(WS, Item, Whole)[1] == #Mats[Item]:GetChildren()*Amount) or (Whole == true and CountParts(WS, Item, Whole)[1] == Amount)
		local PartsTab = CountParts(WS, Item, Whole)[2]
		MoveParts(PartsTab, Tab[i], Spot)
	end
end

local TweenService = game:GetService("TweenService")
spath = game:GetService("CoreGui").ArgonGui.ArgonLoadingScreen.LoadingFrame
wait(.5)
spath.Load.Text = "Authenticating.."
spath.Percentage.Text = 4
wait(.3)
spath.Load.Text = "Passed First check.."
spath.Percentage.Text = 12
wait(1)
spath.Load.Text = "Passed Second check.."
spath.Percentage.Text = 28
wait(.4)
spath.Load.Text = "Sending data.."
spath.Percentage.Text = 34
wait(.2)
spath.Load.Text = "Requesting UI.."
spath.Percentage.Text = 50
wait(.1)
spath.Load.Text = "Loading scripts.."
spath.Percentage.Text = 67
wait(.2)
spath.Load.Text = "Loading Argon.."
spath.Percentage.Text = 80
wait(.5)
spath.Load.Text = "Successfully logged in"
spath.Percentage.Text = 100
wait(.5)
spath.Load:Destroy()
spath.Percentage:Destroy()
wait(1.5)
spath.TxtLoading:Destroy()
spath:TweenSize(UDim2.new(0,100,0,100), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 1, false)
wait(2)
local TI = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
local goal = {}
goal.ImageTransparency = 0
local tween = TweenService:Create(spath, TI, goal)
tween:Play()
wait(1)
spath.ScaleType = Enum.ScaleType.Crop
spath:TweenSize(UDim2.new(0,0,0,100), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 1, false)

wait(1.1)

game.CoreGui.ArgonGui.MainFrame.Visible = true


-- Update script --
UpdateVersion = "Version 1.8.2"

UpdateDate = "2021-06-13"

LastUpdated.Text = "Updated At " .. UpdateDate

DiscordInv = "discord.gg/tdvPGbu"

wait(.1)

MainFrame.Active = true

MainFrame.Selectable = true

MainFrame.Draggable = true

function cleartabs()
	CreditsFrame.Visible = false
	ImportFrame.Visible = false
	PlayerFrame.Visible = false
	ServerFrame.Visible = false
	SpawnFrame.Visible = false
	TpFrame.Visible = false
	ClothingFrame.Visible = false
	GunFrame.Visible = false
	ExtraFrame.Visible = false
end
cleartabs()
CreditsFrame.Visible = true

BaseButt.MouseEnter:Connect(function()
	BaseWhite.Visible = true
end)

BaseButt.MouseLeave:Connect(function()
	BaseWhite.Visible = false
end)

PlayerButt.MouseEnter:Connect(function()
	PlayerWhite.Visible = true
end)

PlayerButt.MouseLeave:Connect(function()
	PlayerWhite.Visible = false
end)

ServerButt.MouseEnter:Connect(function()
	ServerWhite.Visible = true
end)

ServerButt.MouseLeave:Connect(function()
	ServerWhite.Visible = false
end)

SpawnButt.MouseEnter:Connect(function()
	SpawnWhite.Visible = true
end)

SpawnButt.MouseLeave:Connect(function()
	SpawnWhite.Visible = false
end)

TpButt.MouseEnter:Connect(function()
	TpWhite.Visible = true
end)

TpButt.MouseLeave:Connect(function()
	TpWhite.Visible = false
end)

ClothingButt.MouseEnter:Connect(function()
	ClothingWhite.Visible = true
end)

ClothingButt.MouseLeave:Connect(function()
	ClothingWhite.Visible = false
end)

GunButt.MouseEnter:connect(function()
	GunWhite.Visible = true
end)

GunButt.MouseLeave:connect(function()
	GunWhite.Visible = false
end)

ExtralButt.MouseEnter:connect(function()
	ExtraWhite.Visible = true
end)

ExtralButt.MouseLeave:connect(function()
	ExtraWhite.Visible = false
end)


----------------------

BaseButt.MouseButton1Down:Connect(function()
	cleartabs()
	ImportFrame.Visible = true
end)

ClothingButt.MouseButton1Down:connect(function()
	cleartabs()
	ClothingFrame.Visible = true
end)

PlayerButt.MouseButton1Down:Connect(function()
	cleartabs()
	PlayerFrame.Visible = true
end)

ServerButt.MouseButton1Down:Connect(function()
	cleartabs()
	ServerFrame.Visible = true
end)

SpawnButt.MouseButton1Down:Connect(function()
	cleartabs()
	SpawnFrame.Visible = true
end)

TpButt.MouseButton1Down:Connect(function()
	cleartabs()
	TpFrame.Visible = true
end)

GunButt.MouseButton1Down:connect(function()
	cleartabs()
	GunFrame.Visible = true
end)

ExtralButt.MouseButton1Down:connect(function()
	cleartabs()
	ExtraFrame.Visible = true
end)

-- script functions time!!! --
R = require(game.ReplicatedStorage.Node).Remote
local metaCall = getrawmetatable(getrenv().shared)
for i, v in pairs(debug.getupvalues(metaCall.__index)) do
	if i == 3 then
		for a, b in pairs(debug.getupvalues(v)) do
			if a == 6 then
				Serial = b
			elseif a == 7 then
				GetKey = b

			end
		end
	end
end


if not _G.fireserver then
	_G.fireserver = function(Re, ...)
		Re = R[tostring(Re)]
		Re:FireServer(Serial({...}, GetKey()))
	end
end

function spawnitem()
	if game.Players:FindFirstChild(PlayerSpawnBox.Text) then
		local loot
		for i, it in next, game:GetService('Lighting').LootDrops:GetChildren() do
			if ('').lower(it.Name) == ('').lower(ItemBox.Text) then
				loot = it
				break
			end
		end
		local position = game.Players[PlayerSpawnBox.Text].Character.HumanoidRootPart.Position - (loot.PrimaryPart and loot:GetPrimaryPartCFrame().p or loot.Model:FindFirstChildOfClass('Part').CFrame.p)
		for i = 1, tonumber(QuantityBox.Text) or 1 do
			_G.fireserver('ChangeParent', loot, game.Lighting.Materials)
			workspace.Remote.PlaceMaterial:FireServer(loot.Name, position + Vector3.new(math.random(-4, 4), 0, math.random(-4, 4)), false, false)
			_G.fireserver('ChangeParent', loot, game.Lighting.LootDrops)
		end   
	else
		PlayerSpawnBox.Text = "Player name"
	end
end
StorageRep = game.ReplicatedStorage
----------------------

Base1.MouseButton1Down:Connect(function()
	BaseSelectedTxt.Text = "Devils Church"
end)

Base2.MouseButton1Down:Connect(function()
	BaseSelectedTxt.Text = "Circle Base"
end)

Base3.MouseButton1Down:Connect(function()
	BaseSelectedTxt.Text = "Sky Base"
end)

OctageonBase.MouseButton1Down:Connect(function()
	BaseSelectedTxt.Text = OctageonBase.Text
end)

Fortress.MouseButton1Down:connect(function()
	BaseSelectedTxt.Text = "Fortress"
end)

SmolBase.MouseButton1Down:Connect(function()
	BaseSelectedTxt.Text = SmolBase.Text
end)

DmitrisBase.MouseButton1Down:Connect(function()
	BaseSelectedTxt.Text = DmitrisBase.Text
end)


ImportButt.MouseButton1Down:Connect(function()
	if BaseSelectedTxt.Text == "Devils Church" then
		
loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/DevilsChurch.txt"))();

	end
	if BaseSelectedTxt.Text == "Circle Base" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/Circle%20Base.txt"))();	end
	if BaseSelectedTxt.Text == "Sky Base" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/Rauls%20Sky%20Base.txt"))();
	end
	if BaseSelectedTxt.Text == "Octageon Base" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/Octa%20Base.txt"))();	end
	if BaseSelectedTxt.Text == "Fortress" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/Fortress.txt"))();
	end
	if BaseSelectedTxt.Text == "Smol Base" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/Small%20Base.txt"))();
	end
	if BaseSelectedTxt.Text == "Dmitris Base" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GeneralOfAR/Argon-Bases/main/Dimitris%20Base.txt"))();		end
end)

playerl = game.Players.LocalPlayer.Name

NuggetToggle2.MouseButton1Down:connect(function()
	NuggetToggle2.Visible = false
	NuggetToggle.Visible = true
	_G.fireserver('ChangeParent', game.Players[playerl].Character['Left Arm'], StorageRep)
	_G.fireserver('ChangeParent', game.Players[playerl].Character['Right Arm'], StorageRep)
	_G.fireserver('ChangeParent', game.Players[playerl].Character['Left Leg'], StorageRep)
	_G.fireserver('ChangeParent', game.Players[playerl].Character['Right Leg'], StorageRep)
end)

NuggetToggle.MouseButton1Down:connect(function()
	NuggetToggle2.Visible = true
	NuggetToggle.Visible = false
	_G.fireserver('ChangeParent', StorageRep['Left Arm'], game.Players[playerl].Character)
	_G.fireserver('ChangeParent', StorageRep['Right Arm'], game.Players[playerl].Character)
	_G.fireserver('ChangeParent', StorageRep['Left Leg'], game.Players[playerl].Character)
	_G.fireserver('ChangeParent', StorageRep['Right Leg'], game.Players[playerl].Character)
end)

C4WalkToggle2.MouseButton1Down:connect(function()
	C4WalkOn = true
	C4WalkToggle2.Visible = false
	C4WalkToggle.Visible = true
	if C4WalkOn == true then
		repeat wait()
			local player = game.Players.LocalPlayer
			local material = game.Lighting.Materials.C4Placed
			local pos = player.Character.Torso.Position - material.Head.Position + Vector3.new(0,0,0)
			game.Workspace.Remote.PlaceC4:FireServer(material, pos, true)
		until C4WalkOn == false
	end
end)

C4WalkToggle.MouseButton1Down:connect(function()
	C4WalkToggle2.Visible = true
	C4WalkToggle.Visible = false
	C4WalkOn = false
end)

TM46WalkToggle2.MouseButton1Down:connect(function()
	TM46WalkToggle2.Visible = false
	TM46WalkToggle.Visible = true
	TM46WalkOn = true
	if TM46WalkOn == true then
		repeat wait()
			local player = game.Players.LocalPlayer
			local material = game.Lighting.Materials.TM46Placed
			local pos = player.Character.Torso.Position - material.Head.Position + Vector3.new(0,0,0)
			game.Workspace.Remote.PlaceC4:FireServer(material, pos, true)
		until TM46WalkOn == false
	end
end)

TM46WalkToggle.MouseButton1Down:connect(function()
	TM46WalkToggle2.Visible = true
	TM46WalkToggle.Visible = false
	TM46WalkOn = false
end)

VS50WalkToggle2.MouseButton1Down:connect(function()
	VS50WalkToggle2.Visible = false
	VS50WalkToggle.Visible = true
	VS50WalkOn = true
	if VS50WalkOn == true then
		repeat wait()
			local player = game.Players.LocalPlayer
			local material = game.Lighting.Materials.VS50Placed
			local pos = player.Character.Torso.Position - material.Head.Position + Vector3.new(0,0,0)
			game.Workspace.Remote.PlaceC4:FireServer(material, pos, true)
		until VS50WalkOn == false
	end
end)

VS50WalkToggle.MouseButton1Down:connect(function()
	VS50WalkToggle2.Visible = true
	VS50WalkToggle.Visible = false
	VS50WalkOn = false
end)

InfStaminaToggle2.MouseButton1Down:connect(function()
	InfStaminaToggle2.Visible = false
	InfStaminaToggle.Visible = true
	Stamina = true
	while wait() do
		if Stamina == true then
			game.Players.LocalPlayer.Backpack.GlobalFunctions.Stamina.Value = 100
		end
	end
end)

InfStaminaToggle.MouseButton1Down:connect(function()
	InfStaminaToggle2.Visible = true
	InfStaminaToggle.Visible = false
	Stamina = false
end)

NoFogToggle2.MouseButton1Down:connect(function()
	NoFogToggle2.Visible = false
	NoFogToggle.Visible = true
	NoFog = true
	if NoFog == true then
		repeat wait()
			if game.Lighting.FogEnd ~= 9999999 then
				game.Lighting.FogEnd = 9999999
			end
		until NoFog == false
	end
end)

NoFogToggle.MouseButton1Down:connect(function()
	NoFogToggle2.Visible = true
	NoFogToggle.Visible = false
	NoFog = false
	game.Lighting.FogEnd = 1300
end)

NoVestToggle2.MouseButton1Down:connect(function()
	NoVestToggle2.Visible = false
	NoVestToggle.Visible = true
	for i, v in pairs(game.Workspace[game.Players.LocalPlayer.Name]:GetChildren()) do
		if v.Name == "Tactical" then
			_G.fireserver("ChangeParent", game.Workspace[game.Players.LocalPlayer.Name].Tactical, game:GetService("ReplicatedStorage"))
		end
		if v.Name == "Standard" then
			_G.fireserver("ChangeParent", game.Workspace[game.Players.LocalPlayer.Name].Standard, game:GetService("ReplicatedStorage")) -- standard
		end
		if v.Name == "Heavy" then
			_G.fireserver("ChangeParent", game.Workspace[game.Players.LocalPlayer.Name].Heavy, game:GetService("ReplicatedStorage"))
		end
	end
end)

NoVestToggle.MouseButton1Down:connect(function()
	NoVestToggle2.Visible = true
	NoVestToggle.Visible = false
	for i, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
		if v.Name == "Tactical" then
			_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Tactical, game.Workspace[game.Players.LocalPlayer.Name])
		end
		if v.Name == "Standard" then
			_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Standard, game.Workspace[game.Players.LocalPlayer.Name])
		end
		if v.Name == "Heavy" then
			_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Heavy, game.Workspace[game.Players.LocalPlayer.Name])
		end
	end
end)


Walkspeed.MouseButton1Down:connect(function()
	if ValueBoxLocalPlayer.Text ~= nil then
		eplr.PlayerGui.HitEqualsYouDie.WalkspeedEdit.Disabled = true
		eplr.PlayerGui.HitEqualsYouDie.JumpLimiter.Disabled = true 
		eplr.PlayerGui.SkyboxRenderMode.Disabled = true
		_G.walkspeed = ValueBoxLocalPlayer.Text
		eplr.Character.Humanoid.WalkSpeed = _G.walkspeed
	else
		return
	end
end)

JumpPower.MouseButton1Down:connect(function()
	if ValueBoxLocalPlayer.Text ~= nil then
		eplr.PlayerGui.HitEqualsYouDie.WalkspeedEdit.Disabled = true
		eplr.PlayerGui.HitEqualsYouDie.JumpLimiter.Disabled = true 
		eplr.PlayerGui.SkyboxRenderMode.Disabled = true
		eplr.Character.Humanoid.JumpPower = ValueBoxLocalPlayer.Text
	else
		return
	end
end)

InvisToggle2.MouseButton1Down:connect(function()
	InvisToggle2.Visible = false
	InvisToggle.Visible = true
	_G.fireserver("VehichleLightsSet",game.Players[game.Players.LocalPlayer.Name].Character, "Plastic", 1)
end)

InvisToggle.MouseButton1Down:connect(function()
	InvisToggle2.Visible = true
	InvisToggle.Visible = false
	_G.fireserver("VehichleLightsSet",game.Players[game.Players.LocalPlayer.Name].Character, "Plastic", 0)
end)

GhostToggle2.MouseButton1Down:connect(function()
	GhostToggle2.Visible = false
	GhostToggle.Visible = true
	_G.fireserver("VehichleLightsSet",game.Players[game.Players.LocalPlayer.Name].Character, "Plastic", .6)
end)

GhostToggle.MouseButton1Down:connect(function()
	GhostToggle2.Visible = true
	GhostToggle.Visible = false
	_G.fireserver("VehichleLightsSet",game.Players[game.Players.LocalPlayer.Name].Character, "Plastic", 0)
end)

NoLegsButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver('ChangeParent', game.Players.v.Character['Left Leg'], nil)
        _G.fireserver('ChangeParent', game.Players.v.Character['Right Leg'], nil)
        end
    else
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Left Leg'], nil)
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Right Leg'], nil) 
    end
end)

NoArmsButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver('ChangeParent', game.Players.v.Character['Left Arm'], nil)
        _G.fireserver('ChangeParent', game.Players.v.Character['Right Arm'], nil)
        end
    else
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Left Arm'], nil)
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Right Arm'], nil) 
    end
end)

NuggetButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver('ChangeParent', game.Players.v.Character['Left Arm'], game.ReplicatedStorage)
        _G.fireserver('ChangeParent', game.Players.v.Character['Right Arm'], game.ReplicatedStorage)
        _G.fireserver('ChangeParent', game.Players.v.Character['Left Leg'], game.ReplicatedStorage)
        _G.fireserver('ChangeParent', game.Players.v.Character['Right Leg'], game.ReplicatedStorage)
        end
    else
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Left Arm'], game.ReplicatedStorage)
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Right Arm'], game.ReplicatedStorage)
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Left Leg'], game.ReplicatedStorage)
        _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character['Right Leg'], game.ReplicatedStorage) 
    end
end)

UnNuggetButt.MouseButton1Down:connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Right Leg'], game.Players.v.Character)
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Right Arm'], game.Players.v.Character)
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Left Leg'], game.Players.v.Character)
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Left Arm'], game.Players.v.Character)
        end
    else
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Right Leg'], game.Players[ServerPlayerbox.Text].Character)
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Right Arm'], game.Players[ServerPlayerbox.Text].Character)
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Left Leg'], game.Players[ServerPlayerbox.Text].Character)
        _G.fireserver('ChangeParent', game.ReplicatedStorage['Left Arm'], game.Players[ServerPlayerbox.Text].Character) 
    end
end)

NoVestButt.MouseButton1Down:Connect(function()
	for i, v in pairs(game.Workspace[game.Players.LocalPlayer.Name]:GetChildren()) do
		if v.Name == "Tactical" then
			_G.fireserver("ChangeParent", game.Workspace[ServerPlayerbox.Text].Tactical, game:GetService("ReplicatedStorage"))
		end
		if v.Name == "Standard" then
			_G.fireserver("ChangeParent", game.Workspace[ServerPlayerbox.Text].Standard, game:GetService("ReplicatedStorage"))
		end
		if v.Name == "Heavy" then
			_G.fireserver("ChangeParent", game.Workspace[ServerPlayerbox.Text].Heavy, game:GetService("ReplicatedStorage"))
		end
	end
end)

AddVest.MouseButton1Down:connect(function()
	for i, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
		if v.Name == "Tactical" then
			_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Tactical, game.Workspace[ServerPlayerbox.Text])
		end
		if v.Name == "Standard" then
			_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Standard, game.Workspace[ServerPlayerbox.Text])
		end
		if v.Name == "Heavy" then
			_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Heavy, game.Workspace[ServerPlayerbox.Text])
		end
	end
end)

InvisButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver("VehichleLightsSet",game.Players.v.Character, "Plastic", 1)
        end
    else
        if ServerPlayerbox.Text == nil then
            getrenv()["_G"].SendMessage("Select a player.","Yellow")
        else
            _G.fireserver("VehichleLightsSet",game.Players[ServerPlayerbox.Text].Character, "Plastic", 1)
        end 
    end
end)

GhostButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver("VehichleLightsSet",game.Players.v.Character, "Plastic", .6)
        end
    else
        if ServerPlayerbox.Text == nil then
            getrenv()["_G"].SendMessage("Select a player.","Yellow")
        else
            _G.fireserver("VehichleLightsSet",game.Players[ServerPlayerbox.Text].Character, "Plastic", .6)
        end 
    end
end)

ExplodeButt.MouseButton1Down:connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        workspace.Remote.Detonate:FireServer({Name = "", Head = game.Workspace.v.Head})
        end
    else
        if ServerPlayerbox.Text == nil then
            getrenv()["_G"].SendMessage("Select a player.","Yellow")
        else
            workspace.Remote.Detonate:FireServer({Name = "", Head = game.Workspace[ServerPlayerbox.Text].Head})
        end
    end
end)

KickGroupsButt.MouseButton1Down:Connect(function()
	for _, v in pairs(game.Lighting.Groups:GetChildren()) do
		if v.Name ~= ("GlobalGroups") then
			for _, p in pairs(game.Players:GetPlayers()) do
				game.Workspace.Remote.GroupKick:FireServer(v,p)
			end
		end
	end
end)

CrashButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        game.Workspace.Remote.AddClothing:FireServer("PermanentBan", game.Players.v, "", "", "")
        end
    else
        if ServerPlayerbox.Text == nil then
            getrenv()["_G"].SendMessage("Select a player.","Yellow")
        else
            game.Workspace.Remote.AddClothing:FireServer("PermanentBan", game.Players[ServerPlayerbox.Text], "", "", "")
        end
    end
end)

KillButt.MouseButton1Down:Connect(function()
    if ServerPlayerbox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver('ChangeParent', game.Players.v.Character.Head, nil)
        end
    else
            _G.fireserver('ChangeParent', game.Players[ServerPlayerbox.Text].Character.Head, nil)
        end
end)

GodButt.MouseButton1Down:Connect(function()
        if ServerPlayerbox.Text == nil then
            getrenv()["_G"].SendMessage("Select a player.","Yellow")
        else if ServerPlayerbox.Text == game:GetService("Players").LocalPlayer.Name then
            _G.fireserver("Damage", game.Players[ServerPlayerbox.Text].Character.Humanoid, math.huge)
            game:GetService("Players").LocalPlayer.Character.Humanoid.Health = 100
            game:GetService("Players").LocalPlayer.PlayerGui.Survival.Bin.Health.BackgroundColor3 = Color3.fromRGB(255, 2, 225)
		    game:GetService("Players").LocalPlayer.PlayerGui.Survival.Bin.Health.Bar.BackgroundColor3 = Color3.fromRGB(255, 2, 225)
            else
                _G.fireserver("Damage", game.Players[ServerPlayerbox.Text].Character.Humanoid, math.huge)
        end
    end
end)

ClearButt.MouseButton1Down:Connect(function()
	Sizes = {}
	Materials = game.Lighting.Materials
	for i, v in pairs(Materials:GetChildren()) do
		if v:FindFirstChild("Head") then
			local S = v.Head.Size
			Sizes[tostring(S.X)..tostring(S.Y)..tostring(S.Z)] = true
		end
	end
	local Amount = 0
	function Count()
		Amount = Amount + 1
		if Amount >= 1000 then
			wait(1)
			Amount = 0
		end
	end
	for i, v in pairs(game.Workspace:GetDescendants()) do
		if v:IsA("BasePart") or v:FindFirstChild("Head") and not game.Players:FindFirstChild(tostring(v.Parent)) then
			if v:IsA("BasePart") and Sizes[(tostring(v.Size.X)..tostring(v.Size.Y)..tostring(v.Size.Z))] == true and not Materials:FindFirstChild(tostring(v.Parent)) then
				fireserver("ChangeParent", v, nil)
				Count()
			elseif not v:IsA("BasePart") and v:FindFirstChild("Head") then
				local S = v.Head.Size
				if Sizes[tostring(S.X)..tostring(S.Y)..tostring(S.Z)] == true then
					fireserver("ChangeParent", v, nil)
					Count()
				end
			elseif Materials:FindFirstChild(tostring(v)) then
				fireserver("ChangeParent", v, nil)
			end
		end
	end
end)

ClearBasesButt.MouseButton1Down:Connect(function()
	Sizes = {}
	Materials = game.Lighting.Materials
	for i, v in pairs(Materials:GetChildren()) do
		if v:FindFirstChild("Head") then
			local S = v.Head.Size
			Sizes[tostring(S.X)..tostring(S.Y)..tostring(S.Z)] = true
		end
	end
	local Amount = 0
	function Count()
		Amount = Amount + 1
		if Amount >= 1000 then
			wait(1)
			Amount = 0
		end
	end
	for i, v in pairs(game.Workspace:GetDescendants()) do
		if v:IsA("BasePart") or v:FindFirstChild("Head") and not game.Players:FindFirstChild(tostring(v.Parent)) then
			if v:IsA("BasePart") and Sizes[(tostring(v.Size.X)..tostring(v.Size.Y)..tostring(v.Size.Z))] == true and not Materials:FindFirstChild(tostring(v.Parent)) then
				fireserver("ChangeParent", v, nil)
				Count()
			elseif not v:IsA("BasePart") and v:FindFirstChild("Head") then
				local S = v.Head.Size
				if Sizes[tostring(S.X)..tostring(S.Y)..tostring(S.Z)] == true then
					fireserver("ChangeParent", v, nil)
					Count()
				end
			elseif Materials:FindFirstChild(tostring(v)) then
				fireserver("ChangeParent", v, nil)
			end
		end
	end
end)

ClearLootButt.MouseButton1Down:Connect(function()
	_G.fireserver('ChangeParent', game.Workspace.DropLoot, nil)
end)

NoZombiesToggle2.MouseButton1Down:connect(function()
	NoZombiesToggle2.Visible = false
	NoZombiesToggle.Visible = true
	if ZombiesLoop == true then
		repeat wait()
			for _, v in pairs(game.Workspace.Zombies:GetDescendants()) do
				if v.Name == "Zombie" then 
					_G.fireserver("ChangeParent", v, nil)
				end
			end
		until ZombiesLoop == false
	end
end)

NoZombiesToggle.MouseButton1Down:connect(function()
	NoZombiesToggle2.Visible = true
	NoZombiesToggle.Visible = false
	ZombiesLoop = false
end)

NoHillsToggle2.MouseButton1Down:connect(function()
	NoHillsToggle2.Visible = false
	NoHillsToggle.Visible = true
	_G.fireserver("ChangeParent", game:GetService("Workspace")["Anchored Objects"].Plates.Hills, game:GetService("ReplicatedStorage"))
end)

NoHillsToggle.MouseButton1Down:connect(function()
	NoHillsToggle2.Visible = true
	NoHillsToggle.Visible = false
	_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage").Hills, game:GetService("Workspace")["Anchored Objects"].Plates)
end)

NoBuildingsToggle2.MouseButton1Down:connect(function()
	NoBuildingsToggle2.Visible = false
	NoBuildingsToggle.Visible = true
	_G.fireserver("ChangeParent", game:GetService("Workspace")["Anchored Objects"]["Towns/Cities"], game:GetService("ReplicatedStorage"))
end)

NoBuildingsToggle.MouseButton1Down:connect(function()
	NoBuildingsToggle2.Visible = true
	NoBuildingsToggle.Visible = false
	_G.fireserver("ChangeParent", game:GetService("ReplicatedStorage")["Towns/Cities"], game:GetService("Workspace")["Anchored Objects"])
end)

SpamGlobalToggle2.MouseButton1Down:connect(function()
	SpamGlobalToggle2.Visible = false
	SpamGlobalToggle.Visible = true
	ChatSpam = true
	if ChatSpam == true then
		repeat wait()
			game.Workspace.Remote.Chat:FireServer("Global",'spam')
			wait()
			game.Workspace.Remote.Chat:FireServer("Global",'')
		until ChatSpam == false
	end
end)

SpamGlobalToggle.MouseButton1Down:connect(function()
	SpamGlobalToggle2.Visible = true
	SpamGlobalToggle.Visible = false
	ChatSpam = false
end)

SpamGroupToggle2.MouseButton1Down:connect(function()
	SpamGroupToggle2.Visible = false
	SpamGroupToggle.Visible = true
	ChatSpam = true
	if ChatSpam == true then
		repeat wait()
			game.Workspace.Remote.Chat:FireServer("Group",'spam')
			wait()
			game.Workspace.Remote.Chat:FireServer("Group",'')
		until ChatSpam == false
	end
end)

SpamGroupToggle.MouseButton1Down:connect(function()
	SpamGroupToggle2.Visible = true
	SpamGroupToggle.Visible = false
	ChatSpam = false
end)

Kit1.MouseButton1Down:Connect(function()
	ItemBox.Text = "M14"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "M14Ammo50"
	QuantityBox.Text = "8"
	spawnitem()
	wait(.1)
	ItemBox.Text = "MilitaryPackBlack"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "ACOG"
	spawnitem()
	wait(.1)
	ItemBox.Text = "Suppressor762"
	spawnitem()
	wait(.1)
	ItemBox.Text = "BloodBag"
	QuantityBox.Text = "12"
	spawnitem()
	wait(.1)
	ItemBox.Text = "Grip"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = ""
	QuantityBox.Text = ""
end)

Kit2.MouseButton1Down:Connect(function()
	ItemBox.Text = "G36K"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "STANAGAmmo100"
	QuantityBox.Text = "8"
	spawnitem()
	wait(.1)
	ItemBox.Text = "BloodBag"
	QuantityBox.Text = "12"
	spawnitem()
	wait(.1)
	ItemBox.Text = "MilitaryPackBlack"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "ACOG"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "Grip"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = ""
	QuantityBox.Text = ""
end)

Kit6.MouseButton1Down:Connect(function()
	ItemBox.Text = "Patriot"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "STANAGAmmo100"
	QuantityBox.Text = "8"
	spawnitem()
	wait(.1)
	ItemBox.Text = "BloodBag"
	QuantityBox.Text = "12"
	spawnitem()
	wait(.1)
	ItemBox.Text = "MilitaryPackBlack"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "ACOG"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "Grip"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = ""
	QuantityBox.Text = ""
end)

Kit5.MouseButton1Down:Connect(function()
	ItemBox.Text = "FAL"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "M14Ammo50"
	QuantityBox.Text = "8"
	spawnitem()
	wait(.1)
	ItemBox.Text = "BloodBag"
	QuantityBox.Text = "12"
	spawnitem()
	wait(.1)
	ItemBox.Text = "MilitaryPackBlack"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "ACOG"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = "Grip"
	QuantityBox.Text = "1"
	spawnitem()
	wait(.1)
	ItemBox.Text = ""
	QuantityBox.Text = ""
end)

Kit4.MouseButton1Down:Connect(function()
	ItemBox.Text = "ReinforcedWheel"
	QuantityBox.Text = "10"
	spawnitem()
	wait(.1)
	ItemBox.Text = "JerryCan"
	QuantityBox.Text = "4"
	spawnitem()
	wait(.1)
	ItemBox.Text = "FuelTank"
	QuantityBox.Text = "4"
	spawnitem()
	wait(.1)
	ItemBox.Text = "EngineParts"
	QuantityBox.Text = "4"
	spawnitem()
	wait(.1)
	ItemBox.Text = "Armor"
	QuantityBox.Text = "4"
	spawnitem()
	wait(.1)
	ItemBox.Text = "ScrapMetal"
	QuantityBox.Text = "4"
	spawnitem()
	wait(.1)
	ItemBox.Text = "BallisticGlass"
	QuantityBox.Text = "4"
	spawnitem()
	wait(.1)
	ItemBox.Text = ""
	QuantityBox.Text = ""
end)

Kit3.MouseButton1Down:Connect(function()
	ItemBox.Text = "BloodBag"
	QuantityBox.Text = "20"
	spawnitem()
	wait(.1)
	ItemBox.Text = "PainKillers"
	QuantityBox.Text = "10"
	spawnitem()
	wait(.1)
	ItemBox.Text = "MRE"
	QuantityBox.Text = "10"
	spawnitem()
	wait(.1)
	ItemBox.Text = "WaterBottle"
	QuantityBox.Text = "10"
	spawnitem()
	wait(.1)
	ItemBox.Text = ""
	QuantityBox.Text = ""
end)

SpawnItemButt.MouseButton1Down:Connect(function()
	spawnitem()
end)

UnvisButt.MouseButton1Down:Connect(function()
	if ServerPlayerbox.Text == nil then
		getrenv()["_G"].SendMessage("Select a player.","Yellow")
	else
		_G.fireserver("VehichleLightsSet",game.Players[ServerPlayerbox.Text].Character, "Plastic", 0)
	end
end)

SendButt.MouseButton1Down:Connect(function()
	if game.Players:FindFirstChild(Player1Box.Text) == nil then
		getrenv()["_G"].SendMessage("Uh-oh! U sure u did this correct?","Red")
	end
	if game.Players:FindFirstChild(Player2Box.Text) == nil then
		getrenv()["_G"].SendMessage("Uh-oh! U sure u did this correct?","Red")
		wait(1)
		getrenv()["_G"].SendMessage("Also if you found this DM ItsDarkNiight","Green")
	else
		local AddClothing = game.Workspace.Remote.AddClothing
		local teleporter = game:GetService("Players")[Player1Box.Text]
		local goto = game:GetService("Players")[Player2Box.Text]

		AddClothing:FireServer("driven", teleporter.Character, "","","")
		AddClothing:FireServer("IsBuildingMaterial", teleporter.Character.HumanoidRootPart, "poop","","")
		AddClothing:FireServer("SeatPoint", teleporter.Character.Torso, "","","")
		game:GetService("Workspace").Remote.HurtZombie:FireServer(teleporter.Character)
		wait(0.2)
		game:GetService("Workspace").Remote.ReplicatePart:FireServer(teleporter.Character.HumanoidRootPart, goto.Character.Head.CFrame)
		wait(1)
		_G.fireserver("ChangeParent", teleporter.Character.driven, nil)
		_G.fireserver("ChangeParent", teleporter.Character.HumanoidRootPart.IsBuildingMaterial, nil)
		_G.fireserver("ChangeParent", teleporter.Character.Torso.SeatPoint, nil)
		return
	end	
end)

-- start of gun update v1.7.8 --

Rate.MouseButton1Down:Connect(function()
	if game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action.Value ~= 1 then
		getrenv()["_G"].SendMessage("This weapon is not Automatic, you should change the firemode to 1, firerate was still set","Red")
	end
	for i, v in pairs (game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]:GetChildren()) do
		if v.Name == ("Shooter") then
			local prevpartent = game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]
			if game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action:FindFirstChild("Rate") then
				_G.fireserver("ChangeParent", v, game:GetService("Players")[PlrBox.Text].playerstats)
				_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action.Rate, nil)
				repeat wait() until game:GetService("Players")[PlrBox.Text].playerstats:FindFirstChild("Shooter")
				wait(0.3)
				game.Workspace.Remote.AddClothing:FireServer("Rate", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action, getrenv()["_G"].Obfuscate (PlrvalBox.Text), "skiddie fouuund", "SKID!!!!")
				wait(0.3)
				_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].playerstats.Shooter, prevpartent)
				wait(0.3)
			else 
				_G.fireserver("ChangeParent", v, game:GetService("Players")[PlrBox.Text].playerstats)
				repeat wait() until game:GetService("Players")[PlrBox.Text].playerstats:FindFirstChild("Shooter")
				wait(0.3)
				game:GetService("Workspace").Remote.AddClothing:FireServer("Rate", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action, getrenv()["_G"].Obfuscate (PlrvalBox.Text), "skiddie fouuund", "SKID!!!!")
				wait(0.3)
				_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].playerstats.Shooter, prevpartent)
				wait(0.3)
			end
		end
	end
	wait(1)
	if not game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Shooter then
		getrenv()["_G"].SendMessage("Some error happend, re-drop ur weapon and try again","Red")
	else
		getrenv()["_G"].SendMessage("Rate Successfully set!","Green")
	end    
end)

Accuracy.MouseButton1Down:Connect(function()
	for i, v in pairs (game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]:GetChildren()) do
		if v.Name == ("Shooter") then
			local prevpartent = game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]
			_G.fireserver("ChangeParent", v, game:GetService("Players")[PlrBox.Text].playerstats)
			_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Accuracy, nil)
			repeat wait() until game:GetService("Players")[PlrBox.Text].playerstats:FindFirstChild("Shooter")
			wait(0.3)
			game.Workspace.Remote.AddClothing:FireServer("Accuracy", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats, getrenv()["_G"].Obfuscate (PlrvalBox.Text), "Zoomed", getrenv()["_G"].Obfuscate (1))
			wait(0.3)
			_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].playerstats.Shooter, prevpartent)
			wait(0.3)
			getrenv()["_G"].SendMessage("The weapons accuracy was set succesfully!","Green")
			getrenv()["_G"].SendMessage("The lower accuracy value the more accurate","Green")
			wait(1)
			if not game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Shooter then
				getrenv()["_G"].SendMessage("Some error happend, re-drop ur weapon and try again","Red")
			end
		end
	end	
end)

Firemode.MouseButton1Down:Connect(function()
	for i, v in pairs (game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]:GetChildren()) do
		if v.Name == ("Shooter") then
			local prevpartent = game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]
			_G.fireserver("ChangeParent", v, game:GetService("Players")[PlrBox.Text].playerstats)
			repeat wait() until game:GetService("Players")[PlrBox.Text].playerstats:FindFirstChild("Shooter")
			_G.fireserver("ChangeValue", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action.Original, PlrvalBox.Text)
			wait(0.3)
			_G.fireserver("ChangeValue", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action, PlrvalBox.Text)
			wait(0.3)
			_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].playerstats.Shooter, prevpartent)
			wait(0.3)
			if game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Action.Value > 5 then
				getrenv()["_G"].SendMessage("Set a rate if the weapons original mode was semi","Yellow")
				getrenv()["_G"].SendMessage("Firemode value cannot be higer than 5","Red")
			else 
				getrenv()["_G"].SendMessage("The weapons firemode was set succesfully!","Green")
				wait(1)
				if not game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Shooter then
					getrenv()["_G"].SendMessage("Some error happend, re-drop ur weapon and try again","Red")
				end	
			end
		end
	end	
end)

Recoil.MouseButton1Down:Connect(function()
	for i, v in pairs (game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]:GetChildren()) do
		if v.Name == ("Shooter") then
			local prevpartent = game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]
			_G.fireserver("ChangeParent", v, game:GetService("Players")[PlrBox.Text].playerstats)
			_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats.Recoil, nil)
			wait(0.5)
			game.Workspace.Remote.AddClothing:FireServer("Recoil", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Stats, getrenv()["_G"].Obfuscate (PlrvalBox.Text), "skiddie fouuund", "SKID!!!!")
			wait(0.3)
			_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].playerstats.Shooter, prevpartent)
			wait(0.3)
			getrenv()["_G"].SendMessage("The weapons recoil was set succesfully!","Green")
			getrenv()["_G"].SendMessage("The lower recoil value the less recoil","Green")
			wait(1)
			if not game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text].Shooter then
				getrenv()["_G"].SendMessage("Some error happend, re-drop ur weapon and try again","Red")
			end
		end
	end	
end)

Ammo.MouseButton1Click:Connect(function()
	for i, v in pairs(game:GetService("Players")[PlrBox.Text].playerstats.slots:GetDescendants()) do
		if v.Name == "MaxClip" then
			_G.fireserver("ChangeValue", v, PlrvalBox.Text)
			for a, b in pairs(game:GetService("Players")[PlrBox.Text].playerstats.slots:GetDescendants()) do
				if b.Name == "Clip" then
					_G.fireserver("ChangeValue", b, getrenv()["_G"].Obfuscate (PlrvalBox.Text))
				end
			end
		end
	end
end)

Bug.MouseButton1Click:Connect(function()
	_G.fireserver("ChangeParent", game:GetService("Players")[PlrBox.Text].Backpack[PlrGunBox.Text]:FindFirstChild("Shooter"), nil)
	getrenv()["_G"].SendMessage("The player needs to re-drop their weapon for it to work again","Red")
end)

-- end of gun update v1.7.8 --

-- start of clothing update v1.7.9 --

shirt_var = false

pants_var = false

thing = false

function setclothing(shirtid, pantsid, var_player)
	if thing == false then
		thing = true
		if shirtid == nil or shirtid == "nothing" then
			shirt_var = false
		else
			shirt_var = true
		end

		if pantsid == nil or pantsid == "nothing" then
			pants_var = false
		else
			pants_var = true
		end

		clothing = game:GetService("Players"):FindFirstChild(var_player).playerstats

		if shirt_var == true then
			_G.fireserver("ChangeParent", clothing.character.shirt.ObjectID, nil)

			game.Workspace.Remote.AddClothing:FireServer("ObjectID", clothing, getrenv()["_G"].Obfuscate("5001"), "Shirt", shirtid)

			wait(0.5)

			_G.fireserver("ChangeParent", clothing.ObjectID, clothing.character.shirt)  
		end

		if pants_var == true then
			_G.fireserver("ChangeParent", clothing.character.pants.ObjectID, nil)

			game.Workspace.Remote.AddClothing:FireServer("ObjectID", clothing.character, getrenv()["_G"].Obfuscate("6001"), "Pants", pantsid)

			wait(0.5)

			_G.fireserver("ChangeParent", clothing.character.ObjectID, clothing.character.pants)
		end
		wait(1)
		thing = false
	end
end

ClothesChangeBtt.MouseButton1Down:connect(function()
	if ClothingPlayerBox.Text ~= nil then
		if PantsIdBox.Text ~= nil or ShirtIdBox.Text ~= nil then
			setclothing(ShirtIdBox.Text, PantsIdBox.Text, ClothingPlayerBox.Text)
		else
			return
		end
	else
		return
	end
end)

SSfit.MouseButton1Down:connect(function()
	if ClothingPlayerBox.Text ~= nil then
		if PantsIdBox.Text ~= nil or ShirtIdBox.Text ~= nil then
			setclothing("337129807", "337130336", ClothingPlayerBox.Text)
		else
			return
		end
	else
		return
	end
end)

Adminfit.MouseButton1Down:connect(function()
	if ClothingPlayerBox.Text ~= nil then
		if PantsIdBox.Text ~= nil or ShirtIdBox.Text ~= nil then
			setclothing("337128174", "337128215", ClothingPlayerBox.Text)
		else
			return
		end
	else
		return
	end
end)

OneShot.MouseButton1Click:Connect(function()
	if OneShot.TextColor3 == Color3.fromRGB(255, 0, 0)then
		getrenv()["_G"].SendMessage("One Shot already enabled! Feel free to change the timer","Green")
	else
		OneShot.TextColor3 = Color3.fromRGB(255, 0, 0)
		getrenv()["_G"].SendMessage("Press F + Left Click on a player to make em one shot!","Green")
		Mouse = game:GetService("Players").LocalPlayer:GetMouse()
		Mouse.Button1Down:connect(function()
			if not game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.F) then
				return
			end
			if not Mouse.Target then
				return
			end
			if Mouse.Target.Name == "Part" or Mouse.Target.Name == "Handle" or Mouse.Target.Name == "Head" and Mouse.Target.Parent.Parent:FindFirstChild("Humanoid") then
				_G.modelprevparent = Mouse.Target.Parent.Parent:FindFirstChild("Humanoid")
			elseif Mouse.Target.Name == "Handle" and Mouse.Target.Parent.Parent:FindFirstChild("Humanoid") then
				_G.modelprevparent = Mouse.Target.Parent.Parent:FindFirstChild("Humanoid")
				getrenv()["_G"].SendMessage(Mouse.Target.Parent.Parent.Name.."Has been turned into one shot (don't worry he doesnt know LOL!)","Green")
				game.Workspace.Remote.AddClothing:FireServer("DefenseMultiplier", _G.modelprevparent, 100000000, "lul", "my name is dark and im so cool")
				wait(1)
				getrenv()["_G"].SendMessage("One Shot timer has been set to " .. OneShotTimer.Text .. " seconds","Yellow")
				wait(OneShotTimer.Text)
				getrenv()["_G"].SendMessage("Player is no longer One Shot","Red")
				_G.fireserver("ChangeParent", _G.modelprevparent:FindFirstChild("DefenseMultiplier"), nil)
			elseif Mouse.Target.Parent:FindFirstChild("Humanoid") then
				_G.prevparent = Mouse.Target.Parent:FindFirstChild("Humanoid")
				getrenv()["_G"].SendMessage(Mouse.Target.Parent.Name.."Has been turned into one shot (don't worry he doesnt know LOL!)","Green")
				game.Workspace.Remote.AddClothing:FireServer("DefenseMultiplier", _G.prevparent, 100000000, "lul", "my name is dark and im so cool")
				wait(1)
				getrenv()["_G"].SendMessage("One Shot timer has been set to " .. OneShotTimer.Text .. " seconds","Yellow")
				wait(OneShotTimer.Text)
				getrenv()["_G"].SendMessage("Player is no longer One Shot!","Red")
				_G.fireserver("ChangeParent", _G.prevparent:FindFirstChild("DefenseMultiplier"), nil)
			end
		end)
	end
end)


Spectate.MouseButton1Down:Connect(function()
	game.Workspace.CurrentCamera.CameraSubject = game.Players[ServerPlayerbox.Text].Character	
end)

UnSpectate.MouseButton1Down:Connect(function()
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character
end)

FlyToggle2.MouseButton1Down:Connect(function()
	eplr.PlayerGui.HitEqualsYouDie.WalkspeedEdit.Disabled = true
	eplr.PlayerGui.HitEqualsYouDie.JumpLimiter.Disabled = true 
	eplr.PlayerGui.SkyboxRenderMode.Disabled = true
	flying = true
	lplayer = game:GetService("Players").LocalPlayer
	local T = lplayer.Character.HumanoidRootPart
	local CONTROL = {F = 0, B = 0, L = 0, R = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
	local speedget = flyspeed.Text
	local SPEED = speedget
	local BG = Instance.new('BodyGyro', T)
	local BV = Instance.new('BodyVelocity', T)
	lplayer = game:GetService("Players").LocalPlayer

	local Mouse = lplayer:GetMouse()
	BG.P = 9e4
	BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	BG.cframe = T.CFrame
	BV.velocity = Vector3.new(0, 0.1, 0)
	BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
	speedfly = 1
	spawn(function()
		repeat wait()
			lplayer.Character.Humanoid.PlatformStand = true
			if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
				SPEED = 50
			elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0) and SPEED ~= 0 then
				SPEED = 0
			end
			if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
				BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
			elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
				BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
			else
				BV.velocity = Vector3.new(0, 0.1, 0)
			end
			BG.cframe = workspace.CurrentCamera.CoordinateFrame
		until not flying
		CONTROL = {F = 0, B = 0, L = 0, R = 0}
		lCONTROL = {F = 0, B = 0, L = 0, R = 0}
		SPEED = 0
		BG:destroy()
		BV:destroy()
		lplayer.Character.Humanoid.PlatformStand = false
	end)
	Mouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = speedfly
		elseif KEY:lower() == 's' then
			CONTROL.B = -speedfly
		elseif KEY:lower() == 'a' then
			CONTROL.L = -speedfly
		elseif KEY:lower() == 'd' then
			CONTROL.R = speedfly
		end
	end)
	Mouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		end
	end)
end)

FlyToggle.MouseButton1Down:Connect(function()
	FlyToggle.Visible = false
	FlyToggle2.Visible = true

	flying = false
	lplayer.Character.Humanoid.PlatformStand = false

end)

CleanC4.MouseButton1Down:connect(function()
	for random,workspac in pairs(game.Workspace:GetChildren()) do
		if workspac.Name == "C4Placed" or "TM46Placed" or "VS50Placed" then
			_G.fireserver("ChangeParent", game.Workspace.C4Placed, nil)
		elseif workspac.Name == "TM46Placed" then
			_G.fireserver("ChangeParent", game.Workspace.TM46Placed, nil)
		elseif workspac.Name == "VS50Placed" then
			_G.fireserver("ChangeParent", game.Workspace.VS50Placed, nil)
		end
	end
end)

HungerButt.MouseButton1Click:Connect(function()
    if TrollPlayerBox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        fireserver("ChangeValue", game.Players.v.playerstats.Hunger, TrollValBox.Text)
        end
    else
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.Hunger, TrollValBox.Text)
    end
end)

ThirstButt.MouseButton1Click:Connect(function()
    if TrollPlayerBox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        fireserver("ChangeValue", game.Players.v.playerstats.Thirst, TrollValBox.Text)
        end
    else
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.Thirst, TrollValBox.Text)
    end
end)

RButt.MouseButton1Click:Connect(function()
	for i, v in pairs(game.Workspace:GetChildren()) do
		for x, y in pairs(game.Lighting.LootDrops:GetChildren()) do
			if v.Name == y.Name then
				fireserver("ChangeParent", v, nil)
			end
		end
	end

	for a, b in pairs(game.Workspace.Vehicles:GetChildren()) do
		if b.Stats.MaxSpeed.Value >= 101 then
			fireserver("ChangeParent", b, nil)
		end
	end
end)

DaysButt.MouseButton1Click:Connect(function()
    if TrollPlayerBox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        fireserver("ChangeValue", game.Players.v.playerstats.Days, TrollValBox.Text)
        end
    else
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.Days, TrollValBox.Text)
    end
end)
KillsButt.MouseButton1Click:Connect(function()
    if TrollPlayerBox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        fireserver("ChangeValue", game.Players.v.playerstats.PlayerKill, TrollValBox.Text)
        fireserver("ChangeValue", game.Players.v.playerstats.PlayerKill.Bandit, 0)
        fireserver("ChangeValue", game.Players.v.playerstats.PlayerKill.Defensive, 0)
        fireserver("ChangeValue", game.Players.v.playerstats.PlayerKill.Aggressive, TrollValBox.Text)
        end
    else
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.PlayerKill, TrollValBox.Text)
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.PlayerKill.Bandit, 0)
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.PlayerKill.Defensive, 0)
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.PlayerKill.Aggressive, TrollValBox.Text)
    end
end)
zKillsButt.MouseButton1Click:Connect(function()
    if TrollPlayerBox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        fireserver("ChangeValue", game.Players.v.playerstats.ZombieKill, TrollValBox.Text)
        fireserver("ChangeValue", game.Players.v.playerstats.ZombieKill.Military, TrollValBox.Text)
        fireserver("ChangeValue", game.Players.v.playerstats.ZombieKill.Civilian, 0)
        end
    else
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.ZombieKill, TrollValBox.Text)
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.ZombieKill.Military, TrollValBox.Text)
        fireserver("ChangeValue", game.Players[TrollPlayerBox.Text].playerstats.ZombieKill.Civilian, 0)
    end
end)

SpecAllButt.MouseButton1Click:Connect(function()
	getrenv()["_G"].SendMessage("Disabled due to abuse.","Red")
	-- if you want this feature so badly just look at the updates tab of github and use the old version
end)

SkinsButt.MouseButton1Click:Connect(function()
	getrenv()["_G"].SendMessage("Everyone recived random skins.","Green")
	local Numbers = {1, 2, 3, 5, 7, 6, 8, 9}

	function generateRandom()
		return Numbers[math.random(1, #Numbers)]
	end

	for i,v in pairs(game:GetService("Players"):GetChildren()) do

		for i,v2 in pairs(v.playerstats.skins:GetDescendants()) do
			if v2:IsA("IntValue") then
				fireserver("ChangeValue", v2, generateRandom())
			end
		end
	end	
end)

WeirdButt.MouseButton1Click:Connect(function()
	if TrollPlayerBox.Text == "all" then
        for i,v in pairs(game.Players:GetChildren()) do
        _G.fireserver("VehichleLightsSet",game.Players.v.Character, "ForceField", 0)
        end
    else
        _G.fireserver("VehichleLightsSet",game.Players[TrollPlayerBox.Text].Character, "ForceField", 0)
    end
end)

------ auto fill xdxdxdxd ------
function autofill(table,text)
	for i,v in pairs(table)do
		if string.sub(v.Name,1,#text):lower()==text:lower() then
			return v.Name
		end
	end
end


Player1Box.FocusLost:Connect(function()
	local playername1 = autofill(game.Players:GetChildren(),Player1Box.Text)
	if not playername1 then
		return
	end
	Player1Box.Text = playername1
end)

Player2Box.FocusLost:Connect(function()
	local playername2 = autofill(game.Players:GetChildren(),Player2Box.Text)
	if not playername2 then
		return
	end
	Player2Box.Text = playername2
end)
PlayerSpawnBox.FocusLost:Connect(function()
	local playername3 = autofill(game.Players:GetChildren(),PlayerSpawnBox.Text)
	if not playername3 then
		return
	end
	PlayerSpawnBox.Text = playername3
end)
ClothingPlayerBox.FocusLost:Connect(function()
	local playername21 = autofill(game.Players:GetChildren(),ClothingPlayerBox.Text)
	if not playername21 then
		return
	end
	ClothingPlayerBox.Text = playername21
end)

ServerPlayerbox.FocusLost:Connect(function()
	local playername10 = autofill(game.Players:GetChildren(),ServerPlayerbox.Text)
	if not playername10 then
		return
	end
	ServerPlayerbox.Text = playername10
end)
PlrBox.FocusLost:Connect(function()
	local playername1 = autofill(game.Players:GetChildren(),PlrBox.Text)
	if not playername1 then
		return
	end
	PlrBox.Text = playername1
end)

PlrGunBox.FocusLost:Connect(function()
	local gunboxlol = autofill(game.Players[PlrBox.Text].Backpack:GetChildren(),PlrGunBox.Text)
	if not gunboxlol then
		return
	end
	PlrGunBox.Text = gunboxlol
end)

TrollPlayerBox.FocusLost:Connect(function()
	local playername11 = autofill(game.Players:GetChildren(),TrollPlayerBox.Text)
	if not playername11 then
		return
	end
	TrollPlayerBox.Text = playername11
end)

------ auto fill xdxdxdxd ------
