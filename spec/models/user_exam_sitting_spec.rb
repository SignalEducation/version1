# == Schema Information
#
# Table name: user_exam_sittings
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_sitting_id   :integer
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe UserExamSitting do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  UserExamSitting.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(UserExamSitting.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:exam_sitting) }
  it { should belong_to(:subject_course) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:exam_sitting_id) }
  it { should validate_numericality_of(:exam_sitting_id) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should validate_presence_of(:date) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserExamSitting).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
