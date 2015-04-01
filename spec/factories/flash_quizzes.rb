# == Schema Information
#
# Table name: flash_quizzes
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  background_color    :string(255)
#  foreground_color    :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

FactoryGirl.define do
  factory :flash_quiz do
    flash_card_stack_id 1
    background_color "MyString"
    foreground_color "MyString"
  end

end
