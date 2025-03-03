local RSGCore = exports['rsg-core']:GetCoreObject()

function CreateUniqueNumber()
    local customid = math.random(1, 99999999999)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM stx_horsebreeding WHERE customid = ?) AS uniqueCheck', { customid })
    if result == 0 then return customid end
    return CreateUniqueNumber()
end

function GenerateHorseid()
    local UniqueFound = false
    local horseid = nil
    while not UniqueFound do
        horseid = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM player_horses WHERE horseid = ?', { horseid })
        if result == 0 then
            UniqueFound = true
        end
    end
    return horseid
end

RegisterNetEvent("stx-horsebreeding:server:startbreeding", function(data)
    local currenttime = os.time()
    local expiretime = os.time() + Config.Time
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local PlayerCID = Player.PlayerData.citizenid
    local uniqueid = CreateUniqueNumber()

    MySQL.insert('INSERT INTO stx_horsebreeding (citizenid, customid, malemodel, maleid, femalemodel, femaleid, timer, breeding) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',{PlayerCID, uniqueid, data.malemodel, data.maleid, data.femalemodel, data.femaleid, expiretime, "Yes"})

    MySQL.update('UPDATE player_horses SET inBreed = ? WHERE horseid = ?', {"Yes", data.maleid}) -- male
    Wait(1000)
    MySQL.update('UPDATE player_horses SET inBreed = ? WHERE horseid = ?', {"Yes", data.femaleid}) -- female

    MySQL.update('UPDATE player_horses SET active = ? WHERE id = ? AND citizenid = ?', { false, data.maleid, Player.PlayerData.citizenid })
    MySQL.update('UPDATE player_horses SET active = ? WHERE id = ? AND citizenid = ?', { false, data.femaleid, Player.PlayerData.citizenid })
end)

RegisterNetEvent("stx-horsebreeding:server:confirmbreeding", function(stable, customid, horsename, femaleid, maleid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player == nil then return end
    local result = MySQL.query.await('SELECT gendergen, modelgen FROM stx_horsebreeding WHERE customid = ?', {customid})
    print(Player)
    local horseid = GenerateHorseid()
    local breedable = {"Yes", "No"}
    local randomIndex1 = math.random(1, #breedable)
    MySQL.insert('INSERT INTO player_horses(stable, citizenid, horseid, name, horse, gender, active, born, breedable, inBreed) VALUES(@stable, @citizenid, @horseid, @name, @horse, @gender, @active, @born, @breedable, @inBreed)', {
        ['@stable'] = stable,
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@horseid'] = horseid,
        ['@name'] = horsename,
        ['@horse'] = result[1].modelgen,
        ['@gender'] = result[1].gendergen,
        ['@active'] = false,
        ['@born'] = os.time(),
        ['@breedable'] = breedable[randomIndex1],
        ['@inBreed'] = "No"
    })


    ---
    MySQL.update('UPDATE player_horses SET inBreed = ? WHERE horseid = ?', {"No", maleid}) -- male
    MySQL.update('UPDATE player_horses SET inBreed = ? WHERE horseid = ?', {"No", femaleid}) -- female

    MySQL.update('DELETE FROM stx_horsebreeding WHERE customid = ?',{customid})
end)


--- Callbacks

lib.callback.register('stx-horsebreeding:server:callback:getBreedableMale', function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local PlayerCID = Player.PlayerData.citizenid
    print(PlayerCID)
    local result = MySQL.query.await('SELECT * FROM player_horses WHERE citizenid = ? AND gender = ? AND inBreed = ?', {PlayerCID, "male", "No"})
    return result

end)

lib.callback.register('stx-horsebreeding:server:callback:getBreedableFemale', function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local PlayerCID = Player.PlayerData.citizenid
    print(PlayerCID)
    local result = MySQL.query.await('SELECT * FROM player_horses WHERE citizenid = ? AND gender = ? AND inBreed = ?', {PlayerCID, "female", "No"})
    return result
end)

lib.callback.register('stx-horsebreeding:server:callback:getPlayerBreedings', function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local PlayerCID = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM stx_horsebreeding WHERE citizenid = ?', {PlayerCID})
    return result
end)

lib.callback.register('stx-horsebreeding:server:callback:getHorseName', function(source, id)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local PlayerCID = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT name FROM player_horses WHERE horseid = ?', {id})
    return result[1].name
end)

lib.callback.register('stx-horsebreeding:server:callback:getBreedTime', function(source, id)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local PlayerCID = Player.PlayerData.citizenid
    local currenttime = os.time()

    local result = MySQL.query.await('SELECT timer FROM stx_horsebreeding WHERE customid = ?', {id})
    local timeleft = result[1].timer - currenttime
    return math.floor(timeleft / 60)
end)





CreateThread(function()
    while true do
        Wait(8000)
        local currenttime = os.time()
        local result = MySQL.query.await("SELECT * FROM stx_horsebreeding", {})

        if not result then goto continue end

        for k , v in pairs (result) do
            local expires = tonumber(v.timer)
            print(expires)
            local timeleft = expires - currenttime

            if timeleft <= 0 then
                if v.breeding == "Yes" then
                    local models = {v.femalemodel, v.malemodel}
                    local randomIndex1 = math.random(1, #models)
                    local genders = {"male", "female"}
                    local randomIndex2 = math.random(1, #genders)
                    MySQL.update('UPDATE stx_horsebreeding SET breeding = ?, gendergen = ?, modelgen = ? WHERE customid = ?', {"No", genders[randomIndex2], models[randomIndex1], v.customid})
                end
            else
                local minutesLeft = math.floor(timeleft / 60)
                if minutesLeft > 0 then
                    print(v.customid .. " has " .. minutesLeft .. " minutes left.")
                else
                    print(v.customid .. " has less than a minute left.")
                end
            end

        end

        ::continue::

    end

end)



----
RSGCore.Commands.Add(Config.command, 'Open Breeding Menu', {}, false, function(source)
    local src = source
    TriggerClientEvent('stx-horsebreeding:client:openmainmenu', src)
end)
