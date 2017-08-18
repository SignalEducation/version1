# == Schema Information
#
# Table name: blog_posts
#
#  id            :integer          not null, primary key
#  home_page_id  :integer
#  sorting_order :integer
#  title         :string
#  description   :text
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
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
