# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  payment_frequency_in_months   :integer          default("1")
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string(255)
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default("false")
#  paypal_guid                   :string
#  paypal_state                  :string
#  monthly_percentage_off        :integer
#  previous_plan_price           :float
#  exam_body_id                  :bigint
#  guid                          :string
#  bullet_points_list            :string
#  sub_heading_text              :string
#  most_popular                  :boolean          default("false"), not null
#  registration_form_heading     :string
#  login_form_heading            :string
#

require 'rails_helper'
require 'concerns/filterable_spec.rb'

describe SubscriptionPlan, type: :model do
  it_behaves_like 'filterable'

  # Constants
  it { expect(SubscriptionPlan.const_defined?(:PAYMENT_FREQUENCIES)).to eq(true) }
  it 'should have a valid factory' do
    expect(build(:subscription_plan)).to be_valid
  end

  describe 'relationships' do
    it { should belong_to(:currency) }
    it { should have_many(:invoice_line_items) }
    it { should have_many(:subscriptions) }
    it { should belong_to(:subscription_plan_category) }
  end

  describe 'validations' do
    it 'should have a valid factory' do
      expect(build(:subscription_plan)).to be_valid
    end

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }

    it { should validate_inclusion_of(:payment_frequency_in_months).in_array(SubscriptionPlan::PAYMENT_FREQUENCIES) }

    it { should validate_presence_of(:currency) }

    it { should validate_presence_of(:price) }

    it { should validate_presence_of(:available_from) }

    it { should validate_presence_of(:available_to) }
    it { should allow_value(Proc.new{Time.now.gmtime.to_date + 1.day}.call).for(:available_to) }
    it { should_not allow_value(Proc.new{Time.now.gmtime.to_date }.call).for(:available_to) }


    it { should_not validate_presence_of(:subscription_plan_category_id) }

    it { should validate_length_of(:stripe_guid).is_at_most(255) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'class methods' do

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end

    it { expect(SubscriptionPlan).to respond_to(:get_relevant) }

    describe '.get_related_plans' do
      let(:user) { build_stubbed(:user) }
      let(:exam_body) { build_stubbed(:exam_body) }
      let(:plan_guid) { 'plan_ls_12345' }

      it 'calls .get_individual_related_plan' do
        expect(SubscriptionPlan).to(
          receive(:get_individual_related_plan)
        ).with(plan_guid, user.currency)

        SubscriptionPlan.get_related_plans(user, user.currency, exam_body.id, plan_guid)
      end

      it 'calls .scope_exam_body_plans' do
        expect(SubscriptionPlan).to(
          receive(:scope_exam_body_plans)
        ).with(user, exam_body.id, any_args)

        SubscriptionPlan.get_related_plans(user, user.currency, exam_body.id, plan_guid)
      end

      it 'returns plans' do
        return_value = SubscriptionPlan.get_related_plans(
          user, user.currency, exam_body.id, plan_guid
        )

        expect(return_value).to be_an ActiveRecord::Relation
        expect(return_value.klass).to eq SubscriptionPlan
      end
    end

    describe '.scope_exam_body_plans' do
      let(:user) { build_stubbed(:user) }
      let!(:plan) { create(:subscription_plan) }
      let(:plans) { SubscriptionPlan.all }

      describe 'when the exam_body exists' do
        let(:exam_body) { create(:exam_body) }

        it 'calls .where on the passed in plans with the correct exam_body_id' do
          expect(plans).to receive(:where).with(exam_body_id: exam_body.id)

          SubscriptionPlan.scope_exam_body_plans(user, exam_body.id, plans)
        end
      end

      describe 'when the user has a preferred exam_body' do
        it 'calls .where on the passed in plans with the user preferred exam_body' do
          expect(plans).to receive(:where).with(exam_body_id: user.preferred_exam_body_id)

          SubscriptionPlan.scope_exam_body_plans(user, nil, plans)
        end
      end

      describe 'when neither the exam_body or preferred_exam_body exist' do
        let(:new_user) { build_stubbed(:user, preferred_exam_body_id: nil) }

        it 'returns the original plans' do
          expect(SubscriptionPlan.scope_exam_body_plans(new_user, nil, plans)).to(
            eq plans
          )
        end
      end
    end

    describe '.get_individual_related_plan' do
      let(:plan) { create(:subscription_plan) }
      let(:currency) { build_stubbed(:currency) }

      it 'finds the subscription_plan' do
        expect(SubscriptionPlan).to receive(:find_by).
          with({guid: plan.guid})

        SubscriptionPlan.get_individual_related_plan(plan.guid, currency)
      end

      it 'raises an error if there is a currency miss-match' do
        expect { SubscriptionPlan.get_individual_related_plan(plan.guid, currency) }.to(
          raise_error(Learnsignal::SubscriptionError, 'The specified plan is not available! Please choose another.')
        )
      end

      it 'raises an error if the plan is not active' do
        plan.update_column(:available_to, 1.days.ago)
        expect { SubscriptionPlan.get_individual_related_plan(plan.guid, currency) }.to(
          raise_error(Learnsignal::SubscriptionError, 'The specified plan is not available! Please choose another.')
        )
      end
    end
  end

  describe 'scopes' do
    it { expect(SubscriptionPlan).to respond_to(:all_in_order) }
    it { expect(SubscriptionPlan).to respond_to(:all_in_display_order) }
    it { expect(SubscriptionPlan).to respond_to(:all_in_update_order) }
    it { expect(SubscriptionPlan).to respond_to(:all_active) }
    it { expect(SubscriptionPlan).to respond_to(:generally_available) }
    it { expect(SubscriptionPlan).to respond_to(:in_currency) }
  end

  describe 'deletion' do
    let(:test_plan) { create(:subscription_plan) }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to(
        receive(:queue_async)
      )
    end

    it 'calls the SubscriptionPlanWorker with the correct attributes' do
      expect(SubscriptionPlanWorker).to(
        receive(:perform_async).with(
          test_plan.id,
          :delete,
          test_plan.stripe_guid,
          test_plan.paypal_guid
        )
      )

      test_plan.destroy
    end
  end

  describe 'instance methods' do
    let(:subscription_plan) { build_stubbed(:subscription_plan) }
    it { should respond_to(:destroyable?) }

    describe '#amount' do
      it 'defers to the currency #format_number method' do
        expect(subscription_plan.currency).to receive(:format_number).with(subscription_plan.price)

        subscription_plan.amount
      end
    end

    describe '#active?' do
      it 'returns true for active subscription_plans' do
        plan = build_stubbed(:subscription_plan, available_from: 1.day.ago, available_to: 1.day.from_now)

        expect(plan.active?).to be true
      end

      it 'returns false before the available_from date' do
        plan = build_stubbed(:subscription_plan, available_from: 1.day.from_now, available_to: 2.days.from_now)

        expect(plan.active?).to be false
      end

      it 'returns false after the available_to date' do
        plan = build_stubbed(:subscription_plan, available_from: 1.day.ago, available_to: 1.day.ago)

        expect(plan.active?).to be false
      end
    end

    describe '#description' do
      it 'returns the correct description for monthly subscription_plans' do
        plan = build_stubbed(:subscription_plan, payment_frequency_in_months: 1)

        expect(plan.description).to include('Pay for LearnSignal online training service every month.')
      end

      it 'returns the correct description for quarterly subscription_plans' do
        plan = build_stubbed(:subscription_plan, payment_frequency_in_months: 3)

        expect(plan.description).to include('Pay for LearnSignal online training service every three months.')
      end

      it 'returns the correct description for yearly subscription_plans' do
        plan = build_stubbed(:subscription_plan, payment_frequency_in_months: 12)

        expect(plan.description).to include('Pay for LearnSignal online training service every 12 months.')
      end

      it 'returns a default description for non-standard subscription_plans' do
        plan = build_stubbed(:subscription_plan, payment_frequency_in_months: 2)

        expect(plan.description).to include('A subscription for the LearnSignal online training service.')
      end
    end
  end

  describe '.search_scopes' do
    it 'has the correct search_scopes' do
      expect(SubscriptionPlan.search_scopes).to eq(%i[prioritise_plan_frequency plan_guid subscription_plan_id])
    end
  end
end
