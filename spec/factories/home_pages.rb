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
#

FactoryGirl.define do
  factory :home_page do
    seo_title 'MyString'
    seo_description 'MyString'
    subscription_plan_category_id 1
    public_url 'MyString'
  end

end
