# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  corporate_customer_id :integer
#  subscription_plan_id  :integer
#  stripe_guid           :string
#  next_renewal_date     :date
#  complimentary         :boolean          default(FALSE), not null
#  current_status        :string
#  created_at            :datetime
#  updated_at            :datetime
#  stripe_customer_id    :string
#  stripe_customer_data  :text
#  livemode              :boolean          default(FALSE)
#  active                :boolean          default(FALSE)
#  terms_and_conditions  :boolean          default(FALSE)
#

require 'rails_helper'

describe Subscription do

  # attr-accessible
  black_list = %w(id created_at updated_at stripe_customer_data stripe_guid)
  Subscription.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(Subscription.const_defined?(:STATUSES)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should have_many(:invoices) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription_plan) }
  it { should have_many(:subscription_transactions) }
  it { should have_one(:referred_signup) }

  # validation
  it { should validate_presence_of(:user_id).on(:update) }

  it { should validate_presence_of(:terms_and_conditions).on(:update) }

  it { should validate_presence_of(:subscription_plan_id) }

  it { should validate_inclusion_of(:current_status).in_array(Subscription::STATUSES).on(:update) }

  it { should validate_inclusion_of(:livemode).in_array([Invoice::STRIPE_LIVE_MODE]).on(:update) }

  it { should validate_length_of(:stripe_guid).is_at_most(255) }
  it { should validate_length_of(:stripe_customer_id).is_at_most(255) }

  # callbacks
  it { should callback(:create_a_subscription_transaction).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Subscription).to respond_to(:all_in_order) }
  it { expect(Subscription).to respond_to(:all_of_status) }
  it { expect(Subscription).to respond_to(:all_active) }

  # class methods
  it { expect(Subscription).to respond_to(:create_using_stripe_subscription) }
  it { expect(Subscription).to respond_to(:get_updates_for_user) }

  # instance methods
  it { should respond_to(:cancel) }
  it { should respond_to(:compare_to_stripe_details) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:reactivation_options) }
  it { should respond_to(:un_cancel) }
  it { should respond_to(:upgrade_options) }
  it { should respond_to(:upgrade_plan) }

end
