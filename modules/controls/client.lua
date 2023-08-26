local disableControls = {}

function zf.disableControls(controls)
    local controlsType = type(controls)
    if controlsType == 'number' then
        disableControls[#disableControls+1] = controls
    elseif controlsType == 'table' and table.type(controls) == "array" then
        for i = 1, #controls do
            disableControls[#disableControls+1] = controls[i]
        end
    end
end

function zf.enableControls(controls)
    local controlsType = type(controls)
    if controlsType == 'number' then
        for i = 1, #disableControls do
            if disableControls[i] == controls then
                table.remove(disableControls, i)
                break
            end
        end
    elseif controlsType == 'table' and table.type(controls) == "array" then
        for i = 1, #disableControls do
            for i2 = 1, #controls do
                if disableControls[i] == controls[i2] then
                    table.remove(disableControls, i)
                end
            end
        end
    end
end

function zf.getDisabledControls()
    return disableControls
end

CreateThread(function()
    while true do
        local timer = 0
        if #disableControls == 0 then timer = 300 else timer = 0
            for i = 1, #disableControls do
                DisableControlAction(2, disableControls[i], true)
            end
        end
        Wait(timer)
    end
end)