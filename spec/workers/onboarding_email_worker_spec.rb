# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe OnboardingEmailWorker do
  let(:basic_student)       { create(:basic_student) }
  let(:course_lesson_log)   { create(:course_lesson_log, user: basic_student) }
  let(:onboarding_process)  { create(:onboarding_process, user: basic_student, course_lesson_log: course_lesson_log) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(OnboardingProcess).to receive(:find).and_return(onboarding_process)
    allow_any_instance_of(OnboardingProcess).to receive(:next_step).and_return(CourseStep.last)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { OnboardingEmailWorker }

  it 'OnboardingEmailWorker job is processed in medium queue.' do
    expect { subject.perform_async(onboarding_process.id, 1) }.to change(subject.jobs, :size).by(1)
  end
end
