local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

--visit my discord: https://discord.gg/wsyryrC  CREATE BY Stark#5844 DO NOT REMOVE CREDITS
--visit my discord: https://discord.gg/wsyryrC  CREATE BY Stark#5844 DO NOT REMOVE CREDITS
--visit my discord: https://discord.gg/wsyryrC  CREATE BY Stark#5844 DO NOT REMOVE CREDITS

local isCarryingAnyBox_food = false

local trabalhando_food = false

local VehicleTrampo_food 

local obj 

local EntegasTotais = 0

local RetornarBase = false

local NpcData = nil

local PosAtual = 0

local PegouSacola_2 = false




-- CREATE BLIPS
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones_food.Blip.Pos)
  
	SetBlipSprite (blip, Config.Zones_food.Blip.Sprite) --67
	SetBlipDisplay(blip,  Config.Zones_food.Blip.Display)
	SetBlipScale  (blip,  Config.Zones_food.Blip.Scale)
	SetBlipColour (blip,  Config.Zones_food.Blip.Color)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Config.Zones_food.Blip.Label)
	EndTextCommandSetBlipName(blip)
end)





Citizen.CreateThread(function() 

	while true do
		local time = 1000

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones_food) do

			if k == 'PegarJob_food' then
				if #(coords - v.Pos) < 40.0 then
					time = 5
					DrawMarker(37, v.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.5, 255, 102, 0, 100, true, true, 2, false, false, false, false)
				end

				if #(coords - v.Pos) < 1.1  then
					if trabalhando_food then
						ShowHelpNotification(Config.Locales['IsWorking'])
					else
						ShowHelpNotification(Config.Locales['StartJob'])
						if IsControlJustReleased(0, 51) then
							trabalhando_food = true
							IniciarJob_food()
						end
					end
				end			
			end

			if k == 'EndJob_food' then
				if RetornarBase then
					if #(coords - v.Pos) < 40.0 then
						time = 5
						DrawMarker(20, v.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.5, 255, 0, 0, 100, false, true, 2, false, false, false, false)
					end

					if #(coords - v.Pos) < 1.2 then
						ShowHelpNotification(Config.Locales['PressEndJob'])
						if IsControlJustReleased(0, 51) then
							EndJob_food()
						end
					end		

				end
			end		
					
		end	

		Citizen.Wait(time)
	end	

end)

function IniciarJob_food()


	local spawnPoint = nil
	local spawnPointHeading = nil

	local vehHash = GetHashKey(Config.VehicleName)

	ShowLoadingPrompt(Config.Locales['LoadingVehicle'], 3)


	RequestModel(vehHash)
	while not HasModelLoaded(vehHash) do
		Citizen.Wait(50)
	end

	ShowLoadingPrompt(Config.Locales['SearchLocation'], 3)--]]

	local timer = 0
	local isTrailerSpawnAvailable = false
	while true do
		Wait(1000)
		for k,v in ipairs(Config.VehicleSpawnLocation) do
			local checkPos = GetClosestVehicle(v.Pos,3.001,0,71)
			if not DoesEntityExist(checkPos) and checkPos == 0 then
				spawnPoint = v.Pos
				spawnPointHeading = v.Heading
				isTrailerSpawnAvailable = true
				break
			end
		end

		if isTrailerSpawnAvailable then
			break
		end

		timer = timer + 1

		if timer >= 15 and not isTrailerSpawnAvailable then
			ShowNotification(Config.Locales['NotFoundLocation'])	
			break	
		end	
	end	--]]
		
	HideLoadingPrompt()

	if isTrailerSpawnAvailable then
		SpawnVehicle(vehHash, spawnPoint, spawnPointHeading, function(vehicle) 
			while DoesEntityExist(vehicle) and not NetworkGetEntityIsNetworked(vehicle) do
				NetworkRegisterEntityAsNetworked(vehicle)
					
				Citizen.Wait(100)
			end
			local netId = GetNetIdFromEntity(vehicle)

			local vehSpawned = GetVehicleFromNetId(netId)
			VehicleTrampo_food = vehSpawned
			trabalhando_food = true
			isTrailerSpawnAvailable = false
			ShowNotification(Config.Locales['EnterVehicle'])
			Citizen.Wait(3000)
			IniciarEntregas_food(VehicleTrampo_food)
		end)
	end	--]]
end	

