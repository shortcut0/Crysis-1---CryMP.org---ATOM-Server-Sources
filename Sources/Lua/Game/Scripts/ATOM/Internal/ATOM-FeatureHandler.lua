--------------------------------------------------
-- ATOM Features Plugin

-----------------

FEATURENAME_ARENA = "arenas"
FEATURENAME_STADIUM = "stadium"
FEATURENAME_PERMASCORE = "permascore"

-----------------
ATOMFeatures = {

    aFeatures   = {},
    aDefault    = {
       { "menu",        "Admin Menu", true },
       { "attach",      "Weapon Attach Handler", true },
       { "idleanim",    "IdleAnimation Handler", true },
       { "taunt",       "Player BattleVoice Handler", true },
       { "grab",        "Player Grabbing Handler", true },
       { "objectgrab",  "Advanced Object Grabbing", false },
       { "ragdollsync",  "Accurate Ragdoll Syncing", true },
       { "rca",         "Remote Client Access", true },
       { FEATURENAME_ARENA,      "Arena Plugin (PVP, Boxing, Custom Arenas)", true },
       { FEATURENAME_STADIUM,    "Football Plugin", true },
       { FEATURENAME_PERMASCORE,  "Player PermaScore Plugin", true },
    },
    --[[ {
        "Name", -- name
        "FriendlyName", -- UI friendly name
        true/false, -- enabled/disabled
        ...
    } --]]

}

-----------------

eID_FeatureName = 1
eID_FeatureNameFriendly = 2
eID_FeatureStatus = 3
eID_IsTemporary = 4

-----------------
-- Init
ATOMFeatures.Init = function(self)

    ------
   -- SysLog("ATOMFeatures:Init()")

    ------
    g_features = self
    ATOM:SetPostInit("g_features.PostInit", "g_features")

    ------
    AddDefaultFeature = function(...)
        return self:AddDefaultFeature({ ... })
    end
    SetBetaFeature = function(hPlayer, sName, bStatus, bKeepOnRestart, ...)
        return self:SetFeature(hPlayer, sName, bStatus, ...)
    end
    GetBetaFeature = function(sName)
        return self:GetFeature(sName)
    end
    GetFeatureName = function(sName)
        return self:GetFeatureFriendlyName(sName)
    end
    GetBetaFeatureStatus = function(sName)
        return self:GetFeatureStatus(sName)
    end

    ------
    self:LoadFile()
end

-----------------
-- Init
ATOMFeatures.PostInit = function(self)

    ------
    --SysLog("ATOMFeatures:PostInit()")

    ------
    self:LoadDefaultFeatures()
end

-----------------
-- Init
ATOMFeatures.Reset = function(self)
    self.aFeatures = {}
    self.aDefault = {}

    self:SaveFile()
    self:LoadFile()
end

-----------------
-- Init
ATOMFeatures.LoadFile = function(self)
    LoadFile("ATOMFeatures", "Features.lua")
end

-----------------
-- Init
ATOMFeatures.SaveFile = function(self)

    local aSave = {}
    for i = 1, table.count(self.aFeatures) do
        --if (self.aFeatures[i][eID_IsTemporary] == true) then
        --else
            table.insert(aSave, self.aFeatures[i])
        --end
    end
    SaveFile("ATOMFeatures", "Features.lua", "g_features:LoadFeature", aSave)
end

-----------------
-- Init
ATOMFeatures.AddDefaultFeature = function(self, aInfo)

    local sName = aInfo.NameShort
    if (string.empty(sName)) then
        return SysLog("No name specified to AddDefaultFeature()")
    end

    local sNameFriendly = checkString(aInfo.NameFriendly, sName)
    local aProperties = checkArray(aInfo.Properties)

    if (self:GetDefaultFeature(sName)) then
        return ATOMLog:LogWarning("Attempt to overwrite default feature %s", sName)
    end

    table.insert(self.aDefault, { sName, sNameFriendly, unpack(aProperties) })
end

-----------------
-- Init
ATOMFeatures.LoadDefaultFeatures = function(self)

    local aDefault = self.aDefault
    local iLoaded = table.count(aDefault)
    if (iLoaded == 0) then
        return
    end

    for i, aFeature in pairs(aDefault) do
        self:LoadFeature(aFeature)
    end

    SysLog("Loaded %d Default Features", iLoaded)
