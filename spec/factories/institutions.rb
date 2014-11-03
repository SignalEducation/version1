# == Schema Information
#
# Table name: institutions
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  short_name      :string(255)
#  name_url        :string(255)
#  description     :text
#  feedback_url    :string(255)
#  help_desk_url   :string(255)
#  subject_area_id :integer
#  sorting_order   :integer
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :institution do
    sequence(:name)       {|n| "Institute #{n}"}
    sequence(:short_name) {|n| "ACA#{n}"}
    sequence(:name_url}   {|n| "institute-#{n}"}
    description           'Lorem ipsum'
    feedback_url          'http://example.com/feedback'
    help_desk_url         'http://help.example.com'
    subject_area_id       1 # todo
    sequence(:sorting_order} {|n| n * 10}

    factory :active_institution do
      active              true
    end

    factory :inactive_institution do
      active              false
    end
  end

end
