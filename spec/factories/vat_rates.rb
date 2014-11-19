# == Schema Information
#
# Table name: vat_rates
#
#  id              :integer          not null, primary key
#  vat_code_id     :integer
#  percentage_rate :float
#  effective_from  :date
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :vat_rate do
    vat_code_id 1
    percentage_rate 1.5
    effective_from { Time.now }
  end

end
