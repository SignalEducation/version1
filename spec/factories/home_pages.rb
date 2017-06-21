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
#  group_id                      :integer
#  subject_course_id             :integer
#

FactoryGirl.define do
  factory :home_page do
    sequence(:seo_title)           { |n| "title-#{n}" }
    seo_description                'Seo Description'
    sequence(:public_url)          { |n| "abc#{n}" }

    factory :home do
      public_url '/'
    end

    factory :acca_home do
      public_url 'acca'
    end

    factory :cfa_home do
      public_url 'cfa'
    end


  end

end
