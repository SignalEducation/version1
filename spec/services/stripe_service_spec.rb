require 'rails_helper'

describe StripeService, type: :service do

  # INSTANCE METHODS ###########################################################

  # CUSTOMERS ==================================================================

  describe '#create_customer' do
    let(:user) { create(:user) }

    it 'creates the customer on Stripe' do
      expect(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

      subject.create_customer(user)
    end

    it 'updates the user with the Stripe customer id' do
      allow(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

      expect {
        subject.create_customer(user)
      }.to change { user.stripe_customer_id }.from(nil).to('stripe_test_id')
    end
  end

  describe '#get_customer' do
    it 'calls #retrieve on Stripe::Customer with the passed in Stripe ID' do
      expect(Stripe::Customer).to receive(:retrieve).with('stripe_test_id')

      subject.get_customer('stripe_test_id')
    end
  end

  # PLANS ======================================================================

  describe '#create_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'calls CREATE on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:create)
      allow(subject).to receive(:update_subscription_plan)

      subject.create_plan(plan)
    end

    it 'calls #update_subscription_plan with the correct args' do
      allow(Stripe::Plan).to receive(:create)
      expect(subject).to receive(:update_subscription_plan)

      subject.create_plan(plan)
    end
  end

  describe '#get_plan' do
    it 'calls #retrieve on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:retrieve).with({id: 'test_id'})

      subject.get_plan('test_id')
    end
  end

  describe '#update_plan' do
    let(:plan) { build_stubbed(:subscription_plan, stripe_guid: 'test_id') }

    before :each do
      @dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(@dbl)
      allow(@dbl).to receive(:name=)
      allow(@dbl).to receive(:save)
    end

    it 'calls #get_plan with the correct args' do
      expect(subject).to receive(:get_plan).with('test_id').and_return(@dbl)

      subject.update_plan(plan)
    end

    it 'calls #name= on the Plan with the correct args' do
      expect(@dbl).to receive(:name=).with("LearnSignal #{plan.name}")

      subject.update_plan(plan)
    end

    it 'calls #save on the Plan' do
      expect(@dbl).to receive(:save)

      subject.update_plan(plan)
    end
  end

  describe '#delete_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'calls #get_plan with the correct args' do
      dbl = double
      expect(subject).to receive(:get_plan).with('test_id').and_return(dbl)
      allow(dbl).to receive(:delete)

      subject.delete_plan('test_id')
    end

    it 'calls #delete on a PayPal plan if it exists' do
      dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(dbl)
      expect(dbl).to receive(:delete)

      subject.delete_plan('test_id')
    end

    it 'does not call #delete on a PayPal plan if it does not exist' do
      dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(nil)
      expect(dbl).not_to receive(:delete)

      subject.delete_plan('test_id')
    end
  end

  # SUBSCRIPTIONS ==============================================================

  # def change_plan(old_sub, new_plan_id)
  #   user = old_sub.user
  #   new_subscription_plan = SubscriptionPlan.find_by_id(new_plan_id)
  #   validate_plan_changable(old_sub, new_subscription_plan, user)
    
  #   if stripe_subscription = get_updated_subscription_from_stripe(old_sub, new_subscription_plan)
  #     ActiveRecord::Base.transaction do
  #       new_sub = Subscription.new(
  #         user_id: user.id,
  #         subscription_plan_id: new_plan_id,
  #         complimentary: false,
  #         active: true,
  #         livemode: (stripe_subscription[:plan][:livemode]),
  #         stripe_status: stripe_subscription[:status],
  #       )
  #       # mass-assign-protected attributes

  #       ## This means it will have the same stripe_guid as the old Subscription ##
  #       new_sub.stripe_guid = stripe_subscription[:id]

  #       new_sub.next_renewal_date = Time.at(stripe_subscription[:current_period_end])
  #       new_sub.stripe_customer_id = old_sub.stripe_customer_id
  #       new_sub.stripe_customer_data = get_customer(old_sub.stripe_customer_id).to_hash
  #       new_sub.save(validate: false)
  #       new_sub.start

  #       user.student_access.update_attributes(subscription_id: new_sub.id, account_type: 'Subscription', content_access: true)

  #       #Only one subscription is active for a user at a time; when creating new subscriptions old ones must be set to active: false.
  #       old_sub.update_attributes(stripe_status: 'canceled', active: false)
  #       old_sub.cancel

  #       return new_sub
  #     end
  #   end

  # rescue ActiveRecord::RecordInvalid => exception
  #   Rails.logger.error("ERROR: Subscription#upgrade_plan - AR.Transaction failed.  Details: #{exception.inspect}")
  #   raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
  # rescue => e
  #   Rails.logger.error("ERROR: Subscription#upgrade_plan - failed to update Subscription at Stripe.  Details: #{e.inspect}")
  #   raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
  # end

  # def create_and_return_subscription(subscription, stripe_token, coupon)
  #   stripe_subscription = create_subscription(subscription, stripe_token, coupon)
  #   stripe_customer = Stripe::Customer.retrieve(subscription.user.stripe_customer_id)
  #   subscription.assign_attributes(
  #     complimentary: false,
  #     active: true,
  #     livemode: stripe_subscription[:plan][:livemode],
  #     stripe_status: stripe_subscription.status,
  #     stripe_guid: stripe_subscription.id,
  #     next_renewal_date: Time.at(stripe_subscription.current_period_end),
  #     stripe_customer_id: stripe_customer.id,
  #     coupon_id: coupon.try(:id),
  #     stripe_customer_data: stripe_customer.to_hash.deep_dup
  #   )
  #   subscription
  # end

  # PRIVATE METHODS ============================================================

  # def get_updated_subscription_from_stripe(old_sub, new_subscription_plan)
  #   stripe_customer = get_customer(old_sub.stripe_customer_id)
  #   stripe_subscription = stripe_customer.subscriptions.retrieve(old_sub.stripe_guid)
  #   stripe_subscription.plan = new_subscription_plan.stripe_guid
  #   stripe_subscription.prorate = true
  #   stripe_subscription.trial_end = 'now'

  #   stripe_subscription.save
  # rescue Stripe::CardError => e
  #   body = e.json_body
  #   err  = body[:error]
  #   Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
  #   raise Learnsignal::SubscriptionError.new("Sorry! Your request was declined because - #{err[:message]}")
  # end

  # def create_subscription(subscription, stripe_token, coupon)
  #   Stripe::Subscription.create(
  #     customer: subscription.user.stripe_customer_id,
  #     items: [{
  #       plan: subscription.subscription_plan.stripe_guid,
  #       quantity: 1
  #     }],
  #     source: stripe_token,
  #     coupon: coupon.try(:code),
  #     trial_end: 'now'
  #   )
  # rescue Stripe::CardError => e
  #   body = e.json_body
  #   err  = body[:error]
  #   Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
  #   raise Learnsignal::SubscriptionError.new("Sorry! Your request was declined because - #{err[:message]}")
  # rescue => e
  #   Rails.logger.error "DEBUG: Subscription#create Failure for unknown reason - Error: #{e.inspect}"
  #   raise Learnsignal::SubscriptionError.new('Sorry Something went wrong! Please contact us for assistance.')
  # end

  # def update_subscription_plan(subscription_plan, stripe_plan)
  #   subscription_plan.update(
  #     stripe_guid: stripe_plan.id,
  #     livemode: stripe_plan[:livemode]
  #   )    
  # end

  # def stripe_plan_id
  #   Rails.env + '-' + ApplicationController::generate_random_code(20)
  # end

  # def validate_plan_changable(subscription, new_plan, user)
  #   if !(subscription && subscription.user.default_card)
  #     raise Learnsignal::SubscriptionError.new(I18n.t('controllers.subscriptions.update.flash.invalid_card'))
  #   elsif subscription.subscription_plan.currency_id != new_plan.currency_id
  #     raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.currencies_mismatch'))
  #   elsif !new_plan.active?
  #     raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.new_plan_is_inactive'))
  #   elsif !%w(active past_due).include?(subscription.stripe_status)
  #     raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded'))
  #   elsif !user.trial_or_sub_user?
  #     raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
  #   elsif !(user.subscription_payment_cards.all_default_cards.length > 0)
  #     raise Learnsignal::SubscriptionError.new(I18n.t('models.subscriptions.upgrade_plan.you_have_no_default_payment_card'))
  #   end
  # end
end