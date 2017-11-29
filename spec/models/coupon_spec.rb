# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_coupon_data :text
#

require 'rails_helper'

describe Coupon do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Coupon.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(Coupon.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:stripe) }
  it { should belong_to(:currency) }

  # validation
  it { should validate_presence_of(:stripe_id) }
  it { should validate_numericality_of(:stripe_id) }

  it { should validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:amount_off) }

  it { should validate_presence_of(:duration) }

  it { should validate_presence_of(:duration_in_months) }

  it { should validate_presence_of(:max_redemptions) }

  it { should validate_presence_of(:percent_off) }

  it { should validate_presence_of(:redeem_by) }

  it { should validate_presence_of(:times_redeemed) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Coupon).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
