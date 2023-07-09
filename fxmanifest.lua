fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'ZF Labo'
description 'A library for FiveM developers to make their life easier when using QBCore & ESX.'
version '1.2.0'

dependencies {
	'/server:5848',
    '/onesync',
}

files {
    'init.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
}

shared_script 'modules/init.lua'
shared_scripts {
    '@es_extended/imports.lua',

    'modules/**/shared.lua',
}

client_scripts {
    'imports/callbacks/client.lua',
    'modules/**/client.lua',
    'modules/**/client/*.lua'
}

server_scripts {
    'imports/callbacks/server.lua',
    'modules/**/server.lua',
    'modules/**/server/*.lua',
}