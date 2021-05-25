# frozen_string_literal: true

require 'rails_helper'
require 'mandrill_client'
require 'sidekiq/testing'

RSpec.describe CourseLogsWorker do
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(Accredible::Credentials).to receive(:create).and_return(true)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { CourseLogsWorker }

  it 'Accredible job is processed in importers queue.' do
    expect { subject.perform_async(Faker::Name.first_name, Faker::Internet.email, 1) }.to change(subject.jobs, :size).by(1)
  end
end
