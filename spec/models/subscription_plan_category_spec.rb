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
  subject { FactoryBot.build(:subscription_plan_category) }

  # Constants

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
