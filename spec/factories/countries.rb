# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string
#  iso_code      :string
#  country_tld   :string
#  sorting_order :integer
#  in_the_eu     :boolean          default(FALSE), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string
#

FactoryGirl.define do
  factory :country do
    sequence(:name)           { |n| "Country #{n}" }
    sequence(:iso_code)       { |n| "CTY-#{n}" }
    country_tld               '.com'
    sequence(:sorting_order)  {|n| n * 10 }
    continent                 'Europe'

    factory :eu_country do
      in_the_eu true

      factory :ireland do
        name 'Ireland'
        iso_code 'IE'
        country_tld '.ie'
        currency_id 1
      end

      factory :uk do
        name 'United Kingdom'
        iso_code 'GB'
        country_tld '.uk'
        currency_id 2
      end
    end

    factory :non_eu_country do
      in_the_eu false
      continent 'Asia'

      factory :usa do
        name 'United States'
        iso_code 'US'
        currency_id 3
        continent 'North America'
      end
    end
  end

end
