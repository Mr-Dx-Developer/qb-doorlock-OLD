QBCore = nil

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
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
local drowtargetdoors = {}
local isAuth = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for i,j in ipairs(drowtargetdoors) do
		local displayText = j.status
		
		
		if j.isAuth then
			displayText = "~g~E~w~ - " .. displayText
		end
		DrawText3Ds(j.x, j.y, j.z, displayText)

		
		if IsControlJustReleased(0, 38) then
			if j.isAuth then
				setDoorLocking(j.doorID, j.id)
					j.status = "Locking.."
					
				if j.doorID.locked then
				j.status = "Unlocking.."
				end
			end
		end
	
		end
		
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local playerCoords = GetEntityCoords(GetPlayerPed(-1))
		local distance, objCoords
		local withinreach
		
		drowtargetdoors = {}
			for k,doorID in ipairs(QB.Doors) do


					if doorID.size then
						size = doorID.size
					end

				if doorID.doors then
					distance = #(playerCoords - doorID.doors[1].objCoords)
					objCoords = doorID.textCoords
				else
					distance = #(playerCoords - doorID.objCoords)
					objCoords = doorID.objCoords
				end

				if doorID.distance then
					withinreach = doorID.distance
					else
						withinreach = maxDistance
				end

				if distance < 50 then

					if doorID.doors then
						for _,v in ipairs(doorID.doors) do
							FreezeEntityPosition(v.object, doorID.locked)
	
							if doorID.locked and v.objYaw and GetEntityRotation(v.object).z ~= v.objYaw then
								SetEntityRotation(v.object, 0.0, 0.0, v.objYaw, 2, true)
							end
						end
					else
						FreezeEntityPosition(doorID.object, doorID.locked)
	
						if doorID.locked and doorID.objYaw and GetEntityRotation(doorID.object).z ~= doorID.objYaw then
							SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
						end
					end
				end


				if distance < withinreach then
					local aux = {}
					local isAuthorized = IsAuthorized(doorID)
					aux['id'] = k
					aux['x'] = objCoords.x
					aux['y'] = objCoords.y 
					aux['z'] = objCoords.z 
					aux['isAuth'] = IsAuthorized(doorID)

					if doorID.locked then
						aux['status'] = "Locked" 
					elseif not doorID.locked then
						aux['status'] = "Unlocked"
					end

					aux['doorID'] = doorID 
					-- print("Add door with id:", k)
					table.insert(drowtargetdoors, aux)
					-- drowtargetdoors.k = aux



				end

			end
	end
end)
--[[
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords, awayFromDoors = GetEntityCoords(GetPlayerPed(-1)), true

		for k,doorID in ipairs(QB.Doors) do
			local distance

			if doorID.doors then
				distance = #(playerCoords - doorID.doors[1].objCoords)
			else
				distance = #(playerCoords - doorID.objCoords)
			end

			if doorID.distance then
				maxDistance = doorID.distance
			end
			if distance < 50 then
				awayFromDoors = false
				if doorID.doors then
					for _,v in ipairs(doorID.doors) do
						FreezeEntityPosition(v.object, doorID.locked)

						if doorID.locked and v.objYaw and GetEntityRotation(v.object).z ~= v.objYaw then
							SetEntityRotation(v.object, 0.0, 0.0, v.objYaw, 2, true)
						end
					end
				else
					FreezeEntityPosition(doorID.object, doorID.locked)

					if doorID.locked and doorID.objYaw and GetEntityRotation(doorID.object).z ~= doorID.objYaw then
						SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
					end
				end
			end

			if distance < maxDistance then
				awayFromDoors = false
				if doorID.size then
					size = doorID.size
				end

				local isAuthorized = IsAuthorized(doorID)

				if isAuthorized then
					if doorID.locked then
						displayText = "~g~E~w~ - Locked"
					elseif not doorID.locked then
						displayText = "~g~E~w~ - Unlocked"
					end
				elseif not isAuthorized then
					if doorID.locked then
						displayText = "Locked"
					elseif not doorID.locked then
						displayText = "Unlocked"
					end
				end

				if doorID.locking then
					if doorID.locked then
						displayText = "Unlocking.."
					else
						displayText = "Locking.."
					end
				end

				if doorID.objCoords == nil then
					doorID.objCoords = doorID.textCoords
				end

				DrawText3Ds(doorID.objCoords.x, doorID.objCoords.y, doorID.objCoords.z, displayText)

				print(k)

				if IsControlJustReleased(0, 38) then
					if isAuthorized then
						setDoorLocking(doorID, k)
					end
				end
			end
		end

		if awayFromDoors then
			Citizen.Wait(1000)
		end
	end
end)
--]]


-- local props = {
-- 	"prison_prop_door1",
-- 	"prison_prop_door2",
-- 	"v_ilev_gtdoor",
-- 	"prison_prop_door1a"
-- }

-- Citizen.CreateThread(function()
-- 	while true do
-- 		for k, v in pairs(props) do
-- 			local ped = GetPlayerPed(-1)
-- 			local pos = GetEntityCoords(ped)
-- 			local ClosestDoor = GetClosestObjectOfType(pos.x, pos.y, pos.z, 5.0, GetHashKey(v), 0, 0, 0)
-- 			if ClosestDoor ~= 0 then
-- 				local DoorCoords = GetEntityCoords(ClosestDoor)
	
-- 				DrawText3Ds(DoorCoords.x, DoorCoords.y, DoorCoords.z, "OBJ: "..v..", x: "..round(DoorCoords.x, 0)..", y: "..round(DoorCoords.y, 0)..", z: "..round(DoorCoords.z, 0))
-- 			end
-- 		end
-- 		Citizen.Wait(1)
-- 	end
-- end)

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
						if hasItem then
							closestDoorKey, closestDoorValue = k, v
							TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
						else
							QBCore.Functions.Notify("You are missing a toolkit..", "error")
						end
					else
						QBCore.Functions.Notify('The door is already unlocked??', 'error', 2500)
					end
				else
					QBCore.Functions.Notify('The door lock is too strong', 'error', 2500)
				end
			end
		end
    end, "screwdriverset")
end)

function lockpickFinish(success)
    if success then
		QBCore.Functions.Notify('Succes!', 'success', 2500)
		setDoorLocking(closestDoorValue, closestDoorKey)
    else
        QBCore.Functions.Notify('Failed..', 'error', 2500)
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
        Citizen.Wait(5)
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
		if gang == PlayerData.job.name then
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