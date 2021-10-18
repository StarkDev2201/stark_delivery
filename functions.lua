function ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('starkDeliver', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('starkDeliver', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('starkDeliver')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end


function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end


function IsCurrentSessionValid()
	return (NetworkIsSessionStarted() and NetworkIsSessionActive())
end

function GetNetIdFromEntity(entity)
	if IsCurrentSessionValid() and DoesEntityExist(entity) and NetworkGetEntityIsNetworked(entity) then
		return NetworkGetNetworkIdFromEntity(entity)
	end
	
	return 0
end

function GetVehicleFromNetId(netId)
    if IsCurrentSessionValid() and NetworkDoesNetworkIdExist(netId) then
	    return NetToVeh(netId)
	end
	
	return 0
end

function GetObjectFromNetId(netId)
    if IsCurrentSessionValid() and NetworkDoesNetworkIdExist(netId) then
	    return NetToObj(netId)
	end
	
	return 0
end

function ShowLoadingPrompt(msg, type)
    BeginTextCommandBusyspinnerOn("STRING")
    AddTextComponentString(msg)
    EndTextCommandBusyspinnerOn(type)
end

function HideLoadingPrompt(removeSpinFromMemory)
    BusyspinnerOff()
	
	if removeSpinFromMemory then
		Citizen.InvokeNative(0xC65AB383CD91DF98)
	end
end

function clearAreaOfVehicles(radius)
	local closeby = vRPg.getVehicleAtRaycast(radius)
	if IsEntityAVehicle(closeby) then
	  SetVehicleHasBeenOwnedByPlayer(closeby,false)
	  Citizen.InvokeNative(0xAD738C3085FE7E11, closeby, false, true)
	  SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(closeby))
	  Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(closeby))
	  return clearAreaOfVehicles(radius)
	end
	return true
end

SpawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		local timeout = 0

		SetNetworkIdCanMigrate(networkId, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb then
			cb(vehicle)
		end
	end)
end

--[[function RequestModel(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end--]]


function DeleteVeh(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end
