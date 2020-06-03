# frozen_string_literal: true
require 'rails_helper'

describe CourseLog do
  let(:user)        { create(:user) }
  let(:course)      { create(:active_course) }
  let!(:course_log) { create(:course_log, course: course, user: user) }

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:course) }
    it { should belong_to(:latest_course_step) }
    it { should have_many(:enrollments) }
    it { should have_many(:course_section_logs) }
    it { should have_many(:course_lesson_logs) }
    it { should have_many(:course_step_logs) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:course_id) }
    it { should validate_presence_of(:percentage_complete) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:update_enrollment).after(:save) }
  end

  describe 'scopes' do
    it { expect(CourseLog).to respond_to(:all_in_order) }
    it { expect(CourseLog).to respond_to(:all_complete) }
    it { expect(CourseLog).to respond_to(:all_incomplete) }
    it { expect(CourseLog).to respond_to(:for_user) }
    it { expect(CourseLog).to respond_to(:for_course) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:elements_total_for_completion) }
    it { should respond_to(:active_enrollment) }
    it { should respond_to(:recalculate_scul_completeness) }
    it { should respond_to(:f_name) }
    it { should respond_to(:l_name) }
    it { should respond_to(:user_email) }
    it { should respond_to(:date_of_birth) }
    it { should respond_to(:enrolled) }
    it { should respond_to(:exam_date) }
    it { should respond_to(:enrollment_sitting) }
    it { should respond_to(:student_number) }
    it { should respond_to(:completion_cme_count) }
  end

  describe 'Methods' do
    describe '.to_csv' do
      context 'return course' do
        it do
          expect(CourseLog.to_csv).to include(
            'id', 'user_id', 'user_email', 'f_name', 'l_name', 'enrolled', 'enrollment_sitting',
            'exam_date', 'student_number', 'date_of_birth', 'completed', 'percentage_complete',
            'count_of_cmes_completed', 'completion_cme_count'
          )
        end
      end
    end

    describe '#destroyable?' do
      context 'always return true' do
        it { expect(course_log).to be_destroyable }
      end
    end

    describe '#elements_total_for_completion' do
      context 'zero as completation' do
        it { expect(course_log.elements_total_for_completion).to be_zero }
      end
    end

    describe '#recalculate_scul_completeness' do
      subject { course_log.recalculate_scul_completeness }

      context 'change completed lessons in log' do
        it { expect { subject }.to change { course_log.count_of_videos_taken }.from(nil).to(0) }
        it { expect { subject }.to change { course_log.count_of_notes_completed }.from(nil).to(0) }
        it { expect { subject }.to change { course_log.count_of_constructed_responses_taken }.from(nil).to(0) }
        it { expect(course_log.count_of_cmes_completed).to be_zero }
      end
    end

    describe '#check_dependencies' do
      it 'stubb destroyable to tru to cover method' do
        allow_any_instance_of(CourseLog).to receive(:destroyable?).and_return(false)
        course_log.destroy

        expect(course_log.errors).not_to be_empty
      end
    end

    describe '#emit_certificate' do
      let(:worker) { CourseLogsWorker }

      before do
        Sidekiq::Testing.fake!
        Sidekiq::Worker.clear_all
        allow_any_instance_of(CourseLogsWorker).to receive(:perform).and_return(true)
        allow_any_instance_of(Course).to receive(:emit_certificate?).and_return(true)
      end

      it 'work receive a job' do
        expect { course_log.update(completed: true) }.to change(worker.jobs, :size).by(1)
      end
    end
  end
end
