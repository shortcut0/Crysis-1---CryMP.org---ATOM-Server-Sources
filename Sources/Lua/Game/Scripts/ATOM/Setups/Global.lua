ATOMSetup:AddSetup('Global', function()

    if (g_gameRules.class ~= "InstantAction") then
        return
    end

    SysLog("Global Setup loaded")

    do return end

    local aM4A1 = System.GetEntitiesByClass("M4A1")
    local iValidM4 = 0
    for i, hItem in pairs(checkArray(aM4A1)) do
        if (hItem.Properties.Respawn and checkNumber(hItem.Properties.Respawn.bRespawn) == 1) then
            iValidM4 = iValidM4 + 1
        end
    end

    if (iValidM4 >= 3) then
        return
    end

    local aItems = {}
    for i, hItem in pairs(System.GetEntities()) do
        local aRespawn = checkArray(hItem.Properties, { Respawn = { bRespawn = 0 } }).Respawn
        if (hItem.weapon and string.matchex(hItem.class, "FY71", "SCAR", "SMG") and aRespawn and checkNumber(aRespawn.bRespawn, 0) == 1) then
            table.insert(aItems, hItem)
        end
    end

    local iItems = table.count(aItems)
    if (iItems <= 3) then
        return
    end

    local iReplace = math.round(iItems / 3)
    local iReplaced = 0
    for i, hItem in pairs(table.shuffle(aItems)) do
        local hNew = System.SpawnEntity({ class = "M4A1", name = hItem:GetName(), properties = hItem.Properties, orientation = hItem:GetDirectionVector(), position = hItem:GetPos() })
        hNew:SetAngles(hItem:GetAngles())
        hNew.Properties.Respawn = hItem.Properties.Respawn

        g_game:ScheduleEntityRespawn(hNew.id, false, hNew.Properties.Respawn.fTimer)
        g_game:AbortEntityRespawn(hItem.id, true)
        System.RemoveEntity(hItem.id)

        iReplaced = iReplaced + 1
        if (iReplaced >= iReplace) then
            break
        end
    end

end)