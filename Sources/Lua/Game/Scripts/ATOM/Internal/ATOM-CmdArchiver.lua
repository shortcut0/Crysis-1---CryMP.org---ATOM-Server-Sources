--------------------------------------------------
-- ATOM Features Plugin

-----------------
ATOMArchive = {

    aArchived   = {

        {
            "test12234",
            "server",
            atommath:Get("timestamp"),
            "Command",
            false,
            "NewValue"
        }

    },
    --[[ {
        "Name", -- name of the command
        "userId", -- id of the user who archived this command
        iTimestamp, -- timestamp of the date this command has been archived
        "type", -- the type of the archived object
        bTemporary, -- indicator saying that this is a temporary archive (resets on server reload)
        "value"
        ...
    } --]]

}

-----------------

eID_ArchiveName = 1
eID_ArchiveUser = 2
eID_ArchiveDate = 3
eID_ArchiveType = 4
eID_ArchiveTemporary = 5
eID_ArchiveValue = 6
eID_ArchiveOriginalValue = 7

-----------------
-- Init
ATOMArchive.Init = function(self)

    ------
  --  SysLog("ATOMArchive:Init()")

    ------
    g_archive = self
    ATOM:SetAfterInit("g_archive.PostInit", "g_archive")
    ATOM:AutoSaveFile("g_archive.SaveFile", "g_archive")

    ------
    self:LoadFile()
end

-----------------
-- Init
ATOMArchive.PostInit = function(self)

    ------
    --SysLog("ATOMArchive:PostInit()")

    ------
    self:SyncArchive()
end

-----------------
-- Init
ATOMArchive.Reset = function(self)
    self.aArchived = {}

    self:SaveFile()
    self:LoadFile()
end

-----------------
-- Init
ATOMArchive.LoadFile = function(self)
    LoadFile("ATOMArchive", "Archive.lua")
end

-----------------
-- Init
ATOMArchive.SaveFile = function(self)

    local aSave = {}
    for i = 1, table.count(self.aArchived) do
        if (self.aArchived[i][eID_ArchiveTemporary] == true) then
        else
            table.insert(aSave, self.aArchived[i])
        end
    end
    SaveFile("ATOMArchive", "Archive.lua", "g_archive:LoadArchived", aSave)
end

-----------------
-- Init
ATOMArchive.ArchiveCommand = function(self, sCommand, hPlayer, sReason)

end

-----------------
-- Init
ATOMArchive.DeleteArchive = function(self, iIndex, bRestoreOriginal)

    local aObject = self.aArchived[iIndex]
    if (bRestoreOriginal) then
        if (aObject[eID_ArchiveType] == "Command") then
            self:RestoreCommand(aObject, aObject[eID_ArchiveName])
        end
    end

    table.remove(self.aArchived, iIndex)
    self:SaveFile()

end

-----------------
-- Init
ATOMArchive.ArchiveObject = function(self, sType, sName, idValue, hPlayer, sReason, sUpdateMessage)

    if (not self:IsValidType(sType)) then
        return false, "unknown archive format"
    end

    local idNewValue, sNewMsg = self:FixValueForType(sType, idValue)
    if (idNewValue) then
        idValue = idNewValue
    end

    if (sNewMsg) then
        sUpdateMessage = sNewMsg
    end

    local bOk, sError = self:IsTypeOk(sType, sName, idValue)
    if (not bOk) then
        return false, sError
    end

    local aArchived = self:GetArchived(sType, sName, false)
    local iArchived = self:GetArchived(sType, sName, true)
    if (not idValue) then
        if (not aArchived) then
            return false, "archive does not exist"
        end

        self:DeleteArchive(iArchived, true)
        if (hPlayer) then
            SendMsg(CHAT_ARCHIVE, hPlayer, "((%s)%s: Removed from the Archive (Reload the Server for changes to take Effect))", sType, string.upper(sName))
        end
        ATOMLog:LogUser(ARCHIVE, "Object (%s) %s Was Removed from the Archive", sType, sName)
        self:SaveFile()
        self:SyncArchive()

        return true
    end

    if (aArchived) then
        self.aArchived[iArchived][eID_ArchiveValue] = idValue
        if (hPlayer) then
            SendMsg(CHAT_ARCHIVE, hPlayer, "((%s)%s: Value was Updated %s)", sType, string.upper(sName), checkString(sUpdateMessage,""))
            self.aArchived[iArchived][eID_ArchiveUser] = hPlayer:GetIdentifier()
        end
        ATOMLog:LogUser(ARCHIVE, "Value of Archived Object (%s) %s Was Changed (%s, %s)", sType, sName, type(idValue), tostring(idValue))
        self:SaveFile()
        self:SyncArchive()
        return true
    end

    if (hPlayer) then
        SendMsg(CHAT_ARCHIVE, hPlayer, "((%s)%s: Was Added to the Archive)", sType, string.upper(sName), checkString(sUpdateMessage,""))
    end
    ATOMLog:LogUser(ARCHIVE, "Added new Object (%s) %s to Archive (%s, %s)", sType, sName, type(idValue), tostring(idValue))

    local aNewObject = {}
    aNewObject[eID_ArchiveName] = sName
    aNewObject[eID_ArchiveType] = sType
    aNewObject[eID_ArchiveUser] = (hPlayer and hPlayer:GetIdentifier() or nil)
    aNewObject[eID_ArchiveDate] = atommath:Get("timestamp")
    aNewObject[eID_ArchiveValue] = idValue
    aNewObject[eID_ArchiveTemporary] = false

    self:AddToArchive(aNewObject)
    self:SyncArchive()
    self:SaveFile()
    return true
