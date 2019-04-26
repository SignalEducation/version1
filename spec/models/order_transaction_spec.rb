# == Schema Information
#
# Table name: order_transactions
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  user_id          :integer
#  product_id       :integer
#  stripe_order_id  :string
#  stripe_charge_id :string
#  live_mode        :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

describe OrderTransaction do

  # relationships
  it { should belong_to(:order) }
  it { should belong_to(:user) }
  it { should belong_to(:product) }

  # validation
  it { should validate_presence_of(:order_id) }
  it { should validate_numericality_of(:order_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:product_id) }
  it { should validate_numericality_of(:product_id) }

  it { should validate_presence_of(:stripe_order_id) }

  it { should validate_presence_of(:stripe_charge_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(OrderTransaction).to respond_to(:all_in_order) }

  # class methods
  it { expect(OrderTransaction).to respond_to(:create_from_stripe_data) }

  # instance methods
  it { should respond_to(:destroyable?) }


end
