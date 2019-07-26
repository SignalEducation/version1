# frozen_string_literal: true

class HubSpotContactWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(user_id)
    HubSpot::Contacts.new.batch_create([user_id])
  end
end
