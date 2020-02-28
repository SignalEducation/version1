# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_id          :integer
#  subject_course_user_log_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  active                     :boolean          default("false")
#  exam_body_id               :integer
#  exam_date                  :date
#  expired                    :boolean          default("false")
#  paused                     :boolean          default("false")
#  notifications              :boolean          default("true")
#  exam_sitting_id            :integer
#  computer_based_exam        :boolean          default("false")
#  percentage_complete        :integer          default("0")
#

require 'rails_helper'

describe Enrollment do

  describe 'relationships' do
    it { should belong_to(:exam_body) }
    it { should belong_to(:exam_sitting) }
    it { should belong_to(:user) }
    it { should belong_to(:subject_course) }
    it { should belong_to(:subject_course_user_log) }
  end

  describe 'validations' do
    before do
      @enrollment = build(:enrollment, user_id: 1, subject_course_id: 1,
                          subject_course_user_log_id: 1, exam_body_id: 1, exam_sitting_id: 1)
    end

    it 'should have a valid user_id' do
      expect{ @enrollment.user_id = nil }.to change{ @enrollment.valid? }.to false
    end

    it 'should have a valid exam_body_id' do
      expect{ @enrollment.exam_body_id = nil }.to change{ @enrollment.valid? }.to false
    end

    it 'should have a valid subject_course_id' do
      expect{ @enrollment.subject_course_id = nil }.to change{ @enrollment.valid? }.to false
    end

  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_subject_course_user_log).before(:validation) }
    it { should callback(:create_expiration_worker).after(:create) }
    it { should callback(:deactivate_siblings).after(:create) }
    it { should callback(:create_expiration_worker).after(:update), if: :exam_date_changed? }
  end

  describe 'scopes' do
    it { expect(Enrollment).to respond_to(:all_in_order) }
    it { expect(Enrollment).to respond_to(:all_in_admin_order) }
    it { expect(Enrollment).to respond_to(:all_in_exam_sitting_order) }
    it { expect(Enrollment).to respond_to(:all_reverse_order) }
    it { expect(Enrollment).to respond_to(:all_in_exam_order) }
    it { expect(Enrollment).to respond_to(:by_sitting_date) }
    it { expect(Enrollment).to respond_to(:all_in_recent_order) }
    it { expect(Enrollment).to respond_to(:all_active) }
    it { expect(Enrollment).to respond_to(:all_not_active) }
    it { expect(Enrollment).to respond_to(:all_expired) }
    it { expect(Enrollment).to respond_to(:all_valid) }
    it { expect(Enrollment).to respond_to(:all_not_expired) }
    it { expect(Enrollment).to respond_to(:for_subject_course) }
    it { expect(Enrollment).to respond_to(:this_week) }
    it { expect(Enrollment).to respond_to(:by_sitting) }
    it { expect(Enrollment).to respond_to(:all_completed) }
  end

  describe 'class methods' do
    it { expect(Enrollment).to respond_to(:search) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:valid_enrollment?) }
    it { should respond_to(:enrollment_date) }
    it { should respond_to(:student_number) }
    it { should respond_to(:alternate_exam_sittings) }
    it { should respond_to(:sibling_enrollments) }
    it { should respond_to(:display_percentage_complete) }
    it { should respond_to(:status) }
    it { should respond_to(:days_until_exam) }
  end

end
