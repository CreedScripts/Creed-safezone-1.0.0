RegisterServerEvent('safezone:addWeaponToInventory')
AddEventHandler('safezone:addWeaponToInventory', function(weaponHash)
    local source = source

    print(("Weapon stored in inventory for player %s: %s"):format(source, weaponHash))
end)
