# == Schema Information
#
# Table name: exercises
#
#  id                      :bigint           not null, primary key
#  product_id              :bigint
#  state                   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint
#  corrector_id            :bigint
#  submission_file_name    :string
#  submission_content_type :string
#  submission_file_size    :bigint
#  submission_updated_at   :datetime
#  correction_file_name    :string
#  correction_content_type :string
#  correction_file_size    :bigint
#  correction_updated_at   :datetime
#  submitted_on            :datetime
#  corrected_on            :datetime
#  returned_on             :datetime
#  order_id                :bigint
#

FactoryBot.define do
  factory :exercise do
    product
    user
    order
  end
end
