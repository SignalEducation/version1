# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  iso_code      :string(255)
#  country_tld   :string(255)
#  sorting_order :integer
#  in_the_eu     :boolean          default("false"), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string(255)
#

FactoryBot.define do
  factory :country do
    sequence(:name)           { |n| "Country #{n}" }
    sequence(:iso_code)       { |n| "CTY-#{n}" }
    country_tld               { '.com' }
    sequence(:sorting_order)  {|n| n * 10 }
    continent                 { 'Europe' }
    currency

    factory :eu_country do
      in_the_eu { true }

      factory :ireland do
        name { 'Ireland' }
        iso_code { 'IE' }
        country_tld { '.ie' }
        association :currency, factory: :euro
      end

      factory :uk do
        name { 'United Kingdom' }
        iso_code { 'GB' }
        country_tld { '.uk' }
        association :currency, factory: :gbp
      end

      factory :fr do
        name { 'France' }
        iso_code { 'FR' }
        country_tld { '.fr' }
        association :currency, factory: :euro
      end
    end

    factory :non_eu_country do
      in_the_eu { false }
      continent { 'Asia' }

      factory :usa do
        name { 'United States' }
        iso_code { 'US' }
        association :currency, factory: :usd
        continent { 'North America' }
      end
    end
  end

end
