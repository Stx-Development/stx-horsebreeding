fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author "fzzy | github.com/MuhammadAbdullahShurjeel"
description "It is a utility script created for rsg-horses. It allows player to do breeding of horses"

client_scripts {
    "client/editable.lua",
    "client/client.lua"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/editable.lua",
    "server/server.lua"
}

shared_scripts {
    '@ox_lib/init.lua',
    "shared/config.lua"
}

lua54 "yes"