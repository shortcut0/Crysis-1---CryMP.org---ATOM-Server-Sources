ATOM_Utils = {};
if (DEBUG_MESSAGES == nil) then
	--DEBUG_MESSAGES = true; -- not for release server
end;

----------------------------------------------------------
--
-- prints a debug message
--
----------------------------------------------------------

ATOM_Utils.Debug = function(...)

	if (not DEBUG_MESSAGES) then
		return
	end

	local all = { ... };
	local new = {};
	for i, p in pairs(all or{}) do
		if (isVec(p)) then
			new[ arrSize(new) + 1 ] = Vec2Str(p);
		elseif (isTable(p)) then
			new[ arrSize(new) + 1 ] = DebugTable(p, nil, true, i);
			--table.remove(all, i);
		else
			new[ arrSize(new) + 1 ] = tostr(p);
		end;
	end;
	local message = tableConcat(new, " ");
	if (_LASTMESSAGE and _LASTMESSAGE[1] == System.GetFrameTime() and _LASTMESSAGE[2] == message) then
		_STACK = (_STACK or 0) + 1;
	else
		_STACK = nil;
	end;
	if (_STACK and _STACK >= 30) then
		System.LogAlways(string.format("<ATOM> ERROR : Stopped stack overflow from message %s", message));
		return false;
	end;
	_LASTMESSAGE = { System.GetFrameTime(), message };
	if (SendMsg and DEBUG_MESSAGES) then
		ATOMLog:LogDebug(ADMINISTRATOR, message)
		SendMsg(CHAT_DEBUG, GetPlayers(ADMINISTRATOR), message);
	end;
	SysLog("<DEBUG> : " .. message);
	SysLogVerb(4, "<DEBUG> Came From %s", debug.traceback())
end;


----------------------------------------------------------
--
-- prints contend of a table
--
----------------------------------------------------------

ATOM_Utils.DebugTable = function(t, off, returnAsString, tname)
	
	if (tostring(t) == LAST_DEBUGGED_TABLE) then
		TDB_OVERFLOW = (TDB_OVERFLOW or 0) + 1;
		if (TDB_OVERFLOW > 10) then
			System.LogAlways(string.format("Stopped table debugging overflow. (%d, %s)",TDB_OVERFLOW, tostr(t)));
			return;
		end;
	else
		TDB_OVERFLOW = 0;
	end;
	LAST_DEBUGGED_TABLE = tostring(t);
	local off = off or " ";
	local r = "";
	if (not returnAsString) then
		SysLog((tostr(tname or t)) .. " = { ");
	else
		r = (tostr(tname or t)) .. " = { ";
	end;
	for i, v in pairs(totable(t)) do
		if (type(v) == "table") then
			if (not returnAsString) then
				DebugTable(v, off .. off, nil, i);
			else
				r = r .. DebugTable(v, nil, true, i);
			end;
		else
			if (not returnAsString) then
				SysLog(off .. tostr(i) .. " = " .. tostr(v) .. ";");
			else
				r = r .. tostr(i) .. " = " .. tostr(v) .. ";"
			end;
		end;
	end;
	if (not returnAsString) then
		SysLog("};");
	else
		return r;
	end;
	
end;


----------------------------------------------------------
--
-- logs a message to the console
--
----------------------------------------------------------

-- ATOM_Utils.LogAlways = function(t, ...)
	-- if (...) then
		-- return System.LogAlways("<ATOM> : " .. string.format(tostr(t), ...));
	-- else
		-- return System.LogAlways("<ATOM> : " .. tostr(t));
	-- end;
-- end;

ATOM_Utils.LogAlways = function(...)
	ATOM_SysLog(...)
end;

----------------------------------------------------------
--
-- logs a message to the console
--
----------------------------------------------------------

ATOM_Utils.LogAlwaysWithVerbosity = function(iVerbosity, ...)
	local iVerb = (System.GetCVar("log_verbosity") or ATOMLog and ATOMLog.verb or 0);
	if (iVerb >= iVerbosity) then
		ATOM_SysLog(...)
	end
end


----------------------------------------------------------
--
-- logs a message to the console
--
----------------------------------------------------------

