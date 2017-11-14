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
#  active                     :boolean          default(FALSE)
#  exam_body_id               :integer
#  exam_date                  :date
#  expired                    :boolean          default(FALSE)
#  paused                     :boolean          default(FALSE)
#  notifications              :boolean          default(TRUE)
#

require 'rails_helper'

describe Enrollment do

  # attr-accessible
  black_list = %w(id created_at paused)
  Enrollment.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:exam_body) }
  it { should belong_to(:user) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:subject_course_user_log) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should_not validate_presence_of(:subject_course_user_log_id) }
  it { should validate_numericality_of(:subject_course_user_log_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_expiration_worker).after(:create) }
  it { should callback(:deactivate_siblings).after(:create) }
  it { should callback(:create_expiration_worker).after(:update), if: :exam_date_changed? }

  # scopes
  it { expect(Enrollment).to respond_to(:all_in_order) }
  it { expect(Enrollment).to respond_to(:all_in_admin_order) }
  it { expect(Enrollment).to respond_to(:all_active) }
  it { expect(Enrollment).to respond_to(:all_expired) }
  it { expect(Enrollment).to respond_to(:all_not_expired) }
  it { expect(Enrollment).to respond_to(:for_subject_course) }
  it { expect(Enrollment).to respond_to(:all_valid) }
  it { expect(Enrollment).to respond_to(:all_paused) }
  it { expect(Enrollment).to respond_to(:all_un_paused) }
  it { expect(Enrollment).to respond_to(:all_for_notifications) }
  it { expect(Enrollment).to respond_to(:all_not_for_notifications) }
  it { expect(Enrollment).to respond_to(:this_week) }
  it { expect(Enrollment).to respond_to(:all_completed) }

  # class methods
  it { expect(Enrollment).to respond_to(:to_csv) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:valid_enrollment?) }
  it { should respond_to(:course_name) }
  it { should respond_to(:user_email) }
  it { should respond_to(:student_number) }
  it { should respond_to(:date_of_birth) }
  it { should respond_to(:percentage_complete) }
  it { should respond_to(:rounded_percentage_complete) }
  it { should respond_to(:elements_complete_count) }
  it { should respond_to(:course_elements_count) }
  it { should respond_to(:sibling_enrollments) }
  it { should respond_to(:status) }


end
