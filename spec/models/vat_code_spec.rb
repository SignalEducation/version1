# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string
#  label      :string
#  wiki_url   :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe VatCode do

  # relationships
  it { should belong_to(:country) }
  it { should have_many(:vat_rates) }

  # validation
  it { should validate_presence_of(:country_id) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:label) }
  it { should validate_length_of(:label).is_at_most(255) }

  it { should validate_length_of(:wiki_url).is_at_most(255) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(VatCode).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
