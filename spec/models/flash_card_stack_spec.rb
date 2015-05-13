# == Schema Information
#
# Table name: flash_card_stacks
#
#  id                                       :integer          not null, primary key
#  course_module_element_flash_card_pack_id :integer
#  name                                     :string(255)
#  sorting_order                            :integer
#  final_button_label                       :string(255)
#  content_type                             :string(255)
#  created_at                               :datetime
#  updated_at                               :datetime
#  destroyed_at                             :datetime
#

require 'rails_helper'

describe FlashCardStack do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  FlashCardStack.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(FlashCardStack.const_defined?(:CONTENT_TYPES)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element_flash_card_pack) }
  it { should have_one(:flash_quiz) }
  it { should have_many(:flash_cards) }

  # validation
  it { should validate_presence_of(:course_module_element_flash_card_pack_id).on(:update) }
  xit { should validate_numericality_of(:course_module_element_flash_card_pack_id) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:final_button_label) }
  it { should validate_length_of(:final_button_label).is_at_most(255) }

  it { should validate_presence_of(:content_type) }
  it { should validate_length_of(:content_type).is_at_most(255) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(FlashCardStack).to respond_to(:all_destroyed) }
  it { expect(FlashCardStack).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

end
