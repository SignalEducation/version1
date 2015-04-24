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
#  destroyed_at                  :datetime
#

require 'rails_helper'

describe QuizAnswer do

  # attr-accessible
  black_list = %w(id created_at updated_at correct destroyed_at)
  QuizAnswer.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(QuizAnswer.const_defined?(:WRONGNESS)).to eq(true) }

  # relationships

  it { should have_many(:quiz_attempts) }
  it { should have_many(:quiz_contents) }
  it { should belong_to(:quiz_question) }
  it { should belong_to(:wrong_answer_video) }

  # validation
  it { should validate_presence_of(:quiz_question_id).on(:update) }
  xit { should validate_numericality_of(:quiz_question_id) }

  it { should validate_inclusion_of(:degree_of_wrongness).in_array(QuizAnswer::WRONGNESS) }

  it { should_not validate_presence_of(:wrong_answer_video_id).on(:update) }
  xit { should validate_numericality_of(:wrong_answer_video_id) }

  # callbacks
  it { should callback(:set_the_field_correct).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:set_wrong_answer_video_id).before(:update) }

  # scopes
  it { expect(QuizAnswer).to respond_to(:all_in_order) }
  it { expect(QuizAnswer).to respond_to(:all_destroyed) }

  # class methods
  it { expect(QuizAnswer).to respond_to(:ids_in_specific_order) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

end
