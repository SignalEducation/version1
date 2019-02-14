# == Schema Information
#
# Table name: content_page_sections
#
#  id                :integer          not null, primary key
#  content_page_id   :integer
#  text_content      :text
#  panel_colour      :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  subject_course_id :integer
#  sorting_order     :integer
#

FactoryBot.define do
  factory :content_page_section do
    content_page_id { 1 }
    text_content { 'MyText' }
    panel_colour { '#fffeee' }
  end
end
