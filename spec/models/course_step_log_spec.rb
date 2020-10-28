# == Schema Information
#
# Table name: course_step_logs
#
#  id                         :integer          not null, primary key
#  course_step_id             :integer
#  user_id                    :integer
#  session_guid               :string(255)
#  element_completed          :boolean          default("false"), not null
#  time_taken_in_seconds      :integer
#  quiz_score_actual          :integer
#  quiz_score_potential       :integer
#  is_video                   :boolean          default("false"), not null
#  is_quiz                    :boolean          default("false"), not null
#  course_lesson_id           :integer
#  latest_attempt             :boolean          default("true"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  seconds_watched            :integer          default("0")
#  count_of_questions_taken   :integer
#  count_of_questions_correct :integer
#  course_id                  :integer
#  course_lesson_log_id       :integer
#  course_log_id              :integer
#  is_constructed_response    :boolean          default("false")
#  preview_mode               :boolean          default("false")
#  course_section_id          :integer
#  course_section_log_id      :integer
#  quiz_result                :integer
#  is_note                    :boolean          default("false")
#  is_practice_question       :boolean          default("false")
#

require 'rails_helper'

describe CourseStepLog do

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:course) }
    it { should belong_to(:course_log) }
    it { should belong_to(:course_section) }
    it { should belong_to(:course_section_log) }
    it { should belong_to(:course_lesson) }
    it { should belong_to(:course_lesson_log) }
    it { should belong_to(:course_step) }
    it { should have_many(:quiz_attempts) }
    it { should have_one(:constructed_response_attempt) }
  end

  describe 'validations' do

    before do
      @cmeul = build(:course_step_log, user_id: 1, course_id: 1,
                     course_section_id: 1, course_lesson_id: 1, course_lesson_log_id: 1)
    end

    it 'should have a valid user_id' do
      expect{ @cmeul.user_id = nil }.to change{ @cmeul.valid? }.to false
    end

    it 'should have a valid course_id' do
      expect{ @cmeul.course_id = nil }.to change{ @cmeul.valid? }.to false
    end

    it 'should have a valid course_lesson_id' do
      expect{ @cmeul.course_lesson_id = nil }.to change{ @cmeul.valid? }.to false
    end

    it 'should have a valid course_section_id' do
      expect{ @cmeul.course_section_id = nil }.to change{ @cmeul.valid? }.to false
    end

  end

  describe 'callbacks' do
    it { should callback(:create_course_lesson_log).before(:validation) }
    it { should callback(:set_latest_attempt).before(:create) }
    it { should callback(:set_booleans).before(:create) }
    it { should callback(:update_course_lesson_log).after(:save) }
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseStepLog).to respond_to(:all_in_order) }
    it { expect(CourseStepLog).to respond_to(:all_completed) }
    it { expect(CourseStepLog).to respond_to(:all_incomplete) }
    it { expect(CourseStepLog).to respond_to(:for_user) }
    it { expect(CourseStepLog).to respond_to(:for_course_lesson) }
    it { expect(CourseStepLog).to respond_to(:for_course_step) }
    it { expect(CourseStepLog).to respond_to(:for_course) }
    it { expect(CourseStepLog).to respond_to(:for_current_user) }
    it { expect(CourseStepLog).to respond_to(:latest_only) }
    it { expect(CourseStepLog).to respond_to(:quizzes) }
    it { expect(CourseStepLog).to respond_to(:videos) }
    it { expect(CourseStepLog).to respond_to(:constructed_responses) }
    it { expect(CourseStepLog).to respond_to(:with_elements_active) }
    it { expect(CourseStepLog).to respond_to(:this_week) }
    it { expect(CourseStepLog).to respond_to(:this_month) }
  end

  describe 'class methods' do
    it { expect(CourseStepLog).to respond_to(:to_csv) }
  end

  describe 'instance methods' do
    it { should respond_to(:cm) }
    it { should respond_to(:cme) }
    it { should respond_to(:completed) }
    it { should respond_to(:type) }
    it { should respond_to(:latest) }
    it { should respond_to(:score) }
    it { should respond_to(:seconds) }
    it { should respond_to(:destroyable?) }
  end
end
