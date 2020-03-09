# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Zendesk::RequestWorker do
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(Zendesk::Requests).to receive(:create).and_return(:ok)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { Zendesk::RequestWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async('name', 'email', 'subject', 'message') }.to change(subject.jobs, :size).by(1)
  end
end
