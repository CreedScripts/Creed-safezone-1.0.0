local isInSafezone = false
local safezoneBlips = {}


local function notify(message, type)
    lib.notify({
        title = 'Safezone',
        description = message,
        type = type or 'inform'
    })
end


local function showSafezoneUI()
    lib.showTextUI('In Safezone', {
        position = "top-center",
        icon = 'shield-alt',
        iconColor = '#ffffff',
        style = {
            borderRadius = '12px',
            backgroundColor = 'rgba(72, 187, 120, 0.9)',
            color = '#ffffff',
            padding = '10px 20px',
            fontSize = '18px',
            fontWeight = 'bold',
            boxShadow = '0px 0px 10px rgba(0, 0, 0, 0.5)'
        }
    })
end


local function hideSafezoneUI()
    lib.hideTextUI()
end


local function isPlayerInSafezone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.Safezones) do
        local dist = #(playerCoords - zone.coords)
        if dist <= zone.radius then
            return true
        end
    end
    return false
end


local function playCustomSound(soundFile)
    SendNUIMessage({
        transactionType = "playSound",
        transactionFile = soundFile
    })
end


local function limitVehicleSpeed()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if DoesEntityExist(vehicle) then
            local speedLimit = Config.SafezoneSpeedLimit / 3.6 -- Convert km/h to m/s
            local currentSpeed = GetEntitySpeed(vehicle)
            local reverse = GetVehicleCurrentGear(vehicle) == 0 


            if currentSpeed > speedLimit then
                local reducedSpeed = reverse and -speedLimit or speedLimit 
                SetVehicleForwardSpeed(vehicle, reducedSpeed)
            end


            SetVehicleEngineTorqueMultiplier(vehicle, 1.0 - (currentSpeed / speedLimit))
        end
    end
end


local function manageWeaponsInSafezone()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)


    if IsPedArmed(playerPed, 7) and weaponHash ~= GetHashKey("WEAPON_UNARMED") then
        RemoveWeaponFromPed(playerPed, weaponHash)

        TriggerServerEvent('safezone:addWeaponToInventory', weaponHash)
        notify("Weapons are not allowed in the safe zone. Weapon stored in inventory.", 'error')
    end


    DisableControlAction(0, 37, true) 
    if IsPedArmed(playerPed, 7) then
        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
    end
end


local function disableCombatActions()
    local playerPed = PlayerPedId()


    DisableControlAction(0, 24, true) 
    DisableControlAction(0, 25, true) 
    DisableControlAction(0, 140, true) 
    DisableControlAction(0, 141, true) 
    DisableControlAction(0, 142, true) 
    DisableControlAction(0, 257, true) 
    DisableControlAction(0, 263, true) 
    DisableControlAction(0, 264, true) 
end


local function createSafezoneBlips()
    for _, zone in ipairs(Config.Safezones) do
        local blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
        SetBlipAlpha(blip, 75) 
        SetBlipColour(blip, 2) 
        table.insert(safezoneBlips, blip)
    end
end


local function removeSafezoneBlips()
    for _, blip in ipairs(safezoneBlips) do
        RemoveBlip(blip)
    end
    safezoneBlips = {}
end


CreateThread(function()
    createSafezoneBlips()

    while true do
        local insideSafezone = isPlayerInSafezone()


        if insideSafezone and not isInSafezone then
            isInSafezone = true
            showSafezoneUI()
            notify("You have entered a safe zone!", 'success')
            playCustomSound("sounds/enter_safezone.mp3")


        elseif not insideSafezone and isInSafezone then
            isInSafezone = false
            hideSafezoneUI()
            notify("You have left the safe zone!", 'warning')
            playCustomSound("sounds/leave_safezone.mp3")
        end


        if isInSafezone then
            limitVehicleSpeed()
            disableCombatActions()
            manageWeaponsInSafezone()
        end

        Wait(0) 
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        removeSafezoneBlips()
    end
end)














