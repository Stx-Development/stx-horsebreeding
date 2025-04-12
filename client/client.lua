local RSGCore = exports['rsg-core']:GetCoreObject()
local males = {}
local females = {}

local function JobCheck()
    local PlayerData = RSGCore.Functions.GetPlayerData().job.name
    for k, v in pairs (Config.Jobs) do
        if PlayerData == v then
            return true
        end
    end
    return false

end

RegisterNetEvent("stx-horsebreeding:client:openmainmenu", function()
    local jobcheck = JobCheck()
    if not jobcheck then NotifyHandler("Breeding System", "You are not allowed to do this", "error", 5000) return end 
    lib.registerContext({
        id = 'stx-horsebreeding:client:openmainmenun',
        title = 'Breeding System',
        options = {
            {
                title = "Breeding Menu",
                description = "Menu to start breeding of two horses",
                onSelect = function()
                    TriggerEvent("stx-horsebreeding:client:openbreedingmenu")
                end,
            },
            {
                title = "Check Breedings",
                description = "Check breeding progress",
                onSelect = function()
                    TriggerEvent("stx-horsebreeding:client:openplayerbreedingmenu")
                end,
            },
            {
                title = "Select Male Horse",
                description = "Select your male horse to breed with.",
                onSelect = function()
                    TriggerEvent("stx-horsebreeding:client:openmalehorsebreedingmenu")
                end,
            },
            {
                title = "Select Female Horse",
                description = "Select your female horse to breed with.",
                onSelect = function()
                    TriggerEvent("stx-horsebreeding:client:openfemalehorsebreedingmenu")
                end,
            },
        }
    })
    lib.showContext('stx-horsebreeding:client:openmainmenun')

end)


