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
#  address_line1       :string(255)
#  account_country     :string(255)
#  account_country_id  :integer
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
#  address_line2       :string(255)
#  address_city        :string(255)
#  address_state       :string(255)
#  address_zip         :string(255)
#  address_country     :string(255)
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
  it { expect(SubscriptionPaymentCard.const_defined?(:CHECKING_STATUSES)).to eq(true) }

  # relationships
  it { should have_many(:subscription_transactions) }
  it { should belong_to(:user) }
  it { should belong_to(:account_address_country) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:stripe_card_guid) }
  it { should validate_length_of(:stripe_card_guid).is_at_most(255) }

  it { should validate_inclusion_of(:status).in_array(SubscriptionPaymentCard::STATUSES) }
  it { should validate_length_of(:status).is_at_most(255) }

  it { should validate_presence_of(:brand) }
  it { should validate_length_of(:brand).is_at_most(255) }

  it { should validate_presence_of(:last_4) }
  it { should validate_length_of(:last_4).is_at_most(255) }

  it { should validate_presence_of(:expiry_month) }

  it { should validate_presence_of(:expiry_year) }

  it { should_not validate_presence_of(:account_country_id) }
  it { should validate_numericality_of(:account_country_id) }

  it { should validate_length_of(:address_line1).is_at_most(255) }
  it { should validate_length_of(:account_country).is_at_most(255) }
  it { should validate_length_of(:stripe_object_name).is_at_most(255) }
  it { should validate_length_of(:funding).is_at_most(255) }
  it { should validate_length_of(:cardholder_name).is_at_most(255) }
  it { should validate_length_of(:fingerprint).is_at_most(255) }
  it { should validate_length_of(:cvc_checked).is_at_most(255) }
  it { should validate_length_of(:address_line1_check).is_at_most(255) }
  it { should validate_length_of(:address_zip_check).is_at_most(255) }
  it { should validate_length_of(:dynamic_last4).is_at_most(255) }
  it { should validate_length_of(:customer_guid).is_at_most(255) }
  it { should validate_length_of(:address_line2).is_at_most(255) }
  it { should validate_length_of(:address_city).is_at_most(255) }
  it { should validate_length_of(:address_state).is_at_most(255) }
  it { should validate_length_of(:address_zip).is_at_most(255) }
  it { should validate_length_of(:address_country).is_at_most(255) }

  # callbacks
  it { should callback(:create_on_stripe_using_token).before(:validation).on(:create).if(:stripe_token) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubscriptionPaymentCard).to respond_to(:all_in_order) }
  it { expect(SubscriptionPaymentCard).to respond_to(:all_default_cards) }

  # class methods
  it { expect(SubscriptionPaymentCard).to respond_to(:build_from_stripe_data) }
  it { expect(SubscriptionPaymentCard).to respond_to(:get_updates_for_user) }

  # instance methods
  it { should respond_to(:create_on_stripe_using_token) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:make_default_card=) }
  it { should respond_to(:make_default_card) }
  it { should respond_to(:status) }
  it { should respond_to(:stripe_token=) }
  it { should respond_to(:stripe_token) }
  it { should respond_to(:update_as_the_default_card) }

end
