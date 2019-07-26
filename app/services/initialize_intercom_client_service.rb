class InitializeIntercomClientService

  def initialize
    @intercom_client = Intercom::Client.new(token: ENV['INTERCOM_ACCESS_TOKEN'])
  end

  def perform
    return @intercom_client
  end


end
