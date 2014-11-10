# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  user_id                  :integer
#  session_guid             :string(255)
#  element_completed        :boolean          default(FALSE), not null
#  time_taken_in_seconds    :integer
#  quiz_score_actual        :integer
#  quiz_score_potential     :integer
#  is_video                 :boolean          default(FALSE), not null
#  is_quiz                  :boolean          default(FALSE), not null
#  course_module_id         :integer
#  latest_attempt           :boolean          default(TRUE), not null
#  corporate_customer_id    :integer
#  created_at               :datetime
#  updated_at               :datetime
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
  #it { CourseModuleElementUserLog.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:user) }
  it { should belong_to(:course_module) }
  xit { should belong_to(:corporate_customer) }
  it { should have_many(:quiz_attempts) }

  # validation
  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should_not validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:session_guid) }

  it { should validate_presence_of(:time_taken_in_seconds) }

  it { should validate_presence_of(:quiz_score_actual) }

  it { should validate_presence_of(:quiz_score_potential) }

  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  it { should validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:mark_previous_attempts_as_latest_false).after(:create) }
  it { should callback(:set_latest_attempt).before(:create) }

  # scopes
  it { expect(CourseModuleElementUserLog).to respond_to(:all_in_order) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_session_guid) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_unknown_users) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module) }
  it { expect(CourseModuleElementUserLog).to respond_to(:for_course_module_element) }
  it { expect(CourseModuleElementUserLog).to respond_to(:latest_only) }
  it { expect(CourseModuleElementUserLog).to respond_to(:quizzes) }
  it { expect(CourseModuleElementUserLog).to respond_to(:videos) }

  # class methods
  it { should respond_to(:for_user_or_session) }


  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:mark_previous_attempts_as_latest_false) }

end
