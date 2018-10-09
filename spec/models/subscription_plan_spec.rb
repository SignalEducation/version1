# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#

require 'rails_helper'

describe SubscriptionPlan do

  # attr-accessible
  black_list = %w(id created_at updated_at stripe_guid)
  SubscriptionPlan.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(SubscriptionPlan.const_defined?(:PAYMENT_FREQUENCIES)).to eq(true) }

  describe 'relationships' do
    it { should belong_to(:currency) }
    it { should have_many(:invoice_line_items) }
    it { should have_many(:subscriptions) }
    it { should belong_to(:subscription_plan_category) }
  end

  describe 'validations' do
    it 'should have a valid factory' do
      expect(build(:subscription_plan)).to be_valid
    end

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }

    it { should validate_inclusion_of(:payment_frequency_in_months).in_array(SubscriptionPlan::PAYMENT_FREQUENCIES) }

    it { should validate_presence_of(:currency_id) }

    it { should validate_presence_of(:price) }

    it { should validate_presence_of(:available_from) }

    it { should validate_presence_of(:available_to) }
    it { should allow_value(Proc.new{Time.now.gmtime.to_date + 1.day}.call).for(:available_to) }
    it { should_not allow_value(Proc.new{Time.now.gmtime.to_date }.call).for(:available_to) }

    it { should validate_presence_of(:trial_period_in_days) }

    it { should_not validate_presence_of(:subscription_plan_category_id) }

    it { should validate_length_of(:stripe_guid).is_at_most(255) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_on_stripe_platform).before(:create) }
    it { should callback(:update_on_stripe_platform).before(:update) }
    it { should callback(:delete_on_stripe_platform).after(:destroy) }
  end

  describe 'class methods' do
    it { expect(SubscriptionPlan).to respond_to(:generally_available_or_for_category_guid) }
  end

  describe 'scopes' do
    it { expect(SubscriptionPlan).to respond_to(:all_in_order) }
    it { expect(SubscriptionPlan).to respond_to(:all_in_display_order) }
    it { expect(SubscriptionPlan).to respond_to(:all_in_update_order) }
    it { expect(SubscriptionPlan).to respond_to(:all_active) }
    it { expect(SubscriptionPlan).to respond_to(:for_students) }
    it { expect(SubscriptionPlan).to respond_to(:for_non_standard_students) }
    it { expect(SubscriptionPlan).to respond_to(:generally_available) }
    it { expect(SubscriptionPlan).to respond_to(:in_currency) }
  end

  describe 'instance methods' do
    let(:subscription_plan) { create(:subscription_plan) }

    describe '#amount' do
      it 'defers to the currency #format_number method' do
        expect(subscription_plan.currency).to receive(:format_number).with(subscription_plan.price)

        subscription_plan.amount
      end
    end

    describe '#active?' do
      it 'returns true for active subscription_plans' do
        plan = build_stubbed(:subscription_plan, available_from: 1.day.ago, available_to: 1.day.from_now)

        expect(plan.active?).to be true
      end

      it 'returns false before the available_from date' do
        plan = build_stubbed(:subscription_plan, available_from: 1.day.from_now, available_to: 2.days.from_now)

        expect(plan.active?).to be false
      end

      it 'returns false after the available_to date' do
        plan = build_stubbed(:subscription_plan, available_from: 1.day.ago, available_to: 1.day.ago)

        expect(plan.active?).to be false
      end
    end

    it { should respond_to(:active?) }
    it { should respond_to(:age_status) }
    it { should respond_to(:description) }
    it { should respond_to(:unlimited_access) }
    it { should respond_to(:cancel_anytime) }
    it { should respond_to(:description_without_trial) }
    it { should respond_to(:destroyable?) }
  end
end
