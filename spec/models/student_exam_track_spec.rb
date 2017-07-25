# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  latest_course_module_element_id :integer
#  exam_schedule_id                :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  session_guid                    :string
#  course_module_id                :integer
#  percentage_complete             :float            default(0.0)
#  count_of_cmes_completed         :integer          default(0)
#  subject_course_id               :integer
#  count_of_questions_taken        :integer
#  count_of_questions_correct      :integer
#  count_of_quizzes_taken          :integer
#  count_of_videos_taken           :integer
#

require 'rails_helper'

describe StudentExamTrack do

  # attr-accessible
  black_list = %w(id created_at updated_at exam_level_id exam_section_id exam_schedule_id count_of_questions_taken count_of_questions_correct count_of_quizzes_taken count_of_videos_taken)
  StudentExamTrack.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()StudentExamTrack.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:course_module) }
  it { should belong_to(:latest_course_module_element) }

  # validation
  it { should_not validate_presence_of(:user_id) }

  it { should validate_presence_of(:subject_course_id) }

  it { should_not validate_presence_of(:latest_course_module_element_id) }

  it { should validate_presence_of(:session_guid) }
  it { should validate_length_of(:session_guid).is_at_most(255) }

  it { should validate_presence_of(:course_module_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StudentExamTrack).to respond_to(:all_in_order) }
  it { expect(StudentExamTrack).to respond_to(:for_session_guid) }
  it { expect(StudentExamTrack).to respond_to(:for_unknown_users) }
  it { expect(StudentExamTrack).to respond_to(:with_active_cmes) }
  it { expect(StudentExamTrack).to respond_to(:all_complete) }

  # class methods
  it { expect(StudentExamTrack).to respond_to(:assign_user_to_session_guid) }
  it { expect(StudentExamTrack).to respond_to(:for_user_or_session) }

  # instance methods
  it { should respond_to(:destroyable?) }

end
