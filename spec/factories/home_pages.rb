# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  home                          :boolean          default(FALSE)
#  header_heading                :string
#  header_paragraph              :text
#  header_button_text            :string
#  background_image              :string
#  header_button_link            :string
#  header_button_subtext         :string
#  footer_link                   :boolean          default(FALSE)
#  mailchimp_list_guid           :string
#  mailchimp_section_heading     :string
#  mailchimp_section_subheading  :string
#  mailchimp_subscribe_section   :boolean          default(FALSE)
#

FactoryBot.define do
  factory :home_page do
    sequence(:name)                { |n| "homepage-#{n}" }
    sequence(:seo_title)           { |n| "title-#{n}" }
    seo_description                'Seo Description'
    group_id                       1
    subject_course_id              nil
    sequence(:public_url)          { |n| "abc#{n}" }

    factory :home do
      public_url '/'
      custom_file_name 'home'
      name 'home'
      home true
    end

    factory :landing_page_1 do
      public_url '/acca1'
      name 'Landing Page 1'
    end

    factory :landing_page_2 do
      public_url '/acca2'
      name 'Landing Page 2'
    end

  end

end
