# == Schema Information
#
# Table name: flash_quizzes
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  background_color    :string
#  foreground_color    :string
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

require 'rails_helper'

describe FlashQuiz do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  FlashQuiz.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(FlashQuiz.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:flash_card_stack) }
  it { should have_many(:quiz_questions) }

  # validation
  it { should validate_presence_of(:flash_card_stack_id).on(:update) }
  it { should validate_numericality_of(:flash_card_stack_id) }

  it { should validate_presence_of(:background_color) }
  it { should validate_length_of(:background_color).is_at_most(255) }

  it { should validate_presence_of(:foreground_color) }
  it { should validate_length_of(:foreground_color).is_at_most(255) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(FlashQuiz).to respond_to(:all_destroyed) }
  it { expect(FlashQuiz).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

end
