# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe OnboardingEmailWorker do
  let(:onboarding_process) { build(:onboarding_process) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(OnboardingProcess).to receive(:find).and_return(onboarding_process)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { OnboardingEmailWorker }

  xit 'OnboardingEmailWorker job is processed in medium queue.' do
    expect { subject.perform_async(onboarding_process.id, false) }.to change(subject.jobs, :size).by(1)
  end
end
