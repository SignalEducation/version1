# == Schema Information
#
# Table name: subject_course_user_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  session_guid                         :string
#  subject_course_id                    :integer
#  percentage_complete                  :integer          default("0")
#  count_of_cmes_completed              :integer          default("0")
#  latest_course_module_element_id      :integer
#  completed                            :boolean          default("false")
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  count_of_questions_correct           :integer
#  count_of_questions_taken             :integer
#  count_of_videos_taken                :integer
#  count_of_quizzes_taken               :integer
#  completed_at                         :datetime
#  count_of_constructed_responses_taken :integer
#

require 'rails_helper'

describe SubjectCourseUserLog do

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:subject_course) }
    it { should belong_to(:latest_course_module_element) }
    it { should have_many(:enrollments) }
    it { should have_many(:course_section_user_logs) }
    it { should have_many(:student_exam_tracks) }
    it { should have_many(:course_module_element_user_logs) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:subject_course_id) }
    it { should validate_presence_of(:percentage_complete) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:update_enrollment).after(:save) }
  end

  describe 'scopes' do
    it { expect(SubjectCourseUserLog).to respond_to(:all_in_order) }
    it { expect(SubjectCourseUserLog).to respond_to(:all_complete) }
    it { expect(SubjectCourseUserLog).to respond_to(:all_incomplete) }
    it { expect(SubjectCourseUserLog).to respond_to(:for_user) }
    it { expect(SubjectCourseUserLog).to respond_to(:for_subject_course) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:elements_total_for_completion) }
    it { should respond_to(:active_enrollment) }
    it { should respond_to(:recalculate_scul_completeness) }
    it { should respond_to(:f_name) }
    it { should respond_to(:l_name) }
    it { should respond_to(:user_email) }
    it { should respond_to(:date_of_birth) }
    it { should respond_to(:enrolled) }
    it { should respond_to(:exam_date) }
    it { should respond_to(:enrollment_sitting) }
    it { should respond_to(:student_number) }
    it { should respond_to(:completion_cme_count) }
  end

end
