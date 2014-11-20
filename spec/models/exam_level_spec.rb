# == Schema Information
#
# Table name: exam_levels
#
#  id                                :integer          not null, primary key
#  qualification_id                  :integer
#  name                              :string(255)
#  name_url                          :string(255)
#  is_cpd                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  active                            :boolean          default(FALSE), not null
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#

require 'rails_helper'

describe ExamLevel do

  # attr-accessible
  black_list = %w(id created_at updated_at best_possible_first_attempt_score)
  ExamLevel.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()ExamLevel.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:exam_sections) }
  it { should belong_to(:qualification) }
  it { should have_many(:course_modules) }
  it { should have_many(:student_exam_tracks) }
  it { should have_many(:user_exam_level) }

  # validation
  it { should validate_presence_of(:qualification_id) }
  it { should validate_numericality_of(:qualification_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:calculate_best_possible_score).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamLevel).to respond_to(:all_in_order) }

  # class methods
  it { expect(ExamLevel).to respond_to(:get_by_name_url) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }

end
