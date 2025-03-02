# HORSE BREEDING SCRIPT | Stx Scripts
![Screenshot 2025-03-02 213153](https://github.com/user-attachments/assets/408eed70-6c4e-440c-b7d4-de67c6a7f21f)

## DESCRIPTION

This script is specially made to work with rsg-horses. This script allows you to breed two horses thats the main purpose of this

CAN WE GET 50 STARS ON THIS.......

## REQUIREMENTS
RSG HORSES
OX_LIB

## INSTALLAION
Insert The Given SQL

You also need to make changed in the rsg-horses

Search rsg-horses:server:BuyHorse in server/server.lua and replace the event with this:
```lua
RegisterServerEvent('rsg-horses:server:BuyHorse', function(price, model, stable, horsename, gender)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if (Player.PlayerData.money.cash < price) then
        TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('error.no_cash'), type = 'error', duration = 5000 })
        return
    end
    local horseid = GenerateHorseid()
    local breedable = {"Yes", "No"}
    local randomIndex1 = math.random(1, #breedable)
    MySQL.insert('INSERT INTO player_horses(stable, citizenid, horseid, name, horse, gender, active, born, breedable, inBreed) VALUES(@stable, @citizenid, @horseid, @name, @horse, @gender, @active, @born, @breedable, @inBreed)', {
        ['@stable'] = stable,
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@horseid'] = horseid,
        ['@name'] = horsename,
        ['@horse'] = model,
        ['@gender'] = gender,
        ['@active'] = false,
        ['@born'] = os.time(),
        ['@breedable'] = breedable[randomIndex1],
        ['@inBreed'] = "No"
    })
    Player.Functions.RemoveMoney('cash', price)
    TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('success.horse_owned'), type = 'success', duration = 5000 })
end)
```

After that search rsg-horses:server:GetHorse in server/server.lua and replace the callback with this:
```
lib.callback.register('rsg-horses:server:GetHorse', function(source, stable)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local horses = {}
    local Result = MySQL.query.await('SELECT * FROM player_horses WHERE citizenid=@citizenid AND stable=@stable AND inBreed =@inBreed', { ['@citizenid'] = Player.PlayerData.citizenid, ['@stable'] = stable, ["@inBreed"] = "No", })
    for i = 1, #Result do
        horses[#horses + 1] = Result[i]
    end
    return horses
end)
```
## Support

- [Join my discord for support](https://discord.gg/fPjSxEHFMt)
- [Check Out My Paid Scripts](https://stxlabs.tebex.io)
