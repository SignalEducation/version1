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
#

FactoryGirl.define do
  factory :flash_card_stack do
    course_module_element_flash_card_pack_id 1
name "MyString"
sorting_order 1
final_button_label "MyString"
content_type "MyString"
  end

end
