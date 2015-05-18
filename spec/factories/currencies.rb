# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  iso_code        :string
#  name            :string
#  leading_symbol  :string
#  trailing_symbol :string
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
    active                    true

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
      trailing_symbol         'c'
    end

    factory :usd do
      active                  true
      name                    'US Dollar'
      iso_code                'USD'
      leading_symbol          '$'
      trailing_symbol         'c'
    end

    factory :gbp do
      active                  true
      name                    'Pounds Sterling'
      iso_code                'GBP'
      leading_symbol          '£'
      trailing_symbol         'p'
    end
  end

end
