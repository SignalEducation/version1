# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                          :integer          not null, primary key
#  course_module_element_id    :integer
#  user_id                     :integer
#  session_guid                :string(255)
#  element_completed           :boolean          default(FALSE), not null
#  time_taken_in_seconds       :integer
#  quiz_score_actual           :integer
#  quiz_score_potential        :integer
#  is_video                    :boolean          default(FALSE), not null
#  is_quiz                     :boolean          default(FALSE), not null
#  course_module_id            :integer
#  latest_attempt              :boolean          default(TRUE), not null
#  corporate_customer_id       :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  course_module_jumbo_quiz_id :integer
#  is_jumbo_quiz               :boolean          default(FALSE), not null
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
  #it { expect()CourseModuleElementUserLog.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:corporate_customer) }
  it { should belong_to(:course_module) }
  it { should belong_to(:course_module_element) }
  it { should belong_to(:course_module_jumbo_quiz) }
  it { should have_many(:quiz_attempts) }
  it { should belong_to(:user) }

  # validation
  it { should_not validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should_not validate_presence_of(:course_module_jumbo_quiz_id) }
  it { should validate_numericality_of(:course_module_jumbo_quiz_id) }

  it { should_not validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:session_guid) }

  it { should validate_presence_of(:time_taken_in_seconds) }

  describe 'for quizzes...' do
    before :each do
      allow(subject).to receive(:is_quiz).and_return(true)
    end
    it { should validate_presence_of(:quiz_score_actual).on(:update) }
    it { should validate_presence_of(:quiz_score_potential).on(:update) }
  end

  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  it { should_not validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  # callbacks
  it { should callback(:set_latest_attempt).before(:create) }
  it { should callback(:set_booleans).before(:create) }
  it { should callback(:calculate_score).after(:create) }
  it { should callback(:create_or_update_student_exam_track).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementUserLog).to respond_to(:all_in_order) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_session_guid) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_unknown_users) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module_element) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_jumbo_quiz) }
  it { expect(CourseModuleElementUserLog).to respond_to(:latest_only) }
  it { expect(CourseModuleElementUserLog).to respond_to(:quizzes) }
  it { expect(CourseModuleElementUserLog).to respond_to(:videos) }
  it { expect(CourseModuleElementUserLog).to respond_to(:jumbo_quizzes) }

  # class methods
  it { expect(CourseModuleElementUserLog).to respond_to(:assign_user_to_session_guid) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_user_or_session) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:recent_attempts) }
  it { should respond_to(:recent_attempts) }
  it { should respond_to(:student_exam_track) }


end
