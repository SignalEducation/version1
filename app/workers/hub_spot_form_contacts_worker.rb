# frozen_string_literal: true

class HubSpotFormContactsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(form_data)
    HubSpot::FormContacts.new.create(form_data)
  end
end