end

-----------------
-- Init
ATOMArchive.GetArchive = function(self)
    return self.aArchived
end

-----------------
-- Init
ATOMArchive.SyncArchive = function(self)
    self:UpdateCommands()
end

-----------------
-- Init
ATOMArchive.UpdateCommands = function(self)

    for i, aObject in pairs(self.aArchived) do
        if (aObject[eID_ArchiveType] == "Command") then

            local sName = aObject[eID_ArchiveName]
            local aCommand = ATOMCommands:GetCommand(sName)
            if (aCommand) then
                aObject[eID_ArchiveOriginalValue] = aCommand[7]
                ATOMCommands.Commands[string.lower(sName)][2] = aObject[eID_ArchiveValue]
            else
                self:LogError("Attempt to update a non-existing command from the archive (%s)", sName)
            end

           -- SysLog("Patched Command %s", sName)
        end
    end

end

-----------------
-- Init
ATOMArchive.RestoreCommand = function(self, aObject, sName)
    local aCommand = ATOMCommands:GetCommand(sName)
    if (aCommand) then
        ATOMCommands.Commands[string.lower(sName)][2] = aObject[eID_ArchiveOriginalValue]
    else
        self:LogError("Attempt to update a non-existing command from the archive (%s)", sName)
    end
end

-----------------
-- Init
ATOMArchive.IsValidType = function(self, sType)
    return (string.matchex(sType, "Command"))
end

-----------------
-- Init
ATOMArchive.IsTypeOk = function(self, sType, sName, idValue)

    if (sType == "Command") then
        if (not ATOMCommands:GetCommand(sName)) then
            return false, "Command to Archive not found"
        end

        if (idValue == nil or string.empty(idValue)) then
            return true
        end

        if (not IsUserGroup(idValue) or idValue ~= ARCHIVE) then
            return false, "Usergroup must be ARCHIVE"
        end
    end

    return true

end

-----------------
-- Init
ATOMArchive.FixValueForType = function(self, sType, idValue)

    if (idValue == nil or string.empty(idValue)) then
        return idValue
    end

    if (sType == "Command") then
        return ARCHIVE, "Usergroup Archive"
    end

    return idValue

end


-----------------
-- Init
ATOMArchive.GetArchived = function(self, sType, sName, bReturnIndex)

    local aArchived = self.aArchived
    if (table.count(aArchived) == 0) then
        return nil
    end

    for i, aObject in pairs(aArchived) do
        if (aObject[eID_ArchiveType] == sType and aObject[eID_ArchiveName] == sName) then
            if (bReturnIndex) then
                return i
            end
            return aObject
        end
    end

    return nil
end

-----------------
-- Init
ATOMArchive.AddToArchive = function(self, aArchivedInfo)

    local sName = aArchivedInfo[eID_ArchiveName]
    local sType = aArchivedInfo[eID_ArchiveType]
    local idValue = aArchivedInfo[eID_ArchiveValue]
    local idUser = aArchivedInfo[eID_ArchiveUser]
    local iTimestamp = aArchivedInfo[eID_ArchiveDate]

    if (string.empty(sName)) then
        return false, self:LogError("Attempt to add new object to archive with an invalid name (%s)", tostring(sName))
    end

    if (string.empty(sType) or not self:IsValidType(sType)) then
        return false, self:LogError("Attempt to add new object to archive with an invalid type (%s)", tostring(sType))
    end

    if (idValue == nil) then
        return false, self:LogError("Attempt to add new object to archive with an invalid value (%s)", tostring(idValue))
    end

    if (iTimestamp == nil) then
        self:LogError("Adding new object to archive with an invalid date (%s)", tostring(iTimestamp))
    end

    if (idUser == nil) then
        self:LogError("Adding new object to archive with an invalid user (%s)", tostring(idUser))
    end

    if (self:GetArchived(sType, sName)) then
        return false, self:LogError("Attempt to add an already existing object to the archive (%s, %s)", tostring(sName), tostring(sType))
    end

    local aNewObject = {}
    aNewObject[eID_ArchiveName] = sName
    aNewObject[eID_ArchiveType] = sType
    aNewObject[eID_ArchiveUser] = idUser
    aNewObject[eID_ArchiveDate] = iTimestamp
    aNewObject[eID_ArchiveValue] = idValue
    aNewObject[eID_ArchiveTemporary] = false

    table.insert(self.aArchived, aNewObject)
end

-----------------
-- Init
ATOMArchive.LoadArchived = function(self, ...)

    local aArchivedInfo = { ... }
    if (isArray(aArchivedInfo) and isArray(aArchivedInfo[1])) then
        aArchivedInfo = aArchivedInfo[1]
    end

    if (not isArray(aArchivedInfo)) then
        return SysLog("Invalid parameters to LoadArchived() (%s)", tostring(aArchivedInfo))
    end

    local sType = aArchivedInfo[eID_ArchiveType]
    if (sType ~= "Command") then
        return SysLog("Invalid archive type to LoadArchived()")
    end

    self:AddToArchive(aArchivedInfo)

    --SysLog("Loaded Server Archive Object (%s)", aArchivedInfo[eID_ArchiveName])
end

-----------------
-- Init
ATOMArchive.LogError = function(self, sMessage, ...)
    SysLog("[Archiver] %s", string.formatex(sMessage, ...))
end

-----------------
ATOMArchive:Init()


