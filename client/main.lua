QBCore = nil

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(10)
	end
end)

local closestDoorKey, closestDoorValue = nil, nil

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		for key, doorID in ipairs(QB.Doors) do
			if doorID.doors then
				for k,v in ipairs(doorID.doors) do
					if not v.object or not DoesEntityExist(v.object) then
						v.object = GetClosestObjectOfType(v.objCoords, 1.0, GetHashKey(v.objName), false, false, false)
					end
				end
			else
				if not doorID.object or not DoesEntityExist(doorID.object) then
					doorID.object = GetClosestObjectOfType(doorID.objCoords, 1.0, GetHashKey(doorID.objName), false, false, false)
				end
			end
		end

		Citizen.Wait(2500)
	end
end)

local maxDistance = 1.25
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local playerCoords, awayFromDoors = GetEntityCoords(PlayerPedId()), true

		---for k,doorID in ipairs(QB.Doors) do
		for i = 1, #QB.Doors do
			local current = QB.Doors[i]
			local distance

			---if doorID.doors then
			---	distance = #(playerCoords - doorID.doors[1].objCoords)
			if current.doors then
				distance = #(playerCoords - current.doors[1].objCoords)
			else
				---distance = #(playerCoords - doorID.objCoords)
				distance = #(playerCoords - current.objCoords)
			end

			--if doorID.distance then
			--	maxDistance = doorID.distance
			if current.distance then
				maxDistance = current.distance
			end
			---if distance < 5 then
			if distance < 10 then
				awayFromDoors = false
				---if doorID.doors then
					---for _,v in ipairs(doorID.doors) do
						---FreezeEntityPosition(v.object, doorID.locked)
						if current.doors then
							for a = 1, #current.doors do
								local currentDoor = current.doors[a]
								FreezeEntityPosition(currentDoor.object, current.locked)

					---	if doorID.locked and v.objYaw and GetEntityRotation(v.object).z ~= v.objYaw then
							---SetEntityRotation(v.object, 0.0, 0.0, v.objYaw, 2, true)
							if current.locked and currentDoor.objYaw and GetEntityRotation(currentDoor.object).z ~= currentDoor.objYaw then
								SetEntityRotation(currentDoor.object, 0.0, 0.0, currentDoor.objYaw, 2, true)
						end
					end
				else
					----FreezeEntityPosition(doorID.object, doorID.locked)
					FreezeEntityPosition(current.object, current.locked)

					---if doorID.locked and doorID.objYaw and GetEntityRotation(doorID.object).z ~= doorID.objYaw then
						----SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
						if current.locked and current.objYaw and GetEntityRotation(current.object).z ~= current.objYaw then
							SetEntityRotation(current.object, 0.0, 0.0, current.objYaw, 2, true)
					end
				end
			end

			if distance < maxDistance then
				awayFromDoors = false
				---if doorID.size then
					---size = doorID.size
					if current.size then
						size = current.size
				end

				---local isAuthorized = IsAuthorized(doorID)
				local isAuthorized = IsAuthorized(current)

				if isAuthorized then
					---if doorID.locked then
					if current.locked then
						displayText = "[~g~E~w~] - Locked"
					---elseif not doorID.locked then
					elseif not current.locked then
						displayText = "[~g~E~w~] - Unlocked"
					end
				elseif not isAuthorized then
					---if doorID.locked then
					if current.locked then
						displayText = "~r~Locked"
					---elseif not doorID.locked then
					elseif not current.locked then
						displayText = "~g~Unlocked"
					end
				end

				--if doorID.locking then
					--if doorID.locked then
					if current.locking then
						if current.locked then
						displayText = "~g~Unlocking.."
					else
						displayText = "~r~Locking.."
					end
				end

				---if doorID.objCoords == nil then
					---doorID.objCoords = doorID.textCoords
					if current.objCoords == nil then
						current.objCoords = current.textCoords
				end

				---DrawText3Ds(doorID.objCoords.x, doorID.objCoords.y, doorID.objCoords.z, displayText)
				DrawText3Ds(current.objCoords.x, current.objCoords.y, current.objCoords.z, displayText)

				if IsControlJustReleased(0, 38) then
					if isAuthorized then
						---setDoorLocking(doorID, k)
						setDoorLocking(current, i)
					end
				end
			end
		end

		if awayFromDoors then
			Citizen.Wait(1000)
		end
	end
end)

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function()
	local ped = GetPlayerPed(-1)
	local pos = GetEntityCoords(ped)
	QBCore.Functions.TriggerCallback('qb-radio:server:GetItem', function(hasItem)
		for k, v in pairs(QB.Doors) do
			local dist = GetDistanceBetweenCoords(pos, QB.Doors[k].textCoords.x, QB.Doors[k].textCoords.y, QB.Doors[k].textCoords.z)
			if dist < 1.5 then
				if QB.Doors[k].pickable then
					if QB.Doors[k].locked then
						if true then
							closestDoorKey, closestDoorValue = k, v
							TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
						else
							QBCore.Functions.Notify("You are missing a lockpick..", "error")
						end
					else
						QBCore.Functions.Notify('The door is already unlocked??', 'error', 2500)
					end
				else
					QBCore.Functions.Notify('The door has a strong lock', 'error', 2500)
				end
			end
		end
    end, "lockpick")
end)

function lockpickFinish(success)
    if success then
		QBCore.Functions.Notify('Success!', 'success', 2500)
		setDoorLocking(closestDoorValue, closestDoorKey)
    else
        QBCore.Functions.Notify('It didn\'t work..', 'error', 2500)
    end
end

function setDoorLocking(doorId, key)
	doorId.locking = true
	openDoorAnim()
    SetTimeout(400, function()
		doorId.locking = false
		doorId.locked = not doorId.locked
		TriggerServerEvent('qb-doorlock:server:updateState', key, doorId.locked)
	end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(6)
    end
end

function IsAuthorized(doorID)
	local PlayerData = QBCore.Functions.GetPlayerData()

	for _,job in pairs(doorID.authorizedJobs) do
		if job == PlayerData.job.name then
			return true
		end
	end

	for _,gang in pairs(doorID.authorizedJobs) do
		if gang == PlayerData.gang.name then
			return true
		end
	end
	
	return false
end

function openDoorAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
	SetTimeout(400, function()
		ClearPedTasks(GetPlayerPed(-1))
	end)
end

RegisterNetEvent('qb-doorlock:client:setState')
AddEventHandler('qb-doorlock:client:setState', function(doorID, state)
	QB.Doors[doorID].locked = state
end)

RegisterNetEvent('qb-doorlock:client:setDoors')
AddEventHandler('qb-doorlock:client:setDoors', function(doorList)
	QB.Doors = doorList
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("qb-doorlock:server:setupDoors")
end)