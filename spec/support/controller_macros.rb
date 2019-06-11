module ControllerMacros
  def attributes_with_foreign_keys(*args)
    FactoryBot.build(*args).attributes.delete_if do |k, v| 
      ["id", "type", "created_at", "updated_at"].member?(k)
    end
  end
end

RSpec.configure do |config|
  config.include ControllerMacros, :type => :controller
end