RegisterNetEvent("stx-horsebreeding:client:openmalehorsebreedingmenu", function()
    local result = lib.callback.await("stx-horsebreeding:server:callback:getBreedableMale", source)
    local menus = {}

    for k, v in pairs (result) do
        menus[#menus + 1] = {
            title = "Horse Name: " ..v.name,
            description = "Gender: " .. v.gender .. "\nBreedable: " .. v.breedable,
            onSelect = function()
                print(#males)
                if #males >= 1  then NotifyHandler("Breeding System", "You already have a selected horse.", "error", 5000) return end

                if v.breedable == "Yes" then
                    males[#males + 1] = {
                        horsename = v.name,
                        horsemodel = v.horse,
                        horsegender = v.gender,
                        horseid = v.horseid,
                        stable = v.stable,
                    }
                    TriggerEvent("stx-horsebreeding:client:openmainmenu")
                else
                    NotifyHandler("Breeding System", "Horse is not breedable", "error", 5000)
                end

            end
        }
    end
    lib.registerContext({
        id = 'stx-horsebreeding:client:openmalehorsebreedingmenuu',
        title = 'Breeding System',
        options = menus,
    })
    lib.showContext('stx-horsebreeding:client:openmalehorsebreedingmenuu')
end)

RegisterNetEvent("stx-horsebreeding:client:openfemalehorsebreedingmenu", function()
    local result = lib.callback.await("stx-horsebreeding:server:callback:getBreedableFemale", source)
    local menus = {}

    for k, v in pairs (result) do
        menus[#menus + 1] = {
            title = "Horse Name: " ..v.name,
            description = "Gender: " .. v.gender .. "\nBreedable: " .. v.breedable,
            onSelect = function()
                if #females >= 1  then NotifyHandler("Breeding System", "You already have a selected horse.", "error", 5000) return end

                if v.breedable == "Yes" then
                    females[#females + 1] = {
                        horsename = v.name,
                        horsemodel = v.horse,
                        horsegender = v.gender,
                        horseid = v.horseid,
                        stable = v.stable,
                    }
                    TriggerEvent("stx-horsebreeding:client:openmainmenu")
                else
                    NotifyHandler("Breeding System", "Horse is not breedable", "error", 5000)
                end

            end
        }
    end
    lib.registerContext({
        id = 'stx-horsebreeding:client:openfemalehorsebreedingmenuu',
        title = 'Breeding System',
        options = menus,
    })
    lib.showContext('stx-horsebreeding:client:openfemalehorsebreedingmenuu')
end)

RegisterNetEvent("stx-horsebreeding:client:openbreedingmenu", function()
    local menus = {}

    if #males < 1 and #females < 1 then
        menus[#menus + 1] = {
            title = "Nothing is selected",
            disabled = true,
        }
        goto continue
    end

    menus[#menus + 1] = {
        title = "Clear Selected Male Horse",
        onSelect = function()
            males = {}
        end,
    }
    menus[#menus + 1] = {
        title = "Clear Selected Female Horse",
        onSelect = function()
            females = {}
        end,
    }
    menus[#menus + 1] = {
        title = "Start Breeding",
        onSelect = function()
            if #males == 1 and #females == 1 then
                local ActiveHorse = exports["rsg-horses"]:CheckActiveHorse()
                if ActiveHorse == 0 then
                    local dbms = {
                        maleid = males[1].horseid,
                        malemodel = males[1].horsemodel,
                        femalemodel = females[1].horsemodel,
                        femaleid = females[1].horseid,
                        mstableid = males[1].stable,
                        festableid = females[1].stable,
                    }
                    TriggerServerEvent("stx-horsebreeding:server:startbreeding", dbms)
                    females = {}
                    males = {}
                end

            else
                NotifyHandler("Breeding System", "One of the genders not selected", "error", 5000)
            end
            
        end,
    }
    for k, v in pairs (males) do
        menus[#menus + 1] = {
            title = " "..v.horsename,
            description = " "..v.horsegender,
            disabled = true,
        }
    end

    for k, v in pairs (females) do
        menus[#menus + 1] = {
            title = " "..v.horsename,
            description = " "..v.horsegender,
            disabled = true,
        }
    end

    ::continue::

    lib.registerContext({
        id = 'stx-horsebreeding:client:openbreedingmenu',
        title = 'Breeding System',
        options = menus,
        onBack = function()
            TriggerEvent("stx-horsebreeding:client:openmainmenu")
        end,
    })
    lib.showContext('stx-horsebreeding:client:openbreedingmenu')

end)

RegisterNetEvent("stx-horsebreeding:client:openplayerbreedingmenu", function()
    local res = lib.callback.await("stx-horsebreeding:server:callback:getPlayerBreedings", source)
    local menus = {}
    for k, v in pairs (res) do
        if v.breeding == "No" then
            Wait(1000)
            local Mname = lib.callback.await("stx-horsebreeding:server:callback:getHorseName", source, v.maleid)
            Wait(1000)
            local Fname = lib.callback.await("stx-horsebreeding:server:callback:getHorseName", source, v.femaleid) 
            menus[#menus + 1] = {
                title = Mname .. " X " .. Fname,
                description = "Breed Gender: " ..v.gendergen,
                onSelect = function()
                    local input = lib.inputDialog("Breeding System", {
                        {
                            type = "input",
                            label = "Enter Name",
                            required = true,
                        },
                        {
                            type = "select",
                            label = "Which stable do you want to send this horse ?",
                            options = Config.stables,
                            required = true,
                        },
                    })

                    if input then
                        TriggerServerEvent("stx-horsebreeding:server:confirmbreeding", input[2], v.customid, input[1], v.femaleid, v.maleid)
                    end

                end
                
            }
        end
    end

    for k, v in pairs (res) do
        if v.breeding == "Yes" then
            Wait(1000)
            local Mname = lib.callback.await("stx-horsebreeding:server:callback:getHorseName", source, v.maleid)
            Wait(1000)
            local Fname = lib.callback.await("stx-horsebreeding:server:callback:getHorseName", source, v.femaleid)
            Wait(1000)
            local timer = lib.callback.await("stx-horsebreeding:server:callback:getBreedTime", source, v.customid)
            menus[#menus + 1] = {
                title = Mname .. " X " .. Fname,
                description = timer .. " Minutes Left",
                disabled = true,
            }
        end
    end

    lib.registerContext({
        id = 'stx-horsebreeding:client:openbreedingcheckingmenu',
        title = 'Breeding System',
        options = menus,
        onBack = function()
            TriggerEvent("stx-horsebreeding:client:openmainmenu")
        end,
    })
    lib.showContext('stx-horsebreeding:client:openbreedingcheckingmenu')


end)