ATOM_Utils.ByteSuffix = function(iBytes, iNullCount, bNoSuffix)

	local aSuffixes = { "bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "HB", "BB" }
	local iIndex = 1
	while iBytes > 1023 and iIndex <= 10 do
		iBytes = iBytes / 1024
		iIndex = iIndex + 1
	end
	
	if (not iNullCount) then
		if (iIndex == 1) then iNullCount = 0 else
			iNullCount = 2
		end
	end
	
	local sBytes = string.format(string.format("%%0.%df%%s", iNullCount), iBytes, ((not bNoSuffix) and (" " .. aSuffixes[iIndex]) or ""))
	return sBytes
end;


----------------------------------------------------------
--
-- converts t to a table
--
----------------------------------------------------------

ATOM_Utils.ToTable = function(t)
	if (not t or type(t) ~= "table") then
		return {};
	end;
	return t;
end;


----------------------------------------------------------
--
-- returns true if vector is a valid vector
--
----------------------------------------------------------

ATOM_Utils.IsVector = function(vector)
	return (type(vector) == 'table' and vector.x and isInt(vector.x) and vector.y and isInt(vector.y) and vector.z and isInt(vector.z) and arrSize(vector) == 3);
end;


----------------------------------------------------------
--
-- creates a vector out of vecto, y and z
--
----------------------------------------------------------

ATOM_Utils.MakeVector = function(vector, y, z)
	if (type(vector) == "table") then
		if (vector.GetPos) then
			return vector:GetPos();
		elseif (vector.x and vector.y and vector.z) then
			return toVec(vector.x, vector.y, vector.z);
		end;
	elseif (vector and y and z) then
		return toVec(vector, y, z);
	elseif (type(vector) == "string") then
		local x, y, z = vector:match("{ x = (%d+), y = (%d+), z = (%d+) }");
		if (x and y and z) then
			return toVec(x, y, z);
		end;
	end;
	return toVec(vector, y, z);
end;


----------------------------------------------------------
--
-- converts x, y and z to a vector
--
----------------------------------------------------------

ATOM_Utils.ToVector = function(x, y, z)
	return { x = tonum(x), y = tonum(y), z = tonum(z) };
end;


----------------------------------------------------------
--
-- Returns true if 'integer' is an integer
--
----------------------------------------------------------

ATOM_Utils.IsInteger = function(integer)
	return type(integer) == "number";
end;

----------------------------------------------------------
--
-- censors a string
--
----------------------------------------------------------

ATOM_Utils.Censor = function(str, star)
	return string.rep((star or "*"), string.len(tostr(str)));
end;

----------------------------------------------------------
--
-- returns the size of the array
--
----------------------------------------------------------

ATOM_Utils.GetArraySize = function(array)

	if (table.count) then
		return (table.count(array)) end

	-- if (type(array)~="table") then
		-- if (type(array)=="string") then
			-- return #array;
		-- end;
		-- SysLog("Error: .GetArraySize, attempt to get size of non table " .. tostring(array));
		-- SysLog(" traceback: %s", debug.traceback() or "<failed>");
	-- end;
	-- local s = #array;
	-- if (s == 0) then
		-- local s1 = 0;
		-- for i, v in pairs(array) do
			-- s1 = s1 + 1;
		-- end;
		-- if (s < s1) then
			-- s = s1;
		-- end;
	-- end;
	-- return s;
end;

----------------------------------------------------------
--
-- formats number to a number
--
----------------------------------------------------------

ATOM_Utils.ToNumber = function(number, orThis)
	if (not number) then
		return orThis or 0;
	end;
	return (tonumber(number) or 0);
end;

----------------------------------------------------------
--
-- formats str to a string
--
----------------------------------------------------------

ATOM_Utils.ToString = function(str, orThis)
	if (str == nil) then
		return orThis or "nil";
	end;
	return tostring(str);
end;

-- merges two tables

ATOM_Utils.Merge = function(inPlace, a, b)
	a, b = totable(a), totable(b);
	if (inPlace) then
		for i, v in pairs(b) do
			if (not a[i] or a[i]~=v) then
				a[i] = v;
			end;
		end;
	else
		local done = {};
		local new = copyTable(a);	
		for i, v in pairs(b) do
			if (not new[i] or (new[i]~=v or type(v) == "table")) then
				new[i] = v;
			end;
		end;
		return new;
	end;
end;

-- Also merges subtables

ATOM_Utils.MergePro = function(a, b)
	a, b = totable(a), totable(b);
	local done = {};
	local new = copyTable(a);	
	for i, v in pairs(b) do
		if (not new[i] or (type(v) ~= "table" and new[i] ~= v)) then
			new[i] = v;
			--Debug("MERGNG KEY >>", i)
		elseif (type(v) == "table") then
			--Debug("MERGING >> ",i)
			new[i] = mergeTables_(new[i], v);
		end;
	end;
	return new;
end;

----------------------------------------------------------
--
-- merges two tables
--
----------------------------------------------------------

ATOM_Utils.CopyTable = function(a)

	local copied = {};
	for key, value in pairs(totable(a)) do
		copied[key] = value;
	end;
	return copied;
end;


----------------------------------------------------------
--
-- formats a string if possible
--
----------------------------------------------------------

ATOM_Utils.FormatString = function(str, ...)
	if (...) then
		return string.format(tostr(str), ...)
	else
		return tostr(str)
	end
end;



----------------------------------------------------------
--
-- formates a string if possible
--
----------------------------------------------------------

ATOM_Utils.CleanString = function(str, pattern, sub)
	return string.gsub(tostr(str), pattern, (sub or ""));
end;


ATOM_Utils.GetPlayers = function(access, notRights, exeptThis)
	local players = {};
	---	SysLog("???")
	for i, player in pairs(g_game:GetPlayers()or System.GetEntitiesByClass("Player")or{}) do
		if (player.actor:IsPlayer()) then
			--Debug(player.GetAccess,"acces=",player:GetAccess(),"str=",player:GetAccessString())
			if (not access or (player.GetAccess and ((notRights and player:GetAccess() <= access) or (not notRights and player:GetAccess() >= access)))) then
				--if (not onlyAlive or (player.IsAlive and player:IsAlive())) then
				if (not exeptThis or (exeptThis and player.id ~= exeptThis)) then
					if (not g_localActor or player~=g_localActor) then
						table.insert(players, player);
					end;
				end;
				--end;
			end;
		end;
	end;
	return players;
end;


ATOM_Utils.GetPlayersInRange = function(pos, range, exeptThis, teamId, alive)
	local players = {};
	---	SysLog("???")
	for i, player in pairs(g_game:GetPlayers()or System.GetEntitiesByClass("Player")or{}) do
		if (player.actor:IsPlayer()) then
			--Debug(player.GetAccess,"acces=",player:GetAccess(),"str=",player:GetAccessString())
			if (GetDistance(player,pos)<range) then
				if (not alive or (player.IsAlive and player:IsAlive())) then
					if (not exeptThis or (exeptThis and player.id ~= exeptThis)) then
						if (not teamId or (sameTeam(player.id,teamId))) then
							if (not g_localActor or player~=g_localActor) then
								table.insert(players, player);
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	return players;
end;


ATOM_Utils.GetTeamName = function(iTeam)
	local aTeams = {
		[0] = "Neutral",
		[1] = "NK",
		[2] = "US"
	}
	return (aTeams[iTeam] or "Neutral")
end;


ATOM_Utils.GetVehicles = function()
	local aVehicles = {};
	for i, hEntity in pairs(System.GetEntities()) do
        --SysLog(tostring(hEntity.vehicle~=nil))
		if (hEntity.vehicle ~= nil) then
			table.insert(aVehicles, hEntity)
		end
	end
	return aVehicles
end;



ATOM_Utils.DoGetPlayers = function(aParams)
	local aPlayers = {}
	local aOthers = {}
	
	----------
	local aEntities = g_game:GetPlayers() or {}
	if (aParams and aParams.AllActors) then
		aEntities = System.GetEntitiesByClass("Player") or {}
	end
	
	for i, player in pairs(aEntities) do
	
		local ok = true
		if (aParams) then
			if (aParams.teamId) then
				if (g_gameRules.class == "InstantAction" or aParams.sameTeam) then
					ok = ok and (g_game:GetTeam(player.id) == aParams.teamId) else
					ok = ok and (g_game:GetTeam(player.id) ~= aParams.teamId) end
			end
			
			if (aParams.pos and aParams.range) then
				ok = ok and (GetDistance(player, aParams.pos) < aParams.range) end
			
			if (aParams.except) then
				ok = ok and (player.id ~= aParams.except) end
			
			if (aParams.access and player.HasAccess) then
				ok = ok and (player:HasAccess(aParams.access)) end
				
			if (aParams.OnlyDead) then
				ok = ok and (player.actor:GetHealth() <= 0) end
				
			if (aParams.OnlyAlive) then
				ok = ok and (player.actor:GetHealth() > 0) end
		end

		----------
		if (ok) then
			aPlayers[#aPlayers+1] = player
			else
				aOthers[#aOthers+1] = aOthers end
	end
	
	----------
	if (aParams and aParams.others) then
		return aPlayers, aOthers end
	
	----------
	return aPlayers
end;


ATOM_Utils.GetPlayersByTeam = function(iTeam, bOtherTeam)
	
	----------
	local aPlayers = {}
	
	----------
	for i, hPlayer in pairs(GetPlayers()) do
		local bOk = g_game:GetTeam(hPlayer.id) == iTeam
		if (bOtherTeam) then
			bOk = (not bOk) end
		
		----------
		if (bOk) then
			table.insert(aPlayers, hPlayer) end
	end
	
	----------
	return aPlayers
end;

ATOM_Utils.ReplaceString = function(a, b, replacer)
	local str, len = b, a;
	if (type(str) == "number" and type(len) == "string") then
		local temp = len;
		len = str;
		str = temp;
	end;
	str = tostr(str);
	len = tonum(len);
	if (len and str) then
		return string.rep((replacer or " "), len - strLen(subColor(str)));
	end;
end;


ATOM_Utils.GetStringLength = function(str)
	return string.len(tostr(str));
end;


ATOM_Utils.IsTable = function(t)

	----------
	if (isArray) then
		return isArray(t) end
	
	----------
	return (t and type(t) == "table")
end

ATOM_Utils.TableConcat = function(t, between)
	local s = "";
	local f = false;
	for i, v in pairs(t or{}) do
		s = s .. (f and (between and tostr(between) or " ") or "") .. tostr(v);
		f = true;
	end;
	return s;
end;


ATOM_Utils.ToBoolean = function(anyValue)
	local t = type(anyValue);
	if (t == "number") then
		return (anyValue<=0 and false or true);
	elseif (t == "string") then
		return (anyValue:lower()=="false" and false or true);
	elseif (t == "boolean") then
		return (anyValue==false and false or true);
	end;
	return false;
end;

ATOM_Utils.BooleanToString = function(b, r)
	local yes, no = (r and unpack(r) or unpack{"true","false"});
	return toboolean(b) and yes or no;
end;

ATOM_Utils.GetFileSize = function(f)

	do
		return fileutils.size(f) end

	local f = tostr(f);
	local file, err = io.open(f, "r");
	if (file) then
		size = file:seek("end");
		file:close();
	else
		ATOMLog:LogError("Failed to load file %s", f);
		size = nil;
	end;
	return size;
end;


LOADED_FILES = LOADED_FILES or {};
ATOM_Utils.LoadFile = function(object, name, loadOnce, forceGlobalPath, createIfMissing)

	local path = ((forceGlobalPath or ATOM.cfg.GlobalData) and ATOM.GloablFileDir or ATOM.LocalFileDir);
		
	local filePath = path .. "/" .. name;
	--SysLog("filePath %s",filePath)
	--[[if (loadOnce and LOADED_FILES[object] and LOADED_FILES[object] == getFileSize(filePath)) then
		return false, "unchanged file already loaded";
	else
		LOADED_FILES[object] = nil;
	end;--]]
	
	--System.LogAlways("ATOM : Load File: " .. filePath .. ", " .. tostring(object) .. ", " .. tostring(name))
	
	local file, error = io.open(filePath, "r+");--(createIfMissing and "w+" or "r+")
	if (not file) then
	--	System.LogAlways("ATOM : File not found or error reading, " .. tostring(error));
	--	Debug("Missing.")
		file, error = io.open(filePath, "w+");
		if (file) then
			file:close();
		end;
		--SysLog("attempt to load empty file  %s", filePath)
		return false;--, "empty file";
	end;
	if (file) then
		--for line in file:lines() do
		--	System.LogAlways(line)
		--end;
		--LOADED_FILES[object] = file:seek("end");
		--local success, error = pcall(function() loadstring(file:read("*all"))(); end);
		local c = file:read("*all");
		file:close();
		
		
	--	System.LogAlways("ATOM : Reading file contend: " .. tostr(c));
		local s,e=pcall(loadstring, c);
		if (not s) then
			if (ATOMLog) then
				ATOMLog:LogError("[1] Failed to load file %s (%s)", filePath, tostring(e));
			end;
			SysLog("[1] Failed to load file %s (%s)", filePath, tostring(e));
			loadstring(c)();
		else
			 s,e=pcall(e);
			 if (not s or e) then
				if (ATOMLog) then
					ATOMLog:LogError("[2] Failed to read file %s (%s)", filePath, e);
				end;
				SysLog("[2] Failed to read file %s (%s)", filePath, e);
			end;
		end;
		--Debug(success,error)
		
		--[[if (not success and error) then
			return false, ATOMLog:LogError(error or "Failed to read file " .. filePath);
		else
			Debug("success",success,"error",error)
			return true;
		end;--]]
		return true;
	else
		return false, ((not createIfMissing and not tostr(error):find("No such")) and ATOMLog:LogError("Failed to open file %s, %s", name, error) or nil);
	end;
end;


ATOM_Utils.SaveFile = function(object, name, loadFunc, ...)

	local path = ((forceGlobalPath or ATOM.cfg.GlobalData) and ATOM.GloablFileDir or ATOM.LocalFileDir);
	local filePath = path .. "/" .. name;


	local file, error = io.open(filePath, "w+");--(createIfMissing and "w+" or "r+")
	--if (not file) then
	--	file, error = io.open(filePath, "w");
	--	file:close();
	--	return false, "empty file";
	--end;
	if (file) then

		local str = "";
		local tmp = {};
		for i, dataPack in pairs({...}) do
			for j, v in pairs(dataPack) do
		--		Debug(" :D")
				str = loadFunc .. "(" .. unpackT(v) .. ");\n";
				file:write(str);
			end;
		end;
		
		file:close();
		
		return true;
	else
		return false, ATOMLog:LogError("Failed to open file %s, %s", name, error);
	end;
end;


ATOM_Utils.SaveFileWithArray = function(object, name, loadFunc, ...)

	local path = ((forceGlobalPath or ATOM.cfg.GlobalData) and ATOM.GloablFileDir or ATOM.LocalFileDir);
	local filePath = path .. "/" .. name;


	file, error = io.open(filePath, "w+");--(createIfMissing and "w+" or "r+")
	--if (not file) then
	--	file, error = io.open(filePath, "w");
	--	file:close();
	--	return false, "empty file";
	--end;
	if (file) then

		local str = "";
		local tmp = {};
		for i, dataPack in pairs({...}) do
			for j, v in pairs(dataPack) do
				str = loadFunc .. "(" .. unpackA(v) .. ");\n";
				file:write(str);
			end;
		end;
		
		file:close();
		
		return true;
	else
		return false, ATOMLog:LogError("Failed to open file %s, %s", name, error);
	end;
end;


ATOM_Utils.SaveFile_Array = function(object, name, what, data)

	local path = ((forceGlobalPath or ATOM.cfg.GlobalData) and ATOM.GloablFileDir or ATOM.LocalFileDir);
	local filePath = path .. "/" .. name;


	file, error = io.open(filePath, "w+");--(createIfMissing and "w+" or "r+")
	--if (not file) then
	--	file, error = io.open(filePath, "w");
	--	file:close();
	--	return false, "empty file";
	--end;
	if (file) then

		file:write(arr2str(data, what));
		
		file:close();
		
		return true;
	else
		return false, ATOMLog:LogError("Failed to open file %s, %s", name, error);
	end;
end;

ATOM_Utils.ArrToString = function(arr, stp, off)
	if (not off) then off=""; end
	if (not stp) then stp=""; end
	local t="";
	t=off..stp.." = {\n";
	for i,v in _pairs(arr) do
		local val=tostring(v);
		if (type(v)=="string") then
			val="\""..v:gsub("[\"]","\\\"").."\"";
		elseif type(v)=="number" and v>100000 then val = string.format("%d", v); end
		local ival=tostring(i);
		if (type(i)=="string") then
			ival="\""..i:gsub("[\"]","\\\"").."\"";
		end
		if (type(v)=="table") then
			t=t..arr2str(v,"["..ival.."]",off.."\t");
		else
			t=t..(off.."\t["..ival.."] = "..val)..";\n";
		end
	end
	t=t..off.."};\n";
	return t;
end;

ATOM_Utils.ArrToString2 = function(arr,stp, off)
	local t="";
	--Debug("FUCK!!!!",stp)
	t=(off or "")..(stp and stp.."="or"").."{";
	--Debug("FUCK!!!!",t)
	--Debug((stp and stp.."="or""))
	
	if (not off) then off=""; end
	if (not stp) then stp=""; end
	for i,v in _pairs(arr) do
		local val=tostring(v);
		if (type(v)=="string") then
			val="\""..v:gsub("[\"]","\\\"").."\"";
		elseif type(v)=="number" and v>100000 then val = string.format("%d", v); end
		local ival=tostring(i);
		if (type(i)=="string") then
			ival=""..i:gsub("[\"]","\\\"").."";
		end
		if (type(v)=="table") then
			t=t..arr2str(v,ival,off.."");
		else
			t=t..(off..ival.."="..val)..";";
		end
	end
	t=t..off.."}";
	return t;
end;

function _pairs(arr)
	local c1=#arr;
	for i,v in pairs(arr) do c1=c1-1; end
	if c1==0 then return ipairs(arr); else return pairs(arr); end
end;
	
ATOM_Utils.UnpackTable = function(t)
	local s = "";
	local c = 0;
	local tc = arrSize(t);
	for i = 1, tc do
		local v = t[i];
		c = c + 1;
		if (type(v) == "number") then
			s = s .. (v > 1000000 and string.format("%d", v) or v);
		elseif (type(v) == "string") then
		--	Debug("Str:"..v)
			s = s .. "\"" .. v .. "\"";
		elseif (type(v) == "table") then
		--	Debug("INDEX:",getIndexName(t, i))
			s = s .. "{ " .. unpackT(v) .. " }";
		elseif (type(v) == "boolean") then
			s = s .. tostring(v);
		elseif (type(v) == "nil") then
			s = s .. "nil";
		end;
		if (c ~= tc) then
			s = s .. ", "
		end;
	end;
	return s;
end;
	
ATOM_Utils.UnpackArray = function(t, isFirstTable)
	local s = [[]];
	local c = 0;
	local tc = arrSize(t);
	local isFirstTable = isFirstTable;
	if (isFirstTable == nil) then
		isFirstTable = 1;
	end;
	local id;
	--Debug("isFirstTable",isFirstTable)
	for i, v in pairs(t) do-- = 1, tc do
		--local v = t[i];
		c = c + 1;
		id = (isFirstTable == 2 and '[' .. (type(i)=="string" and '"'or'') .. i .. (type(i)=="string" and '"'or'')..'] = ' or '') ;
		if (type(v) == "number") then
		--	Debug((type(i)=="number" and ""or"\""))
			s = s .. id .. (v > 1000000 and string.format('%d', v) or v);
		elseif (type(v) == "string") then
		--	Debug("Str:"..v)
			s = s .. id .. '"' .. v .. '"';
		elseif (type(v) == "table") then
		--	Debug("INDEX:",getIndexName(t, i))
		--	Debug(isFirstTable)
			s = s .. id .. "{ " .. unpackA(v, 2) .. " }";
		elseif (type(v) == "boolean") then
			s = s .. id .. tostring(v);
		elseif (not v or type(v) == "nil") then
			s = s .. id .. "nil";
		end;
		if (c ~= tc) then
			s = s .. [[, ]]
		end;
	end;
	return s;
end;
	
ATOM_Utils.UnpackArrayB = function(t, isFirstTable)
	local s = [[]];
	local c = 0;
	local tc = arrSize(t);
	local isFirstTable = isFirstTable;
	if (isFirstTable == nil) then
		isFirstTable = 1;
	end;
	--Debug("isFirstTable",isFirstTable)
	for i, v in pairs(t) do-- = 1, tc do
		--local v = t[i];
		c = c + 1;
		if (type(v) == "number") then
		--	Debug((type(i)=="number" and ""or"\""))
			s = s .. (isFirstTable == 2 and "[" .. (type(i)=="string" and "\""or"") .. i .. (type(i)=="string" and "\""or"").."] = " or "") .. (v > 1000000 and string.format("%d", v) or v);
		elseif (type(v) == "string") then
		--	Debug("Str:"..v)
			s = s .. (isFirstTable == 2 and "[\"" .. (type(i)=="string" and "\""or"") .. i .. (type(i)=="string" and "\""or"") .. "\"] = " or "") .. "\"" .. v .. "\"";
		elseif (type(v) == "table") then
		--	Debug("INDEX:",getIndexName(t, i))
		--	Debug(isFirstTable)
			s = s .. (isFirstTable == 2 and "[\"" .. (type(i)=="string" and "\""or"") .. i .. (type(i)=="string" and "\""or"") .. "\"] = " or "") .. "{ " .. unpackA(v, 2) .. " }";
		elseif (type(v) == "boolean") then
			s = s .. (isFirstTable == 2 and "[\"" .. (type(i)=="string" and "\""or"") .. i .. (type(i)=="string" and "\""or"") .. "\"] = " or "") .. tostring(v);
		elseif (type(v) == "nil") then
			s = s .. (isFirstTable == 2 and "[\"" .. (type(i)=="string" and "\""or"") .. i .. (type(i)=="string" and "\""or"") .. "\"] = " or "") .. "nil";
		end;
		if (c ~= tc) then
			s = s .. [[, ]]
		end;
	end;
	return s;
end;

ATOM_Utils.GetTableIndexName = function(t, id)
	local c = 0;
	for i, v in pairs(t) do
		c = c + 1;
		if (c == id) then
			return i;
		end;
	end;
	return;
end;

ATOM_Utils.GetEntity = function(id)
	local t = type(id);
	if (t == "userdata") then
		return System.GetEntity(id)
		
	elseif (t == "string") then
		return System.GetEntityByName(id)
		
	else
		return id
	end
end

ATOM_Utils.GetObjectFromString = function(objectName)
	local object = "";
	if (not string.find(objectName, "%.")) then
		return _G[objectName];
	end;
	local parts = {};
	for part in string.gmatch(objectName, "[^.]*") do
		--SysLog(part)
		if (#part > 0) then
			parts[ #parts+1 ] = part;
		end;
	end;
	object = "return _G." .. table.concat(parts, ".");
	--Debug("NOT SINGLE name, it's " .. object);
	return loadstring(object)();
end;

ATOM_Utils.CalculateTime = function(total_seconds, bAddSuffix, s, m, h, d, sColor)

	--------
	do
		local sTime = SimpleCalcTime(tonumber(total_seconds)) 
		if (sColor) then
			sTime = string.gsubex(sTime, { ":", "," }, "$9{%~1}" .. sColor) end
			
		if (not bAddSuffix) then
			sTime = string.gsubex(sTime, { "c", "y", "d", "h", "s", "m" }, "") end
			
		return sTime
	end

	--------
	local total_seconds = tonum(total_seconds);

	--------
	local floor, mod = math.floor, math.mod;
	
	--------
	local time_years	= 0
	local time_days		= 0
	local time_hours	= 0
	local time_minutes	= 0
	local time_seconds	= 0
	local time_millisec	= 0
	
	--------
	time_days		= floor(total_seconds / 86400)
	time_hours		= floor(mod(total_seconds, 86400) / 3600)
	time_minutes	= floor(mod(total_seconds, 3600) / 60)
	time_seconds	= floor(mod(total_seconds, 60))

	--------
	local ms = mod(total_seconds, 60) * 1000;
	if ( ms < 1000 ) then
		time_millisec	= floor(mod(ms, 1000));
	end;
	time_millisec = tonum(tostr(time_millisec):sub(1, 2));
	
	
	--------
	if (time_days < 10) then
		time_days = "0" .. time_days
	end;
	if (time_hours < 10) then
		time_hours = "0" .. time_hours
	end;
	if (time_minutes < 10) then
		time_minutes = "0" .. time_minutes
	end;
	if (time_seconds < 10) then
		time_seconds = "0" .. time_seconds
	end;
	if (time_millisec < 10) then
		time_millisec = "0" .. time_millisec;
	end;
	
	--------
	local str = (d and (time_days .. (withI and "d" or"") .. ":") or "") .. (h and time_hours.. (withI and "h" or"") .. ":" or "") .. (m and time_minutes.. (withI and "m" or"") .. ":" or "") .. time_seconds.. (withI and "s" or"") .. (tonum(time_millisec)>0 and (":" .. time_millisec .. (withI and "ms" or"")) or "");
	if (withColor) then
		str = withColor .. str:gsub(":", "$9:" .. withColor);
	end;
	return str
end;

ATOM_Utils.AddToDate = function(total_seconds)

	local add = parseTime(total_seconds);
	local now = os.time();

	return os.date("%c", now + add);
	
end;

ATOM_Utils.CalculateTimestamps = function(t1, t2)
	
	return tonum(ATOMDLL:CalculateTimestamps(t1, t2));

end;


ATOM_Utils.ConvertDateToTable = function(date1)

	local mo, d, y, h, m, s = date1:match("(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)");
	return { year = y+2000, month = mo, day = d, hour = h, min = m, sec = s }
end;


ATOM_Utils.ConvertTableToDate = function(datetable)

	return formatString("%d/%d/%d %d:%d:%d", datetable.year+(datetable.year<2000 and 2000 or 0),datetable.month,datetable.day,datetable.hour,(datetable.minute or datetable.min),(datetable.sec or 0))
end;

ATOM_Utils.ToDate = function(timestamp, dt)
	--local timestamp = tonumber(timestamp)
	
    local day_count, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(tonumber(math_div(timestamp,86400)))

    while days >= day_count(year) do
        days = days - day_count(year) year = year + 1;
    end;
    local tab_overflow = function(seed, table)
		for i = 1, #table do
			if seed - table[i] <= 0 then
				return i, seed;
			end
			seed = seed - table[i];
		end;
	end;
    month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
    
	local hours, minutes, seconds = math.floor(timestamp / 3600 % 24), math.floor(timestamp / 60 % 60), math.floor(timestamp % 60)
    
	local period = hours > 12 and "pm" or "am"
    hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours;
	
    local finished_date = formatString("%d/%d/%04d %02d:%02d:%02d", days, month, year, hours, minutes, seconds);
	if (dt) then
		finished_date = formatString(finished_date .. " %s", period);
	end;
	return finished_date;

end;


ATOM_Utils.MakeCapital = function(str)
	local str = tostr(str):lower();
	if (str and str:sub(1, 1)) then
		str = str:sub(1, 1):upper() .. str:sub(2);
	end;
	return str;
end


ATOM_Utils.CutNumber = function(num, len)
	--local a, b = tostr(num):match("([%d]*)%.([%d]*)");
	--if (not a and not b) then
	--	return num;
	--end;
	--return a .. "." .. b:sub(1, (len or 1));
	return formatString(formatString("%%0.%df", (len or 2)), num);
end;


ATOM_Utils.FormatNumber = function(num, cutLen, distance)
	local fmt = "";
	local cutLen = cutLen or 1;
	local num_end = num;
	if (distance) then
		num = num * 100; -- format m to cm
		local km = ((num / 100) / 1000);
		--[[if (km > 100000000000000) then
			--Debug("THOUSAND KM");
			fmt = "Q km";
			num_end = cutNum(km / 1000000000000000, cutLen);
		elseif (km > 100000000000) then
			--Debug("THOUSAND KM");
			fmt = "T km";
			num_end = cutNum(km / 1000000000000, cutLen);
		elseif (km > 100000000) then
			--Debug("THOUSAND KM");
			fmt = "B km";
			num_end = cutNum(km / 1000000000, cutLen);
		elseif (km > 100000) then
			--Debug("THOUSAND KM");
			fmt = "M km";
			num_end = cutNum(km / 1000000, cutLen);
		elseif (km > 1000) then
			--Debug("THOUSAND KM");
			fmt = "k km";
			num_end = cutNum(km / 1000, cutLen);
		else--]]if (num > 10000) then
			fmt = "km";
			num_end = cutNum(num / 100000, cutLen);
		elseif (num > 10) then
			fmt = "m";
			num_end = cutNum(num / 100, cutLen);
		elseif (num > 1) then
			fmt = "cm"
			num_end = cutNum(num, cutLen);
		else
			fmt = "mm";
			num_end = cutNum(num * 10, cutLen);
		end;
	else
		if (num > 500000000000000) then
			fmt = "Q";
			num_end = cutNum(num / 1000000000000000, cutLen);
		elseif (num > 500000000000) then
			fmt = "T";
			num_end = cutNum(num / 1000000000000, cutLen);
		elseif (num > 500000000) then
			fmt = "B";
			num_end = cutNum(num / 1000000000, cutLen);
		elseif (num > 500000) then
			fmt = "m";
			num_end = cutNum(num / 1000000, cutLen);
		elseif (num > 1000) then
			fmt = "k";
			num_end = cutNum(num / 1000, cutLen);
		else
			num_end = cutNum(num, cutLen);
		end;
	end;
	return num_end .. fmt;
end;


ATOM_Utils.CountTableValues = function(t)
	local v = 0;
	for i, val in pairs(t) do
		v = v + tonum(val);
	end;
	return v;
end;


ATOM_Utils.GetAverage = function(t)
	return countValue(t) / arrSize(t);
end;

----------------------------------------------------------
--
-- by default, cleans string from all cryptic characters
--
----------------------------------------------------------

ATOM_Utils.UTF8Clean = function(str, pattern)
	local newStr = "";
	local cleanPattern = pattern or "[a-zA-Z0-9_'{}\"%(%) %*&%%%$#@!%?/\\;:,%.<>%-%[%]%+]";
	for i = 1, string.len(str) do
		local s = string.sub(str, i, i);
		if (s and s:match(cleanPattern)) then
			newStr = newStr .. s;
		end;
	end;
	return newStr;
end;

----------------------------------------------------------
--
-- by default, cleans string from all normal characters-
-- and returns cryptic mess
--
----------------------------------------------------------

ATOM_Utils.GetCryptFromString = function(str, pattern)
	local newStr = "";
	local cleanPattern = pattern or "[a-zA-Z0-9_'{}\"%(%) %*&%%%$#@!%?/\\;:,%.<>%-%[%]%+]";
	for i = 1, string.len(str) do
		local s = string.sub(str, i, i);
		if (s and not s:match(cleanPattern)) then
			newStr = newStr .. s;
		end;
	end;
	return newStr;
end;


ATOM_Utils.EmptyString = function(str)
	if (not str or string.gsub(tostr(str), " ","")=="") then
		return true;
	end;
	return false;
end;



ATOM_Utils.SystemCommand = function(str)
	System.ExecuteCommand(str);
end;

ATOM_Utils.GetLongestStringFromTable = function(t, i)
	local longest = 0;
	for index, str in pairs(t) do
		if (i == 0 ) then 
			if (string.len(tostring(index)) > longest) then
				longest = string.len(tostring(index));
			end;
		elseif (i == -1 ) then 
			if (string.len(tostring(str)) > longest) then
				longest = string.len(tostring(str));
			end;
		else
			if (string.len(tostring(str[i])) > longest) then
				longest = string.len(tostring(str[i]));
			end;
		end;
	end;
	return longest;
end;


ATOM_Utils.ParseTime = function(s, stringVal)
	local math_add, math_mul = math_add, math_mul;
	if (not s) then
		return nil;
	end;
	local parts = {};
	if (tonumber(s) ~= nil) then
		if (tonumber(s) >= 1000000) then
			return math_add(tostr(s), 0)
		end;
		return tonumber(s);
	end;
	s:gsub("([0-9]+)([smhdoyin]+)", function(num, unit)
		parts[unit] = tonumber(num);
		Debug("unit",unit, "=",num)
	end);
	local y, mo, d, h, m, s = (parts.y or 0), (parts.mo or 0), (parts.d or 0), (parts.h or 0), (parts.m or parts.min or 0), (parts.s or 0);
	local dur = s + m*60 + h*3600 + d * 86400 + mo * 86400 * 30 + y * 86400*365;
	if (stringVal) then
		local _a, _b, _c, _d, _mo, _y = s, math_mul(m, 60), math_mul(h, 3600), math_mul(d, 86400), math_mul(math_mul(mo, 86400), 30), math_mul(math_mul(y, 86400), 365);
		dur = _a+ _b+ _c+ _d+ _mo+ _y; --math_add(_a, math_add(_b, math_add(_c, math_add(_d, math_add(_mo, _y)))));
	end;
	if (tostr(dur)=="0") then
		dur = s + m*60 + h*3600 + d * 86400 + mo * 86400 * 30 + y * 86400*365
	end;
	--Debug("dur",dur)
	return dur;
end;


ATOM_Utils.TimeToString = function(timestamp)

	local t = Int:ToTime(timestamp);
	return string.format("%d/%d/%d | %02d:%02d", t.year, t.month, t.day, t.hour, t.minute);

end;


ATOM_Utils.GetDistance = function(a, b, noX, noY, noZ)
	local p1, p2;
	if (isVec(a)) then
		p1 = copyTable(a);
	elseif (a and a.id) then
		p1 = a:GetPos();
	end;
	
	if (isVec(b)) then
		p2 = copyTable(b);
	elseif (b and b.id) then
		p2 = b:GetPos();
	end;
	
	if (p1 and p2) then
		local xD, yD, zD = p1.x - p2.x, p1.y - p2.y, p1.z - p2.z;
		local distance = math.sqrt((not noX and xD*xD or 0) + (not noY and yD*yD or 0) + (not noZ and zD*zD or 0));
		return distance;
	end;
	return;
end;

ATOM_Utils.SendSpace = function(len, s)
	return string.rep((s or " "), len);
end;

ATOM_Utils.MakeNumberEven = function(n)
	local n=n>0 and math.floor(n) or math.ceil(n);
	local isEven = n%2==0;
	if (isEven) then
		return n;
	end;
	return n+1;
end;

ATOM_Utils.CalcPosition = function(pos, dir, distance, height)

	local newPos = copyTable(pos);
	local newDir = copyTable(dir);
	
	newPos.x = newPos.x + (newDir.x * distance) - newDir.x;
	newPos.y = newPos.y + (newDir.y * distance) - newDir.y;
	newPos.z = newPos.z + (newDir.z * distance) - newDir.z;
	
	return newPos, newDir;
end;

ATOM_Utils.CalcSpawnPosition = function(player, distance, height)

	if (not System.GetEntity(player.id)) then
		SysLog("Actor to CalcSpawnPos was not found (%s)", tostring(player))
		return vector.make(0,0,0),vector.make(0,0,0)
	end

	local pos = copyTable(player:GetBonePos("Bip01 head"));
	local dir = copyTable(player:GetBoneDir("Bip01 head"));
	distance = distance or 5;
	height = height or 1;
	pos.z = pos.z + height;
	ScaleVectorInPlace(dir, distance);
	FastSumVectors(pos, pos, dir);
	dir = player:GetDirectionVector(1);
	
	return pos, dir;
	
end;

ATOM_Utils.AddToVector = function(vec1, vec2)

	local a = makeVec(vec1)
	local b = makeVec(vec2);
	
	return { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z };
end;

ATOM_Utils.GetDirectionVector = function(vVec1, vVec2, fMuliplier, bNormalize)

	local a = makeVec(vVec1)
	local b = makeVec(vVec2);
	
	local dir = subVec(a, b);
	if (fMuliplier) then
		--Debug(dir)
		dir = vecScale(dir, fMuliplier);
		--Debug(dir)
	end;
	
	if (bNormalize) then
		NormalizeVector(dir);
	end;
	
	return dir;
end;

ATOM_Utils.SubVectors = function(vVec1, vVec2)

	local a = makeVec(vVec1)
	local b = makeVec(vVec2);
	
	return { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z };
end;

ATOM_Utils.GetAngles = function(vVec1, vVec2)

	local a = makeVec(vVec1)
	local b = makeVec(vVec2);
	
	local dx, dy, dz = b.x - a.x, b.y - a.y, b.z - a.z;
	local dst = math.sqrt(dx*dx + dy*dy + dz*dz);
	local vec = {
		x = math.atan2(dz, dst),
		y = 0,
		z = math.atan2(-dx, dy)
	};
	
	return vec;
end;

ATOM_Utils.WithinAngles = function(dir1, dir2)

	local Dot = function(a, b)
		return a.x * b.x + a.y * b.y + a.z * b.z;
	end;
	
	local Angle = function(a, b)
		local dt = Dot(a, b)
		local ad = math.sqrt(Dot(a, a)) * math.sqrt(Dot(b, b))
		return math.acos(dt / ad) * 180 / math.pi;
	end;
	
	return Angle(dir1, dir2)
end;

ATOM_Utils.IsPointVisible = function(dir1, dir2, fov)
	return ATOM_Utils.WithinAngles(dir1, dir2) < (fov or System.GetCVar("cl_fov"));
end;

ATOM_Utils.CanSeePosition = function(a, b, fov)
	local d1, d2 = a, b;
	if (not isVec(d1)) then
		d1 = GetDir(a:GetPos(), b:GetPos(), 1);
	end;
	if (not isVec(d2)) then
		d2 = GetDir(a:GetPos(), b:GetPos(), 1);
	end;
	
	return ATOM_Utils.IsPointVisible(d1, d2, fov);
end;

ATOM_Utils.GetAnglesFromDir = function(vDir1)

	local a = makeVec(vDir1)
	--local b = makeVec(vVec2);
	
	local dx, dy, dz = a.x,a.y, a.z; --b.x - a.x, b.y - a.y, b.z - a.z;
	local dst = math.sqrt(dx*dx + dy*dy + dz*dz);
	local vec = {
		x = math.atan2(dz, dst),
		y = 0,
		z = math.atan2(-dx, dy)
	};
	
	return vec;
end;

ATOM_Utils.IsPlayerAlone = function(player, range, alive)

	local pos = player:GetPos();
	local entities = System.GetPhysicalEntitiesInBox(pos, (range or 25));
	if (arrSize(entities) <= 1) then
		return true;
	end;
	
	for i, entity in pairs(entities) do
		if (entity.isPlayer and entity.id ~= player.id) then
			if (not alive or not (entity:IsSpectating() and entity:IsDead())) then
				return false;
			end;
		end;
	end;
	
	return true;
end;

ATOM_Utils.GetClosestEntity = function(class, pos, rad)

	if (not ATOMGameUtils:ValidEntityClass(class)) then
		return;
	end;

	local rad = tonum(rad or 100000);
	local closest;
	for i, entity in pairs(System.GetEntitiesByClass(class)) do
		local dist = getDistance(entity, pos);
		if (dist < rad) then
			rad = dist;
			closest = entity;
		end;
	end;
	return closest;
end;


ATOM_Utils.DirZ2Ang = function(v)

	local dir = makeVec(v);
	
	local angles = {
		x = 0,
		y = 0,
		z = (dir.z / 57.18897142457728) * 2 --1.57373 + 1.57373 ---90/57.18897142457728
	};
	
	return angles

end;


ATOM_Utils.CreateHit = function(entity, damage, shooter)

	local entId = type(entity) == "userdata" and entity or entity.id;
	local shooterId = shooter and (type(shooter) == "userdata" and shooter or shooter.id) or entId;
	

	g_gameRules:CreateHit(entId, shooterId, shooterId, (damage or 25), nil, nil, nil, "normal");

end;


ATOM_Utils.IsSamePlayer = function(player1, player2)

	return not player2 or player2==player1;

end;


ATOM_Utils.GetTerrainElevation = function(pos)

	return System.GetTerrainElevation(pos)

end;



ATOM_Utils.GetWaterElevation = function(pos)

	local iZWater = CryAction.GetWaterInfo(pos)
	return iZWater or -9999

end;


ATOM_Utils.IsUnderground = function(pos)

	local iTerrainZ = ATOM_Utils.GetTerrainElevation(pos)
	return ((pos.z < iTerrainZ))
end;

ATOM_Utils.IsUnderwater = function(pos)

	local iWaterZ = ATOM_Utils.GetWaterElevation(pos)
	return ((pos.z < iWaterZ))
end;

ATOM_Utils.SpawnGUINew = function(props)
	local modelName, position, fMass, scale, dir, noPhys, bStatic, viewDistance, particleEffect, ang, vdir = 
	props.Model, 
	props.Pos,
	props.Mass,
	props.Scale,
	props.Dir,
	props.NoPhys,
	props.Static,
	props.ViewDist,
	props.Effect,
	props.Ang,
	props.VDir
	
	return SpawnGUI(modelName, position, fMass, scale, dir, noPhys, bStatic, viewDistance, particleEffect, ang, vdir)
end;

ATOM_Utils.SpawnGUI = function(modelName, position, fMass, scale, dir, noPhys, bStatic, viewDistance, particleEffect, ang, vdir)
	if (not GUI) then
		Script.ReloadScript("Scripts/Entities/Others/GUI.lua");
	end;
	
	GUI.Properties.objModel = modelName;
	GUI.Properties.bStatic = (bStatic or 0);
	GUI.Properties.fMass = (fMass or 35);
	
	local entityName = tostring(modelName) .. "|"..tostring(bStatic or 0).."+"..tostring(fMass or 35).."+"..tostring(viewDistance or 150).."|"..tostring(particleEffect or "").."|"..tostring(ATOMGameUtils:SpawnCounter());
	
	local spawned = AddEntity({ nosetup = true, network = true, class = "GUI", position = position, orientation = dir, fMass = tonumber(fMass) or -1, name = entityName });
	
	if (ang) then
		spawned:SetAngles(makeVec(ang));
	end;
	
	if (vdir) then
		spawned:SetDirectionVector(vdir);
	end;
	
	if (spawned and scale and scale>0) then
		spawned:SetScale(scale);
	end;
	
	if (spawned and not noPhys) then
		SetPhysParams(spawned, { Mass = fMass }, true)
		g_utils:AwakeEntity(spawned)
	elseif (noPhys) then
		spawned:AwakePhysics(0);
	end;
	return spawned;
end;

ATOM_Utils.SpawnGUILimit = function(sModel, ...)

	if (not ATOM_Utils.GUI_ENTITIES_SPAWNED) then
		ATOM_Utils.GUI_ENTITIES_SPAWNED = {}
		ATOM_Utils.LAST_GUI_SPAWN = {}
		ATOM_Utils.LAST_SPAWNED_GUI = {}
	end

	--if (not ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel]) then
	--	ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel]
	--end

	--SysLog(timerdiff((ATOM_Utils.LAST_GUI_SPAWN[sModel] or 0)))
	if (not timerexpired(ATOM_Utils.LAST_GUI_SPAWN[sModel], 0.1)) then
		--if ((ATOM_Utils.GUI_ENTITIES_SPAWNED or 0) >= 8) then

			if (timerexpired(LAST_GUI_SPAWN_LOG, 0.3)) then
				LAST_GUI_SPAWN_LOG = timerinit()
				SysLog("[Warning] Too many GUIs spawning ( %d )", ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel])

			end
			if (timerexpired(LAST_GUI_SPAWN_LOG_CONSOLE, 1)) then
				LAST_GUI_SPAWN_LOG_CONSOLE = timerinit()
				ATOMLog:LogWarning("Too many GUI Entities spawning ( %d )", ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel])
			end
			--ATOM_Utils.LAST_GUI_SPAWN = timerinit()
			ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel] = (ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel] or 0) + 1
			return ATOM_Utils.LAST_SPAWNED_GUI[sModel]
		--end

		--SysLog(aSpawnParams.name)
	else
		ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel] = 0
		ATOM_Utils.LAST_GUI_SPAWN[sModel] = timerinit()
	end

	local hGUI = SpawnGUI(sModel, ...)
	ATOM_Utils.LAST_SPAWNED_GUI[sModel] = hGUI
	ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel] = (ATOM_Utils.GUI_ENTITIES_SPAWNED[sModel] or 0) + 1
	return hGUI
