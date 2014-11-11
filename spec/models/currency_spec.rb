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

require 'rails_helper'

describe Currency do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Currency.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { Currency.const_defined?(:CONSTANT_NAME) }

  # relationships
  xit { should have_many(:corporate_customer_prices) }
  it { should have_many(:countries) }
  it { should have_many(:invoices) }
  it { should have_many(:subscription_plans) }
  it { should have_many(:subscription_transactions) }

  # validation
  it { should validate_presence_of(:iso_code) }
  it { should validate_uniqueness_of(:iso_code) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:leading_symbol) }

  it { should validate_presence_of(:trailing_symbol) }

  it { should validate_presence_of(:sorting_order) }
  it { should validate_numericality_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Currency).to respond_to(:all_in_order) }
  it { expect(Currency).to respond_to(:all_active) }
  it { expect(Currency).to respond_to(:all_inactive) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
