# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                         :integer          not null, primary key
#  course_module_element_id   :integer
#  user_id                    :integer
#  session_guid               :string
#  element_completed          :boolean          default(FALSE), not null
#  time_taken_in_seconds      :integer
#  quiz_score_actual          :integer
#  quiz_score_potential       :integer
#  is_video                   :boolean          default(FALSE), not null
#  is_quiz                    :boolean          default(FALSE), not null
#  course_module_id           :integer
#  latest_attempt             :boolean          default(TRUE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  seconds_watched            :integer          default(0)
#  count_of_questions_taken   :integer
#  count_of_questions_correct :integer
#  subject_course_id          :integer
#  student_exam_track_id      :integer
#  subject_course_user_log_id :integer
#  is_constructed_response    :boolean          default(FALSE)
#  preview_mode               :boolean          default(FALSE)
#  course_section_id          :integer
#  course_section_user_log_id :integer
#

require 'rails_helper'

describe CourseModuleElementUserLog do

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:subject_course) }
    it { should belong_to(:subject_course_user_log) }
    it { should belong_to(:course_section) }
    it { should belong_to(:course_section_user_log) }
    it { should belong_to(:course_module) }
    it { should belong_to(:student_exam_track) }
    it { should belong_to(:course_module_element) }
    it { should have_many(:quiz_attempts) }
    it { should have_one(:constructed_response_attempt) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:subject_course_id) }
    it { should validate_presence_of(:course_section_id) }
    it { should validate_presence_of(:course_module_id) }

    it { should_not validate_presence_of(:course_module_element_id) }

    describe 'for quizzes...' do
      before :each do
        allow(subject).to receive(:is_quiz).and_return(true)
      end
      it { should validate_presence_of(:quiz_score_actual).on(:update) }
      it { should validate_presence_of(:quiz_score_potential).on(:update) }
    end
  end

  describe 'callbacks' do
    it { should callback(:create_student_exam_track).before(:validation) }
    it { should callback(:set_latest_attempt).before(:create) }
    it { should callback(:set_booleans).before(:create) }
    it { should callback(:calculate_score).after(:create) }
    it { should callback(:create_lesson_intercom_event).after(:create) }
    it { should callback(:update_student_exam_track).after(:save) }
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseModuleElementUserLog).to respond_to(:all_in_order) }
    it { expect(CourseModuleElementUserLog).to respond_to(:all_completed) }
    it { expect(CourseModuleElementUserLog).to respond_to(:all_incomplete) }
    it { expect(CourseModuleElementUserLog).to respond_to(:for_user) }
    it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module) }
    it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module_element) }
    it { expect(CourseModuleElementUserLog).to respond_to(:for_subject_course) }
    it { expect(CourseModuleElementUserLog).to respond_to(:for_current_user) }
    it { expect(CourseModuleElementUserLog).to respond_to(:latest_only) }
    it { expect(CourseModuleElementUserLog).to respond_to(:quizzes) }
    it { expect(CourseModuleElementUserLog).to respond_to(:videos) }
    it { expect(CourseModuleElementUserLog).to respond_to(:constructed_responses) }
    it { expect(CourseModuleElementUserLog).to respond_to(:with_elements_active) }
    it { expect(CourseModuleElementUserLog).to respond_to(:this_week) }
    it { expect(CourseModuleElementUserLog).to respond_to(:this_month) }
    it { expect(CourseModuleElementUserLog).to respond_to(:two_months_ago) }
    it { expect(CourseModuleElementUserLog).to respond_to(:three_months_ago) }
  end

  describe 'class methods' do
    it { expect(CourseModuleElementUserLog).to respond_to(:to_csv) }
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
    it { should respond_to(:recent_attempts) }
  end

end
