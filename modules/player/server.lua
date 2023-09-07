function zf.getPlayer(source)
    if zf.core == 'qb-core' then
        return CoreObject.Functions.GetPlayer(source)
    elseif zf.core == 'esx' then
        return CoreObject.GetPlayerFromId(source)
    end
end

function zf.getPlayers()
    if zf.core == 'qb-core' then
        return CoreObject.Functions.GetQBPlayers()
    elseif zf.core == 'esx' then
        return CoreObject.GetPlayers()
    end
end

-- Money
function zf.addMoney(source, moneyType, amount, reason)
    if not reason then reason = 'unknown' end
    local Player = zf.getPlayer(source)
    local addedMoney = false
    local types = {
        ['cash'] = {
            ['qb-core'] = 'cash',
            ['esx'] = 'money'
        },
        ['bank'] = {
            ['qb-core'] = 'bank',
            ['esx'] = 'bank'
        }
    }

    if zf.core == 'qb-core' then
        moneyType = types[moneyType]['qb-core']
        addedMoney = Player.Functions.AddMoney(moneyType, amount, reason)
    elseif zf.core == 'esx' then
        moneyType = types[moneyType]['esx']
        local currentMoney = Player.getAccount(moneyType)
        Player.addAccountMoney(moneyType, amount, reason)
        if currentMoney + amount == Player.getAccount(moneyType) then
            addedMoney = true
        else
            addedMoney = false
        end
    end
    return addedMoney
end

function zf.removeMoney(source, moneyType, amount, reason)
    if not reason then reason = 'unknown' end
    local Player = zf.getPlayer(source)
    local removedMoney = false
    local types = {
        ['cash'] = {
            ['qb-core'] = 'cash',
            ['esx'] = 'money'
        },
        ['bank'] = {
            ['qb-core'] = 'bank',
            ['esx'] = 'bank'
        }
    }

    if zf.core == 'qb-core' then
        moneyType = types[moneyType]['qb-core']
        removedMoney = Player.Functions.RemoveMoney(moneyType, amount, reason)
    elseif zf.core == 'esx' then
        moneyType = types[moneyType]['esx']
        local currentMoney = Player.getAccount(moneyType)
        Player.removeAccountMoney(moneyType, amount, reason)
        if currentMoney - amount == currentMoney then
            removedMoney = false
        else
            removedMoney = true
        end
    end
    return removedMoney
end

function zf.getMoney(source, moneyType)
    local Player = zf.getPlayer(source)
    local types = {
        ['cash'] = {
            ['qb-core'] = 'cash',
            ['esx'] = 'money'
        },
        ['bank'] = {
            ['qb-core'] = 'bank',
            ['esx'] = 'bank'
        }
    }

    if zf.core == 'qb-core' then
        moneyType = types[moneyType]['qb-core']
        return Player.Functions.GetMoney(moneyType)
    elseif zf.core == 'esx' then
        moneyType = types[moneyType]['esx']
        return Player.getAccount(moneyType)
    end
    return false
end

function zf.setMoney(source, moneyType, amount)
    if not reason then reason = 'unknown' end
    local Player = zf.getPlayer(source)
    local types = {
        ['cash'] = {
            ['qb-core'] = 'cash',
            ['esx'] = 'money'
        },
        ['bank'] = {
            ['qb-core'] = 'bank',
            ['esx'] = 'bank'
        }
    }

    if zf.core == 'qb-core' then
        moneyType = types[moneyType]['qb-core']
        Player.Functions.SetMoney(moneyType, amount, reason)
    elseif zf.core == 'esx' then
        moneyType = types[moneyType]['esx']
        Player.setAccountMoney(moneyType, amount, reason)
    end
end

function zf.getLicences(source)
    local Player = zf.getPlayer(source)
    if zf.core == 'qb-core' then
        local licences = Player.PlayerData.metadata['licences']
        return licences or false
    elseif zf.core == 'esx' then
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            return licences or false
        end)
    end
end

function zf.getLicence(source, licenseType)
    local Player = zf.getPlayer(source)
    if zf.core == 'qb-core' then
        local licences = Player.PlayerData.metadata['licences']
        return licences[licenseType] or false
    elseif zf.core == 'esx' then
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            return licences[licenseType] or false
        end)
    end
end

function zf.addLicence(source, licenseType)
    local Player = zf.getPlayer(source)
    if zf.core == 'qb-core' then
        local licences = Player.PlayerData.metadata['licences']
        licences[licenseType] = true
        Player.Functions.SetMetaData('licences', licences)
        return true
    elseif zf.core == 'esx' then
        TriggerEvent('esx_license:addLicense', source, licenseType, function()
            return true
        end)
    end
    return false
end

function zf.removeLicence(source, licenseType)
    local Player = zf.getPlayer(source)
    if zf.core == 'qb-core' then
        local licences = Player.PlayerData.metadata['licences']
        licences[licenseType] = false
        Player.Functions.SetMetaData('licences', licences)
        return true
    elseif zf.core == 'esx' then
        TriggerEvent('esx_license:removeLicense', source, licenseType, function()
            return true
        end)
    end
    return false
end

function zf.getCitizenId(source)
    local Player = zf.getPlayer(source)
    if zf.core == 'qb-core' then
        local citizenid = Player.PlayerData.citizenid
        return citizenid
    elseif zf.core == 'esx' then
        local citizenid = Player.license
        return citizenid
    end
    return false
end

function zf.getPlayerName(source)
    local Player = zf.getPlayer(source)
    if zf.core == 'qb-core' then
        local player_name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        return player_name
    elseif zf.core == 'esx' then
        local player_name = Player.name
        return player_name
    end
    return false
end


zf.callback.register('zf-lib:getPlayerName', function(source)
    return zf.getPlayerName(source)
end)

zf.callback.register('zf-lib:getlicences', function(source)
    return zf.getLicences(source)
end)

zf.callback.register('zf-lib:getlicence', function(source, licenseType)
    return zf.getLicence(source, licenseType)
end)

zf.callback.register('zf-lib:getCitizenid', function(source)
    return zf.getCitizenId(source)
end)
