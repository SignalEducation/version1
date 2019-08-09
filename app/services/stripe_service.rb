# frozen_string_literal: true

class StripeService
  # CUSTOMERS ==================================================================

  def create_customer!(user)
    customer = Stripe::Customer.create(email: user.email)
    user.update!(stripe_customer_id: customer.id)

    customer
  end

  def get_customer(stripe_customer_id)
    Stripe::Customer.retrieve(stripe_customer_id)
  end

  def set_order_status(intent, order)
    if intent.status == 'requires_action' &&
       stripe_intent.next_action.type == 'use_stripe_sdk'
      order.state = 'pending_3d_secure'
    elsif intent.status != 'succeeded'
      order.state = 'errored'
    end
    order
  end

  def create_purchase(order)
    stripe_intent = create_payment_intent(order)
    order = set_order_status(stripe_intent, order)
    order.assign_attributes(stripe_customer_id: stripe_intent.customer,
                            stripe_payment_intent_id: stripe_intent.id,
                            stripe_client_secret: stripe_intent.client_secret)
    order
  rescue Stripe::CardError => e
    raise_payment_error(e.json_body[:error], __method__.to_s, :decline_reason)
  rescue => e
    raise_payment_error(e, __method__.to_s, :generic)
  end

  def confirm_purchase(order)
    intent = Stripe::PaymentIntent.confirm(order.stripe_payment_intent_id)
    unless intent.status == 'succeeded'
      raise_payment_error({}, __method__.to_s, :generic)
    end
  rescue Stripe::CardError => e
    raise_payment_error(e.json_body[:error], __method__.to_s, :decline_reason)
  end

  # SUBSCRIPTIONS ==============================================================

  def get_subscription(sub_id)
    Stripe::Subscription.retrieve(id: sub_id)
  end

  def change_plan(old_sub, new_plan_id)
    user = old_sub.user
    new_subscription_plan = SubscriptionPlan.find(new_plan_id)
    validate_plan_changable(old_sub, new_subscription_plan, user)

    if stripe_subscription = get_updated_subscription_from_stripe(old_sub, new_subscription_plan)
      ActiveRecord::Base.transaction do
        new_sub = Subscription.new(user_id: user.id,
                                   subscription_plan_id: new_plan_id,
                                   complimentary: false,
                                   livemode: (stripe_subscription[:plan][:livemode]),
                                   stripe_status: stripe_subscription[:status],
                                   changed_from: old_sub)
        # mass-assign-protected attributes

        ## This means it will have the same stripe_guid as the old Subscription ##
        new_sub.stripe_guid = stripe_subscription[:id]

        new_sub.next_renewal_date = Time.at(stripe_subscription[:current_period_end])
        new_sub.stripe_customer_id = old_sub.stripe_customer_id
        new_sub.stripe_customer_data = get_customer(old_sub.stripe_customer_id).to_hash
        new_sub.save(validate: false)
        new_sub.start

        user.student_access.update(subscription_id: new_sub.id, account_type: 'Subscription', content_access: true)

        # Only one subscription is active for a user at a time; when creating new subscriptions old ones must be set to active: false.
        old_sub.update(stripe_status: 'canceled')
        old_sub.cancel

        return new_sub
      end
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    raise_subscription_error(e, __method__.to_s, :sub_change)
  end

  def create_and_return_subscription(subscription_object, stripe_token, coupon)
    customer_id     = subscription_object.user.stripe_customer_id
    customer        = Stripe::Customer.retrieve(customer_id)
    customer.source = stripe_token
    customer.save

    subscription        = create_subscription(subscription, customer.id, coupon)
    client_secret       = subscription[:latest_invoice][:payment_intent][:client_secret]
    subscription_object = merge_subscription_data(subscription_object, subscription, customer, coupon)
    [subscription_object, { client_secret: client_secret, status: :ok }]
  rescue Stripe::CardError => e
    [subscription_object, { error: e, error_message: e.message, status: :error }]
  end

  def merge_subscription_data(subscription_object, subscription, customer, coupon)
    subscription_object.
      assign_attributes(complimentary: false,
                        livemode: subscription[:plan][:livemode],
                        stripe_status: subscription.status,
                        stripe_guid: subscription.id,
                        next_renewal_date: Time.zone.at(subscription.current_period_end),
                        stripe_customer_id: customer.id,
                        coupon_id: coupon.try(:id),
                        stripe_customer_data: customer.to_hash.deep_dup,
                        payment_intent: subscription[:latest_invoice][:payment_intent][:status])

    subscription_object
  end

  def cancel_subscription(subscription)
    if subscription.stripe_customer_id && subscription.stripe_guid
      stripe_customer                          = Stripe::Customer.retrieve(subscription.stripe_customer_id)
      stripe_subscription                      = stripe_customer.subscriptions.retrieve(subscription.stripe_guid)
      stripe_subscription.cancel_at_period_end = true
      response                                 = stripe_subscription.save.to_hash

      if response[:status] == 'canceled'
        subscription.update(stripe_status: 'canceled-pending')
        subscription.cancel_pending
      else
        raise_subscription_error({}, __method__.to_s, :sub_change)
      end
    else
      raise_subscription_error(
        {}, __method__.to_s, :custom,
        'Subscription#cancel failed because it did not have a ' \
        'stripe_customer_id OR a stripe_guid.'
      )
    end
  rescue Stripe::StripeError => e
    raise_subscription_error(e, __method__.to_s, :sub_cancellation)
  end

  def cancel_subscription_immediately(subscription)
    if subscription.stripe_customer_id && subscription.stripe_guid
      stripe_customer = Stripe::Customer.retrieve(subscription.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(subscription.stripe_guid)
      response = stripe_subscription.delete.to_hash
      if response[:status] == 'canceled'
        subscription.update(stripe_status: 'canceled')
        subscription.cancel
      else
        raise_subscription_error({}, __method__.to_s, :sub_change)
      end
    else
      raise_subscription_error({}, __method__.to_s, :sub_cancellation)
    end
  rescue Stripe::StripeError => e
    raise_subscription_error(e, __method__.to_s, :sub_cancellation)
  end

  # INVOICES ===================================================================

  def get_invoice(invoice_id)
    Stripe::Invoice.retrieve(id: invoice_id, expand: ['payment_intent'])
  end

  # PRIVATE ====================================================================

  private

  def create_payment_intent(order)
    Stripe::PaymentMethod.attach(order.stripe_payment_method_id,
                                 customer: order.user.stripe_customer_id)
    Stripe::PaymentIntent.create(
      payment_method: order.stripe_payment_method_id,
      customer: order.user.stripe_customer_id,
      amount: (order.product.price * 100).to_i,
      currency: order.product.currency.iso_code,
      confirmation_method: 'manual',
      confirm: true
    )
  end

  def get_updated_subscription_from_stripe(old_sub, new_subscription_plan)
    stripe_customer = get_customer(old_sub.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.retrieve(old_sub.stripe_guid)
    stripe_subscription.items.first.plan = new_subscription_plan.stripe_guid
    stripe_subscription.prorate = true
    stripe_subscription.trial_end = 'now'

    stripe_subscription.save
  rescue Stripe::CardError => e
    raise_subscription_error(e.json_body[:error], __method__.to_s, :generic)
  end

  def create_subscription(subscription, stripe_customer_id, coupon)
    Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ plan: subscription.subscription_plan.stripe_guid,
                quantity: 1 }],
      coupon: coupon.try(:code),
      trial_end: 'now',
      expand: ['latest_invoice.payment_intent']
    )
  rescue Stripe::CardError => e
    raise_subscription_error(e.json_body[:error], __method__.to_s,
                             :decline_reason)
  rescue => e
    raise_subscription_error(e, __method__.to_s, :generic)
  end

  def validate_plan_changable(subscription, new_plan, user)
    if subscription.user.default_card.nil?
      raise Learnsignal::SubscriptionError,
            I18n.t('controllers.subscriptions.update.flash.invalid_card')
    elsif subscription.subscription_plan.currency_id != new_plan.currency_id
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.currencies_mismatch')
    elsif !new_plan.active?
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.new_plan_is_inactive')
    elsif %w[active past_due].exclude?(subscription.stripe_status)
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded')
    elsif !user.standard_student_user?
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade')
    elsif user.subscription_payment_cards.all_default_cards.empty?
      raise Learnsignal::SubscriptionError,
            I18n.t('models.subscriptions.upgrade_plan.you_have_no_default_payment_card')
    end
  end

  def raise_payment_error(err, method, type)
    Rails.logger.error "StripeService##{method} - #{err.inspect}"
    raise Learnsignal::PaymentError, return_message(err, type)
  end

  def raise_subscription_error(err, method, type, msg = '')
    Rails.logger.error "StripeService##{method} - #{err.inspect}"
    raise Learnsignal::SubscriptionError, return_message(err, type, msg)
  end

  def return_message(e, type, msg)
    case type
    when :generic
      'Sorry Something went wrong! Please contact us for assistance.'
    when :decline_reason
      "Sorry! Your request was declined because - #{e[:message]}"
    when :sub_cancellation
      'Sorry! There was an error cancelling the subscription.'
    when :sub_change
      I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')
    when :custom
      msg
    else
      'Sorry Something went wrong! Please contact us for assistance.'
    end
  end
end
