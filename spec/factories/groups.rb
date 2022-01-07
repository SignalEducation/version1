# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default("false"), not null
#  sorting_order                 :integer
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#  exam_body_id                  :bigint
#  background_colour             :string
#  seo_title                     :string
#  seo_description               :string
#  short_description             :string
#  onboarding_level_subheading   :text
#  onboarding_level_heading      :string
#  tab_view                      :boolean          default("false"), not null
#  disclaimer                    :text
#

FactoryBot.define do
  factory :group do
    sequence(:name)              { |n| "#{Faker::Movies::LordOfTheRings.location} - #{n}" }
    sequence(:name_url)          { |n| "#{Faker::Internet.slug}-#{n}" }
    description                  { Faker::Lorem.sentence }
    active                       { true }
    sorting_order                { 1 }
    short_description            { 'A short description' }
    seo_description              { 'The SEO description' }
    onboarding_level_heading     { 'Welcome Message' }
    onboarding_level_subheading  { 'Welcome Message' }
    seo_title                    { |n| "#{Faker::Internet.domain_name} - #{n}" }
    exam_body
    category

    trait :with_sub_category do
      association :sub_category
    end
  end
end
