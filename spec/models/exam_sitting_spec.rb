# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#  active            :boolean          default(TRUE)
#  computer_based    :boolean          default(FALSE)
#

require 'rails_helper'

describe ExamSitting do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ExamSitting.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:exam_body) }
  it { should belong_to(:subject_course) }
  it { should have_many(:enrollments) }

  # validation
  it { should validate_presence_of(:exam_body_id) }
  it { should validate_numericality_of(:exam_body_id) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:date) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_expiration_worker).after(:create) }

  # scopes
  it { expect(ExamSitting).to respond_to(:all_in_order) }
  it { expect(ExamSitting).to respond_to(:all_active) }
  it { expect(ExamSitting).to respond_to(:all_not_active) }
  it { expect(ExamSitting).to respond_to(:all_computer_based) }
  it { expect(ExamSitting).to respond_to(:all_standard) }
  it { expect(ExamSitting).to respond_to(:sort_by) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:formatted_date) }


end
