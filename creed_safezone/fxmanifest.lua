fx_version 'cerulean'
game 'gta5'

author 'Creed'
description 'Creed Safezone Script'

client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'index.html'

files {
    'index.html',
    'sounds/*.mp3'
}

lua54 'yes'
