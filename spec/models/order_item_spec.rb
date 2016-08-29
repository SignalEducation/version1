# == Schema Information
#
# Table name: order_items
#
#  id                 :integer          not null, primary key
#  order_id           :integer
#  user_id            :integer
#  product_id         :integer
#  stripe_customer_id :string
#  price              :decimal(, )
#  currency_id        :integer
#  quantity           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

describe OrderItem do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  OrderItem.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(OrderItem.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:order) }
  it { should belong_to(:user) }
  it { should belong_to(:product) }
  it { should belong_to(:stripe_customer) }
  it { should belong_to(:currency) }

  # validation
  it { should validate_presence_of(:order_id) }
  it { should validate_numericality_of(:order_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:product_id) }
  it { should validate_numericality_of(:product_id) }

  it { should validate_presence_of(:stripe_customer_id) }
  it { should validate_numericality_of(:stripe_customer_id) }

  it { should validate_presence_of(:price) }

  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:quantity) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(OrderItem).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
