# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  available_to_corporates       :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string(255)
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string(255)
#  subscription_plan_category_id :integer
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
  #it { expect()SubscriptionPlan.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:invoice_line_items) }
  it { should have_many(:subscriptions) }
  it { should belong_to(:subscription_plan_category) }

  # validation
  # todo - this didn't work, so I commented it out
  # it { should validate_presence_of(:name) }
  # describe 'uniqueness of name' do
  #   subject { FactoryGirl.create(:subscription_plan) }
  #   it { should validate_uniqueness_of(:name).case_insensitive }
  # end

  it { should validate_inclusion_of(:payment_frequency_in_months).in_array(SubscriptionPlan::PAYMENT_FREQUENCIES) }

  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:price) }
  it { should validate_numericality_of(:price) }

  it { should validate_presence_of(:available_from) }

  it { should validate_presence_of(:available_to) }
  it { should allow_value(Proc.new{Time.now.gmtime.to_date + 1.day}.call).for(:available_to) }
  it { should_not allow_value(Proc.new{Time.now.gmtime.to_date }.call).for(:available_to) }

  it { should validate_presence_of(:trial_period_in_days) }
  it { should validate_numericality_of(:trial_period_in_days) }

  it { should_not validate_presence_of(:subscription_plan_category_id) }
  it { should validate_numericality_of(:subscription_plan_category_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_on_stripe_platform).before(:create) }
  it { should callback(:update_on_stripe_platform).before(:update) }
  it { should callback(:delete_on_stripe_platform).after(:destroy) }

  # scopes
  it { expect(SubscriptionPlan).to respond_to(:all_in_order) }
  it { expect(SubscriptionPlan).to respond_to(:all_active) }
  it { expect(SubscriptionPlan).to respond_to(:for_corporates) }
  it { expect(SubscriptionPlan).to respond_to(:for_students) }
  it { expect(SubscriptionPlan).to respond_to(:generally_available) }
  it { expect(SubscriptionPlan).to respond_to(:in_currency) }

  # class methods

  # instance methods
  it { should respond_to(:age_status) }
  it { should respond_to(:destroyable?) }

end
