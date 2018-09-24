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
#

require 'rails_helper'

describe CourseModuleElementUserLog do

  # attr-accessible
  black_list = %w(id created_at updated_at latest_attempt)
  CourseModuleElementUserLog.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:subject_course_user_log) }
  it { should belong_to(:student_exam_track) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:course_module) }
  it { should belong_to(:course_module_element) }
  it { should belong_to(:user) }
  it { should have_many(:quiz_attempts) }
  it { should have_one(:constructed_response_attempt) }

  # validation
  it { should_not validate_presence_of(:course_module_element_id) }

  it { should validate_presence_of(:user_id) }

  it { should_not validate_presence_of(:session_guid) }
  it { should validate_length_of(:session_guid).is_at_most(255) }

  it { should_not validate_presence_of(:time_taken_in_seconds) }

  describe 'for quizzes...' do
    before :each do
      allow(subject).to receive(:is_quiz).and_return(true)
    end
    it { should validate_presence_of(:quiz_score_actual).on(:update) }
    it { should validate_presence_of(:quiz_score_potential).on(:update) }
  end

  # callbacks
  it { should callback(:set_latest_attempt).before(:create) }
  it { should callback(:set_booleans).before(:create) }
  it { should callback(:calculate_score).after(:create) }
  it { should callback(:update_user_seconds_consumed).after(:create) }
  it { should callback(:create_lesson_intercom_event).after(:create) }
  it { should callback(:update_user_seconds_consumed_for_videos).after(:save) }
  it { should callback(:create_or_update_student_exam_track).after(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementUserLog).to respond_to(:all_in_order) }
  it { expect(CourseModuleElementUserLog).to respond_to(:all_completed) }
  it { expect(CourseModuleElementUserLog).to respond_to(:all_incomplete) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_user) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module_element) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_subject_course) }
  it { expect(CourseModuleElementUserLog).to respond_to(:latest_only) }
  it { expect(CourseModuleElementUserLog).to respond_to(:quizzes) }
  it { expect(CourseModuleElementUserLog).to respond_to(:videos) }
  it { expect(CourseModuleElementUserLog).to respond_to(:constructed_responses) }
  it { expect(CourseModuleElementUserLog).to respond_to(:with_elements_active) }
  it { expect(CourseModuleElementUserLog).to respond_to(:this_week) }
  it { expect(CourseModuleElementUserLog).to respond_to(:this_month) }
  it { expect(CourseModuleElementUserLog).to respond_to(:two_months_ago) }
  it { expect(CourseModuleElementUserLog).to respond_to(:three_months_ago) }

  # class methods
  it { expect(CourseModuleElementUserLog).to respond_to(:to_csv) }

  # instance methods
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
