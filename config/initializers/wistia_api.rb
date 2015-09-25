require 'wistia'

Wistia.use_config!(wistia: {
                       api: {
                           password: ENV['learnsignal_wistia_api_key'],
                           format: 'json'
                       }
                   })
