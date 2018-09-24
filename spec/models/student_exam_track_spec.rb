# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_module_element_id      :integer
#  exam_schedule_id                     :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string
#  course_module_id                     :integer
#  percentage_complete                  :float            default(0.0)
#  count_of_cmes_completed              :integer          default(0)
#  subject_course_id                    :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  subject_course_user_log_id           :integer
#  count_of_constructed_responses_taken :integer
#

require 'rails_helper'

describe StudentExamTrack do

  # attr-accessible
  black_list = %w(id created_at updated_at exam_level_id exam_section_id exam_schedule_id count_of_questions_taken count_of_questions_correct count_of_quizzes_taken count_of_videos_taken count_of_constructed_responses_taken)
  StudentExamTrack.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:subject_course_user_log) }
  it { should belong_to(:course_module) }
  it { should belong_to(:latest_course_module_element) }
  it { should have_many(:course_module_element_user_logs) }

  # validation
  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  it { should validate_presence_of(:subject_course_user_log_id) }
  it { should validate_numericality_of(:subject_course_user_log_id) }

  it { should_not validate_presence_of(:session_guid) }
  it { should validate_length_of(:session_guid).is_at_most(255) }

  it { should_not validate_presence_of(:user_id) }
  it { should_not validate_presence_of(:latest_course_module_element_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:update_subject_course_user_log).after(:save) }

  # scopes
  it { expect(StudentExamTrack).to respond_to(:all_in_order) }
  it { expect(StudentExamTrack).to respond_to(:for_user) }
  it { expect(StudentExamTrack).to respond_to(:with_active_cmes) }
  it { expect(StudentExamTrack).to respond_to(:all_complete) }
  it { expect(StudentExamTrack).to respond_to(:all_incomplete) }

  # class methods

  # instance methods
  it { should respond_to(:update_subject_course_user_log) }
  it { should respond_to(:completed_cme_user_logs) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:elements_total) }
  it { should respond_to(:elements_complete) }
  it { should respond_to(:latest_cme_user_logs) }
  it { should respond_to(:unique_logs) }
  it { should respond_to(:enrollment) }
  it { should respond_to(:calculate_completeness) }
  it { should respond_to(:worker_update_completeness) }
  it { should respond_to(:recalculate_completeness) }

end
