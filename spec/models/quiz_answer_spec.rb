require 'rails_helper'

describe QuizAnswer do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  QuizAnswer.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { QuizAnswer.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:quiz_question) }
  it { should belong_to(:wrong_answer_video) }

  # validation
  it { should validate_presence_of(:quiz_question_id) }
  it { should validate_numericality_of(:quiz_question_id) }

  it { should validate_presence_of(:degree_of_wrongness) }

  it { should validate_presence_of(:wrong_answer_explanation_text) }

  it { should validate_presence_of(:wrong_answer_video_id) }
  it { should validate_numericality_of(:wrong_answer_video_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizAnswer).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