function IniciarEntregas_food(vehicle_food)

	Citizen.CreateThread(function()
		local lock, lock2, lock3 = GetTrampo_food()
		local SpawnNpcVariavel = false
		if trabalhando_food then
			MissionText(Config.Locales['DeliverFound'], 3000, true)
			local IniciouEntrega_food = true
			while IniciouEntrega_food do
				local time = 1000

				local coords = GetEntityCoords(PlayerPedId())

				local coordsVeh = GetEntityCoords(vehicle_food)

				local distance = #(coords - lock)
				local distanceVeh = #(coords - coordsVeh)

				if distance < 50.0 and IsPedInAnyVehicle(PlayerPedId(), true) then
					time = 5
					DrawMarker(20, lock, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 102, 0, 100, false, true, 2, false, false, false, false)
				end


				if distance < 50.0 and not SpawnNpcVariavel then
					SpawnNpcVariavel = true
					SpawnNpc(lock2, lock3, vehicle_food)
				end

				if distanceVeh < 5.0 and not IsPedInAnyVehicle(PlayerPedId(), false) then
					time = 10
					DrawMarker(20, coordsVeh, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 102, 0, 100, false, true, 2, false, false, false, false)
				end	
					
				local vehicleEsta = GetVehiclePedIsUsing(PlayerPedId())

				if vehicleEsta == vehicle_food then
					if IsPedInAnyVehicle(PlayerPedId(), true) then
						if distance < 2.0 then
							MissionText(Config.Locales['ExitVehicle'])
						end
					end
				end
							
				if not IsPedInAnyVehicle(PlayerPedId(), false) and distance < 1.5 then
					IniciouEntrega_food = false
					PegarSacola_food(vehicle_food, lock2)
				end	

				Citizen.Wait(time)
			end
		end		
	end)	

end

function PegarSacola_food(vehicle_food, lock2)

	Citizen.CreateThread(function() 
		local PegouSacola = false
		while not PegouSacola do
			local time = 500

			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)

			local truckCoord = GetOffsetFromEntityInWorldCoords(vehicle_food, 0.0, 0.0, 0.0)
			local distance = #(coords - truckCoord)

			if distance < 2.0 and not PegouSacola and not IsPedInAnyVehicle(PlayerPedId(), false) and not PegouSacola_2 then
				time = 0
				ShowHelpNotification(Config.Locales['GetDeliver'])
				if IsControlJustReleased(0, 51) then
					PegouSacola = true
					PegouSacola_2 = true
					MissionText(Config.Locales['MissionText'], 2500, true)
					Sacola()
					RemoveBlipp(blip)
				end

			end		
			Citizen.Wait(time)
		end		

	end)
end	



function Sacola()

	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	local objHash = `hei_prop_hei_paper_bag`

	RequestModel(objHash)
	while not HasModelLoaded(objHash) do
		Citizen.Wait(100)
	end
			
			
	obj = CreateObject(objHash, coords - vec3(0.0, 0.0, 0.5), true, false, false)
	SetEntityAsMissionEntity(objHash, true, true)

	while DoesEntityExist(obj) and not NetworkGetEntityIsNetworked(obj) do
		NetworkRegisterEntityAsNetworked(obj)	
		Citizen.Wait(100)
	end


	local netId = GetNetIdFromEntity(obj)
	local obj2 = GetObjectFromNetId(netId)
	local offsetPos = vec3(0.2, 0.0, 0.0)
	local offsetRot = vec3(0.0, -85.0, 0.0)
						

	AttachEntityToEntity(obj, playerPed, GetPedBoneIndex(playerPed, 28422), offsetPos, offsetRot, true, true, false, false, 2, true)
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)

	isCarryingAnyBox_food = true
	BeginCarryAnimThreading_food()

end

function SpawnNpc(lock2,lock3, vehicle)
	SpawnNpcReal(lock3)
	Citizen.CreateThread(function()
		local ChegarNoNpc = false
		while not ChegarNoNpc do
			local time = 1000
			local coords = GetEntityCoords(PlayerPedId())

			--local distance = Vdist(coords, lock2)
			local distance = #(coords - lock2)
			if not IsPedInAnyVehicle(PlayerPedId(), false) and distance < 10.0 then
				time = 0
				DrawMarker(20, lock2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 102, 0, 100, false, true, 2, false, false, false, false)
			end

			if distance < 1.0 then
				if PegouSacola_2 then
					ShowHelpNotification(Config.Locales['DeliverClient'])
					if IsControlJustReleased(0, 51) then
						EntegasTotais = EntegasTotais + 1
						ChegarNoNpc = true
						isCarryingAnyBox_food = false
						PegouSacola_2 = false
						SacolaNpc(obj)
						TriggerServerEvent('stark_delilery:darmoney')
						ShowNotification(Config.Locales['Payment']..Config.Pagamento)
						if EntegasTotais ~= Config.MaxEntregas then
							ShowLoadingPrompt(Config.Locales['NextLocation'],4)
							Citizen.Wait(2500)
							IniciarEntregas_food(vehicle)
							HideLoadingPrompt()
						else
							EntegasTotais = 0
							ShowNotification(Config.Locales['ReturnCompany'])
							RetornarBase = true
							RetunBase()
						end	
					end
				else
					ShowNotification(Config.Locales['ReturnVehicle'])
				end		
			end	
			Citizen.Wait(time)
		end	
	end)
end	

