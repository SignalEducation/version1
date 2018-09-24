# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default(FALSE)
#

FactoryBot.define do
  factory :content_page do
    sequence(:name)       { |n| "Content page - #{n}" }
    sequence(:public_url)       { |n| "content-page-#{n}" }
    sequence(:seo_title)       { |n| "Content page - #{n}" }
    seo_description 'MyText'
    text_content 'MyText'
    h1_text 'MyString'
    h1_subtext 'MyString'
    nav_type 'MyString'
    footer_link false
    active true
  end
end
