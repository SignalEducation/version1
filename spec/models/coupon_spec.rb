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
  it { expect(Coupon.const_defined?(:DURATIONS)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:charges) }
  it { should have_many(:subscriptions) }

  # validation

  it { should validate_presence_of(:name) }

  it { should_not validate_presence_of(:currency_id) }
  it { should validate_numericality_of(:currency_id) }

  it { should validate_presence_of(:code) }

  it { should validate_presence_of(:duration) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_on_stripe).before(:create) }
  it { should callback(:activate).after(:create) }
  it { should callback(:delete_on_stripe).before(:destroy) }

  # scopes
  it { expect(Coupon).to respond_to(:all_in_order) }
  it { expect(Coupon).to respond_to(:all_active) }

  # class methods
  it { expect(Coupon).to respond_to(:verify_coupon_and_get_discount) }
  it { expect(Coupon).to respond_to(:get_and_verify) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:amount_or_percent_off) }
  it { should respond_to(:duration_months_if_repeating) }
  it { should respond_to(:currency_if_amount_off_set) }


end
