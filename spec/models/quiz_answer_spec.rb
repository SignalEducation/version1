# == Schema Information
#
# Table name: quiz_answers
#
#  id                            :integer          not null, primary key
#  quiz_question_id              :integer
#  correct                       :boolean          default(FALSE), not null
#  degree_of_wrongness           :string(255)
#  wrong_answer_explanation_text :text
#  wrong_answer_video_id         :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#

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
  it { QuizAnswer.const_defined?(:WRONGNESS) }

  # relationships
  xit { should belong_to(:quiz_question) }
  xit { should belong_to(:wrong_answer_video) }
  xit { should have_many(:quiz_attempts) }
  xit { should have_many(:quiz_contents) }

  # validation
  it { should validate_presence_of(:quiz_question_id) }
  it { should validate_numericality_of(:quiz_question_id) }

  it { should validate_inclusion_of(:degree_of_wrongness).in_array(QuizAnswer::WRONGNESS) }



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


end
