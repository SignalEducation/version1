# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe HubSpotFormContactsWorker do
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(HubSpot::FormContacts).to receive(:create).and_return(:ok)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { HubSpotFormContactsWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(rand(10)) }.to change(subject.jobs, :size).by(1)
  end
end
