require 'rails_helper'

describe ExamSection do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ExamSection.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { ExamSection.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:exam_level) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:best_possible_first_attempt_score) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamSection).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
