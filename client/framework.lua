local function GetCoreObject()
    if Framework.RunningFramework == 'qb-core' then
        if GetResourceState('qb-core') == 'started' then
            return exports['qb-core']:GetCoreObject()
        else
            print('[zf-lib] qb-core is the selected framework, but qb-core is not started.')
            break
        end
    elseif Framework.RunningFramework == 'esx' then
        if GetResourceState('es_extended') == 'started' then
            return ESX
        else
            print('[zf-lib] es_extended is the selected framework, but es_extended is not started.')
            break
        end
    end
end exports('GetCoreObject', GetCoreObject)

local function TriggerCallback()
end exports('TriggerCallback', TriggerCallback)

local function SpawnVehicle()
end exports('SpawnVehicle', SpawnVehicle)

local function GetClosestPlayer()
end exports('GetClosestPlayer', GetClosestPlayer)

local function GetClosestVehicle()
end exports('GetClosestVehicle', GetClosestVehicle)

local function GetVehicleInDirection()
end exports('GetVehicleInDirection', GetVehicleInDirection)

local function GetVehicleProperties()
end exports('GetVehicleProperties', GetVehicleProperties)

local function SetVehicleProperties()
end exports('SetVehicleProperties', SetVehicleProperties)

local function GetPlayerData()
    if Framework.RunningFramework == 'qb-core' then
        return QBCore.Functions.GetPlayerData()
    end
end exports('GetPlayerData', GetPlayerData)

local function IsPlayerLoaded()
end exports('IsPlayerLoaded', IsPlayerLoaded)

local function Notify()
end exports('Notify', Notify)
