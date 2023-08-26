-- Utils functions
local target, export = nil, nil
if GetResourceState('qb-target') == 'started' then
    target = 'qb-target'
    export = exports['qb-target']
elseif GetResourceState('ox_target') == 'started' then
    target = 'ox_target'
    export = exports['ox_target']
end
function zf.getTarget() return target end

local function convert(options)
    local distance = options.distance
    options = options.options

    -- People may pass options as a hashmap (or mixed, even)
    for k, v in pairs(options) do
        if type(k) ~= 'number' then
            table.insert(options, v)
        end
    end

    for id, v in pairs(options) do
        if type(id) ~= 'number' then
            options[id] = nil
            goto continue
        end

        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.items = v.item
        v.icon = v.icon
        v.groups = v.job

        local groupType = type(v.groups)
        if groupType == 'nil' then
            v.groups = {}
            groupType = 'table'
        end
        if groupType == 'string' then
            local val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end
        elseif groupType == 'table' then
            local val = {}
            if table.type(v.groups) ~= 'array' then
                for k in pairs(v.groups) do
                    val[#val + 1] = k
                end
                v.groups = val
                val = nil
            end

            val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end
        end

        if type(v.groups) == 'table' and table.type(v.groups) == 'empty' then
            v.groups = nil
        end

        if v.event and v.type and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end

            v.event = nil
            v.type = nil
        end

        v.action = nil
        v.job = nil
        v.gang = nil
        v.citizenid = nil
        v.item = nil
        v.qtarget = true

        ::continue::
    end
    return options
end

-- Target functions
function zf.addZone(name, coords, length, width, options, targetoptions)
    if target == 'qb-target' then
        return export:AddBoxZone(name, coords, length, width, options, targetoptions)
    elseif target == 'ox_target' then
        return export:addBoxZone({
            name = name,
            coords = coords,
            size = vec3(length, width, (options.useZ or not options.maxZ) and coords.z or math.abs(options.maxZ - options.minZ)),
            debug = options.debugPoly,
            rotation = options.heading,
            options = convert(targetoptions),
        })
    end
end

function zf.addEntity(entities, options, isNet, noconvert)
    if target == 'qb-target' then
        return export:AddTargetEntity(entities, options)
    elseif target == 'ox_target' then
        if type(entities) ~= 'table' then entities = { entities } end
        options = noconvert and options or convert(options)
        for i=1, #entities do
            local entity = entities[i]
            if isNet then return export:addEntity(entity, options) end
            if NetworkGetEntityIsNetworked(entity) then
                return export:addEntity(NetworkGetNetworkIdFromEntity(entity), options)
            else
                return export:addLocalEntity(entity, options)
            end
        end
    end
end

function zf.addModel(models, options)
    if target == 'qb-target' then
        return export:AddTargetModel(models, options)
    elseif target == 'ox_target' then
        return export:addModel(models, convert(options))
    end
end

function zf.removeZone(name)
    if target == 'qb-target' then
        return export:RemoveZone(name)
    elseif target == 'ox_target' then
        return export:removeZone(name, true)
    end
end

function zf.removeEntity(entities, options)
    if target == 'qb-target' then
        return export:RemoveTargetEntity(entities, options)
    elseif target == 'ox_target' then
        if type(entities) ~= 'table' then entities = { entities } end
        for i=1, #entities do
            local entity = entities[i]
            if NetworkGetEntityIsNetworked(entity) then return export:removeEntity(NetworkGetNetworkIdFromEntity(entity), options)
            else return export:removeLocalEntity(entity, options) end
        end
    end
end

function zf.removeModel(models, options)
    if target == 'qb-target' then
        return export:RemoveTargetModel(models, options)
    elseif target == 'ox_target' then
        return export:removeModel(models, options)
    end
end

function zf.addTargetBone(bones, options)
    if target == 'qb-target' then
        return export:AddTargetBone(bones, options)
    elseif target == 'ox_target' then
        zf.log('error', 'zf.addTargetBone does not support ox_target at the moment. We are sorry for this inconvenient.')
        return
    end
end








-- Peds functions
local Peds = {}
local pedsReady = false
local function SpawnPed(data)
	local spawnedped
	local key, value = next(data)
	if type(value) == 'table' and type(key) ~= 'string' then
		for _, v in pairs(data) do
			if v.spawnNow then
				RequestModel(v.model)
				while not HasModelLoaded(v.model) do
					Wait(0)
				end

				if type(v.model) == 'string' then v.model = joaat(v.model) end

				if v.minusOne then
					spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w or 0.0, v.networked or false, true)
				else
					spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w or 0.0, v.networked or false, true)
				end

				if v.freeze then
					FreezeEntityPosition(spawnedped, true)
				end

				if v.invincible then
					SetEntityInvincible(spawnedped, true)
				end

				if v.blockevents then
					SetBlockingOfNonTemporaryEvents(spawnedped, true)
				end

				if v.animDict and v.anim then
					RequestAnimDict(v.animDict)
					while not HasAnimDictLoaded(v.animDict) do
						Wait(0)
					end

					TaskPlayAnim(spawnedped, v.animDict, v.anim, 8.0, 0, -1, v.flag or 1, 0, false, false, false)
				end

				if v.scenario then
					SetPedCanPlayAmbientAnims(spawnedped, true)
					TaskStartScenarioInPlace(spawnedped, v.scenario, 0, true)
				end

				if v.pedrelations and type(v.pedrelations.groupname) == 'string' then
					if type(v.pedrelations.groupname) ~= 'string' then error(v.pedrelations.groupname .. ' is not a string') end

					local pedgrouphash = joaat(v.pedrelations.groupname)

					if not DoesRelationshipGroupExist(pedgrouphash) then
						AddRelationshipGroup(v.pedrelations.groupname)
					end

					SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
					if v.pedrelations.toplayer then
						SetRelationshipBetweenGroups(v.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
					end

					if v.pedrelations.toowngroup then
						SetRelationshipBetweenGroups(v.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
					end
				end

				if v.weapon then
					if type(v.weapon.name) == 'string' then v.weapon.name = joaat(v.weapon.name) end

					if IsWeaponValid(v.weapon.name) then
						SetCanPedEquipWeapon(spawnedped, v.weapon.name, true)
						GiveWeaponToPed(spawnedped, v.weapon.name, v.weapon.ammo, v.weapon.hidden or false, true)
						SetPedCurrentWeaponVisible(spawnedped, not v.weapon.hidden or false, true)
					end
				end

				if v.target then
					if v.target.useModel then
						zf.addModel(data.model, {
                            options = data.target.options,
                            distance = data.target.distance
                        })
                    else
                        zf.addEntity(spawnedped, {
                            options = data.target.options,
                            distance = data.target.distance
                        })
					end
				end

				v.currentpednumber = spawnedped

				if v.action then
					v.action(v)
				end
			end

			local nextnumber = #Peds + 1
			if nextnumber <= 0 then nextnumber = 1 end

			Peds[nextnumber] = v
		end
	else
		if data.spawnNow then
			RequestModel(data.model)
			while not HasModelLoaded(data.model) do
				Wait(0)
			end

			if type(data.model) == 'string' then data.model = joaat(data.model) end

			if data.minusOne then
				spawnedped = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, data.networked or false, true)
			else
				spawnedped = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z, data.coords.w, data.networked or false, true)
			end

			if data.freeze then
				FreezeEntityPosition(spawnedped, true)
			end

			if data.invincible then
				SetEntityInvincible(spawnedped, true)
			end

			if data.blockevents then
				SetBlockingOfNonTemporaryEvents(spawnedped, true)
			end

			if data.animDict and data.anim then
				RequestAnimDict(data.animDict)
				while not HasAnimDictLoaded(data.animDict) do
					Wait(0)
				end

				TaskPlayAnim(spawnedped, data.animDict, data.anim, 8.0, 0, -1, data.flag or 1, 0, false, false, false)
			end

			if data.scenario then
				SetPedCanPlayAmbientAnims(spawnedped, true)
				TaskStartScenarioInPlace(spawnedped, data.scenario, 0, true)
			end

			if data.pedrelations then
				if type(data.pedrelations.groupname) ~= 'string' then error(data.pedrelations.groupname .. ' is not a string') end

				local pedgrouphash = joaat(data.pedrelations.groupname)

				if not DoesRelationshipGroupExist(pedgrouphash) then
					AddRelationshipGroup(data.pedrelations.groupname)
				end

				SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
				if data.pedrelations.toplayer then
					SetRelationshipBetweenGroups(data.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
				end

				if data.pedrelations.toowngroup then
					SetRelationshipBetweenGroups(data.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
				end
			end

			if data.weapon then
				if type(data.weapon.name) == 'string' then data.weapon.name = joaat(data.weapon.name) end

				if IsWeaponValid(data.weapon.name) then
					SetCanPedEquipWeapon(spawnedped, data.weapon.name, true)
					GiveWeaponToPed(spawnedped, data.weapon.name, data.weapon.ammo, data.weapon.hidden or false, true)
					SetPedCurrentWeaponVisible(spawnedped, not data.weapon.hidden or false, true)
				end
			end

			if data.target then
				if data.target.useModel then
                    zf.addModel(data.model, {
						options = data.target.options,
						distance = data.target.distance
					})
				else
                    zf.addEntity(spawnedped, {
						options = data.target.options,
						distance = data.target.distance
					})
				end
			end

			data.currentpednumber = spawnedped
			
			if data.action then
				data.action(data)
			end
		end

		local nextnumber = #Peds + 1
		if nextnumber <= 0 then nextnumber = 1 end

		Peds[nextnumber] = data
	end
end

function zf.spawnPed(data)
    return SpawnPed(data)
end

-- Spawn Peds when ready
function SpawnPeds()
	if pedsReady or not next(Peds) then return end
	for k, v in pairs(Peds) do
		if not v.currentpednumber or v.currentpednumber == 0 then
			local spawnedped
			RequestModel(v.model)
			while not HasModelLoaded(v.model) do
				Wait(0)
			end

			if type(v.model) == 'string' then v.model = joaat(v.model) end

			if v.minusOne then
				spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w, v.networked or false, false)
			else
				spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w, v.networked or false, false)
			end

			if v.freeze then
				FreezeEntityPosition(spawnedped, true)
			end

			if v.invincible then
				SetEntityInvincible(spawnedped, true)
			end

			if v.blockevents then
				SetBlockingOfNonTemporaryEvents(spawnedped, true)
			end

			if v.animDict and v.anim then
				RequestAnimDict(v.animDict)
				while not HasAnimDictLoaded(v.animDict) do
					Wait(0)
				end

				TaskPlayAnim(spawnedped, v.animDict, v.anim, 8.0, 0, -1, v.flag or 1, 0, false, false, false)
			end

			if v.scenario then
				SetPedCanPlayAmbientAnims(spawnedped, true)
				TaskStartScenarioInPlace(spawnedped, v.scenario, 0, true)
			end

			if v.pedrelations then
				if type(v.pedrelations.groupname) ~= 'string' then error(v.pedrelations.groupname .. ' is not a string') end

				local pedgrouphash = joaat(v.pedrelations.groupname)

				if not DoesRelationshipGroupExist(pedgrouphash) then
					AddRelationshipGroup(v.pedrelations.groupname)
				end

				SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
				if v.pedrelations.toplayer then
					SetRelationshipBetweenGroups(v.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
				end

				if v.pedrelations.toowngroup then
					SetRelationshipBetweenGroups(v.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
				end
			end

			if v.weapon then
				if type(v.weapon.name) == 'string' then v.weapon.name = joaat(v.weapon.name) end

				if IsWeaponValid(v.weapon.name) then
					SetCanPedEquipWeapon(spawnedped, v.weapon.name, true)
					GiveWeaponToPed(spawnedped, v.weapon.name, v.weapon.ammo, v.weapon.hidden or false, true)
					SetPedCurrentWeaponVisible(spawnedped, not v.weapon.hidden or false, true)
				end
			end

			if v.target then
				if v.target.useModel then
					AddTargetModel(v.model, {
						options = v.target.options,
						distance = v.target.distance
					})
				else
					AddTargetEntity(spawnedped, {
						options = v.target.options,
						distance = v.target.distance
					})
				end
			end

			if v.action then
				v.action(v)
			end

			Peds[k].currentpednumber = spawnedped
		end
	end
	pedsReady = true
end

function DeletePeds()
	if not pedsReady or not next(Peds) then return end
	for k, v in pairs(Peds) do
		DeletePed(v.currentpednumber)
		Peds[k].currentpednumber = 0
	end
	pedsReady = false
end

AddEventHandler('onResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then return end
	SpawnPeds()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return end
	DeletePeds()
end)

RegisterNetEvent('esx:playerLoaded', function()
	SpawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	SpawnPeds()
end)