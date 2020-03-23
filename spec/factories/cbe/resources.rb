# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_resources
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  sorting_order         :integer
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  cbe_id                :bigint
#
FactoryBot.define do
  factory :cbe_resource, class: Cbe::Resource do
    name     { Faker::Lorem.word }
    document { File.new(Rails.root.join('spec', 'support', 'fixtures', 'file.pdf')) }
    sequence(:sorting_order)
    association :cbe
  end
end
