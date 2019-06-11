# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#

require 'rails_helper'

describe Order do
  # relationships
  it { should belong_to(:product) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:mock_exam) }
  it { should belong_to(:user) }
  it { should have_one(:order_transaction) }

  # validation
  it 'is invalid without a product' do
    expect(build_stubbed(:order, product: nil)).not_to be_valid
  end

  it 'is invalid without a user' do
    expect(build_stubbed(:order, user: nil)).not_to be_valid
  end

  describe 'for Stripe orders' do
    describe 'when a valid stripe order' do
      it 'validates the stripe_guid' do
        expect(build_stubbed(:order, stripe_token: 'token', stripe_guid: nil)).not_to be_valid
      end

      it 'validates the stripe_customer_id' do
        expect(build_stubbed(:order, stripe_token: 'token', stripe_customer_id: nil)).not_to be_valid
      end

      it 'validates the stripe_status' do
        expect(build_stubbed(:order, stripe_token: 'token', stripe_status: nil)).not_to be_valid
      end
    end

    describe 'when not a stripe order' do
      it 'does not validate the stripe_guid' do
        expect(build_stubbed(:order, stripe_guid: nil)).to be_valid
      end

      it 'does not validate the stripe_customer_id' do
        expect(build_stubbed(:order, stripe_customer_id: nil)).to be_valid
      end

      it 'does not validate the stripe_status' do
        expect(build_stubbed(:order, stripe_status: nil)).to be_valid
      end
    end
  end

  it { should_not validate_presence_of(:coupon_code) }

  it { should_not validate_presence_of(:subject_course_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_order_transaction).after(:create) }

  # scopes
  it { expect(Order).to respond_to(:all_in_order) }
  it { expect(Order).to respond_to(:all_for_course) }
  it { expect(Order).to respond_to(:all_for_product) }
  it { expect(Order).to respond_to(:all_for_user) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  it { should respond_to(:mock_exam) }
  it { should respond_to(:stripe_token) }


end
