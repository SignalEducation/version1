# == Schema Information
#
# Table name: course_module_element_flash_card_packs
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  background_color         :string
#  foreground_color         :string
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#

FactoryGirl.define do
  factory :course_module_element_flash_card_pack do
    course_module_element_id 1
    background_color 'bb3333'
    foreground_color 'eeeeee'
  end

end
