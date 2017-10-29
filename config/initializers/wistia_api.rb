require 'wistia'

Wistia.use_config!(wistia: {
                       api: {
                           password: ENV['LEARNSIGNAL_WISTIA_API_KEY'],
                           format: 'json'
                       }
                   })
