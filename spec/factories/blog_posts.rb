# == Schema Information
#
# Table name: blog_posts
#
#  id                 :integer          not null, primary key
#  home_page_id       :integer
#  sorting_order      :integer
#  title              :string
#  description        :text
#  url                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

FactoryGirl.define do
  factory :blog_post do
    home_page_id 1
    sorting_order 1
    title "MyString"
    description "MyText"
    url "MyString"
  end

end
