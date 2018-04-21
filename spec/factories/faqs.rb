# == Schema Information
#
# Table name: faqs
#
#  id             :integer          not null, primary key
#  name           :string
#  name_url       :string
#  active         :boolean          default(TRUE)
#  sorting_order  :integer
#  faq_section_id :integer
#  question_text  :text
#  answer_text    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :faq do
    name "MyString"
    name_url "MyString"
    active false
    sorting_order 1
    faq_section_id 1
    question_text "MyText"
    answer_text "MyText"
  end
end
