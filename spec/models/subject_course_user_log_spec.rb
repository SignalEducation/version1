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
  black_list = %w(id created_at updated_at count_of_questions_taken count_of_questions_correct count_of_cmes_completed count_of_quizzes_taken count_of_videos_taken latest_course_module_element_id percentage_complete completed)
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

  it { should validate_presence_of(:session_guid) }

  it { should validate_presence_of(:subject_course_id) }

  it { should_not validate_presence_of(:latest_course_module_element_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  xit { should callback(:create_intercom_event).after(:create) }

  # scopes
  it { expect(SubjectCourseUserLog).to respond_to(:all_in_order) }
  it { expect(SubjectCourseUserLog).to respond_to(:for_session_guid) }
  it { expect(SubjectCourseUserLog).to respond_to(:for_unknown_users) }
  it { expect(SubjectCourseUserLog).to respond_to(:all_complete) }
  it { expect(SubjectCourseUserLog).to respond_to(:all_incomplete) }

  # class methods.
  it { expect(SubjectCourseUserLog).to respond_to(:assign_user_to_session_guid) }
  it { expect(SubjectCourseUserLog).to respond_to(:for_user_or_session) }

  # instance methods
  it { should respond_to(:destroyable?) }

  it { should respond_to(:elements_total) }

  it { should respond_to(:recalculate_completeness) }

  it { should respond_to(:student_exam_tracks) }

  it { should respond_to(:start_course_intercom_event) }

end
