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
    #sequence(:public_url)           { |n| "abc#{n}" }

    factory :acca_home do
      public_url 'acca'
    end

    factory :cfa_home do
      public_url 'cfa'
    end

  end

end
