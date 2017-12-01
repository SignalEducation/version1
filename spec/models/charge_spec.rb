# == Schema Information
#
# Table name: charges
#
#  id                           :integer          not null, primary key
#  subscription_id              :integer
#  invoice_id                   :integer
#  user_id                      :integer
#  subscription_payment_card_id :integer
#  currency_id                  :integer
#  coupon_id                    :integer
#  stripe_api_event_id          :integer
#  stripe_guid                  :string
#  amount                       :integer
#  amount_refunded              :integer
#  failure_code                 :string
#  failure_message              :text
#  stripe_customer_id           :string
#  stripe_invoice_id            :string
#  livemode                     :boolean          default(FALSE)
#  stripe_order_id              :string
#  paid                         :boolean          default(FALSE)
#  refunded                     :boolean          default(FALSE)
#  refunds                      :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  original_event_data          :text
#

require 'rails_helper'

describe Charge do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Charge.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(Charge.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:subscription) }
  it { should belong_to(:invoice) }
  it { should belong_to(:user) }
  it { should belong_to(:subscription_payment_card) }
  it { should belong_to(:currency) }
  it { should belong_to(:coupon) }
  it { should belong_to(:stripe_api_event) }
  it { should belong_to(:stripe_customer) }
  it { should belong_to(:stripe_invoice) }
  it { should belong_to(:stripe_order) }

  # validation
  it { should validate_presence_of(:subscription_id) }
  it { should validate_numericality_of(:subscription_id) }

  it { should validate_presence_of(:invoice_id) }
  it { should validate_numericality_of(:invoice_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:subscription_payment_card_id) }
  it { should validate_numericality_of(:subscription_payment_card_id) }

  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:coupon_id) }
  it { should validate_numericality_of(:coupon_id) }

  it { should validate_presence_of(:stripe_api_event_id) }
  it { should validate_numericality_of(:stripe_api_event_id) }

  it { should validate_presence_of(:stripe_guid) }

  it { should validate_presence_of(:amount) }

  it { should validate_presence_of(:amount_refunded) }

  it { should validate_presence_of(:failure_code) }

  it { should validate_presence_of(:failure_message) }

  it { should validate_presence_of(:stripe_customer_id) }
  it { should validate_numericality_of(:stripe_customer_id) }

  it { should validate_presence_of(:stripe_invoice_id) }
  it { should validate_numericality_of(:stripe_invoice_id) }

  it { should validate_presence_of(:stripe_order_id) }
  it { should validate_numericality_of(:stripe_order_id) }

  it { should validate_presence_of(:refunds) }

  it { should validate_presence_of(:status) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Charge).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
