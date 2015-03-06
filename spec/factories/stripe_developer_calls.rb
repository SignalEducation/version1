# == Schema Information
#
# Table name: stripe_developer_calls
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  params_received :text
#  prevent_delete  :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :stripe_developer_call do
    user_id 1
    params_received {{some_data: 'MyText'}}
    prevent_delete false
  end

end
