# frozen_string_literal: true

require 'mandrill_client'

class CbeCloneWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(cbe_id, user_id, url)
    user     = User.find(user_id)
    cbe      = Cbe.find(cbe_id)
    cbe_name = "#{cbe.name} copy"
    cloned   = cbe.duplicate

    if cloned.is_a?(Cbe)
      send_successfully_email(user, url + "/#{cloned.id}", cbe_name)
    else
      send_failed_email(user, url, cbe_name, "Error in clone cbe ##{cbe_id}")
    end
  end

  private

  def send_successfully_email(user, url, cbe_name)
    MandrillClient.new(user).successfully_cbe_clone_email(user.name, url, cbe_name)
  end

  def send_failed_email(user, url, cbe_name, error)
    MandrillClient.new(user).failed_cbe_clone_email(user.name, url, cbe_name, error)
  end
end
