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

  subject { FactoryGirl.build(:currency) }

  # Constants
  #it { expect()Currency.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  # todo it { should have_many(:corporate_customer_prices) }
  it { should have_many(:countries) }
  it { should have_many(:invoices) }
  it { should have_many(:invoice_line_items) }
  it { should have_many(:subscription_plans) }
  it { should have_many(:subscription_transactions) }

  # validation
  it { should validate_presence_of(:iso_code) }
  it { should validate_uniqueness_of(:iso_code) }
  it { should validate_length_of(:iso_code).is_at_most(255) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:leading_symbol) }
  it { should validate_length_of(:leading_symbol).is_at_most(255) }

  it { should validate_presence_of(:trailing_symbol) }
  it { should validate_length_of(:trailing_symbol).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Currency).to respond_to(:all_in_order) }
  it { expect(Currency).to respond_to(:all_active) }
  it { expect(Currency).to respond_to(:all_inactive) }

  # class methods
  it { expect(Currency).to respond_to(:get_by_iso_code) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:format_number) }

end
