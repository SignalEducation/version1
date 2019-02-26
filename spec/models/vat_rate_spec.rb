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

require 'rails_helper'

describe VatRate do

  # Constants
  #it { expect(VatRate.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:invoices) }
  it { should belong_to(:vat_code) }

  # validation
  it { should validate_presence_of(:vat_code_id).on(:update) }

  it { should validate_presence_of(:percentage_rate) }

  it { should validate_presence_of(:effective_from) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(VatRate).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
