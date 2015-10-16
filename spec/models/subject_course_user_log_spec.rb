# == Schema Information
#
# Table name: subject_course_user_logs
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  session_guid                    :string
#  subject_course_id               :integer
#  percentage_complete             :integer          default(0)
#  count_of_cmes_completed         :integer          default(0)
#  latest_course_module_element_id :integer
#  completed                       :boolean          default(FALSE)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  count_of_questions_correct      :integer
#  count_of_questions_taken        :integer
#  count_of_videos_taken           :integer
#  count_of_quizzes_taken          :integer
#

require 'rails_helper'

describe SubjectCourseUserLog do

  # attr-accessible
  black_list = %w(id created_at updated_at count_of_questions_taken count_of_questions_correct count_of_course_module_complete count_of_quizzes_taken count_of_videos_taken)
  SubjectCourseUserLog.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(SubjectCourseUserLog.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:latest_course_module_element) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:session_guid) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubjectCourseUserLog).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
