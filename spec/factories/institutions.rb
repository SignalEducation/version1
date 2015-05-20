# == Schema Information
#
# Table name: institutions
#
#  id                     :integer          not null, primary key
#  name                   :string
#  short_name             :string
#  name_url               :string
#  description            :text
#  feedback_url           :string
#  help_desk_url          :string
#  subject_area_id        :integer
#  sorting_order          :integer
#  active                 :boolean          default(FALSE), not null
#  created_at             :datetime
#  updated_at             :datetime
#  background_colour_code :string
#  seo_description        :string
#  seo_no_index           :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :institution do
    sequence(:name)       {|n| "Institute #{n}"}
    sequence(:short_name) {|n| "ACA#{n}"}
    sequence(:name_url)   {|n| "institute-#{n}"}
    description           'Lorem ipsum'
    feedback_url          'http://example.com/feedback'
    help_desk_url         'http://help.example.com'
    subject_area_id       1
    sequence(:sorting_order) {|n| n * 10}
    background_colour_code 'ff1111'
    seo_description       'Lorem ipsum'
    seo_no_index           false

    factory :active_institution do
      active              true
    end

    factory :inactive_institution do
      active              false
    end
  end

end
