print("EDITABLE LOADED")
function NotifyHandler(title, description, typee, duration)
    print("Tested")
    if Config.Notify == "ox_lib" then
        local data = {
            title = title,
            duration = duration,
            type = typee,
            description = description,
            position = "center-right",
        }
        lib.notify(data)
    else
        -- Custom Code Here
    end
end
