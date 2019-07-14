# == Schema Information
#
# Table name: student_testimonials
#
#  id                 :bigint(8)        not null, primary key
#  home_page_id       :integer
#  sorting_order      :integer
#  text               :text
#  signature          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :bigint(8)
#  image_updated_at   :datetime
#

FactoryBot.define do
  factory :student_testimonial do
    
  end
end
