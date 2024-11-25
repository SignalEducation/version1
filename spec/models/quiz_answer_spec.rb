# == Schema Information
#
# Table name: quiz_answers
#
#  id                  :integer          not null, primary key
#  quiz_question_id    :integer
#  correct             :boolean          default("false"), not null
#  degree_of_wrongness :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe QuizAnswer do
  # Constants
  it { expect(QuizAnswer.const_defined?(:WRONGNESS)).to eq(true) }

  # relationships
  it { should have_many(:quiz_attempts) }
  it { should have_many(:quiz_contents) }
  it { should belong_to(:quiz_question) }

  # validation
  it { should validate_presence_of(:quiz_question_id).on(:update) }

  it { should validate_inclusion_of(:degree_of_wrongness).in_array(QuizAnswer::WRONGNESS) }
  it { should validate_length_of(:degree_of_wrongness).is_at_most(255) }

  # callbacks
  it { should callback(:set_the_field_correct).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(QuizAnswer).to respond_to(:all_in_order) }
  it { expect(QuizAnswer).to respond_to(:ids_in_specific_order) }
  it { expect(QuizAnswer).to respond_to(:correct) }
  it { expect(QuizAnswer).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
