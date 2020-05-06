# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe CsvBulkExerciseWorker do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { CsvBulkExerciseWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(user.id, 1) }.to change(subject.jobs, :size).by(1)
  end

  it 'call creates a new exercise for the user' do
    expect(Exercise.count).to equal 0

    expect { CsvBulkExerciseWorker.new.perform(user.id, product.id) }.to change { user.exercises.count }.by(1)
  end
end
