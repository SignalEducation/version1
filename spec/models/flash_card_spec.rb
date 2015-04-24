# == Schema Information
#
# Table name: flash_cards
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  sorting_order       :integer
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

require 'rails_helper'

describe FlashCard do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  FlashCard.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(FlashCard.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:flash_card_stack) }
  it { should have_many(:quiz_contents) }

  # validation
  it { should validate_presence_of(:flash_card_stack_id).on(:update) }
  xit { should validate_numericality_of(:flash_card_stack_id) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(FlashCard).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
