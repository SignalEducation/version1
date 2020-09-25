# frozen_string_literal: true

require 'rails_helper'
require 'mandrill_client'
require 'sidekiq/testing'

RSpec.describe CbeCloneWorker do
  let(:cbe)  { create(:cbe) }
  let(:user) { create(:content_management_user) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(Cbe).to receive(:duplicate).and_return(Cbe.new)
    allow_any_instance_of(MandrillClient).to receive(:successfully_cbe_clone_email).and_return(true)
    allow_any_instance_of(MandrillClient).to receive(:failed_cbe_clone_email).and_return(true)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { CbeCloneWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(cbe.id, user.id, Faker::Internet.slug) }.to change(subject.jobs, :size).by(1)
  end
end
