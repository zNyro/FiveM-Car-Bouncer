-- server.lua
local active_bounce_modes = {}

RegisterServerEvent('vehicle_bouncemode:sv:sync_bounce')
AddEventHandler('vehicle_bouncemode:sv:sync_bounce', function()
    local _src = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(_src), false)
    if vehicle and vehicle ~= 0 then
        local veh_netid = NetworkGetNetworkIdFromEntity(vehicle)
        active_bounce_modes[veh_netid] = true
        TriggerClientEvent('vehicle_bouncemode:cl:start_bounce', -1, veh_netid)
    else
    end
end)

RegisterServerEvent('vehicle_bouncemode:sv:stop_bounce')
AddEventHandler('vehicle_bouncemode:sv:stop_bounce', function()
    local _src = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(_src), false)
    if vehicle and vehicle ~= 0 then
        local veh_netid = NetworkGetNetworkIdFromEntity(vehicle)
        active_bounce_modes[veh_netid] = nil
        TriggerClientEvent('vehicle_bouncemode:cl:stop_bounce', -1, veh_netid)
    else
    end
end)