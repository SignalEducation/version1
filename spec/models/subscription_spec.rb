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
#  complementary         :boolean          default(FALSE), not null
#  current_status        :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rails_helper'

describe Subscription do

  # attr-accessible
  black_list = %w(id created_at updated_at stripe_guid)
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
  xit { should belong_to(:corporate_customer) }
  it { should belong_to(:subscription_plan) }
  it { should have_many(:subscription_transactions) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  it { should validate_presence_of(:subscription_plan_id) }
  it { should validate_numericality_of(:subscription_plan_id) }

  it { should validate_presence_of(:next_renewal_date) }

  it { should validate_inclusion_of(:current_status).in_array(Subscription::STATUSES) }

  # callbacks
  it { should callback(:create_on_stripe_platform).before(:create) }
  it { should callback(:update_on_stripe_platform).before(:update) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Subscription).to respond_to(:all_in_order) }
  it { expect(Subscription).to respond_to(:all_of_status) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
