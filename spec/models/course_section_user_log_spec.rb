# == Schema Information
#
# Table name: course_section_user_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  course_section_id                    :integer
#  subject_course_user_log_id           :integer
#  latest_course_module_element_id      :integer
#  percentage_complete                  :float
#  count_of_cmes_completed              :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  subject_course_id                    :integer
#  count_of_constructed_responses_taken :integer
#

require 'rails_helper'

describe CourseSectionUserLog do

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:subject_course) }
    it { should belong_to(:subject_course_user_log) }
    it { should belong_to(:course_section) }
    it { should have_many(:student_exam_tracks) }
    it { should have_many(:course_module_element_user_logs) }
  end

  describe 'validations' do
    before do
      @csul = build(:course_section_user_log, user_id: 1, subject_course_id: 1,
                   course_section_id: 1, subject_course_user_log_id: 1)
    end

    it 'should have a valid user_id' do
      expect{ @csul.user_id = nil }.to change{ @csul.valid? }.to false
    end

    it 'should have a valid subject_course_id' do
      expect{ @csul.subject_course_id = nil }.to change{ @csul.valid? }.to false
    end

    it 'should have a valid course_section_id' do
      expect{ @csul.course_section_id = nil }.to change{ @csul.valid? }.to false
    end

  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_subject_course_user_log).before(:validation), unless: :subject_course_user_log_id }
    it { should callback(:update_subject_course_user_log).after(:update) }
  end

  describe 'scopes' do
    it { expect(CourseSectionUserLog).to respond_to(:all_in_order) }
    it { expect(CourseSectionUserLog).to respond_to(:for_user) }
    it { expect(CourseSectionUserLog).to respond_to(:for_course_section) }
    it { expect(CourseSectionUserLog).to respond_to(:for_user_and_section) }
    it { expect(CourseSectionUserLog).to respond_to(:all_complete) }
    it { expect(CourseSectionUserLog).to respond_to(:all_incomplete) }
    it { expect(CourseSectionUserLog).to respond_to(:with_valid_course_section) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:elements_total) }
    it { should respond_to(:completed?) }
    it { should respond_to(:recalculate_csul_completeness) }
  end


end