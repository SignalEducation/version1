# frozen_string_literal: true

require 'rails_helper'
require 'mandrill_client'
require 'sidekiq/testing'

RSpec.describe CourseCloneWorker do
  let(:course)  { create(:course) }
  let(:user)    { create(:content_management_user) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(Cbe).to receive(:duplicate).and_return(Cbe.new)
    allow_any_instance_of(MandrillClient).to receive(:successfully_course_clone_email).and_return(true)
    allow_any_instance_of(MandrillClient).to receive(:failed_course_clone_email).and_return(true)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { CourseCloneWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(course.id, user.id, Faker::Internet.slug) }.to change(subject.jobs, :size).by(1)
  end
end
