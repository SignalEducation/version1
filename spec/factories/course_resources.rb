# == Schema Information
#
# Table name: course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  course_id                :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default("false")
#  sorting_order            :integer
#  available_on_trial       :boolean          default("false")
#  download_available       :boolean          default("false")
#  course_step_id           :integer
#

FactoryBot.define do
  factory :course_resource do
    sequence(:name) { |n| "Resource #{n}" }
    description     { Faker::Lorem.sentence }
    association     :course

    trait :file_uploaded do
      file_upload  { File.new(Rails.root.join('spec/support/fixtures/file.pdf')) }
    end

    trait :external_link do
      external_url { Faker::Internet.slug }
    end
  end
end
