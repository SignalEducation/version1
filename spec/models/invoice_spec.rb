# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  corporate_customer_id       :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  unit_price_ex_vat           :decimal(, )
#  line_total_ex_vat           :decimal(, )
#  vat_rate_id                 :integer
#  line_total_vat_amount       :decimal(, )
#  line_total_inc_vat          :decimal(, )
#  created_at                  :datetime
#  updated_at                  :datetime
#

require 'rails_helper'

describe Invoice do

  # attr-accessible
  black_list = %w(id created_at updated_at line_total_ex_vat line_total_vat_amount line_total_inc_vat)
  Invoice.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()Invoice.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should belong_to(:corporate_customer) }
  it { should belong_to(:subscription_transaction) }
  it { should belong_to(:subscription) }
  it { should belong_to(:user) }
  it { should belong_to(:vat_rate) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should_not validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  it { should validate_presence_of(:subscription_transaction_id) }
  it { should validate_numericality_of(:subscription_transaction_id) }

  it { should validate_presence_of(:subscription_id) }
  it { should validate_numericality_of(:subscription_id) }

  it { should validate_presence_of(:number_of_users) }

  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:unit_price_ex_vat) }

  it { should_not validate_presence_of(:vat_rate_id) }
  it { should validate_numericality_of(:vat_rate_id) }

  # callbacks
  it { should callback(:calculate_line_totals).before(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Invoice).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
