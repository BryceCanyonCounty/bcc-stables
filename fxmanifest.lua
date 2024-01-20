fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'BCC @Apollyon'


client_scripts {
    'client/client.lua',
    'client/dataview.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

shared_scripts {
    'config/config.lua',
    'config/horse_comp.lua',
    'locale.lua',
    'languages/*.lua'
}

ui_page {
    'ui/index.html'
}

files {
    "ui/index.html",
    "ui/js/*.*",
    "ui/css/*.*",
    "ui/fonts/*.*",
    "ui/img/*.*",
}

version '1.2.2'

