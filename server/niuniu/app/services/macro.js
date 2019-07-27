/**
 * Created by ddz-001 on 2015/9/11.
 */

var macro = module.exports;

macro.checkSQLString = function(str_in){
    var res = str_in.match(/(and)|(exec)|(insert)|(select)|(delete)|(update)|(count)|(\*)|(%)|(chr)|(mid)|(master)|(truncate)|(char)|(declare)|(;)|(or)|(\+)|(\,)|(\')|(union)/);
    if(res === null){
        return true;
    }else{
        return false;
    }
};

macro.checkPass = function(passwd){
    if (passwd.length < 6 || passwd.length > 12){
        return false;
    }
    if(!macro.checkSQLString(passwd)){
        return false;
    }
    var valid = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~!@#$%^&*()_+-=[]{}';
    for(var i = 0; i < passwd.length; i++){
        var char = passwd.charAt(i);
        if(valid.indexOf(char) < 0){
            return false;
        }
    }
    return true;
};

macro.checkAvatar = function(avatar){
    if (avatar.length < 1){
        return false;
    }
    if(!macro.checkSQLString(avatar)){
        return false;
    }
    return true;
};

macro.checkNick = function(nick){
    if (nick.length < 1 || nick.length > 20){
        return false;
    }
    if(!macro.checkSQLString(nick)){
        return false;
    }
    return true;
};

macro.checkDeviceId = function(deviceId){
    if(deviceId.length < 1){
        return false;
    }
    if(!macro.checkSQLString(deviceId)){
        return false;
    }
    return true;
};

macro.checkMobile = function(mobile){
    if(mobile.length < 1){
        return false;
    }
    var re = /(1)(\d{10})$/;
    if(!re.test(mobile)){
        return false;
    }
    return true;
};

macro.GetJoin2TableBaiRen_script = function(){
    var lua ="\
    local split = function(szFullString, szSeparator)\
        local nFindStartIndex = 1\
        local nSplitIndex = 1\
        local nSplitArray = {}\
        while true do\
            local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)\
            if not nFindLastIndex then\
                nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))\
                break\
            end\
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)\
            nFindStartIndex = nFindLastIndex + string.len(szSeparator)\
            nSplitIndex = nSplitIndex + 1\
        end\
        return nSplitArray\
    end\
    \
    local findTable = function(KEYS)\
        local userId = KEYS[1]\
        local roomId = tostring(KEYS[2])\
        local services = split(KEYS[3], ',')\
        local lastTableId = tostring(KEYS[4])\
        local timeNow = tonumber(KEYS[5])\
        local seatId = -1\
        local beforeCnt = -1\
        local afterCnt = -1\
        local location = redis.call('HMGET', 'location:'..tostring(userId), 'serverId', 'roomId', 'tableId', 'seatId')\
        if location[1] and location[2] and location[3] and location[4] then\
            return {location[1],location[2],location[3],location[4],beforeCnt,afterCnt}\
        end\
        local tableList = {101,102,103}\
        if roomId == '102' then\
            tableList = {201,202,203}\
        end\
        local maxTableId = nil\
        local maxTableInfo = nil\
        for i = 1,#tableList\
        do\
            local tableInfo=redis.call('HMGET','tableinfo:'..tostring(tableList[i]),'serverId','playerNum')\
            local playerNum = tableInfo[2]\
            if (playerNum and tableInfo[1]) then\
                if tonumber(playerNum) < 300 then\
                    if not maxTableId then\
                        maxTableId = tableList[i]\
                        maxTableInfo = tableInfo\
                    else\
                        if maxTableInfo and tonumber(playerNum) > tonumber(maxTableInfo[2]) then\
                            maxTableId = tableList[i]\
                            maxTableInfo = tableInfo\
                        end\
                    end\
                end\
            else\
                if not maxTableId then\
                    maxTableId = tableList[i]\
                    maxTableInfo = nil\
                end\
            end\
        end\
        \
        if maxTableId then\
            if not maxTableInfo then\
                local serverId = services[maxTableId%(#services) + 1]\
                redis.call('HMSET','tableinfo:'..tostring(maxTableId),'serverId',serverId,'roomId',roomId,'tableName','','passwd','','status',0,'freshTime',timeNow,'playerNum',1,'robotNum',0,'seat0_user_id',-1,'seat1_user_id',-1,'seat2_user_id',-1,'seat3_user_id',-1,'seat4_user_id',-1,'seat5_user_id',-1)\
                redis.call('HMSET', 'location:'..tostring(userId), 'serverId', serverId, 'roomId', roomId, 'tableId', maxTableId, 'seatId', -1, 'status', 0, 'freshTime', timeNow)\
                redis.call('RPUSH', 'reqsit_userlist', userId)\
                return {serverId,roomId,maxTableId,-1,0,0}\
            else\
                redis.call('HINCRBY', 'tableinfo:'..tostring(maxTableId), 'playerNum', 1)\
                redis.call('RPUSH', 'reqsit_userlist', userId)\
                redis.call('HMSET', 'location:'..tostring(userId), 'serverId', maxTableInfo[1], 'roomId', roomId, 'tableId', maxTableId, 'seatId', -1, 'status', 0, 'freshTime', timeNow)\
                return {maxTableInfo[1],roomId,maxTableId,-1,0,0}\
            end\
        else\
            return {-1,-1,-1,0,0}\
        end\
    end\
    \
    return findTable(KEYS)";
    return lua;
};

macro.GetJoin2Table_script = function(){
    var lua ="\
    local sit_down = function(key,userid)\
        local res = redis.call('HMGET',key,'seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id')\
        local seatid = -1\
        for i = 1,#res\
        do\
            if res[i] == userid then\
                seatid = i -1\
                return seatid\
            end\
        end\
        for i = 1,#res\
        do\
            if res[i] == '-1' then\
                seatid = i - 1\
                local field = 'seat'..tostring(seatid)..'_user_id'\
                local value = tostring(userid)\
                redis.call('HSET',key,field,value)\
                break\
            end\
        end\
        return seatid\
    end\
\
    local player_count = function(key)\
        local res = redis.call('HMGET',key,'seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id')\
        local cnt = 0\
        for i = 1,#res\
        do\
            if res[i] and res[i] ~= '-1' then\
                cnt = cnt + 1\
            end\
        end\
        return cnt\
    end\
\
    local getEmptyTable = function()\
        local key='tablelist:0'\
        local tableId=redis.call('LPOP', key)\
        if not tableId then\
            key='dyntableid'\
            tableId=redis.call('HGET',key,'maxTableId')\
            if tableId then\
                tableId = tableId + 1\
            else\
                tableId = 1000\
            end\
            redis.call('HSET',key,'maxTableId',tableId)\
            return tableId\
        else\
            return tableId\
        end\
    end\
    \
    local join2Table = function(roomId, tableId, userId)\
        local key = 'tableinfo:'..tableId\
        local before_cnt = player_count(key)\
        local seatid = sit_down(key,userId)\
\
        local before_key = 'tablelist:0'\
        if before_cnt ~= 0 then\
            before_key = 'tablelist:' .. roomId .. ':' .. tostring(before_cnt)\
        end\
\
        local after_cnt = player_count(key)\
        local after_key = 'tablelist:0'\
        if after_cnt ~= 0 then\
            after_key = 'tablelist:' .. roomId .. ':' .. tostring(after_cnt)\
        end\
\
        if before_cnt ~= after_cnt then\
            redis.call('LREM',before_key,'0',tableId)\
            redis.call('RPUSH',after_key,tableId)\
        end\
        return seatid,before_cnt,after_cnt\
    end\
\
    local split = function(szFullString, szSeparator)\
        local nFindStartIndex = 1\
        local nSplitIndex = 1\
        local nSplitArray = {}\
        while true do\
            local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)\
            if not nFindLastIndex then\
                nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))\
                break\
            end\
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)\
            nFindStartIndex = nFindLastIndex + string.len(szSeparator)\
            nSplitIndex = nSplitIndex + 1\
        end\
        return nSplitArray\
    end\
    \
    local findTable = function(KEYS)\
        local userId = KEYS[1]\
        local roomId = tostring(KEYS[2])\
        local services = split(KEYS[3], ',')\
        local lastTableId = tostring(KEYS[4])\
        local timeNow = tonumber(KEYS[5])\
        local seatId = -1\
        local beforeCnt = -1\
        local afterCnt = -1\
        local location = redis.call('HMGET', 'location:'..tostring(userId), 'serverId', 'roomId', 'tableId', 'seatId')\
        if location[1] and location[2] and location[3] and location[4] then\
            return {location[1],location[2],location[3],location[4],beforeCnt,afterCnt}\
        end\
        for pNum = 4,1,-1\
        do\
            local res=redis.call('LRANGE','tablelist:'..roomId..':'..tostring(pNum),0,-1)\
            for i = 1,#res\
            do\
                while true do\
                    if lastTableId == tostring(res[i]) then\
                        break\
                    end\
                    local tableInfo=redis.call('HMGET','tableinfo:'..tostring(res[i]),'serverId','roomId','status','freshTime','seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id')\
                    local freshTime = tableInfo[4]\
                    if not freshTime then\
                        break\
                    end\
                    if timeNow - tonumber(freshTime) > 5*60 then\
                        break\
                    end\
                    seatId,beforeCnt,afterCnt = join2Table(roomId,res[i],userId)\
                    if seatId >= 0 then\
                        redis.call('RPUSH', 'reqsit_userlist', userId)\
                        redis.call('HMSET', 'location:'..tostring(userId), 'serverId', tableInfo[1], 'roomId', roomId, 'tableId', res[i], 'seatId', seatId, 'status', 0, 'freshTime', timeNow)\
                        return {tableInfo[1],roomId,res[i],seatId,beforeCnt,afterCnt}\
                    else\
                        break\
                    end\
                end\
            end\
        end\
        \
        local tableId = getEmptyTable()\
        local serverId = services[tableId%(#services) + 1]\
        redis.call('HMSET','tableinfo:'..tableId,'serverId',serverId,'roomId',roomId,'tableName','','passwd','','status',0,'freshTime',timeNow,'seat0_user_id',-1,'seat1_user_id',-1,'seat2_user_id',-1,'seat3_user_id',-1,'seat4_user_id',-1)\
        seatId,beforeCnt,afterCnt = join2Table(roomId,tableId,userId)\
        redis.call('RPUSH', 'reqsit_userlist', userId)\
        redis.call('HMSET', 'location:'..tostring(userId), 'serverId', serverId, 'roomId', roomId, 'tableId', tableId, 'seatId', seatId, 'status', 0, 'freshTime', timeNow)\
        return {serverId,roomId,tableId,seatId,beforeCnt,afterCnt}\
    end\
    \
    return findTable(KEYS)";
    return lua;
};

macro.GetJoin2Table_autoMatch_script = function(){
    var lua ="\
    local sit_down = function(key,userid)\
        local res = redis.call('HMGET',key,'seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id')\
        local seatid = -1\
        for i = 1,#res\
        do\
            if res[i] == userid then\
                seatid = i -1\
                return seatid\
            end\
        end\
        for i = 1,#res\
        do\
            if res[i] == '-1' then\
                seatid = i - 1\
                local field = 'seat'..tostring(seatid)..'_user_id'\
                local value = tostring(userid)\
                redis.call('HSET',key,field,value)\
                break\
            end\
        end\
        return seatid\
    end\
\
    local player_count = function(key)\
        local res = redis.call('HMGET',key,'seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id')\
        local cnt = 0\
        for i = 1,#res\
        do\
            if res[i] and res[i] ~= '-1' then\
                cnt = cnt + 1\
            end\
        end\
        return cnt\
    end\
    \
    local join2Table = function(KEYS)\
        local userId = tostring(KEYS[1])\
        local roomId = tostring(KEYS[2])\
        local tableId = tostring(KEYS[3])\
        local key = 'tableinfo:'..tableId\
        local before_cnt = player_count(key)\
        local seatid = sit_down(key,userId)\
\
        local before_key = 'tablelist:0'\
        if before_cnt ~= 0 then\
            before_key = 'tablelist:' .. roomId .. ':' .. tostring(before_cnt)\
        end\
\
        local after_cnt = player_count(key)\
        local after_key = 'tablelist:0'\
        if after_cnt ~= 0 then\
            after_key = 'tablelist:' .. roomId .. ':' .. tostring(after_cnt)\
        end\
\
        if before_cnt ~= after_cnt then\
            redis.call('LREM',before_key,'0',tableId)\
            redis.call('RPUSH',after_key,tableId)\
        end\
        return {seatid,before_cnt,after_cnt}\
    end\
    \
    return join2Table(KEYS)";
    return lua;
};

macro.GetKickUserOff_script = function(){
    var lua ="\
	local player_count = function(key)\
        local res = redis.call('HMGET',key,'seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id','seat5_user_id')\
        local cnt = 0\
        for i = 1,#res\
        do\
            if res[i] and res[i] ~= '-1' then\
                cnt = cnt + 1\
            end\
        end\
        return cnt\
    end\
    \
    local leave_table = function(key,userid,isBaiRen)\
        local res = redis.call('HMGET',key,'seat0_user_id','seat1_user_id','seat2_user_id','seat3_user_id','seat4_user_id','seat5_user_id')\
        local seatid = -1\
        local locationKey = 'location:'..userid\
        for i = 1,#res\
        do\
            if res[i] == tostring(userid) then\
                seatid = i - 1\
                local field = 'seat'..tostring(seatid)..'_user_id'\
                redis.call('HSET',key,field,-1)\
                redis.call('DEL',locationKey)\
            end\
        end\
        if isBaiRen == 1 then\
            redis.call('DEL',locationKey)\
        end\
        return seatid\
    end\
    \
    local kickUserOff = function(KEYS)\
        local userId = tostring(KEYS[1])\
        local roomId = tostring(KEYS[2])\
        local tableId = tostring(KEYS[3])\
        local key = 'tableinfo:'..tableId\
        if roomId == '101' or roomId == '102' then\
            local seatid = leave_table(key,userId,1)\
            return {seatid,2,1}\
        end\
        local before_cnt = player_count(key)\
        local seatid = leave_table(key,userId,0)\
        \
        local before_key = 'tablelist:0'\
        if before_cnt ~= 0 then\
            before_key = 'tablelist:' .. roomId .. ':' .. tostring(before_cnt)\
        end\
        \
        local after_cnt = player_count(key)\
        local after_key = 'tablelist:0'\
        if after_cnt ~= 0 then\
            after_key = 'tablelist:' .. roomId .. ':' .. tostring(after_cnt)\
        end\
        \
        if before_cnt ~= after_cnt then\
            redis.call('LREM',before_key,'0',tableId)\
            redis.call('RPUSH',after_key,tableId)\
        end\
        \
        return {seatid,before_cnt,after_cnt}\
    end\
    \
    return kickUserOff(KEYS)";
    return lua;
};
