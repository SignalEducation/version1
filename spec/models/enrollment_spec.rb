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
#  student_number             :string
#  exam_body_id               :integer
#  exam_date                  :date
#  registered                 :boolean          default(FALSE)
#

require 'rails_helper'

describe Enrollment do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Enrollment.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(Enrollment.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:subject_course_user_log) }
  it { should belong_to(:exam_body) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should_not validate_presence_of(:subject_course_user_log_id) }
  it { should validate_numericality_of(:subject_course_user_log_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Enrollment).to respond_to(:all_in_order) }
  it { expect(Enrollment).to respond_to(:all_active) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
