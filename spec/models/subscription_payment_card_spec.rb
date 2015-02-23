# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string(255)
#  status              :string(255)
#  brand               :string(255)
#  last_4              :string(255)
#  expiry_month        :integer
#  expiry_year         :integer
#  billing_address     :string(255)
#  billing_country     :string(255)
#  billing_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string(255)
#  funding             :string(255)
#  cardholder_name     :string(255)
#  fingerprint         :string(255)
#  cvc_checked         :string(255)
#  address_line1_check :string(255)
#  address_zip_check   :string(255)
#  dynamic_last4       :string(255)
#  customer_guid       :string(255)
#  is_default_card     :boolean          default(FALSE)
#

require 'rails_helper'

describe SubscriptionPaymentCard do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  SubscriptionPaymentCard.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(SubscriptionPaymentCard.const_defined?(:STATUSES)).to eq(true) }

  # relationships
  it { should have_many(:subscription_transactions) }
  it { should belong_to(:user) }
  it { should belong_to(:billing_country) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:stripe_card_guid) }

  it { should validate_inclusion_of(:status).in_array(SubscriptionPaymentCard::STATUSES) }

  it { should validate_presence_of(:brand) }

  it { should validate_presence_of(:last_4) }

  it { should validate_presence_of(:expiry_month) }

  it { should validate_presence_of(:expiry_year) }

  it { should_not validate_presence_of(:billing_country_id) }
  it { should validate_numericality_of(:billing_country_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubscriptionPaymentCard).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
