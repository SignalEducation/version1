# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  vat_rate_id                 :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  issued_at                   :datetime
#  stripe_guid                 :string
#  sub_total                   :decimal(, )      default(0.0)
#  total                       :decimal(, )      default(0.0)
#  total_tax                   :decimal(, )      default(0.0)
#  stripe_customer_guid        :string
#  object_type                 :string           default("invoice")
#  payment_attempted           :boolean          default(FALSE)
#  payment_closed              :boolean          default(FALSE)
#  forgiven                    :boolean          default(FALSE)
#  paid                        :boolean          default(FALSE)
#  livemode                    :boolean          default(FALSE)
#  attempt_count               :integer          default(0)
#  amount_due                  :decimal(, )      default(0.0)
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string
#  subscription_guid           :string
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
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
  it { expect(Invoice.const_defined?(:STRIPE_LIVE_MODE)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription_transaction) }
  it { should belong_to(:subscription) }
  it { should belong_to(:user) }
  it { should belong_to(:vat_rate) }

  # validation
  it { should validate_presence_of(:user_id) }

  it { should validate_presence_of(:subscription_id) }

  it { should validate_presence_of(:number_of_users) }

  it { should validate_presence_of(:currency_id) }

  it { should validate_presence_of(:total) }

  it { should validate_inclusion_of(:livemode).in_array([Invoice::STRIPE_LIVE_MODE])}

  it { should validate_length_of(:stripe_guid).is_at_most(255) }
  it { should validate_length_of(:stripe_customer_guid).is_at_most(255) }
  it { should validate_length_of(:object_type).is_at_most(255) }
  it { should validate_length_of(:charge_guid).is_at_most(255) }
  it { should validate_length_of(:subscription_guid).is_at_most(255) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:set_vat_rate).after(:create) }

  # scopes
  it { expect(Invoice).to respond_to(:all_in_order) }

  # class methods
  it { expect(Invoice).to respond_to(:build_from_stripe_data) }
  it { expect(Invoice).to respond_to(:update_from_stripe) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:status) }

end