end;

ATOM_Utils.SpawnBSE = function(props)

	--local modelName, bStatic, fMass, fDistance, particleEffect, garbage = self:GetName():match("(.*)|(.*)+(.*)+(.*)|(.*)|(.*)");
	local modelName, bHasPhys, fMass, fDistance, particleEffect, position, dir = 
	props.Model,
	props.bHasPhys,
	props.Mass,
	props.ViewDist,
	props.Effect,
	props.Pos or props.Position,
	props.Dir;

	local entityName = tostring(modelName) .. "|"..tostring(bHasPhys or 1).."+"..tostring(fMass or 35).."+"..tostring(viewDistance or 150).."|"..tostring(particleEffect or "").."|"..tostring(ATOMGameUtils:SpawnCounter());
	local spawned = AddEntity({ nosetup = true, network = false, class = "BasicEntity", position = position, orientation = dir, fMass = tonumber(fMass) or -1, name = entityName });
	
	return spawned;
end;

ATOM_Utils.SpawnCAP = function(modelName, position, fMass, scale, dir, noPhys, bStatic, viewDistance, particleEffect, ang, vdir)
	--if (not GUI) then
	--	Script.ReloadScript("Scripts/Entities/Others/GUI.lua");
	--end;
	
	CustomAmmoPickupLarge.Properties.objModel = modelName;
	CustomAmmoPickupLarge.Properties.bStatic = (bStatic or 0);
	CustomAmmoPickupLarge.Properties.fMass = (fMass or 35);
	
	local entityName = tostring(modelName) .. "|x|x|x|x" .. g_gameRules.Utils:SpawnCounter();-- .. "|"..tostring(bStatic or 0).."+"..tostring(fMass or 35).."+"..tostring(viewDistance or 150).."|"..tostring(particleEffect or "").."|"..tostring(ATOMGameUtils:SpawnCounter());
	
	local spawned = AddEntity({ network = false, class = "CustomAmmoPickupLarge", position = position, dir = dir, fMass = tonumber(fMass) or -1, name = entityName, properties = { bPhysics = not noPhys and 1 or 0 } });
	
	if (ang) then
		spawned:SetAngles(makeVec(ang));
	end;
	
	if (vdir) then
		spawned:SetDirectionVector(vdir);
	end;
	
	if (spawned and scale and scale>0) then
		spawned:SetScale(scale);
	end;
	
	if (spawned and not noPhys) then
	--	SetPhysParams(spawned, { Mass = fMass }, true);
	--	spawned:AwakePhysics(1);
	elseif (noPhys) then
	--	spawned:AwakePhysics(0);
	end;
	

	--[[spawned.OnHit = function(self, hit)
		ATOMItem_OnHit(self, hit);
	end;
	
	if (spawned.Server ) then
		spawned.Server.OnHit = function(self, hit)
			ATOMItem_OnHit(self, hit);
		end;
	end;--]]
	
	return spawned;
