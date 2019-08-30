# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default(FALSE), not null
#  sorting_order                 :integer
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :bigint(8)
#  image_updated_at              :datetime
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :bigint(8)
#  background_image_updated_at   :datetime
#  exam_body_id                  :bigint(8)
#  background_colour             :string
#  seo_title                     :string
#  seo_description               :string
#  short_description             :string
#

FactoryBot.define do
  factory :group do
    sequence(:name)       { |n| "#{Faker::Movies::LordOfTheRings.location} - #{n}" }
    name_url              { Faker::Internet.slug }
    description           { Faker::Lorem.sentence }
    active                { true }
    sorting_order         { 1 }
    short_description     { 'A short description' }
    seo_description       { 'The SEO description' }
    seo_title             { Faker::Internet.domain_name }
    exam_body
  end
end
