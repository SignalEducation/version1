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
#  course_id                     :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  home                          :boolean          default("false")
#  logo_image                    :string
#  footer_link                   :boolean          default("false")
#  mailchimp_list_guid           :string
#  registration_form             :boolean          default("false"), not null
#  pricing_section               :boolean          default("false"), not null
#  seo_no_index                  :boolean          default("false"), not null
#  login_form                    :boolean          default("false"), not null
#  preferred_payment_frequency   :integer
#  header_h1                     :string
#  header_paragraph              :string
#  registration_form_heading     :string
#  login_form_heading            :string
#  footer_option                 :string           default("white")
#  video_guid                    :string
#  header_h3                     :string
#  background_image              :string
#  usp_section                   :boolean          default("true")
#  stats_content                 :text
#  course_description            :text
#  header_description            :text
#  onboarding_welcome_heading    :string
#  onboarding_welcome_subheading :text
#  onboarding_level_heading      :string
#  onboarding_level_subheading   :text
#

FactoryBot.define do
  factory :home_page do
    sequence(:name)                { |n| "homepage-#{n}" }
    sequence(:seo_title)           { |n| "title-#{n}" }
    seo_description                { 'Seo Description' }
    group_id                       { 1 }
    course_id                      { nil }
    sequence(:public_url)          { |n| "abc#{n}" }
    onboarding_welcome_heading     { 'Welcome Heading' }
    onboarding_welcome_subheading  { 'Welcome Subheading' }
    onboarding_level_heading       { 'Level Heading' }
    onboarding_level_subheading    { 'Level Subheading' }

    factory :home do
      public_url { '/' }
      custom_file_name { 'home' }
      name { 'home' }
      home { true }
    end

    factory :landing_page_1 do
      name       { 'Landing Page 1' }
      public_url { '/acca1' }
    end

    factory :landing_page_2 do
      name       { 'Landing Page 2' }
      public_url { '/acca2' }
    end

    factory :landing_page_3 do
      name       { 'Landing Page 3' }
      public_url { 'acca-free-lesson' }
    end

    trait :about_us do
      name       { 'About Us' }
      public_url { 'about-us' }
    end
  end
end
