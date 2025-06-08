-- client.lua
local is_bounce_mode_active = false
local original_height = {}
local bounce_time = 0
local bounce_active_vehicles = {}


local function isVehicleAllowed(vehicleModel)
    for _, model in ipairs(Config.AllowedVehicles) do
        if vehicleModel == GetHashKey(model) then
            return true
        end
    end
    return false
end


local function notifyPlayer(message)
    TriggerEvent('esx:showNotification', message)
end


local function toggleBounce()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    if vehicle ~= 0 then
        local vehicleModel = GetEntityModel(vehicle)
        if isVehicleAllowed(vehicleModel) then
            is_bounce_mode_active = not is_bounce_mode_active
            bounce_time = GetGameTimer()
            if is_bounce_mode_active then
                original_height[vehicle] = GetVehicleSuspensionHeight(vehicle)
                bounce_active_vehicles[vehicle] = true
                TriggerServerEvent('vehicle_bouncemode:sv:sync_bounce')
                notifyPlayer("Bouncen aktiviert! Max. Geschwindigkeit: " .. Config.MaxBounceSpeed .. " km/h")
                CreateThread(function()
                    while is_bounce_mode_active do
                        SetEntityMaxSpeed(vehicle, Config.MaxBounceSpeed / 3.6) 
                        Wait(500)
                    end
                end)
            else
                bounce_active_vehicles[vehicle] = nil
                SetVehicleSuspensionHeight(vehicle, original_height[vehicle] or 0)
                SetEntityMaxSpeed(vehicle, 999.0) 
                TriggerServerEvent('vehicle_bouncemode:sv:stop_bounce')
                notifyPlayer("Bouncen deaktiviert!")
            end
        else
        end
    else
    end
end


RegisterNetEvent('vehicle_bouncemode:cl:start_bounce')
AddEventHandler('vehicle_bouncemode:cl:start_bounce', function(veh_netid)
    local vehicle = NetworkGetEntityFromNetworkId(veh_netid)
    if DoesEntityExist(vehicle) then
        bounce_active_vehicles[vehicle] = true
        CreateThread(function()
            while bounce_active_vehicles[vehicle] do
                local time_since_start = (GetGameTimer() - bounce_time) / 1000.0
                local new_bounce_height = 0.05 * math.sin(2 * math.pi * 1.5 * time_since_start)
                SetVehicleSuspensionHeight(vehicle, (original_height[vehicle] or 0) + new_bounce_height)
                Wait(50)
            end
        end)
    end
end)


RegisterNetEvent('vehicle_bouncemode:cl:stop_bounce')
AddEventHandler('vehicle_bouncemode:cl:stop_bounce', function(veh_netid)
    local vehicle = NetworkGetEntityFromNetworkId(veh_netid)
    if DoesEntityExist(vehicle) then
        bounce_active_vehicles[vehicle] = nil
        SetVehicleSuspensionHeight(vehicle, original_height[vehicle] or 0)
        SetEntityMaxSpeed(vehicle, 999.0) 
    end
end)


RegisterKeyMapping('toggleBounce', 'Toggle Fahrzeug Bounce', 'keyboard', 'E')
RegisterCommand('toggleBounce', function()
    toggleBounce()
end, false)
