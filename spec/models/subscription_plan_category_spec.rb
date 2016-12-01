# == Schema Information
#
# Table name: subscription_plan_categories
#
#  id                   :integer          not null, primary key
#  name                 :string
#  available_from       :datetime
#  available_to         :datetime
#  guid                 :string
#  created_at           :datetime
#  updated_at           :datetime
#  trial_period_in_days :integer
#

require 'rails_helper'

describe SubscriptionPlanCategory do

  # attr-accessible
  black_list = %w(id created_at updated_at guid)
  SubscriptionPlanCategory.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:subscription_plan_category) }

  # Constants
  #it { expect(SubscriptionPlanCategory.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:subscription_plans) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:available_from) }

  it { should validate_presence_of(:available_to) }

  # callbacks
  it { should callback(:set_guid).before(:validation).on(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubscriptionPlanCategory).to respond_to(:all_in_order) }
  it { expect(SubscriptionPlanCategory).to respond_to(:active_with_guid) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:current) }
  it { should respond_to(:full_name) }
  it { should respond_to(:status) }

end
