# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_module_element_id      :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string(255)
#  course_module_id                     :integer
#  percentage_complete                  :float            default("0")
#  count_of_cmes_completed              :integer          default("0")
#  subject_course_id                    :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  subject_course_user_log_id           :integer
#  count_of_constructed_responses_taken :integer
#  course_section_id                    :integer
#  course_section_user_log_id           :integer
#

require 'rails_helper'

describe StudentExamTrack do

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:subject_course) }
    it { should belong_to(:subject_course_user_log) }
    it { should belong_to(:course_section) }
    it { should belong_to(:course_section_user_log) }
    it { should belong_to(:course_module) }
    it { should belong_to(:latest_course_module_element) }
    it { should have_many(:course_module_element_user_logs) }
  end

  describe 'validations' do
    before do
      @set = build(:student_exam_track, user_id: 1, subject_course_id: 1,
                  course_module_id: 1, course_section_user_log_id: 1,
                  course_section_id: 1, subject_course_user_log_id: 1)
    end

    it 'should have a valid user_id' do
      expect{ @set.user_id = nil }.to change{ @set.valid? }.to false
    end

    it 'should have a valid subject_course_id' do
      expect{ @set.subject_course_id = nil }.to change{ @set.valid? }.to false
    end

    it 'should have a valid course_module_id' do
      expect{ @set.course_module_id = nil }.to change{ @set.valid? }.to false
    end

    it 'should have a valid course_section_id' do
      expect{ @set.course_section_id = nil }.to change{ @set.valid? }.to false
    end

    it 'should have a valid subject_course_user_log_id' do
      expect{ @set.subject_course_user_log_id = nil }.to change{ @set.valid? }.to false
    end
  end


  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_course_section_user_log).before(:validation), unless: :course_section_user_log_id }
    it { should callback(:update_course_section_user_log).after(:update) }
  end

  describe 'scopes' do
    it { expect(StudentExamTrack).to respond_to(:all_in_order) }
    it { expect(StudentExamTrack).to respond_to(:for_user) }
    it { expect(StudentExamTrack).to respond_to(:for_course_module) }
    it { expect(StudentExamTrack).to respond_to(:for_user_and_module) }
    it { expect(StudentExamTrack).to respond_to(:with_active_cmes) }
    it { expect(StudentExamTrack).to respond_to(:with_valid_course_module) }
    it { expect(StudentExamTrack).to respond_to(:all_complete) }
    it { expect(StudentExamTrack).to respond_to(:all_incomplete) }
  end

  describe 'instance methods' do
    it { should respond_to(:cme_user_logs) }
    it { should respond_to(:completed_cme_user_logs) }
    it { should respond_to(:destroyable?) }
    it { should respond_to(:elements_total) }
    it { should respond_to(:elements_complete) }
    it { should respond_to(:latest_cme_user_logs) }
    it { should respond_to(:unique_logs) }
    it { should respond_to(:enrollment) }
    it { should respond_to(:recalculate_set_completeness) }
  end


end
