# frozen_string_literal: true

class HubSpotContactWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(users_id)
    HubSpot::Contacts.new.batch_create(Array(users_id))
  end
end