end;



ATOM_Utils.RECENT_EXPLOSIONS = {}
ATOM_Utils.SpawnExplosion = function(effect, pos, radius, damage, dir, s, w, scale)

	if (not effect) then
		return false, "invalid effect"
	end

	--if (not ATOM_Utils.RECENT_EXPLOSIONS[effect]) then
	--	ATOM_Utils.RECENT_EXPLOSIONS[effect] = timerinit()
	--end

	--if (not timerexpired(ATOM_Utils.RECENT_EXPLOSIONS[effect], 0.1)) then
	--	return SysLog("Explosions with effect %s are spamming", effect)
	--end

	--ATOM_Utils.RECENT_EXPLOSIONS[effect] = timerinit()

	local pos = pos or toVec(0,0,0)
	local dir = dir or toVec(0,0,1)
	local scale = scale or 1
	local radius = radius or 1
	local damage = damage or 1
	local shooterId, weaponId = NULL_ENTITY, NULL_ENTITY;
	if (s and s.id and GetEnt(s.id)) then
		shooterId = s.id
	end;
	if (w and w.id and GetEnt(w.id)) then
		weaponId = w.id
	end

	g_gameRules:CreateExplosion(shooterId, weaponId, damage, pos, dir, radius, 45, radius, radius, effect, scale, radius, radius/2, radius/2);