end

-----------------
-- Init
ATOMFeatures.LoadFeature = function(self, ...)

    local aFeatureInfo = { ... }
    if (isArray(aFeatureInfo) and isArray(aFeatureInfo[1])) then
        aFeatureInfo = aFeatureInfo[1]
    end

    if (not isArray(aFeatureInfo)) then
        return SysLog("Invalid parameters to LoadFeature() (%s)", tostring(aFeatureInfo))
    end

    local sFeature = aFeatureInfo[eID_FeatureName]
    if (string.empty(sFeature) or not isString(sFeature)) then
        return SysLog("Empty or Invalid feature name to LoadFeature()")
    end

    if (self:GetFeature(sFeature)) then
        return --SysLog("Attempt to load Feature (%s) twice in LoadFeature()", tostring(sFeature))
    end

    table.insert(self.aFeatures, {
        unpack(aFeatureInfo)
    })

    --SysLog("Loaded Server Feature (%s, %s) with Status %s", sFeature, aFeatureInfo[eID_FeatureNameFriendly], string.bool(aFeatureInfo[eID_FeatureStatus], BTOSTRING_TOGGLED))
end

-----------------
-- Init
ATOMFeatures.GetDefaultFeature = function(self, sName)

    local aDefault = self.aDefault
    local iCount = table.count(aDefault)
    if (iCount == 0) then
        return nil
    end

    for i = 1, iCount do
        if (sName == aDefault[i][eID_FeatureName]) then
            return aDefault[i]
        end
    end

    return nil
end

-----------------
-- Init
ATOMFeatures.GetFeatures = function(self)
    return self.aFeatures
end

-----------------
-- Init
ATOMFeatures.SetFeature = function(self, hPlayer, sName, bStatus, bKeepOnRestart, aProperties)

    local aFeature = self:GetFeature(sName)
    if (not bStatus) then
        if (not aFeature) then
            return false, "feature does not exist"
        end

        aFeature[eID_FeatureStatus] = false
        aFeature[eID_IsTemporary] = (bKeepOnRestart ~= true)
        self:SaveFile()

        SendMsg(CHAT_ATOM, hPlayer, "(%s: Server-Feature was Disabled)", self:GetFeatureFriendlyName(sName))
        ATOMLog:LogUser(ADMINISTRATOR, "Server-Feature '%s' was $4Disabled", self:GetFeatureFriendlyName(sName))
        SysLog("Feature %s: Disabled", sName)
        return true
    end

    aFeature[eID_FeatureStatus] = true
    self:SaveFile()

    SendMsg(CHAT_ATOM, hPlayer, "(%s: Server-Feature was Enabled)", self:GetFeatureFriendlyName(sName))
    ATOMLog:LogUser(ADMINISTRATOR, "Server-Feature '%s' was $3Enabled", self:GetFeatureFriendlyName(sName))
    SysLog("Feature %s: Enabled", sName)

    return true

end

-----------------
-- Init
ATOMFeatures.GetFeature = function(self, sName)

    local aFeatures = self.aFeatures
    local iCount = table.count(aFeatures)
    if (iCount == 0) then
        return nil
    end

    for i = 1, iCount do
        if (sName == aFeatures[i][eID_FeatureName]) then
            return aFeatures[i]
        end
    end

    return nil
end

-----------------
-- Init
ATOMFeatures.GetFeatureFriendlyName = function(self, sName)

    local aFeature = self:GetFeature(sName)
    if (not aFeature) then
        return nil
    end
    return aFeature[eID_FeatureNameFriendly]
end

-----------------
-- Init
ATOMFeatures.GetFeatureStatus = function(self, sName)

    local aFeature = self:GetFeature(sName)
    if (not aFeature) then
        return nil
    end
    return aFeature[eID_FeatureStatus]
end

-----------------
-- Init
ATOMFeatures.GetFeatureProperty = function(self, sName, iPropertyIndex)

    local aFeature = self:GetFeature(sName)
    if (not aFeature) then
        return nil
    end
    return aFeature[iPropertyIndex]
end

-----------------
ATOMFeatures:Init()


