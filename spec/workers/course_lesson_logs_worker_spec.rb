# frozen_string_literal: true

require 'rails_helper'
require 'mandrill_client'
require 'sidekiq/testing'

RSpec.describe CourseLessonLogsWorker do
  let(:log) { build(:course_lesson_log) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { described_class }

  context 'correct' do
    it 'CourseLessonLogsWorker job is processed.' do
      allow(CourseLessonLog).to receive(:find).and_return(log)
      allow_any_instance_of(CourseLessonLog).to receive(:recalculate_set_completeness).and_return(true)

      expect { subject.perform_async(log.id) }.to change(subject.jobs, :size).by(1)
    end
  end

  context 'incorrect' do
    it 'CourseLessonLogsWorker job is not processed.' do
      allow(CourseLessonLog).to receive(:find).and_raise(ActiveRecord::RecordInvalid)

      expect { subject.perform_async(log.id) }.to change(subject.jobs, :size).by(1)
      expect(Rails.logger).to receive(:error)
    end
  end
end