end;


ATOM_Utils.SetMinium = function(num, min)

	if (num<min) then
		return min;
	else
		return num;
	end;

end;


ATOM_Utils.SetMaximum = function(num, max)

	if (num>max) then
		return max;
	else
		return num;
	end;

end;

ATOM_Utils.InInventory = function(player, id)
	for i, v in pairs(player.inventory:GetInventoryTable()or{}) do
		if (v==id) then
			return true;
		end;
	end;
end;

ATOM_Utils.SetPhysicalParams = function(entity, props, Buoyancy)
	
	local PhysicsParams = {
		bRigidBody = 1,
		bRigidBodyActive = 1,
		bResting = 1,
		Density = -1,
		Mass = 100,
     	Buoyancy=
		{
			water_density = 1000,
			water_damping = 0,
			water_resistance = 1000,	
		},
		bStaticInDX9Multiplayer = 0,
	};

	if (props.Mass) then
		PhysicsParams.Mass = tonumber(props.Mass)
	end;
	if (props.Density) then
		PhysicsParams.Density = tonumber(props.Density)
	end;

	EntityCommon.PhysicalizeRigid( entity, -1, PhysicsParams, 1 );
	if (Buoyancy) then
		entity:SetPhysicParams(PHYSICPARAM_BUOYANCY, PhysicsParams.Buoyancy);
	end;
