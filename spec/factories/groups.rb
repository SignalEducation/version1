# == Schema Information
#
# Table name: groups
#
#  id            :integer          not null, primary key
#  name          :string
#  name_url      :string
#  active        :boolean          default(FALSE), not null
#  sorting_order :integer
#  description   :text
#  subject_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :group do
    name "MyString"
name_url "MyString"
active false
sorting_order 1
description "MyText"
subject_id 1
  end

end
