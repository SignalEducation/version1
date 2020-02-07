# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SlackNotificationWorker do
  let(:exercise) { create(:exercise) }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(Exercise.new.class).to receive(:notify_submitted).and_return(:ok)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { SlackNotificationWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(:exercise, exercise.id, :notify_submitted) }.to change(subject.jobs, :size).by(1)
  end
end
