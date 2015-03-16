# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  corporate_customer_id :integer
#  subscription_plan_id  :integer
#  stripe_guid           :string(255)
#  next_renewal_date     :date
#  complimentary         :boolean          default(FALSE), not null
#  current_status        :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  stripe_customer_id    :string(255)
#  stripe_customer_data  :text
#  livemode              :boolean          default(FALSE)
#

require 'rails_helper'

describe Subscription do

  # attr-accessible
  black_list = %w(id created_at updated_at stripe_guid, next_renewal_date stripe_customer_data stripe_guid)
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
  it { should belong_to(:corporate_customer) }
  it { should have_many(:invoices) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription_plan) }
  it { should have_many(:subscription_transactions) }

  # validation
  it { should validate_presence_of(:user_id).on(:update) }
  it { should validate_numericality_of(:user_id) }

  it { should_not validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  it { should validate_presence_of(:subscription_plan_id) }
  it { should validate_numericality_of(:subscription_plan_id) }

  it { should validate_inclusion_of(:current_status).in_array(Subscription::STATUSES) }

  it { should validate_inclusion_of(:livemode).in_array(Invoice::STRIPE_LIVE_MODE)}

  # callbacks
  it { should callback(:create_on_stripe_platform).before(:validation).on(:create) }
  it { should callback(:create_a_subscription_transaction).after(:create) }
  it { should callback(:update_on_stripe_platform).before(:validation).on(:update) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Subscription).to respond_to(:all_in_order) }
  it { expect(Subscription).to respond_to(:all_of_status) }

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
