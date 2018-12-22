# == Schema Information
#
# Table name: course_section_user_logs
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  course_section_id               :integer
#  subject_course_user_log_id      :integer
#  latest_course_module_element_id :integer
#  percentage_complete             :float
#  count_of_cmes_completed         :integer
#  count_of_quizzes_taken          :integer
#  count_of_videos_taken           :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  subject_course_id               :integer
#

require 'rails_helper'

describe CourseSectionUserLog do

  # Constants

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:course_section) }
  it { should belong_to(:subject_course_user_log) }
  it { should belong_to(:latest_course_module_element) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:latest_course_module_element_id) }
  it { should validate_numericality_of(:latest_course_module_element_id) }

  it { should validate_presence_of(:course_section_id) }
  it { should validate_numericality_of(:course_section_id) }

  it { should validate_presence_of(:percentage_complete) }

  it { should validate_presence_of(:count_of_cmes_completed) }

  it { should validate_presence_of(:subject_course_user_log_id) }
  it { should validate_numericality_of(:subject_course_user_log_id) }

  it { should validate_presence_of(:count_of_quizzes_taken) }

  it { should validate_presence_of(:count_of_videos_taken) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseSectionUserLog).to respond_to(:all_in_order) }

  # class methods
  #it { expect(CourseSectionUserLog).to respond_to(:method_name) }

  # instance methods
  it { should respond_to(:destroyable?) }


end