end;


ATOM_Utils.RemovePlayerFromTable = function(players, playerId)

	local new = players;
	for i, v in pairs(players) do
		if (v == playerId or (type(v) == "table" and v.id == playerId)) then
			table.remove(new, i);
		end;
	end;
	return new;
	
end;


ATOM_Utils.GetFirstTableEntry = function(x)

	for i, v in pairs(x) do
		return v;
	end;
	
end;


ATOM_Utils.RoundNumber = function(x)

	return (x>0 and math.floor(x+0.5) or math.ceil(x-0.5));
	
end;


ATOM_Utils.GetRandom = function(x,y)

	if (type(x) == "number") then
		if (y and type(y)=="number") then
			return math.random(x, y);
		end;
		return math.random(x);
	end;
	-- Debug("X",x)
	local t = math.random(0, arrSize(x));
	local c = 0;
	for i, v in pairs(x) do
		c = c + 1;
		if (c == t) then
	--		Debug("Ok")
			return v;
		end;
	end;
	return x[math.random(arrSize(x))]
end;


ATOM_Utils.PlaySound = function(sound, pos, volume)

	if (not ATOM_Utils.SPAWNED_SOUND_TABLE) then
		ATOM_Utils.SPAWNED_SOUND_TABLE = {}
	end

	if (not timerexpired(ATOM_Utils.SPAWNED_SOUND_TABLE[string.lower(sound)], 0.085)) then
		return
	end

	local spawned = AddEntity({ network = false, class = "CustomAmmoPickupLarge", position = pos, dir = g_Vectors.up, fMass = -1, name = "x|"..sound.."+" .. (volume or "x") .. "|x|x|" .. g_utils:SpawnCounter(), properties = { objModel = "", bPhysics = 0 } });
	ATOM_Utils.SPAWNED_SOUND_TABLE[string.lower(sound)] = timerinit()

	Script.SetTimer(10000, function()
		System.RemoveEntity(spawned.id);
	end)
		
end;


ATOM_Utils.PlaySoundOnPlayer = function(player, sound, pos, volume)

	ExecuteOnPlayer(player, [[
		g_localActor:PlaySoundEvent("]]..sound..[[", g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT)
	]])
	
		
end;


ATOM_Utils.GetAttachments = function(item, str)

	local all = item.weapon:GetAttachedAccessories();
	if (str) then
		local s = "";
		for i, v in pairs(all) do
			s=s..(not emptyString(s) and "," or "")..GetEnt(v).class;
		end;
		return s
	end;
	return all;
		
end;


ATOM_Utils.Minimum = function(x, y)

	if (y < x) then
		y = x
	end;
	return y;
		
end;


ATOM_Utils.Maximum = function(x, y)

	if (y > x) then
		y = x
	end;
	return y;
		
end;


ATOM_Utils.Countdown = function(player, steps, delay, func)

	for i = 1, steps do
		Script.SetTimer(i * delay * 1000, function()
			func(player, steps - i, i == steps);
		end);
	end;
end;


ATOM_Utils.GetPlayerByProfileID = function(x)

	local players = GetPlayers();
	for i, player in pairs(players) do
		if (tostring(player:GetProfile()) == tostring(x)) then
			return player
		end;
	end;
	return nil;
end;


ATOM_Utils.RayHit = function(pos, dir, dist, id, types)

	local dist = dist or 4086;
	local entities = types or ent_all;
	local dir = dir or g_Vectors.up;
	local hits = Physics.RayWorldIntersection(pos, vecScale(dir, dist), dist, entities, id or NULL_ENTITY, nil, g_HitTable);
	local hit = g_HitTable[1];
	if (hits and hits > 0) then
		hit.surfaceName = System.GetSurfaceTypeNameById( hit.surface )
		return hit;
	end;
	return;
end;


ATOM_Utils.ConvertToMB = function(bytes, autoConv, cut)

	if (autoConv) then
		local GB = bytes / ONE_GB;
		local MB = bytes / ONE_MB;
		local KB = bytes / ONE_KB;
		
		local S, M;
		
		if (GB >= 1) then
			S = GB;
			M = "GB";
		elseif (MB >= 1) then
			S = MB;
			M = "MB";
		elseif (KB >= 1) then
			S = KB;
			M = "KB";
		else
			S = bytes;
			M = "B";
		end;
		
		return (cut and formatString("%s%0.2f", (S<10 and"0"or""), S) or S) .. M;
	else
		return bytes / ONE_MB;
	end;
end;


ATOM_Utils.SameTeam = function(id1, id2)
	return g_game:GetTeam(id1) == (type(id2)=="number" and id2 or g_game:GetTeam(id2)) and g_gameRules.class ~= "InstantAction";
end;


ATOM_Utils.NullVector = function(v, y, z)
	if (type(v)=="number") then
		return tonum(v)==0 and tonum(y)==0 and tonum(z)==0;
	end;
	return v.x==0 and v.y==0 and v.z==0;
end;


ATOM_Utils.GetBuildingName = function(building)
	local sType = "Shortcuts Villa";
	local sName = building:GetName():lower()
	
	if (building.class == "SpawnGroup") then
		if ((building.Properties.teamName == "tan" or building.Properties.teamName == "black") and not building.Properties.bCaptureable) then
			sType = "Base"
		else
			sType = "Bunker"
		end
	elseif (building.Properties.buyOptions.bPrototypes == 1) then
		sType = "Prototype Factory"
	elseif (sName:find("air")) then
		sType = "Aviation Factory"
	elseif (sName:find("naval")) then
		sType = "Naval Factory"
	elseif (sName:find("small")) then
		sType = "Small Vehicle Factory"
	else
		sType = "War Factory"
	end;
	return sType
end;



----------------------------------------------------------
--
-- exposes the utility functions
--
----------------------------------------------------------

