IntercomRails.config do |config|

  config.app_id = ENV['Intercom_App_ID'] || 'yqda78s4' # live code = 'a81yx184'
  config.enabled_environments = %w(development production staging)

end
