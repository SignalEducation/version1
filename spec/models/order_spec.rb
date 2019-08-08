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

  describe 'orders_completed_in_time' do
    let(:mock_product) { create(:product, :for_mock) }

    before :each do
      create_list(:order, 3, state: 'completed', product: mock_product,
                  created_at: 2.days.ago)
      create_list(:order, 4, state: 'completed', product: mock_product)
    end

    it 'returns the completed orders created since the specified time' do
      expect(Order.orders_completed_in_time(24.hours.ago).count).to eq 4
      expect(Order.orders_completed_in_time(3.days.ago).count).to eq 7
    end

    it 'does not return un-completed orders' do
      create_list(:order, 4, state: 'pending', product: mock_product)

      expect(Order.orders_completed_in_time(3.days.ago).count).to eq 7
    end
  end

  # class methods

  describe '.send_daily_orders_update' do
    let(:mock_product) { create(:product, :for_mock) }

    it 'calls the orders_completed_in_time scope for 24.hours.ago' do
      expect(Order).to(
        receive(:orders_completed_in_time).
          with(instance_of ActiveSupport::TimeWithZone).and_return []
      )

      Order.send_daily_orders_update
    end

    it 'calls the SlackService when there are relevant orders' do
      create_list(:order, 4, state: 'completed', product: mock_product)
      expect_any_instance_of(SlackService).to receive(:notify_channel)

      Order.send_daily_orders_update
    end

    it 'doesn not call slack when there are no relevant orders' do
      create_list(:order, 3, state: 'completed', product: mock_product,
                  created_at: 2.days.ago)

      expect_any_instance_of(SlackService).not_to receive(:notify_channel)

      Order.send_daily_orders_update
    end
  end

  describe '.product_type_count' do
    let(:mock_product) { create(:product, :for_mock) }
    let(:corrections_product) { create(:product, :for_corrections) }

    before :each do
      create_list(:order, 3, product: mock_product)
      create_list(:order, 4, product: corrections_product)
    end

    it 'returns the correct count for mock exams' do
      expect(Order.product_type_count('mock_exam')).to eq 3
    end
    it 'returns the correct count for corrections' do
      expect(Order.product_type_count('correction_pack')).to eq 4
    end
  end

  # instance methods
  it { should respond_to(:destroyable?) }

  it { should respond_to(:mock_exam) }
  it { should respond_to(:stripe_token) }
end
