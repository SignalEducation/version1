# == Schema Information
#
# Table name: exam_bodies
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  url                                :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  active                             :boolean          default("false"), not null
#  has_sittings                       :boolean          default("false"), not null
#  preferred_payment_frequency        :integer
#  subscription_page_subheading_text  :string
#  constructed_response_intro_heading :string
#  constructed_response_intro_text    :text
#  logo_image                         :string
#  registration_form_heading          :string
#  login_form_heading                 :string
#  audience_guid                      :string
#  landing_page_h1                    :string
#  landing_page_paragraph             :text
#  has_products                       :boolean          default("false")
#  products_heading                   :string
#  products_subheading                :text
#  products_seo_title                 :string
#  products_seo_description           :string
#  emit_certificate                   :boolean          default("false")
#  pricing_heading                    :string
#  pricing_subheading                 :string
#  pricing_seo_title                  :string
#  pricing_seo_description            :string
#  hubspot_property                   :string
#

FactoryBot.define do
  factory :exam_body do
    sequence(:name)                    { |n| "#{Faker::Commerce.product_name} - #{n}" }
    sequence(:hubspot_property)                    { |n| "#{Faker::Commerce.product_name} - #{n}" }
    url                                { 'accaglobal.com/ie/en.html' }
    active                             { true }
    constructed_response_intro_heading { 'Intro Heading' }
    constructed_response_intro_text    { 'Intro Text' }
    landing_page_h1                    { 'Header H1' }
    landing_page_paragraph             { 'Header P Text' }
    products_heading                   { 'Header H1' }
    products_subheading                { 'Header P Text' }
    products_seo_title                 { 'Header H1' }
    products_seo_description           { 'Header P Text' }

    trait :with_group do
      association :group
    end
  end
end
