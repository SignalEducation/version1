# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default(TRUE)
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

describe Refund do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Refund.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(Refund.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:charge) }
  it { should belong_to(:invoice) }
  it { should belong_to(:subscription) }
  it { should belong_to(:user) }
  it { should belong_to(:manager) }

  # validation
  it { should validate_presence_of(:stripe_guid) }

  it { should validate_presence_of(:charge_id) }
  it { should validate_numericality_of(:charge_id) }

  it { should validate_presence_of(:stripe_charge_guid) }

  it { should validate_presence_of(:invoice_id) }
  it { should validate_numericality_of(:invoice_id) }

  it { should validate_presence_of(:subscription_id) }
  it { should validate_numericality_of(:subscription_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:manager_id) }
  it { should validate_numericality_of(:manager_id) }

  it { should validate_presence_of(:amount) }

  it { should validate_presence_of(:reason) }

  it { should validate_presence_of(:status) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Refund).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
