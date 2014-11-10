require 'rails_helper'

describe QuizContent do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  QuizContent.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { QuizContent.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:quiz_question) }
  it { should belong_to(:quiz_answer) }

  # validation
  it { should validate_presence_of(:quiz_question_id) }
  it { should validate_numericality_of(:quiz_question_id) }

  it { should validate_presence_of(:quiz_answer_id) }
  it { should validate_numericality_of(:quiz_answer_id) }

  it { should validate_presence_of(:text_content) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizContent).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
