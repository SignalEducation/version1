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

require 'rails_helper'

describe Country do
  subject { FactoryBot.build(:usa) }

  # Constants
  it { expect(Country.const_defined?(:CONTINENTS)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:subscription_payment_cards) }
  it { should have_many(:users) }
  it { should have_many(:vat_codes) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:iso_code) }
  it { should validate_length_of(:iso_code).is_at_most(255) }

  it { should validate_presence_of(:country_tld) }
  it { should validate_length_of(:country_tld).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:currency_id) }

  it { should validate_inclusion_of(:continent).in_array(Country::CONTINENTS) }
  it { should validate_length_of(:continent).is_at_most(255) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Country).to respond_to(:all_in_order) }
  it { expect(Country).to respond_to(:all_in_eu) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