function SacolaNpc(obj)
	local offsetPos = vec3(0.2, 0.0, 0.0)
	local offsetRot = vec3(0.0, -85.0, 0.0)
	AttachEntityToEntity(obj, NpcData, GetPedBoneIndex(NpcData, 28422), offsetPos, offsetRot, true, true, false, false, 2, true)
	SetCurrentPedWeapon(NpcData, GetHashKey('WEAPON_UNARMED'), true)
	FreezeEntityPosition(NpcData, false)
    SetEntityInvincible(NpcData, false)
    SetBlockingOfNonTemporaryEvents(NpcData, false)
    SetPedAsNoLongerNeeded(NpcData)
    NpcData = nil
end	

function SpawnNpcReal(lock3)

	local NpcModel, NpcHash = GetNpcModel()

	RequestModel(GetHashKey(NpcModel))
    while not HasModelLoaded(GetHashKey(NpcModel)) do
        Wait(1)
    end

	NpcData = CreatePed(4, NpcHash,lock3.x, lock3.y, lock3.z ,lock3.h, false, true)
    SetEntityHeading(NpcData, lock3.h)
    FreezeEntityPosition(NpcData, true)
    SetEntityInvincible(NpcData, true)
end	


function EndJob_food()

	local vehicleEsta = GetVehiclePedIsUsing(PlayerPedId())
	if vehicleEsta == VehicleTrampo_food then
		DeleteVeh(vehicleEsta)
		RetornarBase = false
		VehicleTrampo_food = nil
		trabalhando_food = false
		ShowNotification(Config.Locales['EndJob'])
		RemoveBlipp(blip)
	else
		ShowNotification(Config.Locales['NotVehicle'])
		RemoveBlipp(blip)
	end	

end	


function Marcacao_food(pos)

	if blip == nil then
   	 	RemoveBlip(blip)
   	end	
                        

    blip = AddBlipForCoord(pos)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 33)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Entrega do ~y~Ifood")
    EndTextCommandSetBlipName(blip)
          
    SetBlipRoute(blip, true)

end
function RemoveBlipp(blipp)

    RemoveBlip(blipp)

end

function RetunBase()

	blip = AddBlipForCoord(-1173.3483886719,-900.36102294922,13.74622631073)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 33)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Retornar a base ~r~Ifood")
    EndTextCommandSetBlipName(blip)
          
    SetBlipRoute(blip, true)
end	

---GETS--

function GetNpcModel()

	local model = nil
	local hash = nil

	local entregaRandom = math.random(1, #Config.NpcModels)
	for i,v in pairs(Config.NpcModels) do

		
		if i == entregaRandom then
			model = v.NpcModel
			hash = v.NpcHash
			return model, hash
		end
		
	end

	if model == nil then
		print('erro, pegando nova lock 01')
		return GetNpcModel()
	end
end	

function GetTrampo_food()

	ShowLoadingPrompt('Pegando a localização...', 4)
	local pos = nil 
	local posEntrega = nil
	local posNpc = nil
	
	local entregaRandom = math.random(1, #Config.FoodLocationn)

	for i,v in pairs(Config.FoodLocationn) do

		
		if i == entregaRandom then

			if PosAtual ~= i then
				pos = v.Pos
				posEntrega = v.Pos2
				posNpc = v.Pos3
				PosAtual = i
				HideLoadingPrompt()
			end	
		end	
		
	end



	if pos == nil then
		print('erro, pegando nova lock 01')
		return GetTrampo_food()
	end
	
	if pos ~= nil then
		HideLoadingPrompt()
		Marcacao_food(pos)
		return pos, posEntrega, posNpc
	else
		print('erro, pegando nova lock 02')
		return GetTrampo_food()
	end	

end	



function MissionText(text, time, drawNow)
	BeginTextCommandPrint("STRING")
    AddTextComponentString(text)
    EndTextCommandPrint(time, drawNow)
end    

function BeginCarryAnimThreading_food()
	CreateThread(function()
		while isCarryingAnyBox_food do
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1

			DisableControlAction(0, Keys['R'], true) -- Reload
			DisableControlAction(0, Keys['SPACE'], true) -- Jump
			DisableControlAction(0, Keys['Q'], true) -- Cover
			DisableControlAction(0, Keys['TAB'], true) -- Select Weapon
			DisableControlAction(0, Keys['F'], true) -- Also 'enter'?

			DisableControlAction(2, Keys['LEFTCTRL'], true) -- Disable going stealth

			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			DisableControlAction(0, Keys['F1'], true) -- Disable phone
			DisableControlAction(0, Keys['F2'], true) -- Inventory
			DisableControlAction(0, Keys['F3'], true) -- Animations
			DisableControlAction(0, Keys['F6'], true) -- Job

			DisableControlAction(0, Keys['V'], true) -- Disable changing view
			DisableControlAction(0, Keys['C'], true) -- Disable looking behind
			DisableControlAction(2, Keys['P'], true) -- Disable pause screen
			DisableControlAction(0, Keys['X'], true) -- Disable pause screen

			Citizen.Wait(0)
		end
	end)
end
