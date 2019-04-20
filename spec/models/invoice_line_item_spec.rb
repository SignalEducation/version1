# == Schema Information
#
# Table name: invoice_line_items
#
#  id                   :integer          not null, primary key
#  invoice_id           :integer
#  amount               :decimal(, )
#  currency_id          :integer
#  prorated             :boolean
#  period_start_at      :datetime
#  period_end_at        :datetime
#  subscription_id      :integer
#  subscription_plan_id :integer
#  original_stripe_data :text
#  created_at           :datetime
#  updated_at           :datetime
#

require 'rails_helper'

describe InvoiceLineItem do

  # relationships
  it { should belong_to(:invoice) }
  it { should belong_to(:currency) }
  it { should belong_to(:subscription) }
  it { should belong_to(:subscription_plan) }

  # validation
  it { should validate_presence_of(:invoice_id) }

  it { should validate_presence_of(:amount) }

  it { should validate_presence_of(:currency_id) }

  xit { should validate_presence_of(:period_start_at) }

  xit { should validate_presence_of(:period_end_at) }

  it { should validate_presence_of(:subscription_id) }

  it { should validate_presence_of(:subscription_plan_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(InvoiceLineItem).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
