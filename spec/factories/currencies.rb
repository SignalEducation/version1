# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  iso_code        :string(255)
#  name            :string(255)
#  leading_symbol  :string(255)
#  trailing_symbol :string(255)
#  active          :boolean          default(FALSE), not null
#  sorting_order   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :currency do
    sequence(:iso_code)       { |n| "CCY#{n}" }
    sequence(:name)           { |n| "Currency #{n}" }
    leading_symbol            '£'
    trailing_symbol           'p'
    sequence(:sorting_order)  { |n| n * 100 }

    factory :active_currency do
      active                  true
    end

    factory :inactive_currency do
      active                  false
    end

    factory :euro do
      active                  true
      name                    'Euro'
      iso_code                'EUR'
      leading_symbol          '€'
    end
  end

end
