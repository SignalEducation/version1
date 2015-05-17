# == Schema Information
#
# Table name: subject_areas
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  sorting_order   :integer
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  seo_description :string
#  seo_no_index    :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :subject_area do
    sequence(:name)           { |n| "Subject Area #{n}" }
    sequence(:name_url)       { |n| "subject-area #{n}" }
    sequence(:sorting_order)  { |n| n * 10 }
    seo_description           'Lorem ipsum'
    seo_no_index              false

    factory :active_subject_area do
      active                  true
    end

    factory :inactive_subject_area do
      active                  false
    end
  end

end