ATOM_Utils.HookFunctions = function(self)
	
	if (System.GetCVar("atom_aisystem")==1) then
		AI_ENABLED = true;
		AI_OLD = AI_OLD or {};
		
		for _, _f in pairs(AI or {}) do
			if (not AI_OLD[_]) then
				AI_OLD[_]=_f
			end;
			AI[_]=function(...)
				if (System.GetCVar("log_verbosity")>=3) then
					--SysLog("AI.%s",tostring(_));
					local _DEBUG={...}
					if (_DEBUG) then
						local _R=_DEBUG[1];
						if (_R) then
							if (type(_R)=="userdata") then
								--SysLog("  (%s=%s)", tostring(_R),System.GetEntity(_R):GetName()or"NULL")
							end;
						end;
						if (_=="Animation") then
							SysLog("AI.Animation(%s,%s,%s)",tostr(_DEBUG[1]),tostr(_DEBUG[2]),tostr(_DEBUG[3]))
						end;
					end;
					local x=_DEBUG[1]
					if (x and type(x)=="userdata") then
						local y=System.GetEntity(x);
						if (y) then
							if (_=="EnableWeaponAccessory") then	
								SysLog("Request update")
								--ATOMAI:Update()
							end;
						end;
					end;
				end;
				if (_=="ResetParameters") then
					SysLog("AI.ResetParameters!!");
				--	ATOMDLL:SetServer(false)
				end;
				--ATOMDLL:SetClient(true)
				ATOMDLL:SetMultiplayer(false)
				return AI_OLD[_](...)--, ATOMDLL:SetServer(true),ATOMDLL:SetMultiplayer(true),ATOMDLL:SetClient(false);
			end;
		end;
	end;
	

	-- ******************************************************
	
	if (not OLD_ENVIRONMENT) then
		OLD_ENVIRONMENT = {
			-- System
			["System_LogAlways"] 	= System.LogAlways;
			["System_SpawnEntity"] 	= System.SpawnEntity;
			["System_GetCVar"] 		= System.GetCVar;
			["System_SetCVar"] 		= System.SetCVar;
			["System_Quit"] 		= System.Quit;
			
			-- Game Rules
			["g_gameRules_game_ServerExplosion"] 		= g_gameRules.game.ServerExplosion;
			["g_gameRules_game_SetSynchedEntityValue"] 	= g_gameRules.game.SetSynchedEntityValue;
		};
	end;

	--------------------------------------------
	if (false) then
		g_gameRules.game.SetSynchedEntityValue = function(...)
			local x = { ... };
			if (x) then
				local t_str = "";
				local e;
				for i, v in pairs(x) do
					e = nil;
					if (type(v)=="userdata") then
						e=GetEnt(v) and GetEnt(v):GetName() or tostring(v)
						if (not GetEnt(v)) then
							--SysLog("[SetSynchedEntityValue] Not Sending, player disconnected.");
							return;
						end;
						if (GetEnt(v) and GetEnt(v).GetChannel) then
							if (not g_gameRules.game:GetPlayerByChannelId(GetEnt(v):GetChannel())) then
								--SysLog("[SetSynchedEntityValue] Not Sending, player disconnected.");
								return;
							end
						end
					elseif (type(v)=="table" and v.GetName) then
						e=v:GetName()
						if (not GetEnt(v.id)) then
							--SysLog("[SetSynchedEntityValue][2] Not Sending, player disconnected.");
							return;
						end;
						if (v and v.GetChannel) then
							if (not g_gameRules.game:GetPlayerByChannelId(v:GetChannel())) then
								--SysLog("[SetSynchedEntityValue] Not Sending, player disconnected.");
								return;
							end
						end
					else
						e=tostring(v)
					end;
					t_str = t_str .. (tostring(i)~="1" and"," or"").."["..tostring(i).."]="..e
				end;
				--SysLogVerb(1, "[SetSynchedEntityValue] : %s", tostring(t_str));
			end
			return OLD_ENVIRONMENT["g_gameRules_game_SetSynchedEntityValue"] (...)--, SysLogVerb(1, "Server crashed, maybe?");
		end;
		--------------------------------------------
		g_gameRules.game.ServerExplosion = function(...)
			local x={...};
			local e
			if (x) then
				local t_str=""
				for i, v in pairs(x) do
					e=nil;
					if (type(v)=="userdata") then
						e=GetEnt(v) and GetEnt(v):GetName() or tostring(v)
					elseif (type(v)=="table" and v.GetName) then
						e=v:GetName()
					else
						e=tostring(v)
					end;
					t_str = t_str .. (tostring(i)~="1" and"," or"").."["..tostring(i).."]="..e
				end;
				--SysLogVerb(1, "[ServerExplosion] : %s", tostring(t_str));
			end
			return OLD_ENVIRONMENT["g_gameRules_game_ServerExplosion"] (...), SysLogVerb(1, "Server crashed, maybe?!");
		end
	end
	--------------------------------------------
	System.LogAlways = function(sMsg, x)
	
		if (x) then
			System.LogAlways(("Too many arguments to System.LogAlways"))
			System.LogAlways((debug.traceback()or string.TBFAILED))
		end
	
		local all = System.GetEntitiesByClass("Player")--(GetPlayers and GetPlayers() or {})
		if (#all > 0) then
			for i, v in pairs(all) do
				if (v.ServerConsole) then
					if (SendMsg ~= nil) then
						SendMsg(CONSOLE, v, "$9<$4SV$9> $9%s", sMsg);
					else
						break
					end
				end
			end
		end
		return OLD_ENVIRONMENT["System_LogAlways"] (sMsg)
	end;
	--------------------------------------------
	System.Quit = function(...)
		if (ATOM) then
			ATOM:Quit() end
			
		local args = {...}
		Script.SetTimer(1, function() -- give scripts some time
			OLD_ENVIRONMENT["System_Quit"] (unpack(args))
		end)
	end;
	--------------------------------------------
	System.SetCVar = function(...)
		--SysLog("SetCVar() from");
		--SysLog("%s", debug.traceback()or"<err>");
		
		local args = { ... }
		return OLD_ENVIRONMENT["System_SetCVar"] (...);
	end;
	--------------------------------------------
	System.GetCVar = function(...)
		local args = {...};
		if (args[1] == "g_painSoundGap") then
			SysLogVerb(3, "!! PAINSOUND GAP GetCVar() from");
			SysLogVerb(3, "%s", debug.traceback()or"<err>");
		end;
		return OLD_ENVIRONMENT["System_GetCVar"] (...);
	end;
	--------------------------------------------
	System.SpawnEntity = function(p, ...)
		-- SysLog("Spawning, %s (with name: %s)", tostring(p), (p and p.name or ""));
		if (ATOM) then
			p = ATOM:CheckEntitySpawnParameters(p) end
		return OLD_ENVIRONMENT["System_SpawnEntity"] (p, ...)
	end;
end;

----------------------------------------------------------
--
-- exposes the utility functions
--
----------------------------------------------------------

ATOM_Utils.ExposeFunctions = function(self)
	
	RANDOM_NUMBER = 0.0102030405060708
	
	self:HookFunctions();
	
	
	GetPlayerByProfileID = self.GetPlayerByProfileID;
	GetAttachments	= self.GetAttachments;
	GetBuildingName	= self.GetBuildingName;
	
	SameTeam	 = self.SameTeam;
	sameTeam	 = self.SameTeam;
	censor		 = self.Censor;
	toMB		 = self.ConvertToMB;
	RayHit		 = self.RayHit;
	minimum		 = self.Minimum;
	Minimum		 = self.Minimum;
	min			 = self.Minimum;
	Maximum		 = self.Maximum;
	maximum		 = self.Maximum;
	max			 = self.Maximum;
	Countdown	 = self.Countdown;
	PlaySound	 = self.PlaySound;
	PlPlaySound	 = self.PlaySoundOnPlayer;
	round		 = self.RoundNumber;
	GetRandom	 = self.GetRandom;
	getFirst	 = self.GetFirstTableEntry;
	RemovePlayer = self.RemovePlayerFromTable;
	InInventory	 = self.InInventory;
	setmax		 = self.SetMaximum;
	setmin		 = self.SetMinium;
	longest		 = self.GetLongestStringFromTable;
	Explosion	 = self.SpawnExplosion;
	SpawnADoor	 = self.SpawnAnimDoor;
	SpawnDoor	 = self.SpawnDoor;
	SpawnGUI	 = self.SpawnGUI;
	SpawnGUILimit= self.SpawnGUILimit;
	SpawnBSE	 = self.SpawnBSE;
	SpawnGUINew	 = self.SpawnGUINew;
	SpawnCAP	 = self.SpawnCAP;
	GetGroundPos = self.GetTerrainElevation;
	GetWaterPos  = self.GetWaterElevation;
	UnderGround  = self.IsUnderground;
	IsUnderwater = self.IsUnderwater;
	samePlayer	 = self.IsSamePlayer;
	HitEntity	 = self.CreateHit;
	IsPlayerAlone= self.IsPlayerAlone;
	GetDistance	 = self.GetDistance;
	GetDir		 = self.GetDirectionVector;
	GetAngles	 = self.GetAngles;
	Dir2Ang		 = self.GetAnglesFromDir;
	DirZ2Ang	 = self.DirZ2Ang;
	subVec		 = self.SubVectors;
	add2Vec		 = self.AddToVector;
	add2vec		 = self.AddToVector;
	CalcPos		 = self.CalcPosition;
	CalcSpawnPos = self.CalcSpawnPosition;
	makeEven	 = self.MakeNumberEven;
	space		 = self.SendSpace;
	getDistance	 = self.GetDistance;
	toDate		 = self.ToDate;
	tableToDate	 = self.ConvertTableToDate;
	dateToTable	 = self.ConvertDateToTable;
	addToDate	 = self.AddToDate;
	timeToStr	 = self.TimeToString;
	parseTime	 = self.ParseTime;
	longestStr	 = self.GetLongestStringFromTable;
	getIndexName = self.GetTableIndexName;
	SysCmd		 = self.SystemCommand;
	emptyString	 = self.EmptyString;
	unpackT		 = self.UnpackTable;
	unpackA		 = self.UnpackArray;
	getAverage	 = self.GetAverage;
	average		 = self.GetAverage;
	countValue	 = self.CountTableValues;
	getCrypt	 = self.GetCryptFromString;
	UTF8Clean	 = self.UTF8Clean;
	cutNum		 = self.CutNumber;
	fmtNum		 = self.FormatNumber;
	isInt		 = self.IsInteger;
	arrSize		 = self.GetArraySize;
	tonum		 = self.ToNumber;
	makeVec		 = self.MakeVector;
	toVec		 = self.ToVector;
	NullVector	 = self.NullVector;
	Debug		 = self.Debug;
	DebugTable	 = self.DebugTable;
	SysLog		 = self.LogAlways;
	SysLogVerb	 = self.LogAlwaysWithVerbosity;
	totable		 = self.ToTable;
	tostr		 = self.ToString;
	formatString = self.FormatString;
	repStr		 = self.ReplaceString;
	withinAngles = self.WithinAngles;
	isPntVisible = self.IsPointVisible;
	canSeePos	 = self.CanSeePosition;

	strLen		 = self.GetStringLength;
	copyTable	 = self.CopyTable;
	isVec		 = self.IsVector;
	isTable		 = self.IsTable;
	
	tableConcat  = self.TableConcat;
	
	toboolean	 = self.ToBoolean;
	boolToStr	 = self.BooleanToString;
	
	GetPlayers	 = self.GetPlayers;
	
	LoadFile	 = self.LoadFile;
	SaveFile	 = self.SaveFile;
	SaveFile_Arr = self.SaveFile_Array;
	SaveFileArr  = self.SaveFileWithArray;
	
	arr2str		 = self.ArrToString;
	arr2str_	 = self.ArrToString2;
	
	getFileSize	 = self.GetFileSize;
	
	calcTime	 = self.CalculateTime;
	
	doError		 = function(...)
		return ATOMLog:LogError(...);
	end;
	
	subColor	 = function(str)
		return self.CleanString(str, "%$%d");
	end;
	cleanString	 = function(str, pattern, sub)
		return self.CleanString(str, pattern, sub);
	end;
	mergeTables	 = function(a, b)
		return self.Merge(false, a, b);
	end;
	mergeTablesInPlace 	= function(a, b)
		return self.Merge(true, a, b);
	end;
	mergeTables_ 	= function(a, b)
		return self.MergePro(a, b);
	end;
	
	GetTeamName			= self.GetTeamName;
	
	GetEnt			   	= self.GetEntity;
	getObject			= self.GetObjectFromString;
	
	makeCapital		   	= self.MakeCapital;
	GetClosestEntity	= self.GetClosestEntity;
	SetPhysParams		= self.SetPhysicalParams;
	GetPlayersInRange	= self.GetPlayersInRange;
	GetPlayersByTeam	= self.GetPlayersByTeam;
	DoGetPlayers		= self.DoGetPlayers;
	
	GetVehicles			= self.GetVehicles;
	
	if (g_gameRules) then
		self:InitLater();
	end;
	
	self:LinkDLLFunctions();
	self:AddThirdPartyFunctions();
	
	SendMsg = function()
		SysLog("SendMsg() Dummy called")
		SysLog(" traceback: %s", debug.traceback()or "<unknown>");
	end;
	
	TRACEBACK_FAILED = "<traceback failed>";
end;


ATOM_Utils.AddThirdPartyFunctions = function(self) -- functions from various authors
	function lerp(a, b, t)
		if type(a) == "table" and type(b) == "table" then
			if a.x and a.y and b.x and b.y then
				if a.z and b.z then return lerp3(a, b, t) end
				return lerp2(a, b, t)
			end
		end
		t = clamp(t, 0, 1)
		return a + t*(b-a)
	end

	function _lerp(a, b, t)
		return a + t*(b-a)
	end

	function lerp2(a, b, t)
		t = clamp(t, 0, 1)
		return { x = _lerp(a.x, b.x, t); y = _lerp(a.y, b.y, t); };
	end

	function lerp3(a, b, t)
		t = clamp(t, 0, 1)
		return { x = _lerp(a.x, b.x, t); y = _lerp(a.y, b.y, t); z = _lerp(a.z, b.z, t); };
	end
	
	
	
	-- ======================================
	-- ByteSuffix
	
	ByteSuffix = function(iBytes, iNullCount, bNoSuffix)

		local aSuffixes = { "bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "HB", "BB" }
		local iIndex = 1
		while iBytes > 1023 and iIndex <= 10 do
			iBytes = iBytes / 1024
			iIndex = iIndex + 1
		end
		
		if (not iNullCount) then
			if (iIndex == 1) then iNullCount = 0 else
				iNullCount = 2
			end
		end
		
		local sBytes = string.format(string.format("%%0.%df%%s", iNullCount), iBytes, ((not bNoSuffix) and (" " .. aSuffixes[iIndex]) or ""))
		return sBytes
	end;

	-- ======================================
	-- __NumFits
	
	__NumFits = function(num, target)
		local f = num / target
		if (target > num or f < 1) then
			return { 0, num }
		end
		local fits = string.gsub(f, "%.(.*)", "")
		local rem = num - (fits * target)
		return { fits, rem }
	end
	
	-- ======================================
	-- CalcTime
	
	function __Prettify_Number(iNumber, iBig, sAppendChar)
	
		local iBig = iBig
		if (iBig == nil) then
			iBig = 10 end
	
		local sAppendChar = sAppendChar
		if (sAppendChar == nil) then
			sAppendChar = "0" end
	
		iNumber = tonumber(iNumber)
	
		if (iNumber < iBig) then
			local iAppend = string.len(iBig) - string.len(iNumber)
			local sAppend = ""
			if (iAppend > 0) then
				sAppend = string.rep(sAppendChar, iAppend)
			end
			iNumber = sAppend .. iNumber
		end
		return iNumber
	end
	
	-- ======================================
	-- CalcTime

	-- ireturnStyle
	-- 	0 = 0d:00h:00m:00s
	-- 	1 = 0d: 00h: 00m: 00s
	-- 	2 = 0d, 00h, 00m, 00s
	--	3 = array where [0] = s, [1] = m, ...

	function SimpleCalcTime(iSeconds, ireturnStyle)
	
		--if (not isNumber(iSeconds)) then
		--	iSeconds = 0
		--end
		local iSeconds = checkNumber(iSeconds, 0)
	
		local ireturnStyle = checkVar(ireturnStyle, 1)
		--if (ireturnStyle == nil) then
		--	ireturnStyle = 1 end
	
		if (iSeconds < 0) then
			return "Infinite"
		elseif (iSeconds < 1) then
			return "0s"
		end

		local s = iSeconds

		local c, y, d, h, m
		local t = { 0, 0 }
		local v = s
		-- ----------------------------
		-- Centuries (100 years)
		t = __NumFits(s, 86400 * 365 * 100)
		c = t[1]
		s = t[2]
		-- ----------------------------
		-- Years
		t = __NumFits(s, 86400 * 365)
		y = t[1]
		s = t[2]
		-- ----------------------------
		-- Days
		t = __NumFits(s, 86400)
		d = t[1]
		s = t[2]
		-- ----------------------------
		-- Hours
		t = __NumFits(s, 3600)
		h = t[1]
		s = t[2]
		-- ----------------------------
		-- Minutes
		t = __NumFits(s, 60)
		m = t[1]
		s = t[2]
		-- ----------------------------
		-- get rid of any numbers behind the decimal point
		t = __NumFits(s, 1)
		s = t[1]
		
		local tn = tonumber

		local res
		if ( ireturnStyle == 0 ) then
			__Prettify_Number(s)
			__Prettify_Number(m)
			__Prettify_Number(h)
			__Prettify_Number(d)
			__Prettify_Number(y)
			__Prettify_Number(c)

			res = s .. "s"
			if (tn(m) > 0 or tn(h) > 0 or tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  m .. "m:" .. res
			end
			if (tn(h) > 0 or tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  h .. "h:" .. res
			end
			if (tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  d .. "d:" .. res
			end
			if (tn(y) > 0 or tn(c) > 0) then
				res =  y .. "y:" .. res
			end
			if (tn(c) > 0) then
				res =  c .. "c:" .. res
			end
		-- --------------------------------------------
		elseif ( ireturnStyle == 1 ) then
			__Prettify_Number(s)
			__Prettify_Number(m)
			__Prettify_Number(h)
			__Prettify_Number(d)
			__Prettify_Number(y)
			__Prettify_Number(c)

			res = s .. "s"
			if (tn(m) > 0 or tn(h) > 0 or tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  m .. "m: " .. res
			end
			if (tn(h) > 0 or tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  h .. "h: " .. res
			end
			if (tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  d .. "d: " .. res
			end
			if (tn(y) > 0 or tn(c) > 0) then
				res =  y .. "y: " .. res
			end
			if (tn(c) > 0) then
				res =  c .. "c: " .. res
			end
		-- --------------------------------------------
		elseif ( ireturnStyle == 2 ) then
			__Prettify_Number(s)
			__Prettify_Number(m)
			__Prettify_Number(h)

			res = s .. "s"
			if (tn(m) > 0 or tn(h) > 0 or tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  m .. "m, " .. res
			end
			if (tn(h) > 0 or tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  h .. "h, " .. res
			end
			if (tn(d) > 0 or tn(y) > 0 or tn(c) > 0) then
				res =  d .. "d, " .. res
			end
			if (tn(y) > 0 or tn(c) > 0) then
				res =  y .. "y, " .. res
			end
			if (tn(c) > 0) then
				res =  c .. "c, " .. res
			end
		-- --------------------------------------------
		elseif ( ireturnStyle == 3 ) then
			res = { s, m, h, d, y, c }

		end
		
		-- ----------------------------
		-- return the calulated time
		return res
	end
end;

ATOM_Utils.InitPlayer = function(player, channelId, ip, hostname, port, id, name, country, countryCode, continent, continentCode)
	
	SysLog("Initializing Player on Slot %d, IP: %s, Host: %s, Port: %d, ID: %s, Name: %s, Country: %s, Continent: %s", channelId,tostr(ip),tostr(hostname),tonum(port),tostr(id),tostr(name),tostr(country),tostr(continent));
	
	--Debug("ID == ",id)
	
	player.Info = {
		IP	    = ip,
		Host	= hostname,
		Port 	= port,
		Channel = channelId,
		Id		= id or -1,
		Name	= name,
		Access	= 0,
		IPData	= {
			Country		= country		or "Crysisville",
			CountryCode = countryCode	or "CV",
			Conti		= continent		or "Lingshan Islands",
			ContiCode 	= continentCode	or "LI",
			City 		= city			or "CrapVillage"
		}
	};
	
	player.GetInfo = function(self)
		return self.Info;
	end;
	
	player.GetIP = function(self)
		return self.Info.IP;
	end;
	
	player.GetHostName = function(self)
		return self.Info.Host;
	end;
	
	player.GetPort = function(self)
		return tonum(self.Info.Port);
	end;
	
	player.GetChannel = function(self)
		return tonum(self.Info.Channel);
	end;
	
	player.GetProfile = function(self)
		local id = self.actor:GetProfileId();
	--	Debug(">>",id)
		return type(id) == "number" and string.format("%d", self.actor:GetProfileId()) or id;
	end;
	
	player.GetAccName = function(self)
		return self.Info.Name;
	end;

	player.GetCountry = function(self)
		return self.Info.IPData.Country;
	end;

	player.GetCity = function(self)
		return self.Info.IPData.City;
	end;

	player.GetCountryCode = function(self)
		return self.Info.IPData.CountryCode;
	end;

	player.GetContinent = function(self)
		return self.Info.IPData.Conti;
	end;

	player.GetContinentCode = function(self)
		return self.Info.IPData.ContiCode;
	end;
	
	-- self.__playerIdentifier can be used for registersystems ...
	player.GetIdentifier = function(self)
		return self.__playerIdentifier or self:GetProfile();
	end;
	
	--Debug("ALL INIT!")
end;


ATOM_Utils.LinkDLLFunctions = function(self)

	local HIGHEST_NUMBER = 10000000000000;

	GetPlayer = function(...)
		if (not ...) then
			return
		end
		local p = ATOMDLL:GetPlayerByName(...);
		if (p and g_localActor and p.id==g_localActorId) then
			return;
		end;
		return p;
	end;
	
	GetPlayerByChannelId = function(...)
		return g_game:GetPlayerByChannelId(...);
	end;
	
	math_add = function(a, b)
		local res = tonumber(a)+tonumber(a);
		if (res < HIGHEST_NUMBER) then
			return res;
		end;
		return atommath:Add(tostring(a),tostring(b));
	end;
	
	math_sub = function(a, b)
		local res = tonum(a) - tonum(b);
		if (res < HIGHEST_NUMBER and res > -HIGHEST_NUMBER) then
			return res;
		end;
		return atommath:Sub(tostring(a),tostring(b));
	end;
	
	math_mod = function(a, b)
		local res = tonumber(a) % tonumber(b);
		if (res < HIGHEST_NUMBER and res > -HIGHEST_NUMBER) then
			return res;
		end;
		return atommath:Mod(tostring(a),tostring(b));
	end;
	
	math_div = function(a, b)
		local res = tonumber(a) / tonumber(b);
		if (res < HIGHEST_NUMBER and res > -HIGHEST_NUMBER) then
			return res;
		end;
		return atommath:Div(tostring(a),tostring(b));
	end;
	
	math_mul = function(a, b)
		local res = tonumber(a) * tonumber(b);
		if (res < HIGHEST_NUMBER and res > -HIGHEST_NUMBER) then
			return res;
		end;
		return atommath:Mul(tostring(a),tostring(b));
	end;
	
	math_geq = function(a, b)
		if (tonumber(a) < HIGHEST_NUMBER and tonumber(b) < HIGHEST_NUMBER) then
			return tonum(a)>=tonum(b);
		end;
		return atommath:Geq(tostring(a),tostring(b));
	end;
	
	math_gtr = function(a, b)
		if (tonumber(a) < HIGHEST_NUMBER and tonumber(b) < HIGHEST_NUMBER) then
			return tonum(a)>tonum(b);
		end;
		return atommath:Gtr(tostring(a),tostring(b));
	end;
	
	math_equ = function(a, b)
		if (tonumber(a) < HIGHEST_NUMBER and tonumber(b) < HIGHEST_NUMBER) then
			return tonum(a) == tonum(b);
		end;
		return atommath:Equ(tostring(a),tostring(b));
	end;
	
	math_leq = function(a, b)
		if (tonumber(a) < HIGHEST_NUMBER and tonumber(b) < HIGHEST_NUMBER) then
			return tonum(a) <= tonum(b);
		end;
		return atommath:Leq(tostring(a),tostring(b));
	end;
	
	math_lss = function(a, b)
		if (tonumber(a) < HIGHEST_NUMBER and tonumber(b) < HIGHEST_NUMBER) then
			return tonum(a)<tonum(b);
		end;
		return atommath:Lss(tostring(a),tostring(b));
	end;
end;

ATOM_Utils.InitLater = function(self)
	g_game		 = g_gameRules.game;
	
	string.lenprint = function(s, l, r)
		if (r) then
			return string.rep(" ", l - string.len(subColor(s))) .. tostring(s);
		else
			return tostring(s) .. string.rep(" ", l - string.len(subColor(tostring(s))));
		end;
	end;
end;

ATOM_Utils:ExposeFunctions();