# == Schema Information
#
# Table name: import_trackers
#
#  id             :integer          not null, primary key
#  old_model_name :string
#  old_model_id   :integer
#  new_model_name :string
#  new_model_id   :integer
#  imported_at    :datetime
#  original_data  :text
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :import_tracker do
    old_model_name "MyString"
old_model_id 1
new_model_name "MyString"
new_model_id 1
imported_at "2015-02-05 13:07:48"
original_data ""
  end

end
