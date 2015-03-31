# == Schema Information
#
# Table name: flash_cards
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  sorting_order       :integer
#  created_at          :datetime
#  updated_at          :datetime
#

FactoryGirl.define do
  factory :flash_card do
    flash_card_stack_id 1
sorting_order 1
  end

end
