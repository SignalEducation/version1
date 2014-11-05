# == Schema Information
#
# Table name: qualifications
#
#  id                          :integer          not null, primary key
#  institution_id              :integer
#  name                        :string(255)
#  name_url                    :string(255)
#  sorting_order               :integer
#  active                      :boolean          default(FALSE), not null
#  cpd_hours_required_per_year :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

FactoryGirl.define do
  factory :qualification do
    institution_id        1
    sequence(:name)       {|n| "Qualification #{n}"}
    sequence(:name_url)   {|n| "qualification-#{n}"}
    sequence(:sorting_order) {|n| n * 10}
    cpd_hours_required_per_year 1

    factory :active_qualification do
      active              true
    end

    factory :inactive_qualification do
      active              false
    end
  end

end
