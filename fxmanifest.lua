fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'BCC Team'
description 'BCC Stables for Feather Framework'
version '0.1.0-dev'

dependency 'feather-core'
dependency 'feather-mysql'

server_scripts {
    '@feather-mysql/lib/DB.lua',
    'config.lua',
    'shared/contracts.lua',
    'server/operations.lua',
    'server/migrations.lua',
    'server/persistence.lua',
    'server/repository.lua',
    'server/repository_proof.lua',
    'server/core.lua',
    'server/foundation.lua',
    'server/entity_proof.lua',
    'server/main.lua'
}

client_scripts {
    'client/diagnostics.lua',
    'client/entity_proof.lua'
}
