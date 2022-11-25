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
